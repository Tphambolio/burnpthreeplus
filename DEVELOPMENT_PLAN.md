# Development Plan

## Overview

This document outlines a phased approach to building the BurnP3+ web application, from initial setup through production deployment.

## Development Phases

### Phase 0: Foundation (Week 1-2)
**Goal**: Set up development infrastructure and project scaffolding

#### Tasks
- [x] Research and document BurnP3+ architecture
- [x] Define technology stack
- [ ] Create project structure
- [ ] Set up monorepo with proper folder organization
- [ ] Configure Docker development environment
- [ ] Set up GitHub Actions CI/CD pipeline
- [ ] Create initial documentation
- [ ] Configure code quality tools (linting, formatting, type checking)
- [ ] Set up pre-commit hooks

#### Deliverables
- Project repository with basic structure
- Docker Compose for local development
- CI/CD pipeline running tests
- Development guidelines documented

#### Success Criteria
- Developers can clone repo and run `docker-compose up`
- All services start without errors
- CI pipeline passes on main branch

---

### Phase 1: Core Infrastructure (Week 3-4)
**Goal**: Build foundational services and data models

#### Tasks

##### Backend
- [ ] Set up FastAPI application structure
- [ ] Configure PostgreSQL with PostGIS
- [ ] Set up Redis for caching/queuing
- [ ] Create database models using SQLAlchemy
  - User accounts
  - Scenarios
  - Simulation runs
  - Results metadata
- [ ] Implement Alembic migrations
- [ ] Set up Celery task queue
- [ ] Create health check endpoints

##### Frontend
- [ ] Create React + Vite + TypeScript app
- [ ] Set up Tailwind CSS and shadcn/ui
- [ ] Configure routing (React Router)
- [ ] Set up Zustand state management
- [ ] Create basic layout components (header, sidebar, main)
- [ ] Implement authentication UI (login/register)

##### DevOps
- [ ] Configure MinIO for local S3 storage
- [ ] Set up nginx reverse proxy
- [ ] Create production Dockerfiles (multi-stage builds)

#### Deliverables
- Running backend API with documentation
- Basic frontend application
- Database schema in place
- Local object storage working

#### Success Criteria
- API serves OpenAPI docs at /docs
- Frontend loads and shows login page
- Database migrations run successfully
- Health checks return 200 OK

---

### Phase 2: User Management & Scenarios (Week 5-6)
**Goal**: Implement user authentication and scenario management

#### Tasks

##### Backend
- [ ] Implement JWT authentication
  - Registration endpoint
  - Login endpoint
  - Token refresh
  - Password hashing (bcrypt)
- [ ] Create scenario CRUD endpoints
  - POST /api/scenarios
  - GET /api/scenarios
  - GET /api/scenarios/{id}
  - PUT /api/scenarios/{id}
  - DELETE /api/scenarios/{id}
- [ ] Implement authorization (user can only access own scenarios)
- [ ] Add input validation (Pydantic models)
- [ ] Create unit tests for all endpoints

##### Frontend
- [ ] Implement authentication flow
  - Login page
  - Registration page
  - JWT token storage (localStorage)
  - Auto-refresh tokens
  - Protected routes
- [ ] Create scenario management UI
  - Scenario list view
  - Create scenario form
  - Edit scenario form
  - Delete confirmation
- [ ] Add form validation
- [ ] Show loading states and error messages

##### Database
- [ ] Scenario schema:
  ```sql
  scenarios:
    - id (uuid)
    - user_id (fk)
    - name (string)
    - description (text)
    - created_at (timestamp)
    - updated_at (timestamp)
    - config (jsonb)  -- stores all scenario parameters
  ```

#### Deliverables
- Working authentication system
- Scenario CRUD functionality
- User dashboard showing scenarios

#### Success Criteria
- Users can register and login
- Users can create, view, edit, delete scenarios
- Authorization prevents access to others' scenarios
- Tests achieve >80% coverage

---

### Phase 3: Spatial Data Management (Week 7-8)
**Goal**: Handle upload, storage, and visualization of geospatial data

#### Tasks

##### Backend
- [ ] Create spatial data upload endpoint
  - Support GeoTIFF format
  - File size validation
  - Format validation (GDAL)
  - Store in S3/MinIO
- [ ] Generate thumbnail/preview images
- [ ] Create endpoint to retrieve raster metadata
- [ ] Implement COG (Cloud Optimized GeoTIFF) conversion
- [ ] Create endpoint to serve raster tiles

