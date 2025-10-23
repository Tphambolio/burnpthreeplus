# Technology Stack

## Overview

This document outlines the technology choices for the BurnP3+ web application and provides rationale for each decision.

## Core Principles

1. **Open Source First**: Prefer open-source technologies to align with BurnP3+ heritage
2. **Python-Centric**: Leverage Python for scientific computing and geospatial processing
3. **Modern Web Standards**: Use current best practices for web development
4. **Cloud-Native**: Design for containerized deployment and scaling
5. **Developer Experience**: Choose tools with good documentation and community support

## Technology Choices

### Frontend

#### Framework: React 18+ with TypeScript
**Rationale**:
- Most popular framework with extensive ecosystem
- TypeScript provides type safety for complex data models
- Excellent developer tools and debugging
- Large talent pool
- Strong component library ecosystem

**Alternatives Considered**:
- Vue.js: Simpler but smaller ecosystem
- Svelte: Great performance but less mature
- Angular: Over-engineered for this use case

#### State Management: Zustand
**Rationale**:
- Simpler than Redux, less boilerplate
- TypeScript-first design
- Small bundle size
- Perfect for medium-complexity apps

**Alternatives Considered**:
- Redux Toolkit: More complex, unnecessary overhead
- React Context: Insufficient for complex state
- Jotai/Recoil: Less established

#### Mapping: Leaflet + react-leaflet
**Rationale**:
- Open source (vs Mapbox/Google Maps licensing)
- Excellent GeoTIFF/raster support via plugins
- Lighter weight than OpenLayers
- Large plugin ecosystem
- Well-maintained react bindings

**Plugins**:
- georaster-layer-for-leaflet: Display rasters
- leaflet-draw: Drawing tools
- leaflet-sidebar: UI panels

**Alternatives Considered**:
- Mapbox GL JS: Commercial license required
- OpenLayers: Heavier, steeper learning curve
- Deck.gl: Overkill for 2D mapping

#### Visualization: Recharts + D3.js
**Rationale**:
- **Recharts**: React-friendly, composable charts
- **D3.js**: For custom visualizations when needed
- Both widely used, well-documented

**Alternatives Considered**:
- Plotly.js: Heavier bundle
- Chart.js: Less React-friendly
- Victory: Smaller ecosystem

#### UI Components: shadcn/ui (Radix UI + Tailwind)
**Rationale**:
- Copy-paste components, full customization
- Built on Radix UI (accessibility)
- Tailwind CSS for styling
- No dependency bloat
- Modern, clean aesthetic

**Alternatives Considered**:
- Material-UI: Heavy, opinionated
- Ant Design: Less customizable
- Chakra UI: Good but shadcn more flexible

#### Build Tool: Vite
**Rationale**:
- Lightning-fast hot reload
- Modern ESM-based
- Excellent TypeScript support
- Smaller bundles than Create React App

### Backend

#### API Framework: FastAPI (Python 3.11+)
**Rationale**:
- Python-native for geospatial/scientific libraries
- Automatic OpenAPI documentation
- Type hints for validation (Pydantic)
- Async support for concurrent requests
- Fast performance (Starlette + uvicorn)
- WebSocket support built-in

**Alternatives Considered**:
- Django REST Framework: Heavier, more opinionated
- Flask: Less modern, manual validation
- Node.js Express: Would require Python bridge for processing

#### Task Queue: Celery + Redis
**Rationale**:
- Industry standard for distributed Python tasks
- Robust error handling and retries
- Priority queues for job management
- Monitoring via Flower
- Redis for speed (vs RabbitMQ complexity)

**Alternatives Considered**:
- RQ: Simpler but less features
- Dramatiq: Newer, less adoption
- Temporal: Overkill for this use case

#### API Documentation: OpenAPI (via FastAPI)
**Rationale**:
- Automatically generated from code
- Interactive testing via Swagger UI
- Client SDK generation possible
- Industry standard

### Data Layer

#### Primary Database: PostgreSQL 15+ with PostGIS
**Rationale**:
- Best open-source relational database
- PostGIS for spatial queries
- JSON support for flexible schemas
- Excellent Python support (psycopg3)
- Battle-tested reliability
- Free and open source

