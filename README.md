# BurnP3+ Web Application

A modern, web-based implementation of BurnP3+ (Burn Probability Plus) - a wildfire burn probability modeling system that uses Monte Carlo simulation methods to assess fire risk and susceptibility across landscapes.

## Overview

BurnP3+ combines stochastic draws of fire ignition, weather, and burning conditions with deterministic fire growth models to produce spatially-explicit burn probability estimates and wildfire risk assessments.

### Key Features

- **Four-Stage Simulation Pipeline**
  - Stage 1: Ignition Sampling (Monte Carlo)
  - Stage 2: Burning Conditions Sampling
  - Stage 3: Fire Growth Modeling (Cell2Fire, Prometheus, FireSTARR)
  - Stage 4: Burn Probability Summarization

- **Modern Web Architecture**
  - React + TypeScript frontend with interactive mapping
  - FastAPI backend with async support
  - PostgreSQL + PostGIS for spatial data
  - Celery for distributed task processing
  - S3-compatible object storage

- **Comprehensive Outputs**
  - Burn probability rasters
  - Fire perimeters and behavior metrics
  - Rate of spread, intensity, fuel consumption
  - Statistical summaries and visualizations

## Documentation

- [Architecture](./ARCHITECTURE.md) - Detailed system architecture and design
- [Technology Stack](./TECH_STACK.md) - Technology choices and rationale
- [Development Plan](./DEVELOPMENT_PLAN.md) - Phased development roadmap

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Git
- (Optional) Node.js 20+ and Python 3.11+ for local development

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/burnpthreeplus.git
   cd burnpthreeplus
   ```

2. **Create environment file**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration if needed
   ```

3. **Start all services**
   ```bash
   docker-compose up -d
   ```

4. **Wait for services to be ready** (first run takes longer)
   ```bash
   docker-compose logs -f
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/api/v1/docs
   - Celery Flower: http://localhost:5555
   - MinIO Console: http://localhost:9001

### Development Workflow

#### Backend Development

```bash
# Enter backend container
docker-compose exec backend bash

# Run tests
poetry run pytest

# Run linting
poetry run black app/
poetry run isort app/
poetry run mypy app/

# Create database migration
alembic revision --autogenerate -m "description"

# Run migrations
alembic upgrade head
```

#### Frontend Development

```bash
# Enter frontend container
docker-compose exec frontend sh

# Run linting
pnpm run lint

# Type checking
pnpm run type-check