##### Frontend
- [ ] Integrate Leaflet map component
- [ ] Implement file upload UI with drag-and-drop
- [ ] Display uploaded rasters on map
- [ ] Show raster metadata (extent, resolution, CRS)
- [ ] Add basemap selection (OSM, satellite)
- [ ] Create color ramp selector for visualization

##### Processing
- [ ] Implement rasterio-based processing
  - Read GeoTIFF
  - Validate spatial reference
  - Calculate statistics (min, max, mean)
  - Reproject if needed
- [ ] Create thumbnail generation worker

#### Deliverables
- Spatial data upload/download working
- Interactive map showing user data
- Raster visualization with color ramps

#### Success Criteria
- Users can upload GeoTIFF files
- Uploaded data displays correctly on map
- Metadata is accurately extracted
- Large files are handled efficiently

---

### Phase 4: Pipeline Stage 1 - Ignition Sampling (Week 9-10)
**Goal**: Implement the first stage of the fire simulation pipeline

#### Tasks

##### Backend
- [ ] Create ignition sampling algorithm
  - Read ignition probability raster
  - Implement weighted random sampling
  - Generate specified number of ignitions
  - Handle spatial exclusions (water, non-burnable)
- [ ] Create Celery task for ignition sampling
- [ ] Implement progress tracking
- [ ] Store ignition points in PostGIS
- [ ] Create endpoint to retrieve ignition points

##### Frontend
- [ ] Create simulation configuration UI
  - Number of iterations
  - Number of ignitions per iteration
  - Season/temporal settings
- [ ] Add ignition probability raster upload
- [ ] Display sampled ignitions on map
- [ ] Show sampling progress

##### Testing
- [ ] Unit tests for sampling algorithm
- [ ] Validate statistical distribution
- [ ] Test edge cases (no burnable area, etc.)

#### Data Model
```python
class Ignition:
    id: UUID
    simulation_run_id: UUID
    iteration: int
    point: Point  # PostGIS geometry
    timestamp: datetime
    julian_day: int
```

#### Deliverables
- Working ignition sampling
- Visual confirmation on map
- Progress tracking

#### Success Criteria
- Ignitions follow probability distribution
- Sampling completes in reasonable time
- Results are reproducible with same seed

---

### Phase 5: Pipeline Stage 2 - Burning Conditions (Week 11-12)
**Goal**: Sample weather and burning conditions for each ignition

#### Tasks

##### Backend
- [ ] Design weather data model
  - Temperature, wind speed, wind direction
  - Relative humidity
  - Precipitation
  - Fuel moisture codes (FFMC, DMC, DC)
- [ ] Implement weather sampling
  - Option 1: Upload historical weather data
  - Option 2: Use statistical distributions
  - Match conditions to ignition date/location
- [ ] Create Celery task for condition sampling
- [ ] Store conditions with ignitions

##### Frontend
- [ ] Weather data upload interface
- [ ] Weather distribution configuration UI
- [ ] Display weather statistics
- [ ] Show conditions for sample ignitions

##### Scientific
- [ ] Research Canadian Fire Weather Index (FWI) System
- [ ] Implement FWI calculations
  - Fine Fuel Moisture Code (FFMC)
  - Duff Moisture Code (DMC)
  - Drought Code (DC)
  - Initial Spread Index (ISI)
  - Build Up Index (BUI)
  - Fire Weather Index (FWI)

#### Deliverables
- Weather sampling functional
- FWI calculations implemented
- Conditions assigned to ignitions

#### Success Criteria
- Weather values are realistic
- Temporal/spatial correlation maintained
- FWI codes calculated correctly

---

### Phase 6: Pipeline Stage 3 - Fire Growth (Week 13-16)
**Goal**: Integrate fire growth models to simulate fire spread

This is the most complex and computationally intensive stage.

#### Tasks

##### Fire Model Integration
- [ ] Design fire model abstraction layer
- [ ] Implement Cell2Fire integration
  - Set up Cell2Fire environment
  - Create Python wrapper
  - Handle input/output files
  - Parse fire perimeters and metrics
- [ ] Create Docker image with Cell2Fire
- [ ] Implement Celery task for fire growth
  - Parallel execution per fire
  - Resource limits (memory, CPU time)
  - Timeout handling

##### Landscape Data
- [ ] Support fuel type raster upload
- [ ] Support elevation raster (DEM)
- [ ] Validate fuel type codes
- [ ] Create fuel model lookup tables

##### Backend
- [ ] Create endpoint to start fire growth
- [ ] Store fire perimeters (PostGIS)
- [ ] Store behavior metrics:
  - Rate of spread
  - Fire intensity
  - Fuel consumption
  - Flame length
- [ ] Handle failed simulations gracefully

