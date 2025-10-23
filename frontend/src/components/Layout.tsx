import { Link } from 'react-router-dom'
import { ReactNode } from 'react'

interface LayoutProps {
  children: ReactNode
}

export function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="bg-primary text-primary-foreground shadow-md">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Link to="/" className="text-2xl font-bold">
              BurnP3+
            </Link>
            <nav className="flex gap-6">
              <Link to="/" className="hover:underline">
                Home
              </Link>
              <Link to="/scenarios" className="hover:underline">
                Scenarios
              </Link>
              <Link to="/simulations" className="hover:underline">
                Simulations
              </Link>
            </nav>
          </div>
        </div>
      </header>
      <main className="flex-1 container mx-auto px-4 py-8">{children}</main>
      <footer className="bg-muted text-muted-foreground py-4">
        <div className="container mx-auto px-4 text-center">
          <p>BurnP3+ Web Application - Wildfire Burn Probability Modeling</p>
          <p className="text-sm mt-2">Version 0.1.0</p>
        </div>
      </footer>
    </div>
  )
}
