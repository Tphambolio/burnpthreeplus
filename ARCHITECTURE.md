# BurnP3+ Online Architecture

## Executive Summary

This document outlines the architecture for a web-based implementation of BurnP3+, a wildfire burn probability modeling system originally developed as a SyncroSim package by the Canadian Forest Service.

## Original BurnP3+ Architecture

### Purpose
BurnP3+ is a spatially-explicit fire simulation tool that uses Monte Carlo methods to produce burn probability estimates and wildfire risk assessments across landscapes.

### Core Components

#### 1. Four-Stage Processing Pipeline

**Stage 1: Sample Ignitions**
- Stochastically samples fire ignition locations and counts
- Uses spatial probability grids based on historical fire data
- Generates ignition points for each simulation iteration

**Stage 2: Sample Burning Conditions**
- Samples weather conditions (temperature, wind, humidity)
- Determines fuel moisture conditions
- Assigns burning conditions to each ignition based on temporal/spatial context
- Uses historical weather data and distributions

**Stage 3: Grow Fires**
- Deterministic fire growth simulation using one of three models:
  - **Cell2Fire**: Cellular automaton approach
  - **Prometheus**: Canadian fire behavior prediction system
  - **FireSTARR**: Statistical fire spread model
- Based on Canadian Fire Behavior Prediction System (FBP)
- Produces fire perimeters, spread rates, intensity, fuel consumption

**Stage 4: Summarize Burn Probability**
- Aggregates results across all Monte Carlo iterations
- Calculates burn probability for each cell
- Generates summary statistics:
  - Burn count per pixel
  - Mean fire intensity
  - Mean rate of spread
  - Fuel consumption totals
  - Conditional burn probability

#### 2. Data Model (SyncroSim Structure)

**Datafeeds**: Collections of related data tables
- Input Datafeeds: User configuration, spatial inputs, parameters
- Output Datafeeds: Results, intermediate calculations

**Datasheets**: Individual data tables within datafeeds
- Scenario configuration
- Landscape characteristics
- Fuel type mappings
- Ignition probability grids
- Weather distributions
- Fire behavior outputs

**Transformers**: Processing units that transform input datafeeds to outputs
- Each pipeline stage is implemented as a transformer
- Transformers can be chained in sequence
- Defined via XML configuration (package.xml)

#### 3. Technology Stack (Original)

- **Runtime**: R environment with statistical packages
- **Environment Management**: Conda
- **Integration**: Python, command line, SyncroSim Studio GUI
- **Platforms**: Windows and Linux
- **Data Formats**: Rasters (GeoTIFF), tabular data (CSV/SQLite)

## Online Web Application Architecture

### Design Principles

1. **Scalability**: Handle large landscapes and many concurrent simulations
2. **Modularity**: Maintain separation between pipeline stages
3. **Extensibility**: Easy addition of new fire growth models
4. **Accessibility**: Web-based interface accessible from any device
5. **Performance**: Leverage cloud computing for parallel execution
6. **Reproducibility**: Version control for models, data, and results

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Client Layer                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web UI     │  │  Map Viewer  │  │   Results    │      │
│  │  (React)     │  │  (Leaflet)   │  │  Dashboard   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↕ REST API / WebSocket
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway Layer                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  FastAPI / Express.js                                 │  │
│  │  - Authentication & Authorization                     │  │
│  │  - Request validation                                 │  │
│  │  - Rate limiting                                      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                         │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │   Scenario     │  │   Pipeline     │  │   Results    │  │
│  │   Manager      │  │   Orchestrator │  │   Service    │  │
│  └────────────────┘  └────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                  Processing Layer (Workers)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Stage 1    │→ │   Stage 2    │→ │   Stage 3    │      │
│  │  Ignitions   │  │   Burning    │  │ Fire Growth  │      │
│  │              │  │  Conditions  │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                              ↓               │
│                                       ┌──────────────┐      │
│                                       │   Stage 4    │      │
│                                       │ Summarize    │      │
│                                       └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  PostgreSQL  │  │    Redis     │  │   S3/Blob    │      │
│  │  (Metadata)  │  │   (Queue)    │  │  (Rasters)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Component Details

