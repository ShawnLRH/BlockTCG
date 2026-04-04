import './App.css'
import { Link, NavLink, Route, Routes } from 'react-router-dom'
import HomePage from './pages/HomePage'
import MarketplacePage from './pages/MarketplacePage'
import CollectionPage from './pages/CollectionPage'
import PackOpeningPage from './pages/PackOpeningPage'

function App() {
  return (
    <div className="page-shell">
      {/* nav bar stays fixed at the top across all pages */}
      <header className="top-nav">
        {/* clicking the logo always takes you home */}
        <Link to="/" className="brand">
          BlockTCG
        </Link>

        {/* NavLink automatically adds an "active" class to whichever page you're on */}
        <nav aria-label="Primary" className="nav-links">
          <NavLink to="/marketplace">Marketplace</NavLink>
          <NavLink to="/collection">My Collection</NavLink>
          <NavLink to="/open-pack">Open a Pack</NavLink>
        </nav>

        {/* no functionality yet — will hook up to MetaMask later */}
        <button type="button" className="wallet-btn">
          Connect Wallet
        </button>
      </header>

      {/* only one of these renders at a time depending on the URL */}
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/marketplace" element={<MarketplacePage />} />
        <Route path="/collection" element={<CollectionPage />} />
        <Route path="/open-pack" element={<PackOpeningPage />} />
      </Routes>
    </div>
  )
}

export default App