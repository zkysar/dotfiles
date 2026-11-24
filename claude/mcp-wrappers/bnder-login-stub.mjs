// Stand-in MCP server for bnder, used by ./bnder when no login token is cached.
// It starts cleanly (so apps don't show "bnder couldn't start") and exposes one
// tool, bnder_login, which runs the out-of-band OAuth bootstrap on demand.
// See the bnder skill's references/setup.md for why the bootstrap is needed.
// No dependencies: newline-delimited JSON-RPC over stdio.
import { spawn } from "node:child_process";
import { existsSync, renameSync, rmSync, openSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { createInterface } from "node:readline";

const DIR = join(homedir(), ".mcp-auth", "mcp-remote-0.1.37");
const REAL = "7377299867445b3049db6e70498c2b00"; // key the wrapper reads
const BOOT = "0f9d3286c157f29d8d4f4734f86bfaec"; // key written when --header is set
const TIMEOUT_MS = 5 * 60 * 1000;

const send = (msg) => process.stdout.write(JSON.stringify(msg) + "\n");
const reply = (id, result) => send({ jsonrpc: "2.0", id, result });
const text = (t, isError = false) => ({ content: [{ type: "text", text: t }], isError });

function clearStale() {
  for (const key of [REAL, BOOT]) {
    for (const suffix of ["_lock.json", "_code_verifier.txt"]) {
      rmSync(join(DIR, key + suffix), { force: true });
    }
  }
}

async function login() {
  if (existsSync(join(DIR, `${REAL}_tokens.json`))) {
    return text("Already logged in. Reconnect bnder to load its tools.");
  }
  clearStale();
  const log = openSync(join(DIR, "bnder-login.log"), "w");
  const child = spawn(
    "npx",
    [
      "-y", "mcp-remote@0.1.38", "https://api.bnder.net/consumer/v1/mcp", "3334",
      "--static-oauth-client-info", '{"client_id":"oauth_0c140c8fd93722a2"}',
      "--static-oauth-client-metadata", '{"scope":"read write"}',
      "--header", "Authorization: Bearer bootstrap",
    ],
    { stdio: ["ignore", log, log] },
  );
  const bootTokens = join(DIR, `${BOOT}_tokens.json`);
  const start = Date.now();
  while (!existsSync(bootTokens) && Date.now() - start < TIMEOUT_MS && child.exitCode === null) {
    await new Promise((r) => setTimeout(r, 1000));
  }
  child.kill();
  if (!existsSync(bootTokens)) {
    clearStale();
    return text(`Login did not finish. Log: ${join(DIR, "bnder-login.log")}`, true);
  }
  renameSync(bootTokens, join(DIR, `${REAL}_tokens.json`));
  clearStale();
  return text(
    "Logged in to Bnder. Reconnect bnder to load the real tools: " +
      "in Claude Code run /mcp and reconnect bnder; in Claude Desktop, quit and reopen.",
  );
}

const TOOL = {
  name: "bnder_login",
  description:
    "Bnder (band todo list) is not logged in, so its real tools are unavailable. " +
    "Call this to log in: it opens a Bnder approval page in the browser and waits for the user to approve.",
  inputSchema: { type: "object", properties: {} },
};

createInterface({ input: process.stdin }).on("line", async (line) => {
  let msg;
  try { msg = JSON.parse(line); } catch { return; }
  const { id, method, params } = msg;
  if (id === undefined) return; // notifications
  if (method === "initialize") {
    reply(id, {
      protocolVersion: params?.protocolVersion ?? "2025-06-18",
      capabilities: { tools: {} },
      serverInfo: { name: "bnder-login", version: "1.0.0" },
    });
  } else if (method === "tools/list") {
    reply(id, { tools: [TOOL] });
  } else if (method === "tools/call") {
    reply(id, params?.name === TOOL.name ? await login() : text(`Unknown tool ${params?.name}`, true));
  } else if (method === "ping") {
    reply(id, {});
  } else {
    send({ jsonrpc: "2.0", id, error: { code: -32601, message: `Method not found: ${method}` } });
  }
});
