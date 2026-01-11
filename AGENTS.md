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

- Solidity formatting is managed by `forge fmt` with 4-space indentation and 120-char lines (see `foundry.toml`).
- Imports are sorted and use double quotes; avoid manual formatting drift.
- Interfaces use the `I` prefix (e.g., `IAdapterBase`); contracts use PascalCase.
- Use `src/adapters/lending/<protocol>/` only for lending adapters. For other protocol types, use `src/adapters/<category>/<protocol>/`.
- New adapters should follow existing folder naming, e.g., `src/adapters/lending/<protocol>/`.
## Natspec Conventions

- Always use `///`-style Natspec comments on contracts, functions, and public state.

## Testing Guidelines

- Tests are written in Foundry and live under `test/`.
- Test files use the `*.t.sol` suffix (e.g., `Allocate.t.sol`, `Factory.t.sol`).
- Prefer extending existing base test utilities in `test/**/utils/` when adding new adapters.
- Run `make ftest` before opening a PR; update snapshots if gas usage changes.

## Commit & Pull Request Guidelines

- Commit messages follow a conventional style observed in history: `feat: ...`, `chore: ...`, `docs: ...`.
- Keep PRs focused, with a clear description of behavior changes and testing performed.
- Link related issues when applicable and note any protocol-specific assumptions.

## Security & Configuration Tips

- The Makefile loads `.env`; keep RPC URLs and private keys out of version control.
- Treat adapter changes as protocol-critical: add tests for edge cases and reverts.