**Alternatives Considered**:
- MySQL: Weaker spatial support
- MongoDB: Not ideal for structured data
- SQLite: Not suitable for concurrent writes

#### Cache/Queue: Redis 7+
**Rationale**:
- In-memory speed for queues
- Pub/sub for WebSocket messages
- Session storage
- Result caching
- Simple deployment

**Alternatives Considered**:
- Memcached: Less features
- RabbitMQ: More complex for our needs

#### Object Storage: S3-compatible (AWS S3 / MinIO)
**Rationale**:
- S3 API is industry standard
- MinIO for local/self-hosted deployments
- Scalable storage for large rasters
- Lifecycle policies for data archiving
- Integration with all cloud providers

**Alternatives Considered**:
- Filesystem: Not scalable
- Azure Blob: S3-compatible is more portable
- Google Cloud Storage: Same reasoning

### Geospatial Processing

#### Primary Library: Rasterio + GDAL
**Rationale**:
- Industry standard for raster I/O
- Efficient reading/writing GeoTIFF
- Numpy integration
- Comprehensive format support

#### Spatial Operations: GeoPandas + Shapely
**Rationale**:
- Pandas-like API for vector data
- Easy geometric operations
- PostGIS integration
- Well-documented

#### Array Processing: NumPy + SciPy
**Rationale**:
- Foundation of scientific Python
- Fast array operations
- Statistical functions
- Required by rasterio

#### Visualization Generation: Matplotlib + Colormaps
**Rationale**:
- Create static map exports
- Color ramps for burn probability
- Publication-quality figures

### Fire Growth Models

#### Cell2Fire: Python
**Rationale**:
- Native Python implementation
- Easy integration
- Good performance for cellular automata

#### Prometheus: C++ with Python bindings
**Rationale**:
- High-performance core
- Maintained by Canadian Forest Service
- Existing Python bindings available

### Development Tools

#### Version Control: Git + GitHub
**Rationale**:
- Industry standard
- Integrated with CI/CD
- Project already on GitHub
- Good for open source

#### Package Management (Python): Poetry
**Rationale**:
- Modern dependency management
- Lock files for reproducibility
- Virtual environment management
- Better than pip + requirements.txt

**Alternatives Considered**:
- Pip + venv: Manual, error-prone
- Conda: Heavier, slower

#### Package Management (JavaScript): pnpm
**Rationale**:
- Faster than npm/yarn
- Efficient disk usage (hard links)
- Strict dependency resolution
- Drop-in npm replacement

**Alternatives Considered**:
- npm: Slower, more disk space
- yarn: Similar to pnpm but slower

#### Code Quality (Python)
- **Black**: Opinionated code formatting
- **isort**: Import sorting
- **mypy**: Static type checking
- **pylint**: Linting
- **pytest**: Testing framework
- **coverage.py**: Code coverage

#### Code Quality (JavaScript/TypeScript)
- **ESLint**: Linting
- **Prettier**: Code formatting
- **TypeScript**: Type checking
- **Vitest**: Testing framework
- **Playwright**: E2E testing

#### Pre-commit Hooks: pre-commit
**Rationale**:
- Automatic code quality checks
- Prevent bad commits
- Consistent across team

### Containerization

#### Container Runtime: Docker
**Rationale**:
- Industry standard
- Excellent documentation
- Docker Compose for local dev
- Registry support

#### Orchestration: Docker Compose (local) / Kubernetes (production)
**Rationale**:
- Docker Compose: Simple local development
- Kubernetes: Production-grade orchestration
- Helm charts for deployment
- Auto-scaling support

**Alternatives Considered**:
- Docker Swarm: Less ecosystem
- Nomad: Less adoption

### CI/CD

#### Platform: GitHub Actions
**Rationale**:
- Native GitHub integration
- Free for public repos
- Extensive marketplace
- YAML configuration

**Workflows**:
1. **Test**: Run on every PR
   - Unit tests (pytest, vitest)
   - Linting (black, eslint)
   - Type checking (mypy, tsc)
   - Coverage reporting

