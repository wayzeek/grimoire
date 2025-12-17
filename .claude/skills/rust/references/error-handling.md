# Error Handling

thiserror, anyhow, and Result patterns for Rust error handling.
## Error Handling

### Thiserror for Library Errors

```rust
// GOOD: Structured error types with thiserror
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ApiError {
    #[error("User not found: {0}")]
    UserNotFound(UserId),

    #[error("Invalid credentials")]
    InvalidCredentials,

    #[error("Database error: {0}")]
    Database(#[from] sqlx::Error),

    #[error("HTTP error: {0}")]
    Http(#[from] reqwest::Error),

    #[error("Validation failed: {field}: {message}")]
    Validation {
        field: String,
        message: String,
    },

    #[error("Rate limit exceeded. Try again in {retry_after} seconds")]
    RateLimitExceeded {
        retry_after: u64,
    },

    #[error("Internal error: {0}")]
    Internal(String),
}

// Convert to HTTP responses
impl ApiError {
    pub fn status_code(&self) -> StatusCode {
        match self {
            Self::UserNotFound(_) => StatusCode::NOT_FOUND,
            Self::InvalidCredentials => StatusCode::UNAUTHORIZED,
            Self::Validation { .. } => StatusCode::UNPROCESSABLE_ENTITY,
            Self::RateLimitExceeded { .. } => StatusCode::TOO_MANY_REQUESTS,
            Self::Database(_) | Self::Internal(_) => StatusCode::INTERNAL_SERVER_ERROR,
            Self::Http(_) => StatusCode::BAD_GATEWAY,
        }
    }

    pub fn error_code(&self) -> &str {
        match self {
            Self::UserNotFound(_) => "USER_NOT_FOUND",
            Self::InvalidCredentials => "INVALID_CREDENTIALS",
            Self::Validation { .. } => "VALIDATION_ERROR",
            Self::RateLimitExceeded { .. } => "RATE_LIMIT_EXCEEDED",
            Self::Database(_) => "DATABASE_ERROR",
            Self::Internal(_) => "INTERNAL_ERROR",
            Self::Http(_) => "HTTP_ERROR",
        }
    }
}
```

### Anyhow for Application Errors

```rust
// GOOD: Use anyhow in application code
use anyhow::{Context, Result, bail, ensure};

pub async fn process_user_order(
    user_id: UserId,
    order_id: OrderId,
) -> Result<Order> {
    // Add context to errors
    let user = get_user(&user_id)
        .await
        .context("Failed to fetch user")?;

    ensure!(user.is_active, "User account is not active");

    let order = get_order(&order_id)
        .await
        .context(format!("Failed to fetch order {}", order_id))?;

    if order.user_id != user_id {
        bail!("Order does not belong to user");
    }

    // Process order
    process_payment(&order)
        .await
        .context("Payment processing failed")?;

    Ok(order)
}
```

### Result Extension Traits

```rust
// GOOD: Custom Result extensions
pub trait ResultExt<T, E> {
    fn log_error(self, context: &str) -> Result<T, E>;
    fn map_err_log(self, context: &str) -> Result<T, E>;
}

impl<T, E: std::fmt::Display> ResultExt<T, E> for Result<T, E> {
    fn log_error(self, context: &str) -> Result<T, E> {
        if let Err(ref e) = self {
            tracing::error!("{}: {}", context, e);
        }
        self
    }

    fn map_err_log(self, context: &str) -> Result<T, E> {
        self.map_err(|e| {
            tracing::error!("{}: {}", context, e);
            e
        })
    }
}

// Usage
let result = risky_operation()
    .log_error("Failed to perform risky operation")
    .context("Additional context")?;
```

### Error Mapping

```rust
// GOOD: Convert between error types
impl From<ValidationError> for ApiError {
    fn from(err: ValidationError) -> Self {
        match err {
            ValidationError::InvalidEmail(email) => Self::Validation {
                field: "email".to_string(),
                message: format!("Invalid email: {}", email),
            },
            ValidationError::PasswordTooShort => Self::Validation {
                field: "password".to_string(),
                message: "Password must be at least 8 characters".to_string(),
            },
            // ... other conversions
        }
    }
}

// Automatic conversion with ?
fn create_user(dto: UserDto) -> Result<User, ApiError> {
    let email = validate_email(&dto.email)?; // ValidationError -> ApiError
    let password = hash_password(&dto.password)?; // HashError -> ApiError
    Ok(User { email, password })
}
```

