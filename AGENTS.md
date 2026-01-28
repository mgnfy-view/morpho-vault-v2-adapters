# Repository Guidelines

## Project Structure & Module Organization

- `src/` holds Solidity source code, organized by adapter families (e.g., `src/adapters/lending/aaveV3/`).
- `src/adapterBase/` and `src/utils/` contain shared base contracts and utilities.
- `test/` contains Foundry tests, grouped by protocol (e.g., `test/lending/compoundV3/`).
- `script/` is reserved for Foundry scripts and deployment helpers.
- `dependencies/` is managed by Soldeer; `foundry.toml` and `remappings.txt` define build settings.
- `out/` and `cache/` are build artifacts.

## Build, Test, and Development Commands

- `make` or `make fbuild`: install Soldeer deps and build with Foundry.
- `make compile`: compile without installing dependencies.
- `make ftest`: run the full test suite (`forge test`).
- `make format`: apply formatting (`forge fmt`).
- `make snapshot`: update Foundry gas snapshots.
- `make anvil`: start a local chain with deterministic mnemonic for integration tests.

## Coding Style & Naming Conventions

Follow `.codex/constraints/solidity-style.md` for formatting, naming, and NatSpec rules.
Use `src/adapters/lending/<protocol>/` only for lending adapters; other protocol types go under `src/adapters/<category>/<protocol>/`.

## Testing Guidelines

Unit-testing rules and layout live in `.codex/constraints/testing.md`. Run `make ftest` before opening a PR.

## Commit & Pull Request Guidelines

- Commit messages follow a conventional style observed in history: `feat: ...`, `chore: ...`, `docs: ...`.
- Keep PRs focused, with a clear description of behavior changes and testing performed.
- Link related issues when applicable and note any protocol-specific assumptions.

## Security & Configuration Tips

The Makefile loads `.env`; keep RPC URLs and private keys out of version control.
For security review references, see `.codex/constraints/security-review.md`.