#### Frontend (Client Layer)

**Technology**: React with TypeScript
- **Map Viewer**: Leaflet or Mapbox for interactive spatial display
- **Visualization**: D3.js or Plotly for charts and statistics
- **State Management**: Redux or Zustand
- **UI Framework**: Material-UI or Tailwind CSS

**Key Features**:
- Scenario configuration interface
- File upload for spatial inputs (GeoTIFF)
- Interactive map for viewing inputs and outputs
- Real-time simulation progress monitoring
- Results visualization and export

#### API Gateway

**Technology**: FastAPI (Python) or Express.js (Node.js)
- RESTful endpoints for CRUD operations
- WebSocket support for real-time updates
- Authentication (JWT tokens)
- API documentation (OpenAPI/Swagger)

**Endpoints**:
```
POST   /api/scenarios              Create new scenario
GET    /api/scenarios              List scenarios
GET    /api/scenarios/{id}         Get scenario details
PUT    /api/scenarios/{id}         Update scenario
DELETE /api/scenarios/{id}         Delete scenario

POST   /api/scenarios/{id}/run     Start simulation
GET    /api/scenarios/{id}/status  Check run status
GET    /api/scenarios/{id}/results Get results

POST   /api/spatial/upload         Upload raster data
GET    /api/spatial/{id}           Download raster
```

#### Application Services

**Scenario Manager**
- Handles scenario CRUD operations
- Validates input parameters
- Manages scenario versioning

**Pipeline Orchestrator**
- Queues simulation jobs
- Manages workflow through 4 stages
- Handles retries and error recovery
- Tracks progress and status

**Results Service**
- Aggregates pipeline outputs
- Generates summary statistics
- Prepares data for visualization
- Manages result caching

#### Processing Workers

**Task Queue**: Celery (Python) or Bull (Node.js)
- Distributed task execution
- Parallel processing of Monte Carlo iterations
- Priority queue for job scheduling

**Stage Implementations**:

1. **Ignition Sampling Worker**
   - Reads ignition probability raster
   - Samples ignition locations using weighted random selection
   - Stores ignition points in database

2. **Burning Conditions Worker**
   - Queries weather database or distribution parameters
   - Samples weather conditions for each ignition
   - Assigns temporal attributes

3. **Fire Growth Worker**
   - Integrates with fire growth models (Cell2Fire, Prometheus, FireSTARR)
   - Runs simulation for each fire
   - Outputs fire perimeter and behavior metrics
   - Most computationally intensive stage

4. **Summarization Worker**
   - Aggregates individual fire results
   - Calculates burn probability grids
   - Computes statistical summaries
   - Generates output rasters

#### Data Layer

**PostgreSQL with PostGIS**
- Scenario metadata and configuration
- User accounts and permissions
- Simulation run history
- Vector spatial data (ignition points, fire perimeters)

**Redis**
- Task queue management
- Session storage
- Caching frequently accessed data
- Real-time progress tracking

**Object Storage (S3/Azure Blob/MinIO)**
- Raster files (GeoTIFF)
- Large result datasets
- Archived simulations
- User uploads

### Deployment Architecture

#### Containerization
- **Docker** for all services
- **Docker Compose** for local development
- Separate containers for:
  - Frontend (Nginx serving React app)
  - API server
  - Worker nodes (scalable)
  - Database
  - Redis
  - Object storage (MinIO for local)

#### Orchestration
- **Kubernetes** for production
  - Horizontal pod autoscaling for workers
  - Load balancing for API servers
  - Persistent volumes for databases

#### CI/CD Pipeline
- **GitHub Actions** workflows:
  - Automated testing on PR
  - Linting and code quality checks
  - Build and push Docker images
  - Deploy to staging/production
  - Database migrations

