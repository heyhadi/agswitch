# agswitch

Switch the Google account used by [Antigravity](https://antigravity.google) and `agy` on macOS, without logging out and back in.

```
$ agswitch list
Active: ag2
Saved: ag1 (expires in 30 days)
Saved: ag3 (expires in 30 days)

$ agswitch use ag1
Switched to 'ag1'. 'ag2' saved for 30 days. Open Antigravity again.
```

## How it works

Antigravity keeps its Google login in the macOS Keychain item `gemini`. agswitch swaps that item:

- Inactive accounts are stored **only in the Keychain** as `agswitch:<name>`. No token files on disk.
- One copy per account: the active account lives only in `gemini`.
- Secrets are passed to `security` over stdin, never as command-line arguments, so they don't show up in the process list.
- Each write is read back and verified.
- Stored accounts that go unused for 30 days are deleted (`AGSWITCH_DAYS` to change). This only removes the local copy; it does **not** revoke the token at Google. To revoke, use Google Account → Security → Third-party connections.

## Install

```bash
curl -o ~/.local/bin/agswitch https://raw.githubusercontent.com/heyhadi/agswitch/main/agswitch
chmod +x ~/.local/bin/agswitch
```

Read the script before you run it. It's about 100 lines of bash.

## Usage

Quit Antigravity (Cmd+Q) and any running `agy` before switching. agswitch refuses to run while they're open, because the running app could write the old token back.

| Command | What it does |
| --- | --- |
| `agswitch name <name>` | Name the account that's logged in right now |
| `agswitch new` | Store the active account so you can log in with another one |
| `agswitch use <name>` | Switch to a stored account |
| `agswitch list` | Show the active and stored accounts and their expiry |
| `agswitch forget <name>` | Delete a stored account |

First setup:

1. `agswitch name ag1`
2. `agswitch new`, open Antigravity, sign in with the second account, quit
3. `agswitch name ag2`

## Test

```bash
tests/selftest.sh
```

Uses dummy Keychain items; your real login is never touched.

## Caveats

- Unofficial. Not affiliated with Google.
- Using several accounts to get around usage quotas can break Google's terms and get accounts flagged. This tool is meant for keeping separate accounts separate (work, personal, side projects).
- Conversation history and agent memory in `~/.gemini/antigravity` are shared across accounts; only the login is switched.
- macOS only.

## License

MIT
