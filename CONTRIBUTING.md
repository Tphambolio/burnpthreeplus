# Contributing to BurnP3+ Web Application

Thank you for your interest in contributing to the BurnP3+ Web Application! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/yourusername/burnpthreeplus.git
   cd burnpthreeplus
   ```
3. **Set up the development environment**:
   ```bash
   docker-compose up -d
   ```
4. **Install pre-commit hooks**:
   ```bash
   pip install pre-commit
   pre-commit install
   ```

## Development Workflow

### Creating a Feature

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards

3. **Test your changes**:
   ```bash
   # Backend tests
   docker-compose exec backend poetry run pytest

   # Frontend tests (when available)
   docker-compose exec frontend pnpm test

   # Run all quality checks
   pre-commit run --all-files
   ```

4. **Commit your changes** using conventional commits:
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   ```

### Conventional Commits

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add ignition sampling algorithm
fix: correct burn probability calculation
docs: update API documentation
test: add tests for fire growth model
```

### Submitting a Pull Request

1. **Push your branch** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a pull request** on GitHub:
   - Provide a clear title and description
   - Reference any related issues
   - Ensure all CI checks pass

3. **Address review feedback**:
   - Make requested changes
   - Push additional commits to your branch
   - Request re-review when ready

4. **Merge**:
   - Maintainers will merge when approved
   - Your branch will be deleted after merge

## Code Style Guidelines

### Python (Backend)

- **Formatter**: Black (line length 100)
- **Import Sorting**: isort (Black-compatible profile)
- **Type Hints**: Required for all functions
- **Docstrings**: Google style for all public functions/classes

Example:
```python
def calculate_burn_probability(fires: List[Fire], landscape: Landscape) -> np.ndarray:
    """Calculate burn probability from fire simulations.

    Args:
        fires: List of simulated fire objects
        landscape: Landscape configuration

    Returns:
        Array of burn probabilities for each cell

    Raises:
        ValueError: If fires list is empty
    """
    if not fires:
        raise ValueError("Fires list cannot be empty")

    # Implementation here
    pass
```

### TypeScript/React (Frontend)

- **Formatter**: Prettier
- **Linter**: ESLint with TypeScript rules
- **Style**: Functional components with hooks
- **Props**: TypeScript interfaces for all components

Example:
```typescript
interface MapViewerProps {
  rasterUrl: string;
  extent: BoundingBox;
  onFeatureClick?: (feature: GeoJSON.Feature) => void;
}

export function MapViewer({ rasterUrl, extent, onFeatureClick }: MapViewerProps) {
  // Implementation here
}
```

## Testing Requirements

### Backend Tests

- **Unit tests** for all business logic
- **Integration tests** for API endpoints
- **Minimum coverage**: 80%

```python
# tests/test_ignition_sampling.py
import pytest
from app.services.ignition_sampling import sample_ignitions

def test_sample_ignitions_valid_input():
    """Test ignition sampling with valid inputs."""
    result = sample_ignitions(
        probability_raster=mock_raster,
        num_ignitions=100,
        seed=42
    )
    assert len(result) == 100
    assert all(isinstance(point, Point) for point in result)
```

### Frontend Tests

- **Component tests** for UI components
- **Integration tests** for user flows
- **E2E tests** for critical paths (when available)

## Documentation

### Code Documentation

- **Python**: Docstrings for all public functions, classes, modules
- **TypeScript**: JSDoc comments for complex functions
- **README updates**: For new features that affect usage

### API Documentation

- **OpenAPI**: Automatically generated from FastAPI
- **Examples**: Include request/response examples
- **Descriptions**: Clear descriptions for all endpoints

### User Documentation

- **Guides**: Step-by-step tutorials in `/docs`
- **Screenshots**: Include for UI features
- **Videos**: Optional but helpful for complex workflows

## Project Structure

When adding new code, place it in the appropriate directory:

```
backend/app/
├── api/endpoints/     # API route handlers
├── core/              # Core configuration
├── db/                # Database setup
├── models/            # SQLAlchemy ORM models
├── schemas/           # Pydantic schemas
├── services/          # Business logic
├── tasks/             # Celery tasks
└── tests/             # Tests

frontend/src/
├── components/        # Reusable React components
├── pages/             # Page components
├── hooks/             # Custom React hooks
├── services/          # API client services
├── store/             # State management
├── types/             # TypeScript types
└── utils/             # Utility functions
```

## Performance Guidelines

### Backend

- Use **async/await** for I/O operations
- **Batch database queries** when possible
- **Cache** frequently accessed data in Redis
- **Profile** before optimizing
- Use **database indexes** for frequently queried fields

### Frontend

- **Lazy load** components and routes
- **Memoize** expensive calculations
- **Virtualize** long lists
- **Optimize images** and rasters
- Use **Web Workers** for heavy processing

## Security Guidelines

- **Never commit secrets** (use environment variables)
- **Validate all inputs** on backend
- **Sanitize user inputs** to prevent XSS
- **Use parameterized queries** to prevent SQL injection
- **Implement rate limiting** on public endpoints
- **Follow OWASP** best practices

## Database Migrations

When modifying database models:

1. **Create migration**:
   ```bash
   docker-compose exec backend alembic revision --autogenerate -m "description"
   ```

2. **Review migration** file in `backend/alembic/versions/`

3. **Test migration**:
   ```bash
   docker-compose exec backend alembic upgrade head
   docker-compose exec backend alembic downgrade -1
   docker-compose exec backend alembic upgrade head
   ```

4. **Include migration** in your PR

## Reporting Issues

### Bug Reports

Include:
- **Description**: Clear description of the bug
- **Steps to reproduce**: Detailed steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**: OS, browser, versions
- **Screenshots**: If applicable
- **Logs**: Relevant error messages

### Feature Requests

Include:
- **Problem**: What problem does this solve?
- **Solution**: Proposed solution
- **Alternatives**: Alternative solutions considered
- **Additional context**: Screenshots, examples

## Code Review Process

### For Reviewers

- Be **constructive** and **respectful**
- Focus on **code quality**, **correctness**, **performance**
- Suggest **improvements** with explanations
- Approve when changes meet standards

### For Authors

- Be **open** to feedback
- **Explain** your design decisions
- **Ask questions** if feedback is unclear
- **Iterate** based on feedback

## Community Guidelines

- Be **respectful** and **inclusive**
- **Help** others in discussions
- **Share knowledge** and **learn** from others
- Follow our **Code of Conduct** (to be added)

## Getting Help

- **Documentation**: Check docs first
- **Issues**: Search existing issues
- **Discussions**: Ask questions in GitHub Discussions
- **Discord**: Join our Discord server (to be added)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Recognition

Contributors will be:
- Listed in `CONTRIBUTORS.md`
- Mentioned in release notes
- Credited in documentation (for major contributions)

## Questions?

If you have questions about contributing, please:
1. Check this guide
2. Search existing issues/discussions
3. Ask in GitHub Discussions
4. Contact maintainers

Thank you for contributing to BurnP3+!
