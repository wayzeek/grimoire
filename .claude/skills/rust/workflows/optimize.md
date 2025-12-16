# Rust Performance Optimization

## Profile-Guided Optimization

```toml
[profile.release]
opt-level = 3
lto = true
codegen-units = 1
strip = true
```

## Benchmarking

```rust
#[bench]
fn bench_function(b: &mut Bencher) {
    b.iter(|| {
        // Code to benchmark
    });
}
```

## Common Optimizations

### Use `&str` instead of `String`
```rust
fn process(s: &str) {} // Better than fn process(s: String)
```

### Avoid unnecessary allocations
```rust
// Bad
let vec: Vec<_> = iter.collect();
for item in vec { }

// Good
for item in iter { }
```

### Use iterators
```rust
// Optimized by compiler
data.iter().map(|x| x * 2).filter(|x| x > 10).collect()
```

### Pre-allocate capacity
```rust
let mut vec = Vec::with_capacity(1000);
```