##### Frontend
- [ ] Fire growth configuration UI
  - Fuel type raster upload
  - Elevation data upload
  - Model selection (Cell2Fire, Prometheus)
  - Model parameters
- [ ] Display fire perimeters on map
- [ ] Animate fire growth over time
- [ ] Show fire behavior statistics

#### Performance Considerations
- [ ] Implement spatial partitioning for large landscapes
- [ ] Add queue prioritization
- [ ] Monitor and limit concurrent fire simulations
- [ ] Implement checkpointing for long runs

#### Deliverables
- Cell2Fire model integrated
- Fire perimeters visualized
- Behavior metrics calculated

#### Success Criteria
- Fires grow realistically based on inputs
- Performance is acceptable (<5 min per fire)
- Failed fires don't crash the system
- Results match expected behavior patterns

---

### Phase 7: Pipeline Stage 4 - Summarization (Week 17-18)
**Goal**: Aggregate individual fire results into burn probability maps

#### Tasks

##### Backend
- [ ] Implement burn probability calculation
  - Count burn occurrences per pixel
  - Divide by number of iterations
  - Generate probability raster
- [ ] Calculate summary statistics:
  - Mean fire intensity per cell
  - Mean rate of spread
  - Conditional burn probability
  - Fire size distribution
- [ ] Create Celery task for summarization
- [ ] Store output rasters in S3
- [ ] Store summary statistics in database

##### Frontend
- [ ] Display burn probability map
- [ ] Color ramp for probability (0-1)
- [ ] Interactive legend
- [ ] Summary statistics dashboard:
  - Charts showing fire size distribution
  - Histogram of burn probability values
  - Mean/max intensity maps
- [ ] Download results (GeoTIFF, shapefile)

##### Analysis
- [ ] Implement percentile calculations
- [ ] Calculate exceedance probabilities
- [ ] Generate summary reports (PDF)

#### Deliverables
- Burn probability maps
- Summary statistics
- Downloadable results

#### Success Criteria
- Burn probabilities sum correctly
- Statistics are accurate
- Visualizations are clear and informative
- Results are scientifically defensible

---

### Phase 8: Pipeline Orchestration (Week 19-20)
**Goal**: Connect all stages into a seamless workflow

#### Tasks

##### Backend
- [ ] Create orchestration layer
  - Start pipeline on user trigger
  - Chain stages sequentially
  - Handle stage failures
  - Implement retry logic
- [ ] Real-time progress tracking
  - WebSocket for live updates
  - Progress percentage
  - Stage completion status
  - ETA calculation
- [ ] Email notifications
  - Simulation started
  - Simulation completed
  - Simulation failed

##### Frontend
- [ ] Simulation run page
  - Start simulation button
  - Live progress bar
  - Stage status indicators
  - Cancel simulation option
- [ ] Results explorer
  - Browse completed runs
  - Compare scenarios
  - View historical results

##### Testing
- [ ] End-to-end pipeline test
- [ ] Test failure scenarios
- [ ] Test cancellation
- [ ] Load testing (multiple concurrent runs)

#### Deliverables
- Complete pipeline working end-to-end
- Real-time progress updates
- Robust error handling

#### Success Criteria
- Pipeline completes successfully for test scenario
- Progress updates are accurate
- Failures are handled gracefully
- Users are notified of completion

---

### Phase 9: Advanced Features (Week 21-24)
**Goal**: Add features that enhance usability and analysis

#### Tasks

##### Scenario Comparison
- [ ] Compare burn probability maps from different scenarios
- [ ] Difference maps (A - B)
- [ ] Side-by-side visualization
- [ ] Statistical comparison

##### Batch Processing
- [ ] Run multiple scenarios in sequence
- [ ] Parameter sweeps (vary one parameter)
- [ ] Export batch results

##### Advanced Visualization
- [ ] 3D terrain visualization (Three.js)
- [ ] Fire animation player
- [ ] Time-series charts (seasonal patterns)

##### Export and Reporting
- [ ] Generate PDF reports
- [ ] Export to standard formats (GeoTIFF, KML, Shapefile)
- [ ] Share results via public links

##### Performance Optimization
- [ ] Implement result caching
- [ ] Progressive result loading
- [ ] Optimize raster tile serving
- [ ] Database query optimization

#### Deliverables
- Enhanced analysis tools
- Better visualizations
- Faster performance

#### Success Criteria
- Users can compare scenarios easily
- Exports work in GIS software
- Performance is improved

---

### Phase 10: Prometheus Model Integration (Week 25-26)
**Goal**: Add Prometheus as an alternative fire growth model

#### Tasks

##### Research
- [ ] Obtain Prometheus source code
- [ ] Understand Prometheus API
- [ ] Review Canadian FBP system integration

