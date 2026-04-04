import { useState } from 'react'
import { Link } from 'react-router-dom'

// all the cards that can show up in a pack
// same IDs and names as the marketplace so everything stays consistent
const CARD_POOL = [
  { id: 'DRGN-001', name: 'Card 1',  rarity: 'Legendary' },
  { id: 'KNGT-014', name: 'Card 2',  rarity: 'Epic'      },
  { id: 'ARCN-027', name: 'Card 3',  rarity: 'Rare'      },
  { id: 'BSTN-041', name: 'Card 4',  rarity: 'Uncommon'  },
  { id: 'ELMN-052', name: 'Card 5',  rarity: 'Epic'      },
  { id: 'AETH-066', name: 'Card 6',  rarity: 'Rare'      },
  { id: 'SHAD-073', name: 'Card 7',  rarity: 'Uncommon'  },
  { id: 'FRST-088', name: 'Card 8',  rarity: 'Common'    },
  { id: 'STRM-095', name: 'Card 9',  rarity: 'Common'    },
  { id: 'VLKN-102', name: 'Card 10', rarity: 'Rare'      },
]

// picks n random cards from the pool
// uid is just so React has a unique key even if you pull duplicates
function drawCards(n = 5) {
  const drawn = []
  const pool = [...CARD_POOL]
  for (let i = 0; i < n; i++) {
    const idx = Math.floor(Math.random() * pool.length)
    drawn.push({ ...pool[idx], uid: `${pool[idx].id}-${Date.now()}-${i}` })
  }
  return drawn
}

function PackOpeningPage() {
  // three phases: idle (pack sitting there), opening (loading), revealed (cards shown)
  const [phase, setPhase] = useState('idle')
  const [cards, setCards] = useState([])
  // tracks which cards the user has already flipped
  const [flipped, setFlipped] = useState([])

  function handleOpenPack() {
    setPhase('opening')
    setCards([])
    setFlipped([])
    // the 1.2s delay is just for the "opening" animation — swap with a real contract call later
    setTimeout(() => {
      setCards(drawCards(5))
      setPhase('revealed')
    }, 1200)
  }

  // only flips a card once — can't un-flip it
  function handleFlip(uid) {
    if (!flipped.includes(uid)) {
      setFlipped((prev) => [...prev, uid])
    }
  }

  // resets everything back to the start
  function handleReset() {
    setPhase('idle')
    setCards([])
    setFlipped([])
  }

  return (
    <main className="pack-main">
      {/* top heading section — mirrors the hero on the home page */}
      <section className="pack-heading" aria-label="Pack opening">
        <p className="chain-pill">Powered by Ethereum</p>
        <h1>
          Open a <span>Pack</span>
        </h1>
        <p className="pack-copy">
          Each pack contains 5 randomly drawn cards. Rarity is determined
          on-chain — what you get is what the blockchain gave you.
        </p>
      </section>

      {/* idle state — show the pack and the open button */}
      {phase === 'idle' && (
        <section className="pack-stage" aria-label="Pack ready to open">
          <article className="pack-box" aria-label="Unopened pack">
            <p className="pack-label">BlockTCG Pack</p>
            <p className="pack-sub">5 cards inside</p>
          </article>
          <button
            type="button"
            className="ghost-btn pack-open-btn"
            onClick={handleOpenPack}
          >
            Open Pack
          </button>
        </section>
      )}

      {/* opening state — just a pulsing message while we "wait" for the draw */}
      {phase === 'opening' && (
        <section className="pack-stage" aria-label="Opening pack">
          <div className="pack-opening-anim" aria-live="polite">
            <p>Opening your pack…</p>
          </div>
        </section>
      )}

      {/* revealed state — 5 face-down cards the user taps one by one */}
      {phase === 'revealed' && (
        <>
          <section className="pack-reveal-grid" aria-label="Revealed cards">
            {cards.map((card) => {
              const isFlipped = flipped.includes(card.uid)
              return (
                <article
                  key={card.uid}
                  className={`pack-card ${isFlipped ? 'pack-card--flipped' : ''}`}
                  onClick={() => handleFlip(card.uid)}
                  aria-label={isFlipped ? `${card.name}, ${card.rarity}` : 'Tap to reveal card'}
                >
                  {/* face-down — shows the stripe pattern */}
                  {!isFlipped ? (
                    <div className="pack-card-back">
                      <p>Tap to reveal</p>
                    </div>
                  ) : (
                    // face-up — shows rarity badge, name, and ID
                    <div className="pack-card-front">
                      <p className={`rarity-badge rarity-badge--${card.rarity.toLowerCase()}`}>
                        {card.rarity}
                      </p>
                      <p className="pack-card-name">{card.name}</p>
                      <p className="pack-card-id">{card.id}</p>
                    </div>
                  )}
                </article>
              )
            })}
          </section>

          {/* after revealing, let them open another pack or go check their collection */}
          <section className="pack-actions" aria-label="Post-reveal actions">
            <button type="button" className="ghost-btn" onClick={handleReset}>
              Open Another Pack
            </button>
            <Link to="/collection" className="ghost-btn hero-link-btn">
              View My Collection
            </Link>
          </section>
        </>
      )}
    </main>
  )
}

export default PackOpeningPage