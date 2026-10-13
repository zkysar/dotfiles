#!/usr/bin/env node
// Lazy stdio MCP proxy: defers starting the real server until the first call
// that needs it.
//
//   node lazy-mcp.mjs --name <name> -- <real server command...>
//
// Why: some servers touch macOS-protected folders at startup (copilot-money
// reads another app's sandbox and browser storage), which pops a TCC prompt on
// every Claude launch even when the server is never used.
//
// How: the first run is a plain passthrough that records the server's
// initialize result and list responses (tools/list etc.) to a cache file.
// Later runs answer initialize and those lists from the cache, and only spawn
// the real server on the first other request (e.g. tools/call). The client's
// original initialize request is replayed to the real server at that point.
//
// Cache: ~/.cache/lazy-mcp/<name>-<hash of command>.json, one entry per MCP
// protocol version (Claude Code and Claude Desktop may differ). Changing the
// command (e.g. a version bump) changes the hash, so the cache refreshes on
// its own. Delete the file to force a refresh.

import { spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, writeFileSync, renameSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { createInterface } from "node:readline";

const LIST_METHODS = new Set([
  "tools/list",
  "prompts/list",
  "resources/list",
  "resources/templates/list",
]);
const INIT_ID = "lazy-mcp-init";

const argv = process.argv.slice(2);
const sep = argv.indexOf("--");
const nameIdx = argv.indexOf("--name");
if (sep === -1 || nameIdx === -1 || nameIdx > sep || sep === argv.length - 1) {
  console.error("usage: lazy-mcp.mjs --name <name> -- <command...>");
  process.exit(2);
}
const name = argv[nameIdx + 1];
const cmd = argv.slice(sep + 1);

const hash = createHash("sha256").update(JSON.stringify(cmd)).digest("hex").slice(0, 12);
const cacheDir = join(homedir(), ".cache", "lazy-mcp");
const cachePath = join(cacheDir, `${name}-${hash}.json`);

let cacheFile = {};
try {
  cacheFile = JSON.parse(readFileSync(cachePath, "utf8"));
} catch {}
let cache = null; // entry for this session's protocol version, if any

const send = (msg) => process.stdout.write(JSON.stringify(msg) + "\n");
const log = (s) => console.error(`[lazy-mcp:${name}] ${s}`);

let child = null;
let childReady = false; // real server has answered initialize
const queue = []; // client messages waiting for childReady
const inflight = new Set(); // client request ids forwarded to the real server
let clientInit = null; // client's initialize request, replayed on spawn
let stdinClosed = false;

// Passthrough mode only: request id -> method, to know which responses to record.
let recording = null;
let protocolVersion = null;

function saveCache() {
  try {
    mkdirSync(cacheDir, { recursive: true });
    const tmp = `${cachePath}.${process.pid}.tmp`;
    let latest = {};
    try {
      latest = JSON.parse(readFileSync(cachePath, "utf8"));
    } catch {}
    latest[protocolVersion] = recording.data;
    writeFileSync(tmp, JSON.stringify(latest, null, 2));
    renameSync(tmp, cachePath);
  } catch (err) {
    log(`could not write cache: ${err.message}`);
  }
}

function toChild(msg) {
  if (msg.id !== undefined && msg.method) inflight.add(msg.id);
  child.stdin.write(JSON.stringify(msg) + "\n");
}

function startChild() {
  child = spawn(cmd[0], cmd.slice(1), { stdio: ["pipe", "pipe", "inherit"] });
  child.on("error", (err) => log(`spawn failed: ${err.message}`));
  child.on("exit", (code, signal) => {
    // Fail pending calls instead of leaving the client hanging.
    for (const id of inflight) {
      send({ jsonrpc: "2.0", id, error: { code: -32603, message: `${name} server exited (${signal || code})` } });
    }
    for (const msg of queue) {
      if (msg.id !== undefined && msg.method) {
        send({ jsonrpc: "2.0", id: msg.id, error: { code: -32603, message: `${name} server exited (${signal || code})` } });
      }
    }
    process.exit(code ?? 1);
  });

  createInterface({ input: child.stdout }).on("line", (line) => {
    let msg;
    try {
      msg = JSON.parse(line);
    } catch {
      return process.stdout.write(line + "\n");
    }
    const isResponse = msg.id !== undefined && !msg.method;

    // Lazy mode: swallow the response to our replayed initialize, then flush.
    if (cache && isResponse && msg.id === INIT_ID) {
      child.stdin.write(JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }) + "\n");
      childReady = true;
      while (queue.length) toChild(queue.shift());
      if (stdinClosed) child.stdin.end();
      return;
    }

    if (isResponse) {
      inflight.delete(msg.id);
      if (recording && recording.pending.has(msg.id)) {
        const method = recording.pending.get(msg.id);
        recording.pending.delete(msg.id);
        if (msg.result && !msg.result.nextCursor) {
          recording.data[method] = msg.result;
          if (recording.data.initialize && recording.data["tools/list"]) saveCache();
        }
      }
    }
    send(msg);
  });

  if (cache) {
    child.stdin.write(JSON.stringify({ ...clientInit, id: INIT_ID }) + "\n");
  } else {
    childReady = true;
  }
}

function handleLazy(msg) {
  const isRequest = msg.id !== undefined && msg.method;

  if (child) {
    if (childReady) toChild(msg);
    else queue.push(msg);
    return;
  }

  if (msg.method === "initialize") {
    clientInit = msg;
    return send({ jsonrpc: "2.0", id: msg.id, result: cache.initialize });
  }
  if (msg.method === "notifications/initialized") return; // sent on spawn
  if (msg.method === "ping") return send({ jsonrpc: "2.0", id: msg.id, result: {} });
  if (LIST_METHODS.has(msg.method) && cache[msg.method] && !msg.params?.cursor) {
    return send({ jsonrpc: "2.0", id: msg.id, result: cache[msg.method] });
  }
  if (!isRequest) return; // notifications before spawn have nothing to act on

  log(`starting real server for ${msg.method}`);
  queue.push(msg);
  startChild();
}

function handlePassthrough(msg) {
  if (recording.enabled && msg.id !== undefined && (msg.method === "initialize" || LIST_METHODS.has(msg.method))) {
    recording.pending.set(msg.id, msg.method);
  }
  toChild(msg);
}

const rl = createInterface({ input: process.stdin });
rl.on("line", (line) => {
  if (!line.trim()) return;
  let msg;
  try {
    msg = JSON.parse(line);
  } catch {
    return;
  }
  if (!cache && !recording) {
    // First message decides the mode. Anything unexpected before initialize
    // falls back to passthrough without recording.
    protocolVersion = msg.method === "initialize" ? msg.params?.protocolVersion : null;
    const entry = protocolVersion && cacheFile[protocolVersion];
    if (entry?.initialize && entry["tools/list"]) {
      cache = entry;
    } else {
      recording = { pending: new Map(), data: {}, enabled: !!protocolVersion };
      startChild();
    }
  }
  if (cache) handleLazy(msg);
  else handlePassthrough(msg);
});
rl.on("close", () => {
  stdinClosed = true;
  if (!child) process.exit(0);
  if (childReady) child.stdin.end();
});
