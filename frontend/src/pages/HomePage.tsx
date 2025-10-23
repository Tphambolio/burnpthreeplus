import { Link } from 'react-router-dom'

export function HomePage() {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold mb-6">Welcome to BurnP3+</h1>

      <div className="prose max-w-none">
        <p className="text-lg mb-4">
          BurnP3+ is a web-based wildfire burn probability modeling system that helps you
          assess fire risk and susceptibility across landscapes using Monte Carlo simulation
          methods.
        </p>

        <h2 className="text-2xl font-semibold mt-8 mb-4">Key Features</h2>
        <ul className="list-disc pl-6 mb-6">
          <li>Four-stage simulation pipeline (Ignitions, Conditions, Fire Growth, Summarization)</li>
          <li>Multiple fire growth models (Cell2Fire, Prometheus, FireSTARR)</li>
          <li>Interactive spatial data visualization</li>
          <li>Burn probability mapping and analysis</li>
          <li>Scenario comparison and batch processing</li>
        </ul>

        <h2 className="text-2xl font-semibold mt-8 mb-4">Get Started</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
          <Link
            to="/scenarios"
            className="p-6 border rounded-lg hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold mb-2">Create Scenario</h3>
            <p className="text-muted-foreground">
              Set up your landscape and simulation parameters
            </p>
          </Link>

          <Link
            to="/simulations"
            className="p-6 border rounded-lg hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold mb-2">Run Simulation</h3>
            <p className="text-muted-foreground">
              Execute fire growth models and generate results
            </p>
          </Link>

          <Link
            to="/scenarios"
            className="p-6 border rounded-lg hover:shadow-lg transition-shadow"
          >
            <h3 className="text-xl font-semibold mb-2">View Results</h3>
            <p className="text-muted-foreground">
              Explore burn probability maps and statistics
            </p>
          </Link>
        </div>
      </div>
    </div>
  )
}
