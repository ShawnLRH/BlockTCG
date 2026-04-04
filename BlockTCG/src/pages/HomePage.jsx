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
            <Link to="/open-pack" className="ghost-btn">
              Open a Pack
            </Link>
            <Link to="/marketplace" className="ghost-btn hero-link-btn">
              Browse Marketplace
            </Link>
          </div>
        </section>

        {/* featured cards using the same placeholder style as the marketplace */}
        <section className="cards-row" aria-label="Featured cards">
          {[
            { id: 'DRGN-001', name: 'Card 1', rarity: 'Legendary' },
            { id: 'KNGT-014', name: 'Card 2', rarity: 'Epic'      },
            { id: 'ARCN-027', name: 'Card 3', rarity: 'Rare'      },
            { id: 'BSTN-041', name: 'Card 4', rarity: 'Uncommon'  },
            { id: 'AETH-066', name: 'Card 5', rarity: 'Rare'      },
          ].map((card) => (
            <article className="card-tile" key={card.id}>
              <div className="card-tile-thumb">{card.name}</div>
              <div className="card-tile-info">
                <p className={`rarity-badge rarity-badge--${card.rarity.toLowerCase()}`}>
                  {card.rarity}
                </p>
                <p className="card-tile-name">{card.name}</p>
                <p className="card-tile-id">{card.id}</p>
              </div>
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