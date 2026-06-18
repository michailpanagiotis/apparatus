# rust-analyzer-lspmux

Provides the Rust language server to Claude Code, but routed through
[lspmux](https://codeberg.org/p2502/lspmux) (`lspmux client`) instead of
launching `rust-analyzer` directly.

This lets Claude Code, Neovim, and any other editor share a single
rust-analyzer instance per workspace via the `lspmux server` running as a
systemd user service (`systemctl --user status lspmux`).

Replaces the official `rust-analyzer-lsp@claude-plugins-official` plugin, which
must be disabled to avoid two servers attaching to `.rs` files.

## Requirements
- `lspmux` on `PATH` (e.g. `cargo install lspmux`)
- `rust-analyzer` on `PATH` (`rustup component add rust-analyzer`)
- `lspmux server` running (the `lspmux.service` user unit)