##### Integration
- [ ] Create Prometheus Docker image
- [ ] Implement Prometheus adapter
- [ ] Handle Prometheus-specific inputs
- [ ] Parse Prometheus outputs

##### Testing
- [ ] Compare results with Cell2Fire
- [ ] Validate against known test cases

#### Deliverables
- Prometheus model working
- Model selection UI

#### Success Criteria
- Users can choose between Cell2Fire and Prometheus
- Results are comparable and realistic

---

### Phase 11: Polish and Documentation (Week 27-28)
**Goal**: Prepare for initial release

#### Tasks

##### Documentation
- [ ] User guide (MkDocs)
  - Getting started tutorial
  - Step-by-step workflow
  - FAQ
  - Troubleshooting
- [ ] API documentation (OpenAPI)
- [ ] Developer guide
  - Setting up development environment
  - Contributing guidelines
  - Architecture overview
- [ ] Scientific documentation
  - Model descriptions
  - Validation studies
  - Limitations and assumptions

##### UI/UX Polish
- [ ] Conduct user testing
- [ ] Improve error messages
- [ ] Add tooltips and help text
- [ ] Keyboard shortcuts
- [ ] Accessibility improvements (ARIA labels)

##### Testing
- [ ] Comprehensive E2E tests (Playwright)
- [ ] Cross-browser testing
- [ ] Mobile responsiveness
- [ ] Load testing (JMeter)

##### Security
- [ ] Security audit
- [ ] Dependency vulnerability scan
- [ ] Penetration testing
- [ ] Rate limiting refinement

#### Deliverables
- Comprehensive documentation
- Polished UI
- Security hardening

#### Success Criteria
- New users can complete workflow without help
- Documentation is clear and complete
- No critical security vulnerabilities

---

### Phase 12: Production Deployment (Week 29-30)
**Goal**: Deploy to production environment

#### Tasks

##### Infrastructure
- [ ] Set up Kubernetes cluster (or cloud equivalent)
- [ ] Configure production database (managed PostgreSQL)
- [ ] Set up Redis cluster
- [ ] Configure S3 bucket with lifecycle policies
- [ ] Set up CDN for frontend assets
- [ ] Configure SSL/TLS certificates

##### Deployment
- [ ] Create Helm charts
- [ ] Set up production environment variables
- [ ] Configure secrets management
- [ ] Deploy backend services
- [ ] Deploy frontend
- [ ] Configure load balancers

##### Monitoring
- [ ] Deploy Prometheus + Grafana
- [ ] Set up alerts (PagerDuty/Slack)
- [ ] Configure log aggregation
- [ ] Set up uptime monitoring
- [ ] Create dashboards

##### Backup and DR
- [ ] Automated database backups
- [ ] S3 bucket versioning
- [ ] Disaster recovery plan
- [ ] Backup restoration testing

##### Launch Preparation
- [ ] Beta user testing
- [ ] Performance tuning
- [ ] Load balancing verification
- [ ] Final security review

#### Deliverables
- Production environment live
- Monitoring and alerting active
- Backups configured

#### Success Criteria
- Application accessible at production URL
- All health checks passing
- Monitoring dashboards show healthy metrics
- Backups tested and working

---

## Beyond Initial Release

### Future Enhancements (Post-Launch)

#### Phase 13: Machine Learning Integration
- Train surrogate models for faster predictions
- Use ML to optimize ignition sampling
- Predict fire behavior patterns

#### Phase 14: Real-time Fire Integration
- Ingest satellite fire detection data
- Update simulations with actual fire progression
- Near-real-time risk assessment

#### Phase 15: Climate Scenarios
- Long-term climate projection integration
- Future fuel type modeling
- Multi-decade risk assessment

#### Phase 16: Collaboration Features
- Multi-user shared scenarios
- Comments and annotations
- Version control for scenarios

#### Phase 17: Mobile Application
- React Native mobile app
- Offline capabilities
- Field data collection

#### Phase 18: FireSTARR Integration
- Add third fire growth model
- Uncertainty quantification
- Ensemble modeling

---

## Development Guidelines

### Code Review Process
1. All code must be in a feature branch
2. Pull request required for merge to main
3. At least one reviewer approval
4. All CI checks must pass
5. Code coverage must not decrease

### Testing Requirements
- Unit tests for all business logic
- Integration tests for API endpoints
- E2E tests for critical user flows
- Minimum 80% code coverage

### Documentation Requirements
- All functions must have docstrings
- Complex algorithms need explanation
- API changes must update OpenAPI spec
- User-facing features need user docs

