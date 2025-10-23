# BurnP3+ Knowledge Base

## What is BurnP3+?

**BurnP3+** (Burn Probability, Prediction, and Planning) is an open-source wildfire burn probability modeling system developed in collaboration with the Canadian Forest Service. It extends the original Burn-P3 software with improved scalability, cross-platform compatibility, and modular architecture.

### Key Improvements Over Burn-P3:
- ✅ Scalability to larger landscapes and more scenarios
- ✅ Cross-platform compatibility (Windows & Linux)
- ✅ Multiple interface support (SyncroSim Studio, CLI, R, Python)
- ✅ Modular architecture with pluggable fire growth models
- ✅ Implemented as a SyncroSim Package

---

## Core Modeling Approach

### Monte Carlo Simulation
BurnP3+ uses a **Monte Carlo simulation approach** that combines:
1. **Stochastic components**: Random draws of ignition locations, weather conditions, and burning conditions
2. **Deterministic components**: Fire growth models that simulate fire spread based on inputs

### How It Works
- Each **iteration** represents one simulated fire season
- Typical runs use **tens of thousands of iterations**
- Results are aggregated to produce burn probability maps
- The more iterations, the more statistically robust the probability estimates

---

## Four-Stage Workflow (Exact from Official Docs)

### Stage 1: Sample Ignitions
**Purpose**: Sample the number and locations of ignitions for each simulated burn season (iteration)

**Configuration**:
- **Ignition Count**: Number of fires to ignite per iteration (e.g., 1 for quickstart, realistic values vary)
- **Ignition Grid** (optional): Raster defining spatial ignition probabilities
- Can stratify by Fire Zone

**Output**: Set of ignition points (location + timing) for each iteration

### Stage 2: Sample Burning Conditions
**Purpose**: Sample the burning conditions for each ignition, which depend on when and where the ignitions occurred

**Configuration**:
- **Spread Event Days**: Number of days uncontrolled fires are actively burning and spreading in a season
- **Daily Burning Hours**: Number of hours fires are actively burning per day
- **Daily Weather**: Daily weather data table with required columns:
  - Temperature (°C)
  - Relative Humidity (%)
  - Wind Speed (km/h)
  - Wind Direction (degrees)
  - Precipitation (mm)
  - Fine Fuel Moisture Code (FFMC)
  - Duff Moisture Code (DMC)
  - Drought Code (DC)
  - Initial Spread Index (ISI)
  - Buildup Index (BUI)
  - Fire Weather Index (FWI)

**Stratification**:
- Can vary by Weather Zone (optional raster)
- Can vary by Season

### Stage 3: Grow Fires
**Purpose**: Simulate each fire deterministically using a fire growth model

**Available Models**:
1. **Cell2Fire** (BurnP3+Cell2Fire package)
   - Raster-based cellular automata
   - Fast: up to 30x faster than Prometheus
   - F1-score: 0.83 on Dogrib Fire test
   - Linear runtime scaling

2. **Prometheus** (BurnP3+Prometheus package)
   - Vector-based simulation
   - Very high accuracy for fine-scale work
   - More memory intensive
   - Exponential runtime scaling
   - Requires Prometheus 2021.12.03 installation

3. **FireSTARR** (BurnP3+FireSTARR package)
   - Newer integration
   - Details TBD

**Inputs**:
- Fuel grid (raster with fuel type IDs)
- Elevation grid (optional but recommended)
- Fire Zone (optional stratification)
- Fuel type to growth model crosswalk (e.g., "Boreal Spruce" → C2)
- Sampled burning conditions from Stage 2

**Fire Growth Model Options** (all optional, defaults used if blank):
- Custom Cell2Fire parameters
- Fire suppression rules
- Advanced behavior modifications

### Stage 4: Summarize Burn Probability
**Purpose**: Summarize the outputs of the fire growth model to calculate burn probability and other burn metrics

**Calculations**:
- **Burn Probability**: (Number of times cell burned) / (Total iterations)
- **Burn Count**: Total times each cell burned
- **Area Burned by Fuel Type**: Tabular summary
- **Fire Statistics**: Per-fire metrics

**Output Options**:
- **Tabular**: Fire statistics, area burned by fuel type (Yes/No)
- **Spatial Maps**:
  - Burn Probability (raster)
  - Burn Count (raster)
  - Seasonal stratified maps (Yes/No)
