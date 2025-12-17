# Documentation Standards

Documentation standards and best practices for Rust projects.
## Documentation Standards

### Module Documentation

```rust
//! User management module
//!
//! This module provides functionality for creating, updating, and managing users.
//!
//! # Examples
//!
//! ```
//! use my_library::user::{User, UserService};
//!
//! let service = UserService::new();
//! let user = service.create_user("user@example.com", "password")?;
//! ```
//!
//! # Architecture
//!
//! The module follows a layered architecture:
//! - `model`: Domain models and types
//! - `service`: Business logic
//! - `repository`: Data access layer

pub mod model;
pub mod service;
mod repository;
```

### Function Documentation

```rust
/// Creates a new user with the given credentials.
///
/// This function validates the input, hashes the password, and persists the user
/// to the database. The function is atomic - either all operations succeed or
/// the entire operation fails.
///
/// # Arguments
///
/// * `email` - A valid email address
/// * `password` - A password with at least 8 characters
///
/// # Returns
///
/// Returns the created user on success, or an error if validation fails or
/// the email is already registered.
///
/// # Errors
///
/// This function will return an error if:
/// * The email format is invalid (`ValidationError::InvalidEmail`)
/// * The password is too short (`ValidationError::PasswordTooShort`)
/// * A user with this email already exists (`DatabaseError::Duplicate`)
/// * Database connection fails (`DatabaseError::Connection`)
///
/// # Examples
///
/// ```
/// # use my_library::user::create_user;
/// # async fn example() -> Result<(), Box<dyn std::error::Error>> {
/// let user = create_user("user@example.com", "securepass123").await?;
/// println!("Created user: {}", user.email());
/// # Ok(())
/// # }
/// ```
///
/// # Panics
///
/// This function does not panic under normal circumstances.
///
/// # Safety
///
/// This function does not use unsafe code.
pub async fn create_user(
    email: impl Into<String>,
    password: impl Into<String>,
) -> Result<User, Error> {
    // Implementation
}
```

### Type Documentation

```rust
/// Represents a user in the system.
///
/// Users are identified by a unique ID and email address. Passwords are
/// stored as bcrypt hashes and never exposed in the API.
///
/// # Examples
///
/// ```
/// use my_library::user::User;
///
/// let user = User::new("user@example.com", "password")?;
/// assert_eq!(user.email(), "user@example.com");
/// ```
#[derive(Debug, Clone)]
pub struct User {
    /// Unique identifier for the user
    id: UserId,
    /// Email address (must be unique)
    email: String,
    /// Bcrypt password hash
    password_hash: String,
    /// User's role (admin, user, etc.)
    role: UserRole,
    /// When the user was created
    created_at: DateTime<Utc>,
}
```

### Example Code Blocks

```rust
/// Calculates the total price with tax.
///
/// # Examples
///
/// ```
/// use my_library::calculate_total;
///
/// let total = calculate_total(100.0, 0.08);
/// assert_eq!(total, 108.0);
/// ```
///
/// Multiple items:
///
/// ```
/// # use my_library::{Item, calculate_items_total};
/// let items = vec![
///     Item::new("Widget", 10.0),
///     Item::new("Gadget", 20.0),
/// ];
/// let total = calculate_items_total(&items, 0.08);
/// assert_eq!(total, 32.4);
/// ```
pub fn calculate_total(price: f64, tax_rate: f64) -> f64 {
    price * (1.0 + tax_rate)
}
```

## Async/Await Patterns

### Actor Pattern

```rust
// GOOD: Message-based actor pattern
use tokio::sync::{mpsc, oneshot};

pub struct UserActor {
    receiver: mpsc::Receiver<ActorMessage>,
    repository: UserRepository,
}

enum ActorMessage {
    GetUser {
        id: UserId,
        respond_to: oneshot::Sender<Result<User, Error>>,
    },
    CreateUser {
        email: String,
        password: String,
        respond_to: oneshot::Sender<Result<User, Error>>,
    },
}

impl UserActor {
    pub fn new(repository: UserRepository) -> (Self, ActorHandle) {
        let (sender, receiver) = mpsc::channel(32);
        let actor = Self { receiver, repository };
        let handle = ActorHandle { sender };
        (actor, handle)
    }

    pub async fn run(mut self) {
        while let Some(msg) = self.receiver.recv().await {
            self.handle_message(msg).await;
        }
    }

