# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations).

Common dev commands are transparently rewritten to `rtk <cmd>` by the Bash
PreToolUse hook — no action needed, 0 token overhead. Use these directly:

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Run a raw command without filtering (debugging)
```

If `rtk gain` errors, a different `rtk` (Rust Type Kit) may shadow it on PATH —
verify with `which rtk` (should resolve to the nix profile).