- **Burn Perimeters**: Fire perimeter polygons (Yes/No, only available for some models)

**Note**: If all spatial output rows are blank, BurnP3+ defaults to generating ALL spatial outputs

---

## Required Inputs

### 1. Fuel Data (Raster)
- **Fuel types** based on Canadian Forest Service Fuel Codes:
  - C-1 to C-7: Conifer fuel types
  - D-1, D-2: Deciduous
  - M-1, M-2, M-3, M-4: Mixed wood
  - S-1, S-2, S-3: Slash
  - O-1a, O-1b: Open/grass
- **Fuel characteristics**:
  - Fuel load (kg/m²)
  - Crown base height
  - Crown fuel load
  - Percent conifer/hardwood

### 2. Topography Data (Raster)
- **Elevation** (meters)
- **Slope** (degrees or percent)
- **Aspect** (degrees, 0-360)

### 3. Weather Data
- **Temperature** (°C)
- **Relative Humidity** (%)
- **Wind Speed** (km/h)
- **Wind Direction** (degrees)
- **Precipitation** (mm)

### 4. Fire Weather Index (FWI) Components
- **FFMC** - Fine Fuel Moisture Code (0-101)
- **DMC** - Duff Moisture Code (0-∞)
- **DC** - Drought Code (0-∞)
- **ISI** - Initial Spread Index (0-∞)
- **BUI** - Buildup Index (0-∞)
- **FWI** - Fire Weather Index (0-∞)

### 5. Ignition Patterns
- Spatial distribution of potential ignitions
- Temporal patterns (seasonality)
- Ignition probabilities per cell

---

## Fire Growth Models

### Cell2Fire (Recommended for BurnP3+)
- **Type**: Cellular automata, raster-based
- **Performance**: Up to 30x faster than Prometheus
- **Accuracy**: >90% accuracy, F1-score of 0.83 vs 0.74 for Prometheus
- **Scalability**: Linear runtime scaling (vs exponential for Prometheus)
- **Fire Spread Mechanism**:
  - Uses head ROS (Rate of Spread)
  - Back ROS
  - Flank ROS
  - Based on Canadian FBP System

### Prometheus
- **Type**: Vector-based
- **Accuracy**: Very high for fine-scale simulations
- **Performance**: More computationally demanding
- **Use Case**: When precision is more important than speed

### FireSTARR
- **Type**: Newer model
- **Status**: Recently integrated into BurnP3+
- **Details**: Limited public documentation at this time

---

## Outputs

### Raster Outputs
1. **Burn Probability** (0-1 or 0-100%)
   - Likelihood each cell will burn

2. **Burn Count**
   - Number of times each cell burned across all iterations

3. **Relative Likelihood of Burning**
   - Normalized burn probability

### Fire Behavior Outputs
1. **Rate of Spread (ROS)** - meters/minute
2. **Fire Intensity (FI)** - kW/m
3. **Fuel Consumption** - kg/m²
4. **Crown Fraction Burned** - proportion
5. **Fire Type** - surface, passive crown, active crown

### Vector Outputs
1. **Simulated Fire Perimeters** - polygon shapefiles for each fire
2. **Fire Statistics** - area burned, duration, spread distance

---

## Technical Architecture

### SyncroSim Integration
- BurnP3+ is a **SyncroSim Package**
- Requires SyncroSim v3.0.9+
- Uses SyncroSim's scenario-based modeling framework
- Leverages SyncroSim's data management and parallel processing

### Data Storage
- **ST-Sim** spatiotemporal database structure
- **Raster data**: GeoTIFF format
- **Vector data**: Shapefiles
- **Tabular data**: CSV, database tables

### Computational Requirements
- **Memory**: Proportional to landscape size and resolution
- **CPU**: Benefits from multi-core processors (parallel iterations)
- **Storage**: Large for output perimeters (thousands of fires)

---

## Critical Analysis: What We Built vs What's Needed

### What We Built So Far ✅

**Infrastructure (100% Complete)**:
- ✅ FastAPI backend with REST API
- ✅ PostgreSQL + PostGIS database
- ✅ User authentication (JWT)
- ✅ Scenario management (CRUD operations)
- ✅ Celery + Redis for background jobs
- ✅ Docker containerization
- ✅ Railway deployment (live backend)
- ✅ React + TypeScript frontend
- ✅ Leaflet mapping library
- ✅ CI/CD pipelines (temporarily disabled)

