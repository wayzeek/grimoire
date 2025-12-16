# Rust Best Practices

## Error Handling

```rust
use anyhow::Result;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MyError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Invalid data")]
    InvalidData,
}

fn process() -> Result<(), MyError> {
    // Use ? for error propagation
    let data = read_file()?;
    Ok(())
}
```

## Ownership Patterns

```rust
// Take ownership when needed
fn consume(s: String) { }

// Borrow when possible
fn read(s: &str) { }

// Mutable borrow when modifying
fn modify(s: &mut String) { }
```

## Common Idioms

```rust
// Builder pattern
let config = Config::builder()
    .host("localhost")
    .port(8080)
    .build()?;

// Option/Result combinators
let result = get_value()
    .map(|x| x * 2)
    .and_then(|x| process(x))
    .unwrap_or_default();

// Match for exhaustive handling
match value {
    Some(x) => println!("{}", x),
    None => println!("No value"),
}
```

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_function() {
        assert_eq!(add(2, 2), 4);
    }

    #[test]
    #[should_panic]
    fn test_panic() {
        panic!("Expected panic");
    }
}
```
