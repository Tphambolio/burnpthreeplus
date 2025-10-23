import { useParams } from 'react-router-dom'

export function ResultsPage() {
  const { id } = useParams()

  return (
    <div>
      <h1 className="text-3xl font-bold mb-6">Results</h1>
      <p className="text-muted-foreground mb-4">
        View burn probability maps, fire perimeters, and analysis results.
      </p>
      {id && (
        <p className="text-sm text-muted-foreground">Viewing results for simulation: {id}</p>
      )}
      <div className="mt-8 p-8 border rounded-lg text-center text-muted-foreground">
        <p>Results visualization coming soon...</p>
      </div>
    </div>
  )
}
