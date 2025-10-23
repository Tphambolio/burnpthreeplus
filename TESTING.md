# Testing Guide for BurnP3+ Application

## Quick Start - Running Locally

### Prerequisites

- Docker and Docker Compose installed
- Git
- (Optional) Postman or curl for API testing

### Step 1: Start the Services

```bash
# Clone the repository (if you haven't already)
git clone https://github.com/Tphambolio/burnpthreeplus.git
cd burnpthreeplus

# Pull latest changes
git checkout claude/initialize-burnp3-project-011CUPExpoSehx8oTKgwTVd6
git pull

# Create environment file
cp .env.example .env

# Start all services
docker compose up -d

# Watch the logs
docker compose logs -f
```

### Step 2: Create Database Tables

Once the backend container is running, create the database migration:

```bash
# Enter the backend container
docker compose exec backend bash

# Create initial migration
alembic revision --autogenerate -m "Initial database schema"

# Apply the migration
alembic upgrade head

# Exit the container
exit
```

### Step 3: Test the API

The API will be available at: http://localhost:8000

#### Access API Documentation
Open your browser and go to:
- **Swagger UI**: http://localhost:8000/api/v1/docs
- **ReDoc**: http://localhost:8000/api/v1/redoc

#### Health Check
```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "version": "0.1.0",
  "environment": "development"
}
```

## API Testing Workflow

### 1. Register a New User

```bash
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword123",
    "full_name": "Test User"
  }'
```

Expected response (201 Created):
```json
{
  "id": "uuid-here",
  "email": "test@example.com",
  "full_name": "Test User",
  "is_active": true,
  "is_superuser": false,
  "created_at": "2024-01-15T...",
  "updated_at": "2024-01-15T..."
}
```

### 2. Login

```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=testpassword123"
```

Expected response (200 OK):
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer"
}
```

**Save the access_token** - you'll need it for authenticated requests.

### 3. Test Token Validation

```bash
# Replace YOUR_TOKEN with the access_token from login
curl -X POST "http://localhost:8000/api/v1/auth/test-token" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 4. Create a Scenario

```bash
curl -X POST "http://localhost:8000/api/v1/scenarios/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Wildfire Scenario",
    "description": "A test scenario for burn probability modeling",
    "num_iterations": 100,
    "num_ignitions_per_iteration": 5,
    "config": {
      "region": "test_region",
      "fuel_model": "canadian_fbp"
    }
  }'
```

Expected response (201 Created):
```json
{
  "id": "scenario-uuid",
  "name": "Test Wildfire Scenario",
  "description": "A test scenario for burn probability modeling",
  "owner_id": "user-uuid",
  "config": {
    "region": "test_region",
    "fuel_model": "canadian_fbp"
  },
  "num_iterations": 100,
  "num_ignitions_per_iteration": 5,
  "fuel_raster_key": null,
  "elevation_raster_key": null,
  "ignition_probability_raster_key": null,
  "created_at": "2024-01-15T...",
  "updated_at": "2024-01-15T..."
}
```

### 5. List Your Scenarios

```bash
curl -X GET "http://localhost:8000/api/v1/scenarios/" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 6. Get Specific Scenario

```bash
# Replace SCENARIO_ID with the id from the create response
curl -X GET "http://localhost:8000/api/v1/scenarios/SCENARIO_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 7. Update a Scenario

```bash
curl -X PUT "http://localhost:8000/api/v1/scenarios/SCENARIO_ID" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated description",
    "num_iterations": 200
  }'
```

### 8. Create a Simulation Run

```bash
curl -X POST "http://localhost:8000/api/v1/simulations/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "scenario_id": "SCENARIO_ID",
    "fire_growth_model": "cell2fire"
  }'
```

Expected response (201 Created):
```json
{
  "id": "simulation-uuid",
  "scenario_id": "scenario-uuid",
  "status": "pending",
  "fire_growth_model": "cell2fire",
  "current_stage": 1,
  "progress_percentage": 0.0,
  "created_at": "2024-01-15T...",
  "started_at": null,
  "completed_at": null,
  "results_key": null,
  "summary_statistics": null,
  "error_message": null
}
```

### 9. Get Simulation Status

```bash
curl -X GET "http://localhost:8000/api/v1/simulations/SIMULATION_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 10. Delete a Scenario

```bash
curl -X DELETE "http://localhost:8000/api/v1/scenarios/SCENARIO_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected response: 204 No Content

## Using the Swagger UI (Recommended for Testing)

