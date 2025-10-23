import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { Layout } from './components/Layout'
import { HomePage } from './pages/HomePage'
import { ScenariosPage } from './pages/ScenariosPage'
import { SimulationsPage } from './pages/SimulationsPage'
import { ResultsPage } from './pages/ResultsPage'

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/scenarios" element={<ScenariosPage />} />
          <Route path="/simulations" element={<SimulationsPage />} />
          <Route path="/results/:id" element={<ResultsPage />} />
        </Routes>
      </Layout>
    </Router>
  )
}

export default App
