import { Link } from 'react-router-dom'

function HomePage() {
  return (
    <>
      <main>
        <section className="hero-section">
          <p className="chain-pill">Powered by Ethereum</p>
          <h1>
            Collect. Trade. <span>Own.</span>
          </h1>
          <p className="hero-copy">
            Open mystery packs and receive verifiably rare digital cards. Every
            card is on-chain authentic, scarce, and truly yours.
          </p>
          <div className="hero-cta">
            <button type="button" className="ghost-btn">
              Open a Pack
            </button>
            <Link to="/marketplace" className="ghost-btn hero-link-btn">
              Browse Marketplace
            </Link>
          </div>
        </section>

        <section className="cards-row" aria-label="Featured cards">
          {Array.from({ length: 5 }).map((_, i) => (
            <article className="card-tile" key={i}>
              <p>Pokemon</p>
            </article>
          ))}
        </section>
      </main>

      <section className="stats-strip" aria-label="Platform stats">
        <article>
          <h2>1,240</h2>
          <p>Packs opened</p>
        </article>
        <article>
          <h2>18</h2>
          <p>Unique cards</p>
        </article>
        <article>
          <h2>340</h2>
          <p>Active traders</p>
        </article>
        <article>
          <h2>100%</h2>
          <p>On-chain verified</p>
        </article>
      </section>
    </>
  )
}

export default HomePage