    async fn handle_message(&self, msg: ActorMessage) {
        match msg {
            ActorMessage::GetUser { id, respond_to } => {
                let result = self.repository.get(&id).await;
                let _ = respond_to.send(result);
            }
            ActorMessage::CreateUser { email, password, respond_to } => {
                let result = self.repository.create(&email, &password).await;
                let _ = respond_to.send(result);
            }
        }
    }
}

#[derive(Clone)]
pub struct ActorHandle {
    sender: mpsc::Sender<ActorMessage>,
}

impl ActorHandle {
    pub async fn get_user(&self, id: UserId) -> Result<User, Error> {
        let (send, recv) = oneshot::channel();
        self.sender.send(ActorMessage::GetUser {
            id,
            respond_to: send,
        }).await.map_err(|_| Error::ActorDisconnected)?;

        recv.await.map_err(|_| Error::ActorDisconnected)?
    }

    pub async fn create_user(
        &self,
        email: String,
        password: String,
    ) -> Result<User, Error> {
        let (send, recv) = oneshot::channel();
        self.sender.send(ActorMessage::CreateUser {
            email,
            password,
            respond_to: send,
        }).await.map_err(|_| Error::ActorDisconnected)?;

        recv.await.map_err(|_| Error::ActorDisconnected)?
    }
}

// Usage
let (actor, handle) = UserActor::new(repository);
tokio::spawn(actor.run());

let user = handle.create_user("user@example.com".into(), "password".into()).await?;
```

### Timeout and Retry

```rust
// GOOD: Timeout and retry patterns
use tokio::time::{timeout, sleep, Duration};

pub async fn with_timeout<T, F>(
    duration: Duration,
    future: F,
) -> Result<T, Error>
where
    F: std::future::Future<Output = Result<T, Error>>,
{
    timeout(duration, future)
        .await
        .map_err(|_| Error::Timeout)?
}

pub async fn with_retry<T, F, Fut>(
    max_attempts: u32,
    delay: Duration,
    mut operation: F,
) -> Result<T, Error>
where
    F: FnMut() -> Fut,
    Fut: std::future::Future<Output = Result<T, Error>>,
{
    let mut attempts = 0;

    loop {
        attempts += 1;

        match operation().await {
            Ok(result) => return Ok(result),
            Err(e) if attempts >= max_attempts => return Err(e),
            Err(_) => {
                tracing::warn!(
                    "Operation failed, retrying ({}/{})",
                    attempts,
                    max_attempts
                );
                sleep(delay * attempts).await;
            }
        }
    }
}

// Usage
let result = with_timeout(
    Duration::from_secs(5),
    fetch_user_data(user_id)
).await?;

let result = with_retry(3, Duration::from_secs(1), || {
    fetch_from_api(url)
}).await?;
```

### Concurrent Operations

```rust
// GOOD: Process items concurrently
use tokio::task::JoinSet;
use futures::stream::{StreamExt, FuturesUnordered};

// Pattern 1: JoinSet for bounded concurrency
pub async fn process_users_concurrent(
    user_ids: Vec<UserId>,
    max_concurrent: usize,
) -> Vec<Result<User, Error>> {
    let mut set = JoinSet::new();

    for chunk in user_ids.chunks(max_concurrent) {
        for id in chunk {
            let id = id.clone();
            set.spawn(async move { fetch_user(id).await });
        }

        // Wait for chunk to complete
        while let Some(result) = set.join_next().await {
            match result {
                Ok(user_result) => {
                    // Handle user result
                }
                Err(e) => {
                    tracing::error!("Task panicked: {:?}", e);
                }
            }
        }
    }

    vec![]
}

// Pattern 2: FuturesUnordered for dynamic concurrency
pub async fn process_stream<I, T, F, Fut>(
    items: I,
    max_concurrent: usize,
    processor: F,
) -> Vec<Result<T, Error>>
where
    I: IntoIterator,
    F: Fn(I::Item) -> Fut,
    Fut: std::future::Future<Output = Result<T, Error>>,
{
    let mut futures = FuturesUnordered::new();
    let mut results = Vec::new();
    let mut items = items.into_iter();

    // Fill initial batch
    for item in items.by_ref().take(max_concurrent) {
        futures.push(processor(item));
    }

    // Process with backpressure
    while let Some(result) = futures.next().await {
        results.push(result);

        // Add next item
        if let Some(item) = items.next() {
            futures.push(processor(item));
        }
    }

    results
}
```

### Select Pattern

```rust
// GOOD: Handle multiple async events
use tokio::select;