2. **Build**: Build Docker images
   - Multi-stage builds
   - Layer caching
   - Push to registry (GHCR)

3. **Deploy**: Deploy to environments
   - Staging: Auto-deploy on main branch
   - Production: Manual approval
   - Database migrations
   - Health checks

**Alternatives Considered**:
- GitLab CI: Not using GitLab
- Jenkins: Too complex to maintain
- CircleCI: Costs money

### Monitoring & Observability

#### Application Metrics: Prometheus + Grafana
**Rationale**:
- Open source
- Pull-based metrics
- Powerful query language (PromQL)
- Beautiful dashboards (Grafana)

#### Logging: Structured JSON logs
**Rationale**:
- Easy parsing
- Rich metadata
- Compatible with all log aggregators

**Tools**:
- Python: structlog
- Collection: Promtail + Loki (lightweight)
- Or: ELK stack (Elasticsearch, Logstash, Kibana) for larger scale

#### Error Tracking: Sentry
**Rationale**:
- Excellent error grouping
- Source map support
- Free tier for small projects
- Client + server support

**Alternatives Considered**:
- Rollbar: Less features
- Self-hosted: More maintenance

### Documentation

#### API Docs: OpenAPI/Swagger (auto-generated)
#### Code Docs: Docstrings (Google style)
#### User Docs: MkDocs with Material theme
**Rationale**:
- Markdown-based
- Beautiful theme
- Easy to maintain
- Deploy to GitHub Pages

**Alternatives Considered**:
- Sphinx: More complex
- Docusaurus: React-based (overkill)

### Development Environment

#### Editor: VS Code (recommended)
**Extensions**:
- Python (Microsoft)
- Pylance
- ESLint
- Prettier
- GitLens
- Docker
- Remote Containers

#### Recommended Setup:
- Dev containers for consistent environment
- Shared settings via .vscode/
- Debugging configs included

## Infrastructure Stack (Production)

### Cloud Provider Options

#### AWS
**Services**:
- EC2 / ECS for compute
- RDS for PostgreSQL
- ElastiCache for Redis
- S3 for object storage
- ALB for load balancing
- CloudWatch for monitoring

#### Google Cloud Platform
**Services**:
- GKE for Kubernetes
- Cloud SQL for PostgreSQL
- Memorystore for Redis
- Cloud Storage for objects
- Cloud Load Balancing
- Cloud Monitoring

#### Self-Hosted
**Components**:
- Kubernetes cluster
- PostgreSQL cluster
- Redis cluster
- MinIO for S3-compatible storage
- Nginx ingress
- Prometheus/Grafana stack

**Rationale for flexibility**:
- Research institutions may prefer self-hosted
- Government agencies may have cloud restrictions
- Docker Compose works everywhere for small deployments

## Summary Table

| Layer | Technology | Primary Reason |
|-------|-----------|----------------|
| Frontend Framework | React + TypeScript | Ecosystem & type safety |
| Frontend State | Zustand | Simplicity |
| Mapping | Leaflet | Open source, raster support |
| UI Components | shadcn/ui | Customizable, modern |
| API Framework | FastAPI | Python + async + docs |
| Database | PostgreSQL + PostGIS | Spatial + reliability |
| Cache/Queue | Redis | Speed + simplicity |
| Object Storage | S3-compatible | Standard API |
| Task Queue | Celery | Python + distributed |
| Geospatial | Rasterio + GeoPandas | Industry standard |
| Containers | Docker | Standard |
| Orchestration | Kubernetes | Production scale |
| CI/CD | GitHub Actions | Native integration |
| Monitoring | Prometheus + Grafana | Open source + powerful |

## Version Requirements

```
Python >= 3.11
Node.js >= 20 LTS
PostgreSQL >= 15
Redis >= 7
Docker >= 24
```

## License Considerations

All chosen technologies are open source with permissive licenses:
- MIT: React, FastAPI, Redis, Leaflet
- Apache 2.0: Kubernetes, PostgreSQL
- BSD: NumPy, Pandas
- GPL: GDAL (ok for use, not modification)

No commercial licenses required for core functionality.