1. Open http://localhost:8000/api/v1/docs in your browser
2. Click on any endpoint to expand it
3. Click "Try it out"
4. For authenticated endpoints:
   - First, execute the `/auth/login` endpoint
   - Copy the `access_token` from the response
   - Click the "Authorize" button at the top of the page
   - Enter: `Bearer YOUR_TOKEN` (include the word "Bearer" and a space)
   - Click "Authorize"
5. Now you can test all authenticated endpoints

## Database Inspection

### Connect to PostgreSQL

```bash
docker compose exec db psql -U burnp3 -d burnp3
```

### Useful SQL Commands

```sql
-- List all tables
\dt

-- View users table
SELECT id, email, full_name, is_active FROM users;

-- View scenarios
SELECT id, name, owner_id, num_iterations FROM scenarios;

-- View simulations
SELECT id, scenario_id, status, current_stage, progress_percentage
FROM simulation_runs;

-- View ignitions
SELECT id, simulation_run_id, iteration,
       ST_AsText(point) as location
FROM ignitions;

-- Exit psql
\q
```

## Monitoring Services

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f db
docker compose logs -f worker
```

### Check Service Status

```bash
docker compose ps
```

### MinIO Console

Access the MinIO console at: http://localhost:9001

- Username: `minioadmin`
- Password: `minioadmin`

You can view uploaded raster files here.

### Celery Flower (Task Monitoring)

Access Flower at: http://localhost:5555

Monitor background tasks (ignition sampling, fire growth, etc.)

## Frontend Testing

The frontend will be available at: http://localhost:3000

### Features to Test:
1. Navigate to http://localhost:3000
2. View the home page
3. Click on "Scenarios" in the navigation
4. Click on "Simulations" in the navigation

## Troubleshooting

### Backend won't start

```bash
# Check logs
docker compose logs backend

# Common issues:
# 1. Database not ready - wait a few seconds and restart
docker compose restart backend

# 2. Missing dependencies - rebuild
docker compose build backend
docker compose up -d backend
```

### Database connection issues

```bash
# Ensure PostgreSQL is running
docker compose ps db

# Check PostgreSQL logs
docker compose logs db

# Recreate database container
docker compose down db
docker compose up -d db
```

### Reset Everything

```bash
# Stop all services and remove volumes (WARNING: deletes all data)
docker compose down -v

# Start fresh
docker compose up -d
```

## Testing Error Scenarios

### Test authentication failures:

```bash
# Wrong password
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=test@example.com&password=wrongpassword"

# Expected: 401 Unauthorized

# No token
curl -X GET "http://localhost:8000/api/v1/scenarios/"

# Expected: 401 Unauthorized (missing token)
```

### Test authorization failures:

```bash
# Try to access another user's scenario
# (You'll need two users for this test)

# Expected: 403 Forbidden
```

### Test validation errors:

```bash
# Invalid email format
curl -X POST "http://localhost:8000/api/v1/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "not-an-email",
    "password": "testpassword123"
  }'

# Expected: 422 Unprocessable Entity
```

## Next Steps for Development

After verifying the backend works:

1. ✅ Database models created
2. ✅ Authentication working
3. ✅ CRUD endpoints functional
4. ⏳ Add spatial data upload (Stage 3)
5. ⏳ Implement ignition sampling (Stage 1)
6. ⏳ Add burning conditions (Stage 2)
7. ⏳ Integrate fire growth models (Stage 3)
8. ⏳ Build summarization (Stage 4)

## Performance Testing

### Load Testing with Apache Bench

```bash
# Test health endpoint
ab -n 1000 -c 10 http://localhost:8000/health

# Test authenticated endpoint (need to get token first)
ab -n 100 -c 5 -H "Authorization: Bearer YOUR_TOKEN" \
   http://localhost:8000/api/v1/scenarios/
```

## Security Testing

### Things to verify:
- ✅ Passwords are hashed (never stored in plain text)
- ✅ JWT tokens expire
- ✅ Users can only access their own scenarios
- ✅ Email validation works
- ✅ SQL injection protection (SQLAlchemy parameterized queries)

## Code Quality Checks

```bash
# Run linting
docker compose exec backend poetry run black app/ --check
docker compose exec backend poetry run isort app/ --check

# Run type checking
docker compose exec backend poetry run mypy app/

# Run tests (once we add them)
docker compose exec backend poetry run pytest
```

---

**Happy Testing! 🔥🗺️**

For issues or questions, check the logs first:
```bash
docker compose logs -f backend
```
