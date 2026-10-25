# Hard rules for every eval runner

These rules come before the runner instructions that follow, and override them where they conflict.

1. **No delegation.** Do the setup, the smoke checks, and the batch yourself in this session. No subagents, background or task agents, or delegated sessions. The child eval runs started through the agent CLI are the only other processes doing eval work.
2. **Hard gate.** Write `R/SMOKE_PASSED`, containing the exact per-arm commands and flags, only after every smoke check the runner requires has passed. Before starting each eval run, check that `R/SMOKE_PASSED` exists; if it doesn't, stop and report. Never start the batch on a partial or failed smoke result.
3. **Diagnostics are allowed.** Read the stderr and logs of your own setup and smoke commands freely to find and fix problems. The no-reading rule applies only to eval runs: never open their diffs, final messages, or logs (`R/out/*`), except to compute the classifications the runner defines.
4. **No credential copies.** Never copy, move, or link login, auth, token, or credential-bearing config files (or keychain exports) into temporary homes, config dirs, or eval folders. If an arm can't be isolated without that, stop and report what you tried.
5. **Exact layout.** Write exactly `R/out/$id.jsonl`, `.err`, `.txt`, `.diff`, `.meta`, and `R/key-<arm>.tsv` as the runner specifies; no per-id subfolders or extra formats.
6. **Narrow child tools.** Child eval runs get only file read and edit inside their working dir, plus the language tools the runner lists (python3, rustc, and for Claude go test/go vet/gofmt). No general shell, network, web, patch tools beyond edit, or approval bypass outside an external sandbox.

## Runner instructions
