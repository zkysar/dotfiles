# Bnder MCP setup and recovery

Break-glass reference. Only needed when the `bnder` MCP fails to connect or the
wrapper needs changing.

## Why there is a wrapper

Bnder's MCP server (`https://api.bnder.net/consumer/v1/mcp`) is undocumented and
versioned `0.0.1`, so treat it as beta. It runs through
`claude/mcp-wrappers/bnder` in the dotfiles repo, which pins three things that
are all required:

- **Callback port `3334`.** Bnder's "MCP" OAuth app registers exactly two
  redirect URIs (`localhost:8080/callback`, `localhost:3334/oauth/callback`).
  `mcp-remote` builds `http://localhost:<port>/oauth/callback` and otherwise
  picks a *random* port, which never matches.
- **Static client id** `oauth_0c140c8fd93722a2` (public, no secret) and
  **static scope** `read write`, because the discovery document advertises
  `scopes_supported: ["test"]`.
- **mcp-remote 0.1.38.** Bnder has no API key feature; OAuth is the only way in.

## The 403 cold-start trap

Bnder returns **403 with no `WWW-Authenticate`** when no token is presented (an
*invalid* token correctly returns 401). `mcp-remote` only begins its OAuth flow
on a 401, so with an empty token cache it treats the 403 as fatal and exits,
surfacing as `Failed to reconnect to bnder: -32000`. It can never log in on its
own.

## Bootstrap (or recovery if the refresh token dies)

Force a 401 by presenting a junk token, let the real login run, then move the
cached token to the key the wrapper looks up:

```bash
npx -y mcp-remote@0.1.38 https://api.bnder.net/consumer/v1/mcp 3334 \
  --static-oauth-client-info '{"client_id":"oauth_0c140c8fd93722a2"}' \
  --static-oauth-client-metadata '{"scope":"read write"}' \
  --header 'Authorization: Bearer bootstrap'
# It logs in, then loops on 401 (the custom header overrides the real token).
# Kill it as soon as the token file appears, then:
cd ~/.mcp-auth/mcp-remote-0.1.37
mv 0f9d3286c157f29d8d4f4734f86bfaec_tokens.json 7377299867445b3049db6e70498c2b00_tokens.json
```

Two gotchas in those paths. The cache key is
`md5(serverUrl [+ "|" + JSON.stringify(headers)])`, so adding `--header`
*changes which file is read*, hence the rename. And despite the package being
`0.1.38`, tokens land in **`~/.mcp-auth/mcp-remote-0.1.37/`**: upstream never
bumped its internal `version2` constant.

Once a token is cached the wrapper always sends an `Authorization` header, so
expiry yields a 401 and refresh proceeds normally. If Bnder fixes the
403-should-be-401 bug and the discovery document, drop the wrapper for a plain
`claude mcp add --transport http`.