**Data Models (Partially Complete - 60%)**:
- ✅ User model
- ✅ Scenario model (with JSON config field)
- ✅ SimulationRun model (tracking iterations)
- ✅ Ignition model (PostGIS point geometry)
- ⚠️ Missing: Fuel type crosswalk table
- ⚠️ Missing: Weather data table
- ⚠️ Missing: Raster file metadata table
- ⚠️ Missing: Results storage schema

### Critical Gaps ⛔

1. **No Fire Growth Model Integration**
   - ❌ Cell2Fire not installed
   - ❌ No Python bindings or CLI wrapper
   - ❌ No input file generators for Cell2Fire format
   - ❌ No output parsers for Cell2Fire results

   **Impact**: Can't actually run fire simulations

2. **No Raster Data Management**
   - ❌ No file upload endpoints
   - ❌ No raster validation (format, CRS, resolution checks)
   - ❌ No storage strategy (S3/R2 integration)
   - ❌ No raster processing (reprojection, resampling, cropping)

   **Impact**: Can't accept fuel grids or elevation data

3. **No Weather Data System**
   - ❌ No daily weather data table
   - ❌ No FWI calculator
   - ❌ No weather API integration
   - ❌ No weather scenario management

   **Impact**: Can't define burning conditions

4. **No Simulation Pipeline**
   - ❌ Stage 1 (Sample Ignitions) not implemented
   - ❌ Stage 2 (Sample Burning Conditions) not implemented
   - ❌ Stage 3 (Grow Fires) not implemented
   - ❌ Stage 4 (Summarize Results) not implemented

   **Impact**: Current backend is just a skeleton

5. **No Results Processing**
   - ❌ No burn probability calculation
   - ❌ No raster output storage
   - ❌ No results visualization on frontend
   - ❌ No export functionality

   **Impact**: Even if simulations ran, couldn't show results

### What This Means 🎯

**Current Status**: We have a **complete authentication and scenario management system**, but **zero actual wildfire modeling capability**.

**The Good News**:
- Strong foundation with proper architecture
- Database ready for expansion
- Background job system in place
- Frontend mapping ready

**The Reality**:
- We're at ~15% of a true BurnP3+ web alternative
- Most of the actual modeling work is still ahead
- Need significant backend additions
- Frontend needs raster visualization components

### Realistic Scope Assessment

**Option 1: Full BurnP3+ Web Alternative (Months of Work)**
- Install and integrate Cell2Fire
- Build complete 4-stage pipeline
- Implement all data management
- Support tens of thousands of iterations
- Handle large raster outputs
- Comparable to SyncroSim+BurnP3+ desktop version

**Option 2: Simplified Demo/MVP (2-4 Weeks)**
- Single fire simulation (not Monte Carlo)
- Pre-loaded test landscape
- Simplified weather inputs (static FWI values)
- One fire growth run with Cell2Fire
- Basic burn map visualization
- Proof of concept only

**Option 3: Scenario Manager Only (Current)**
- Keep what we have: user auth + scenario database
- No actual fire modeling
- Could integrate with external BurnP3+ via API
- Portal to manage SyncroSim projects remotely

### Recommendation

Given that we're building "a BurnP3+ app", we should decide:

1. **Full Implementation**: Commit to months of development
   - Need Cell2Fire expertise
   - Significant raster processing work
   - Large-scale computing infrastructure
   - This is a major project

2. **Strategic Pivot**: Build a "BurnP3+ Companion"
   - Scenario management and visualization
   - Import results from desktop BurnP3+
   - Share and compare scenarios online
   - Collaborate on fire modeling projects
   - Much more achievable

3. **Phased Approach**: Start with MVP, expand based on feedback
   - Week 1-2: Single fire simulation working
   - Week 3-4: Basic Monte Carlo (100 iterations)
   - Month 2: Full pipeline with real landscapes
   - Month 3+: Advanced features

**What should we prioritize?**

---

## Implementation Strategy for Our Web App

### Phase 1: Core Simulation Engine (Current)
- ✅ User authentication and scenario management
- ✅ Database for storing scenarios and results
- ⚠️ Need to integrate Cell2Fire executable
- ⚠️ Need raster data upload and validation
- ⚠️ Need FWI weather data management

### Phase 2: Fire Growth Integration (Next Priority)
1. **Install Cell2Fire**
   - Python package or compiled binary
   - Docker container with Cell2Fire pre-installed

