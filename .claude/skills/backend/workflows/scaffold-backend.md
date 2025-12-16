# Scaffold Backend Project

Create a new backend project for blockchain APIs (Node.js/Bun) or web2 APIs (Django).

## Option 1: Node.js/Bun Backend (Blockchain)

### Initialize Project

```bash
mkdir backend
cd backend
bun init -y
```

### Install Dependencies

```bash
# Core
bun add express cors dotenv

# Database
bun add pg drizzle-orm
bun add -D drizzle-kit

# Web3
bun add viem

# Utilities
bun add zod  # Validation

# Dev dependencies
bun add -D @types/express @types/node @types/cors
bun add -D tsx  # TypeScript execution
```

### Project Structure

```
backend/
├── src/
│   ├── index.ts           # Entry point
│   ├── config/
│   │   └── env.ts         # Environment config
│   ├── routes/
│   │   └── api.ts         # API routes
│   ├── services/
│   │   └── blockchain.ts  # Blockchain interactions
│   ├── db/
│   │   ├── schema.ts      # Database schema
│   │   └── client.ts      # DB client
│   └── types/
│       └── index.ts       # TypeScript types
├── .env
├── .env.example
├── package.json
├── tsconfig.json
└── drizzle.config.ts
```

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "allowSyntheticDefaultImports": true,
    "types": ["node", "bun-types"]
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules"]
}
```

### Basic Server (`src/index.ts`)

```typescript
import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3000

app.use(cors())
app.use(express.json())

app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})
```

### Environment Config

`.env.example`:
```bash
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
RPC_URL=https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY
```

### package.json Scripts

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "db:generate": "drizzle-kit generate:pg",
    "db:migrate": "drizzle-kit push:pg"
  }
}
```

## Option 2: Django Backend (Web2)

### Create Django Project

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows

# Install Django
pip install django djangorestframework python-decouple psycopg2-binary

# Create project
django-admin startproject backend .
python manage.py startapp api
```

### Project Structure

```
backend/
├── backend/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── api/
│   ├── __init__.py
│   ├── models.py
│   ├── serializers.py
│   ├── views.py
│   └── urls.py
├── manage.py
├── requirements.txt
├── .env
└── .env.example
```

### Configure Settings

Update `backend/settings.py`:

```python
from decouple import config

INSTALLED_APPS = [
    # ...
    'rest_framework',
    'api',
]

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST', default='localhost'),
        'PORT': config('DB_PORT', default='5432'),
    }
}

REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 100
}
```

### Environment File

`.env.example`:
```bash
SECRET_KEY=your-secret-key
DEBUG=True
DB_NAME=dbname
DB_USER=user
DB_PASSWORD=password
DB_HOST=localhost
DB_PORT=5432
```

### Basic View

`api/views.py`:
```python
from rest_framework.decorators import api_view
from rest_framework.response import Response

@api_view(['GET'])
def health_check(request):
    return Response({'status': 'ok'})
```

### URL Configuration

`api/urls.py`:
```python
from django.urls import path
from . import views

urlpatterns = [
    path('health/', views.health_check),
]
```

`backend/urls.py`:
```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')),
]
```

### requirements.txt

```
django==5.0
djangorestframework==3.14
python-decouple==3.8
psycopg2-binary==2.9
```

### Run Migrations

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

## Common Setup (Both Stacks)

### Docker Support

See `/backend-docker` workflow.

### Database Setup

PostgreSQL:
```bash
# Using Docker
docker run --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres

# Or install locally
```

### Testing Setup

Node.js:
```bash
bun add -D vitest
```

Django:
```bash
pip install pytest pytest-django
```

## Output
- Fully configured backend project
- Database connection ready
- Basic API endpoint working
- Environment variables configured
- Development server running