### Data Flow Example

1. **User creates scenario**:
   - Frontend sends scenario config to API
   - API validates and stores in PostgreSQL
   - Spatial inputs uploaded to object storage

2. **User starts simulation**:
   - API creates job and pushes to Redis queue
   - Returns job ID to frontend
   - WebSocket connection established for updates

3. **Pipeline execution**:
   - Orchestrator pulls job from queue
   - Stage 1 worker samples ignitions (parallel per iteration)
   - Stage 2 worker samples conditions for each ignition
   - Stage 3 worker grows fires (most time consuming)
   - Stage 4 worker aggregates results
   - Progress updates sent via WebSocket

4. **Results delivery**:
   - Final rasters written to object storage
   - Summary statistics stored in PostgreSQL
   - Frontend notified via WebSocket
   - User views results on interactive map

### Scaling Considerations

**Horizontal Scaling**:
- Worker pool can scale based on queue depth
- Multiple API servers behind load balancer
- Database read replicas for queries

**Optimization Strategies**:
- Parallel execution of Monte Carlo iterations
- Spatial partitioning for large landscapes
- Result caching for common queries
- Progressive result delivery (show partial results)

**Resource Management**:
- Memory limits for worker containers
- CPU allocation based on fire growth model
- Disk space monitoring for raster storage
- Queue prioritization for paid vs free users

## Fire Growth Model Integration

### Modular Design

Each fire growth model implemented as a separate module:
- Common interface for all models
- Docker containers with model-specific dependencies
- Easy to add new models (e.g., FARSITE, FlamMap)

### Model Adapter Pattern

```python
class FireGrowthModel(ABC):
    @abstractmethod
    def initialize(self, landscape, fuels, weather):
        pass

    @abstractmethod
    def grow_fire(self, ignition_point, duration, conditions):
        pass

    @abstractmethod
    def get_perimeter(self):
        pass

    @abstractmethod
    def get_behavior_metrics(self):
        pass
```

### Supported Models

**Cell2Fire**
- Cellular automaton approach
- Fast execution, good for large landscapes
- Python-based

**Prometheus**
- Canadian FBP system implementation
- High accuracy for Canadian fuel types
- C++ core with Python bindings

**FireSTARR** (future)
- Statistical fire spread model
- Handles uncertainty quantification
- R/C++ hybrid

## Security Considerations

- **Authentication**: JWT-based auth with refresh tokens
- **Authorization**: Role-based access control (RBAC)
- **Data Isolation**: User data segregation
- **Input Validation**: Strict validation of all uploads
- **Rate Limiting**: Prevent abuse of compute resources
- **Encryption**: TLS for data in transit, encryption at rest for sensitive data
- **Audit Logging**: Track all scenario runs and data access

## Monitoring & Observability

- **Application Metrics**: Prometheus + Grafana
- **Logging**: Structured logging to Elasticsearch/Loki
- **Tracing**: Distributed tracing with Jaeger
- **Alerts**: PagerDuty/Slack for critical failures
- **Health Checks**: Endpoint monitoring for all services

## Future Enhancements

1. **Machine Learning Integration**
   - Train ML models to predict burn probability faster
   - Use as surrogate for full physics-based models

2. **Real-time Fire Tracking**
   - Integration with satellite fire detection
   - Update simulations with actual fire progression

3. **Climate Scenario Planning**
   - Run simulations under different climate projections
   - Compare historical vs future fire risk

4. **Multi-user Collaboration**
   - Shared scenarios and results
   - Commenting and annotations

5. **Mobile Application**
   - Field data collection
   - Offline mode for remote areas

## References

- BurnP3+ Documentation: https://burnp3.github.io/BurnP3Plus/
- SyncroSim Framework: https://docs.syncrosim.com/
- Canadian Fire Behavior Prediction System
- Original Burn-P3 (Parisien et al., 2019)
