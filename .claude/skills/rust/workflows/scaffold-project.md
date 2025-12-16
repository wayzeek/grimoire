# Scaffold Rust Project

## Binary Project

```bash
cargo new my_project
cd my_project
cargo run
```

## Library Project

```bash
cargo new --lib my_lib
cd my_lib
cargo test
```

## Workspace

```toml
# Cargo.toml
[workspace]
members = ["cli", "lib", "server"]
resolver = "2"

[workspace.dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
```

## Project Structure

```
my_project/
├── src/
│   ├── main.rs       # Binary entry point
│   ├── lib.rs        # Library root
│   └── module.rs     # Modules
├── tests/            # Integration tests
├── benches/          # Benchmarks
├── examples/         # Example code
└── Cargo.toml
```

## Common Dependencies

```toml
[dependencies]
# Async runtime
tokio = { version = "1", features = ["full"] }

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Error handling
anyhow = "1"
thiserror = "1"

# CLI
clap = { version = "4", features = ["derive"] }

# HTTP
reqwest = { version = "0.11", features = ["json"] }
axum = "0.7"

[dev-dependencies]
tokio-test = "0.4"
```