pub async fn wait_for_event(
    shutdown: tokio::sync::broadcast::Receiver<()>,
    mut events: mpsc::Receiver<Event>,
) -> Result<(), Error> {
    loop {
        select! {
            // Handle shutdown signal
            _ = shutdown.recv() => {
                info!("Received shutdown signal");
                break;
            }

            // Handle events
            Some(event) = events.recv() => {
                process_event(event).await?;
            }

            // Timeout if no events
            _ = sleep(Duration::from_secs(60)) => {
                warn!("No events received in 60 seconds");
            }
        }
    }

    Ok(())
}
```

## Performance Patterns

### Zero-Copy Operations

```rust
// BAD: Unnecessary allocations
fn process_data(data: &[u8]) -> Vec<u8> {
    let string = String::from_utf8(data.to_vec()).unwrap(); // Copy
    let processed = string.to_uppercase(); // Allocation
    processed.into_bytes() // Another allocation
}

// GOOD: Minimize copies
fn process_data(data: &[u8]) -> Vec<u8> {
    data.iter()
        .map(|b| b.to_ascii_uppercase())
        .collect()
}

// GOOD: Borrow instead of clone
fn get_user_email(users: &[User], id: &UserId) -> Option<&str> {
    users.iter()
        .find(|u| &u.id == id)
        .map(|u| u.email.as_str()) // Return reference
}
```

### Iterator Chaining

```rust
// GOOD: Lazy evaluation with iterators
pub fn process_large_dataset(data: &[Item]) -> Vec<ProcessedItem> {
    data.iter()
        .filter(|item| item.is_valid())
        .filter(|item| item.price > 0.0)
        .map(|item| item.process())
        .collect()
}

// GOOD: Avoid intermediate collections
// BAD
let valid: Vec<_> = data.iter().filter(|x| x.is_valid()).collect();
let processed: Vec<_> = valid.iter().map(|x| x.process()).collect();

// GOOD
let processed: Vec<_> = data.iter()
    .filter(|x| x.is_valid())
    .map(|x| x.process())
    .collect();
```

### Capacity Pre-allocation

```rust
// GOOD: Pre-allocate when size is known
pub fn merge_vectors<T: Clone>(vecs: &[Vec<T>]) -> Vec<T> {
    let total_len = vecs.iter().map(|v| v.len()).sum();
    let mut result = Vec::with_capacity(total_len);

    for vec in vecs {
        result.extend_from_slice(vec);
    }

    result
}

// GOOD: Reserve capacity incrementally
pub fn collect_items<T>(source: impl Iterator<Item = T>) -> Vec<T> {
    let (lower, upper) = source.size_hint();
    let capacity = upper.unwrap_or(lower);

    let mut result = Vec::with_capacity(capacity);
    result.extend(source);
    result
}
```

### Cow for Conditional Cloning

```rust
use std::borrow::Cow;

// GOOD: Clone only when necessary
pub fn normalize_string(input: &str) -> Cow<str> {
    if input.chars().all(|c| c.is_lowercase()) {
        Cow::Borrowed(input)
    } else {
        Cow::Owned(input.to_lowercase())
    }
}

// Usage
let s1 = "hello";
let s2 = "WORLD";
let n1 = normalize_string(s1); // No allocation
let n2 = normalize_string(s2); // Allocates
```

### SmallVec for Small Collections

```rust
use smallvec::{SmallVec, smallvec};

// GOOD: Stack allocation for small sizes
type Tags = SmallVec<[String; 4]>; // Up to 4 tags on stack

pub struct Item {
    name: String,
    tags: Tags, // No heap allocation for <= 4 tags
}

impl Item {
    pub fn new(name: String) -> Self {
        Self {
            name,
            tags: smallvec![],
        }
    }

    pub fn add_tag(&mut self, tag: String) {
        self.tags.push(tag); // Grows to heap if needed
    }
}
```

## Testing Standards

### Unit Tests

```rust
// GOOD: Comprehensive unit tests
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation() {
        let user = User::new("test@example.com", "password123").unwrap();
        assert_eq!(user.email(), "test@example.com");
    }

    #[test]
    fn test_invalid_email() {
        let result = User::new("invalid-email", "password123");
        assert!(matches!(result, Err(ValidationError::InvalidEmail(_))));
    }

    #[test]
    fn test_password_too_short() {
        let result = User::new("test@example.com", "short");
        assert!(matches!(result, Err(ValidationError::PasswordTooShort)));
    }

    #[test]
    #[should_panic(expected = "Empty password")]
    fn test_empty_password_panics() {
        let _ = hash_password("");
    }
}
```

### Integration Tests

```rust
// tests/integration_test.rs
use my_library::{UserService, Config};

