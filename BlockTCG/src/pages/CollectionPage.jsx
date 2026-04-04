import { Link } from 'react-router-dom'

// placeholder collection — will be replaced with real wallet data once the contract is connected
const MY_CARDS = [
  { id: 'DRGN-001', name: 'Card 1',  rarity: 'Legendary', copies: 1 },
  { id: 'KNGT-014', name: 'Card 2',  rarity: 'Epic',      copies: 2 },
  { id: 'ARCN-027', name: 'Card 3',  rarity: 'Rare',      copies: 1 },
  { id: 'BSTN-041', name: 'Card 4',  rarity: 'Uncommon',  copies: 3 },
  { id: 'ELMN-052', name: 'Card 5',  rarity: 'Epic',      copies: 1 },
  { id: 'AETH-066', name: 'Card 6',  rarity: 'Rare',      copies: 2 },
  { id: 'SHAD-073', name: 'Card 7',  rarity: 'Uncommon',  copies: 2 },
  { id: 'FRST-088', name: 'Card 8',  rarity: 'Common',    copies: 4 },
  { id: 'STRM-095', name: 'Card 9',  rarity: 'Common',    copies: 3 },
  { id: 'VLKN-102', name: 'Card 10', rarity: 'Rare',      copies: 1 },
]

function CollectionPage() {
  return (
    <main className="collection-main">
      {/* heading row — mirrors the marketplace layout */}
      <section className="collection-heading" aria-label="My collection overview">
        <div>
          <h1>My Collection</h1>
          <p>
            Cards you own, verified on-chain. Each card shows its rarity and
            the number of copies in your wallet.
          </p>
        </div>
      </section>

      {/* quick summary stats — same style as the home page stats strip */}
      <section className="collection-stats" aria-label="Collection summary">
        <article>
          {/* just counts how many entries are in MY_CARDS */}
          <h2>{MY_CARDS.length}</h2>
          <p>Unique cards</p>
        </article>
        <article>
          {/* adds up all the copies across every card */}
          <h2>{MY_CARDS.reduce((acc, c) => acc + c.copies, 0)}</h2>
          <p>Total owned</p>
        </article>
        <article>
          {/* counts cards that are Epic or Legendary */}
          <h2>{MY_CARDS.filter((c) => c.rarity === 'Legendary' || c.rarity === 'Epic').length}</h2>
          <p>Epic &amp; above</p>
        </article>
        <article>
          {/* hardcoded for now — will come from on-chain data later */}
          <h2>3</h2>
          <p>Packs opened</p>
        </article>
      </section>

      {/* the actual card grid — same 3-column layout as the marketplace */}
      <section className="collection-grid" aria-label="Card collection">
        {MY_CARDS.map((card) => (
          <article className="collection-card" key={card.id}>
            {/* diagonal stripe placeholder — same as marketplace thumbnails */}
            <div
              className="collection-thumb"
              role="img"
              aria-label="Card art placeholder"
            >
              <p>{card.name}</p>
            </div>

            <div className="collection-card-content">
              {/* colour-coded rarity pill */}
              <p className={`rarity-badge rarity-badge--${card.rarity.toLowerCase()}`}>
                {card.rarity}
              </p>
              <h2>{card.name}</h2>
              <p>Card ID: {card.id}</p>
              {/* how many of this card you're holding */}
              <p className="collection-copies">×{card.copies} owned</p>
            </div>

            {/* takes you to the marketplace to list this card for sale */}
            <div className="collection-card-actions">
              <Link to="/marketplace" className="ghost-btn collection-action-btn">
                List for Sale
              </Link>
            </div>
          </article>
        ))}
      </section>
    </main>
  )
}

export default CollectionPage