### Git Workflow
- Branch naming: `feature/description`, `bugfix/description`, `hotfix/description`
- Commit messages: Follow conventional commits
- Squash commits when merging

### Performance Targets
- API response time: <200ms (95th percentile)
- Page load time: <2 seconds
- Time to interactive: <3 seconds
- Simulation start: <10 seconds

### Accessibility Requirements
- WCAG 2.1 Level AA compliance
- Keyboard navigation
- Screen reader support
- Color contrast ratios

---

## Risk Management

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Fire model integration complexity | High | Medium | Start early, allocate extra time, consult experts |
| Scalability issues with large landscapes | High | Medium | Implement spatial partitioning, optimize early |
| Slow simulation performance | High | Low | Use compiled code (C++), parallel processing |
| Data storage costs | Medium | Medium | Implement lifecycle policies, compress data |
| Security vulnerabilities | High | Low | Regular audits, dependency scanning, security review |

### Project Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Scope creep | Medium | High | Strict phase gates, prioritize features |
| Unclear requirements | Medium | Medium | Regular user feedback, iterative development |
| Resource constraints | High | Medium | Realistic timelines, prioritize MVP features |
| Third-party dependency issues | Medium | Low | Pin versions, maintain forks if needed |

---

## Success Metrics

### Development Metrics
- Sprint velocity (story points per week)
- Code coverage percentage
- Number of open bugs
- CI/CD pipeline success rate

### Product Metrics
- Number of registered users
- Number of simulations run
- Average simulation completion time
- User retention rate (30-day)

### Quality Metrics
- API uptime (target: 99.9%)
- Error rate (target: <0.1%)
- Page load time (target: <2s)
- User satisfaction score

---

## Team Roles (If Expanding)

### Current: Solo Development
- All roles handled by primary developer

### Future Team Structure

**Backend Developer**
- API development
- Database design
- Fire model integration

**Frontend Developer**
- React components
- Map visualization
- UI/UX implementation

**DevOps Engineer**
- CI/CD pipelines
- Infrastructure management
- Monitoring and scaling

**Fire Science Expert**
- Model validation
- Scientific accuracy
- Documentation

**UX Designer**
- User research
- Interface design
- Usability testing

---

## Milestones

| Milestone | Date | Deliverable |
|-----------|------|-------------|
| M1: Foundation Complete | Week 2 | Project setup, CI/CD working |
| M2: Core Infrastructure | Week 4 | API + Frontend + Database |
| M3: User Management | Week 6 | Auth + Scenarios |
| M4: Spatial Data | Week 8 | Upload and visualize rasters |
| M5: Ignition Sampling | Week 10 | Stage 1 working |
| M6: Burning Conditions | Week 12 | Stage 2 working |
| M7: Fire Growth | Week 16 | Stage 3 working (Cell2Fire) |
| M8: Summarization | Week 18 | Stage 4 working |
| M9: Full Pipeline | Week 20 | End-to-end simulation |
| M10: Advanced Features | Week 24 | Comparison, batch, export |
| M11: Prometheus Model | Week 26 | Second model integrated |
| M12: Polish | Week 28 | Documentation, testing |
| M13: Production Launch | Week 30 | Live production system |

---

## Getting Started (Immediate Next Steps)

1. **Review and approve architecture** (this document)
2. **Set up project structure** (Phase 0)
3. **Create Docker Compose environment**
4. **Initialize FastAPI backend**
5. **Initialize React frontend**
6. **Set up GitHub Actions**
7. **Begin Phase 1 development**

---

## Appendix A: Estimated Effort

### Total Estimated Time
- **Phase 0**: 2 weeks
- **Phases 1-12**: 28 weeks
- **Total**: ~7-8 months for MVP

### Assumptions
- Single developer working full-time
- Some fire science expertise available for consultation
- Access to test data and example scenarios
- Familiarity with chosen technologies

### Acceleration Opportunities
- Parallel frontend/backend development (with team)
- Reuse existing fire model implementations
- Use managed cloud services (reduce DevOps work)
- Limit initial scope (start with Cell2Fire only)

---

## Appendix B: Minimum Viable Product (MVP)

If timeline needs to be compressed, here's the MVP scope:

**Must Have**:
- User authentication
- Single scenario management
- Upload landscape data (fuel, elevation)
- Upload ignition probability
- Run simulation with Cell2Fire only
- View burn probability map
- Download results

**Can Wait**:
- Scenario comparison
- Batch processing
- Prometheus model
- Advanced visualizations
- PDF reports
- Real-time progress (use polling instead)

**MVP Timeline**: ~4 months

---

*This development plan is a living document and will be updated as the project progresses.*
