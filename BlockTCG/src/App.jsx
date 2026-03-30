import './App.css'
import { Link, NavLink, Route, Routes } from 'react-router-dom'
import HomePage from './pages/HomePage'
import MarketplacePage from './pages/MarketplacePage'

function App() {
  return (
    <div className="page-shell">
      <header className="top-nav">
        <Link to="/" className="brand">
          BlockTCG
        </Link>
        <nav aria-label="Primary" className="nav-links">
          <NavLink to="/marketplace">Marketplace</NavLink>
          <a href="#">My Collection</a>
          <a href="#">How It Works</a>
        </nav>
        <button type="button" className="wallet-btn">
          Connect Wallet
        </button>
      </header>

      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/marketplace" element={<MarketplacePage />} />
      </Routes>
    </div>
  )
}

export default App