#[tokio::test]
async fn test_create_and_fetch_user() {
    // Setup
    let config = Config::test();
    let service = UserService::new(config).await.unwrap();

    // Create user
    let user = service
        .create_user("test@example.com", "password123")
        .await
        .unwrap();

    // Fetch user
    let fetched = service
        .get_user(&user.id())
        .await
        .unwrap();

    // Assert
    assert_eq!(fetched.email(), user.email());
}
```

### Property-Based Testing

```rust
// GOOD: Property tests with proptest
use proptest::prelude::*;

proptest! {
    #[test]
    fn test_user_id_roundtrip(s in "[a-zA-Z0-9-]{1,100}") {
        let user_id = UserId::new(s.clone()).unwrap();
        assert_eq!(user_id.as_str(), s);
    }

    #[test]
    fn test_price_calculation(
        price in 0.0f64..1000.0,
        tax_rate in 0.0f64..1.0
    ) {
        let total = calculate_total(price, tax_rate);
        assert!(total >= price);
        assert!(total <= price * 2.0);
    }
}
```

### Benchmark Tests

```rust
// benches/benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};
use my_library::*;

fn benchmark_user_creation(c: &mut Criterion) {
    c.bench_function("create_user", |b| {
        b.iter(|| {
            User::new(
                black_box("test@example.com"),
                black_box("password123")
            )
        })
    });
}

fn benchmark_hash_password(c: &mut Criterion) {
    c.bench_function("hash_password", |b| {
        b.iter(|| {
            hash_password(black_box("password123"))
        })
    });
}

criterion_group!(benches, benchmark_user_creation, benchmark_hash_password);
criterion_main!(benches);
```

## Type System Patterns

### Phantom Types

```rust
// GOOD: Use phantom types for compile-time guarantees
use std::marker::PhantomData;

struct Validated;
struct Unvalidated;

#[derive(Debug)]
struct Email<State = Unvalidated> {
    address: String,
    _state: PhantomData<State>,
}

impl Email<Unvalidated> {
    pub fn new(address: impl Into<String>) -> Self {
        Self {
            address: address.into(),
            _state: PhantomData,
        }
    }

    pub fn validate(self) -> Result<Email<Validated>, ValidationError> {
        if !self.address.contains('@') {
            return Err(ValidationError::InvalidEmail(self.address));
        }

        Ok(Email {
            address: self.address,
            _state: PhantomData,
        })
    }
}

impl Email<Validated> {
    pub fn as_str(&self) -> &str {
        &self.address
    }
}

// Only validated emails can be used in API
fn send_email(to: Email<Validated>, body: &str) {
    // Implementation
}

// Usage
let email = Email::new("user@example.com")
    .validate()?;
send_email(email, "Hello!");
```

### Sealed Traits

```rust
// GOOD: Prevent external trait implementations
mod sealed {
    pub trait Sealed {}
}

pub trait Operation: sealed::Sealed {
    fn execute(&self) -> Result<(), Error>;
}

pub struct Create;
pub struct Update;
pub struct Delete;

impl sealed::Sealed for Create {}
impl sealed::Sealed for Update {}
impl sealed::Sealed for Delete {}

impl Operation for Create {
    fn execute(&self) -> Result<(), Error> {
        // Implementation
    }
}

// External crates cannot implement Operation
```

### Associated Types vs Generics

```rust
// Use associated types when there's one natural implementation
trait Repository {
    type Item;
    type Error;

    fn get(&self, id: &str) -> Result<Self::Item, Self::Error>;
}

struct UserRepository;

impl Repository for UserRepository {
    type Item = User;
    type Error = DatabaseError;

    fn get(&self, id: &str) -> Result<User, DatabaseError> {
        // Implementation
    }
}

// Use generics when multiple implementations make sense
trait Processor<Input, Output> {
    fn process(&self, input: Input) -> Output;
}

struct JsonProcessor;

impl Processor<String, serde_json::Value> for JsonProcessor {
    fn process(&self, input: String) -> serde_json::Value {
        serde_json::from_str(&input).unwrap()
    }
}

impl Processor<Vec<u8>, serde_json::Value> for JsonProcessor {
    fn process(&self, input: Vec<u8>) -> serde_json::Value {
        serde_json::from_slice(&input).unwrap()
    }
}
```
