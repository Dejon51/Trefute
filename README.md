# Trefute

> A chess engine written in C.

Trefute is a free and open-source chess engine. The project is in its early
stages — the build system and project scaffolding are in place, and the engine
itself is under active development.

## Status

🚧 **Early development.** There is no playable engine yet; this repository
currently provides the project structure and build tooling. The sections below
are placeholders to be filled in as the engine takes shape.

## Features

_None yet — to be added._

<!--
Planned areas to document here as they land, e.g.:
- Board representation
- Move generation
- Search (e.g. alpha-beta, iterative deepening)
- Evaluation
- UCI protocol support
-->

## Requirements

- A C compiler supporting **C17** (`cc`, `clang`, or `gcc`)
- `make`

## Building

The project uses a `Makefile` with two build profiles.

```bash
# Optimized release build (-O3 -flto -std=c17) — the default
make

# Debug build (-O0 -g3 + AddressSanitizer/UBSan)
make debug
```

Build artifacts are placed under `_build/<profile>/`. Run `make help` to see all
available targets.

## Running

```bash
# Build and run the release binary
make run

# Pass arguments to the engine
make ARGS="..." run
```

## Project layout

```
trefute/
├── src/            # Engine source code
├── Makefile        # Build system (release / debug profiles)
├── LICENSE         # GNU GPL v3
└── README.md
```

## Contributing

Contributions are welcome! Since the project is just getting started, the best
way to help is to open an issue to discuss ideas before submitting a pull
request. Please make sure your code builds cleanly under both the `release` and
`debug` profiles and is formatted with `make format`.

## License

Trefute is licensed under the **GNU General Public License v3.0**. See the
[LICENSE](LICENSE) file for the full text.
