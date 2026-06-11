# 0007 - LLM-only profile does not manage git

## Status

Accepted

## Context

When sharing the LLM environment profile with colleagues, a decision is needed on whether to include git (and its configuration) in `home-llm.nix`.

Colleagues have varied existing setups:
- Some have git installed via Homebrew
- Some rely on macOS's built-in git (from Xcode Command Line Tools)
- Some may have no git at all

## Decision

`home-llm.nix` does not include git. Colleagues use whatever git they already have.

git (with name, email, and ghq settings) remains in `home-dev.nix` for those who want the full development setup.

## Rationale

- **Minimize disruption**: colleagues may already have Homebrew-managed git. Introducing a Nix-managed git that takes PATH precedence could cause unexpected behavior.
- **Scope matches purpose**: the goal of `home-llm.nix` is a local LLM environment, not a full development toolchain. git is not required to run Ollama or Open WebUI.
- **Lower adoption barrier**: the fewer tools Nix manages for colleagues, the easier it is to explain and troubleshoot the setup.

## Rejected alternatives

- **Include git in `home-llm.nix`**: ensures consistent git version and config, but risks conflicting with existing Homebrew installations and exceeds the stated scope.

## Consequences

- Colleagues with no git must install it separately (via Xcode Command Line Tools: `xcode-select --install`) before cloning the repo
- This is documented in the README as a prerequisite for colleagues
- `home-dev.nix` remains the right place for git if a colleague later wants Nix-managed git
