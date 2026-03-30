const listings = [
  {
    id: 'LIST-001',
    cardName: 'Card 1',
    cardId: 'DRGN-001',
    rarity: 'Legendary',
    seller: '0x93f2...A1d4',
    price: '125 BTK',
  },
  {
    id: 'LIST-002',
    cardName: 'Card 2',
    cardId: 'KNGT-014',
    rarity: 'Epic',
    seller: '0xAA07...9cE2',
    price: '62 BTK',
  },
  {
    id: 'LIST-003',
    cardName: 'Card 3',
    cardId: 'ARCN-027',
    rarity: 'Rare',
    seller: '0x5Dd9...fE87',
    price: '28 BTK',
  },
  {
    id: 'LIST-004',
    cardName: 'Card 4',
    cardId: 'BSTN-041',
    rarity: 'Uncommon',
    seller: '0x11Bc...42AA',
    price: '15 BTK',
  },
  {
    id: 'LIST-005',
    cardName: 'Card 5',
    cardId: 'ELMN-052',
    rarity: 'Epic',
    seller: '0x7A31...0c65',
    price: '74 BTK',
  },
  {
    id: 'LIST-006',
    cardName: 'Card 6',
    cardId: 'AETH-066',
    rarity: 'Rare',
    seller: '0x4fe8...91D0',
    price: '34 BTK',
  },
]

function MarketplacePage() {
  return (
    <main className="market-main">
      <section className="market-heading" aria-label="Marketplace overview">
        <div>
          <h1>Available Listings</h1>
          <p>
            Browse listed cards from verified owners. Placeholder art is shown for
            now and will be replaced with real card thumbnails from metadata.
          </p>
        </div>
        <button type="button" className="primary-btn">
          List My Card
        </button>
      </section>

      <section className="listing-grid" aria-label="Card listings">
        {listings.map((listing) => (
          <article className="listing-card" key={listing.id}>
            <div className="listing-thumb" role="img" aria-label="Card thumbnail placeholder">
              {listing.cardName}
            </div>
            <div className="listing-content">
              <h2>{listing.cardName}</h2>
              <p>
                Card ID: {listing.cardId}
              </p>
              <p>
                Rarity: {listing.rarity}
              </p>
              <p>
                Seller: {listing.seller}
              </p>
              <p className="listing-price">Price: {listing.price}</p>
            </div>
          </article>
        ))}
      </section>
    </main>
  )
}

export default MarketplacePage