# Format code
pnpm run format
```

### Stopping Services

```bash
# Stop all services
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop and remove containers + volumes (WARNING: deletes all data)
docker-compose down -v
```

## Project Structure

```
burnpthreeplus/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API endpoints
│   │   ├── core/           # Core configuration
│   │   ├── db/             # Database setup
│   │   ├── models/         # SQLAlchemy models
│   │   ├── schemas/        # Pydantic schemas
│   │   ├── services/       # Business logic
│   │   ├── tasks/          # Celery tasks
│   │   └── tests/          # Backend tests
│   ├── Dockerfile.dev
│   ├── pyproject.toml
│   └── poetry.lock
├── frontend/               # React frontend
│   ├── src/
│   │   ├── components/    # Reusable components
│   │   ├── pages/         # Page components
│   │   ├── hooks/         # Custom React hooks
│   │   ├── services/      # API client services
│   │   ├── store/         # Zustand state management
│   │   ├── types/         # TypeScript types
│   │   └── utils/         # Utility functions
│   ├── Dockerfile.dev
│   ├── package.json
│   └── vite.config.ts
├── .github/
│   └── workflows/         # GitHub Actions CI/CD
├── docker-compose.yml
├── ARCHITECTURE.md
├── TECH_STACK.md
├── DEVELOPMENT_PLAN.md
└── README.md
```

## Technology Stack

### Frontend
- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **State Management**: Zustand
- **Mapping**: Leaflet + react-leaflet
- **UI Components**: shadcn/ui (Radix + Tailwind)
- **Visualization**: Recharts, D3.js

### Backend
- **Framework**: FastAPI (Python 3.11)
- **Database**: PostgreSQL 15 + PostGIS
- **Cache/Queue**: Redis 7
- **Task Queue**: Celery
- **Object Storage**: MinIO (S3-compatible)
- **ORM**: SQLAlchemy
- **Geospatial**: Rasterio, GeoPandas, GDAL

### DevOps
- **Containerization**: Docker + Docker Compose
- **CI/CD**: GitHub Actions
- **Code Quality**: Black, isort, mypy, ESLint, Prettier
- **Testing**: pytest, Vitest
- **Monitoring**: Prometheus, Grafana (production)

## Development Status

🚧 **Currently in Phase 0: Foundation Setup**

This project is under active development. See [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) for the complete roadmap.

### Completed
- ✅ Architecture design and documentation
- ✅ Technology stack selection
- ✅ Project scaffolding and structure
- ✅ Docker development environment
- ✅ CI/CD pipeline setup
- ✅ Basic backend API structure
- ✅ Basic frontend application

### In Progress
- 🔄 Core infrastructure (database models, API endpoints)

### Upcoming
- ⏳ User authentication and scenario management
- ⏳ Spatial data upload and visualization
- ⏳ Pipeline Stage 1: Ignition sampling
- ⏳ Pipeline Stage 2: Burning conditions
- ⏳ Pipeline Stage 3: Fire growth models
- ⏳ Pipeline Stage 4: Burn probability summarization

## Contributing

### Code Quality

This project uses automated code quality tools:

```bash
# Install pre-commit hooks
pip install pre-commit
pre-commit install

# Run manually
pre-commit run --all-files
```

### Testing

- Backend tests must pass: `pytest`
- Frontend must build: `pnpm run build`
- All linters must pass
- Code coverage target: 80%+

### Git Workflow

1. Create feature branch: `git checkout -b feature/description`
2. Make changes and commit
3. Push and create pull request
4. Wait for CI checks to pass
5. Request review
6. Merge when approved

## Fire Growth Models

### Supported Models

1. **Cell2Fire** (Planned)
   - Cellular automaton approach
   - Fast execution for large landscapes
   - Python-based

2. **Prometheus** (Planned)
   - Canadian Fire Behavior Prediction System
   - High accuracy for Canadian fuel types
   - C++ with Python bindings

3. **FireSTARR** (Future)
   - Statistical fire spread model
   - Uncertainty quantification
   - R/C++ hybrid

## Scientific Background

BurnP3+ is based on the original Burn-P3 software developed by the Canadian Forest Service and implements the Canadian Fire Behavior Prediction (FBP) System.

### References

- [BurnP3+ Documentation](https://burnp3.github.io/BurnP3Plus/)
- [BurnP3+ GitHub](https://github.com/BurnP3/BurnP3Plus)
- [SyncroSim Framework](https://syncrosim.com/)
- Canadian Fire Behavior Prediction System

## License

[To be determined - coordinate with BurnP3+ project]

## Acknowledgments

- Canadian Forest Service for developing BurnP3+
- ApexRMS for SyncroSim framework
- Open source community for the technology stack

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/burnpthreeplus/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/burnpthreeplus/discussions)

## Roadmap

See [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) for the complete development roadmap.

### Milestones

- **M1**: Foundation Complete (✅ Current)
- **M2**: Core Infrastructure (Week 4)
- **M3**: User Management (Week 6)
- **M4**: Spatial Data (Week 8)
- **M5**: Ignition Sampling (Week 10)
- **M6**: Burning Conditions (Week 12)
- **M7**: Fire Growth (Week 16)
- **M8**: Summarization (Week 18)
- **M9**: Full Pipeline (Week 20)
- **M13**: Production Launch (Week 30)

---

**Version**: 0.1.0
**Status**: Development
**Last Updated**: 2025-10-23