2. **Create Input Generators**
   - Convert uploaded rasters to Cell2Fire format
   - Generate weather scenario files
   - Create ignition grid files

3. **Simulation Orchestration**
   - Celery worker calls Cell2Fire for each iteration
   - Progress tracking (iteration X of N)
   - Result aggregation

### Phase 3: Output Processing
1. **Parse Cell2Fire outputs**
2. **Calculate burn probability** (burn count / total iterations)
3. **Generate summary statistics**
4. **Create visualization layers** for web mapping

### Phase 4: Advanced Features
1. **Multiple weather scenarios**
2. **Custom ignition patterns**
3. **Fire size distribution analysis**
4. **Cost-benefit analysis tools**

---

## Key Technical Dependencies We Need

### Python Packages
```python
# Current (already have)
fastapi
sqlalchemy
geoalchemy2
celery
redis

# Need to add
rasterio          # Raster I/O and processing
fiona             # Vector data I/O
shapely           # Geometric operations
numpy             # Array operations
scipy             # Scientific computing
pyproj            # Coordinate transformations
```

### External Software
```bash
# Required
GDAL              # Geospatial data processing
Cell2Fire         # Fire growth model

# Optional
Prometheus        # Alternative fire growth model
FireSTARR         # Alternative fire growth model
```

### Frontend Additions Needed
```javascript
// Already have
leaflet           # Mapping
react-leaflet     # React integration

// Need to add
geotiff.js        # Client-side raster rendering
leaflet-geotiff   # Leaflet raster layer support
chroma-js         # Color scales for burn probability
```

---

## Critical Success Factors

### For MVP (Minimum Viable Product)
1. ✅ User can upload fuel and topography rasters
2. ✅ User can define weather conditions (FWI values)
3. ✅ User can configure simulation parameters (# iterations)
4. ✅ System runs Cell2Fire in background
5. ✅ User can view burn probability map
6. ✅ User can download results

### For Production
1. Handle large landscapes (millions of cells)
2. Support distributed computing (multiple workers)
3. Efficient raster storage (COG format)
4. Progressive result updates during simulation
5. Comparison tools between scenarios
6. Integration with weather APIs for real-time data

---

## Next Steps for Our Project

### Immediate (Before Deployment)
1. ✅ Deploy frontend to Vercel
2. ✅ Test basic authentication flow
3. ✅ Verify database connectivity

### Short-term (Week 1-2)
1. Install Cell2Fire in Docker container
2. Create raster upload endpoint
3. Test single fire simulation
4. Display results on map

### Medium-term (Week 3-4)
1. Implement full Monte Carlo loop
2. Add progress tracking
3. Calculate burn probability from iterations
4. Add result export functionality

### Long-term (Month 2+)
1. Optimize for large landscapes
2. Add Prometheus/FireSTARR support
3. Implement advanced analysis tools
4. User documentation and tutorials

---

## Questions to Consider

1. **Scale**: Start with small test landscapes or support full-scale from day 1?
2. **Compute**: Run simulations on Railway, or integrate AWS Lambda/Batch?
3. **Storage**: Where to store large raster outputs? (S3, Cloudflare R2?)
4. **Cell2Fire**: Use Python bindings or call CLI executable?
5. **Real-time vs Batch**: Show live progress or email when complete?

---

## Resources

- **BurnP3+ Documentation**: https://burnp3.github.io/BurnP3Plus/
- **Cell2Fire Paper**: https://www.frontiersin.org/articles/10.3389/ffgc.2021.692706/full
- **Canadian FBP System**: https://www.canadawildfire.org/
- **ApexRMS (Developers)**: https://apexrms.com/burnp3plus/
- **SyncroSim**: https://syncrosim.com/

---

## Conclusion

BurnP3+ is a sophisticated wildfire simulation system that combines:
- Statistical sampling (Monte Carlo)
- Physical fire behavior models (FBP System)
- Geospatial analysis (raster processing)
- High-performance computing (thousands of iterations)

Our web application should **not reinvent** the fire growth models, but rather:
1. Provide an accessible web interface
2. Manage input data and scenarios
3. Orchestrate the simulation engine (Cell2Fire)
4. Visualize and analyze results
5. Enable scenario comparison and planning

We're building a **cloud-native, web-based alternative** to the desktop SyncroSim+BurnP3+ combination, making wildfire risk modeling more accessible to researchers and land managers worldwide.
