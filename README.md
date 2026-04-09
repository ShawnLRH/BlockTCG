# BlockTCG

# Project Overview
Blockchain dApp based on a blind-box style collectible card system. The idea is that users can purchase a pack and receive random digital cards, with card ownership and supply tracked on-chain. Ensuring authenticity and true rarity. Our focus is on addressing the fragmentation in existing collectible ecosystems, where issuance, ownership, and secondary trading are often split across different platforms. By integrating these functions into a single application, we hope to create a more cohesive system with transparent scarcity, wallet-based ownership, and an internal trading economy.

## How to test the contracts

### Step 1: ChainLink VRF Subscription set up

Claim Sepolia ETH: https://cloud.google.com/application/web3/faucet/ethereum/sepolia

Claim LINK Token: https://faucets.chain.link/sepolia

**Set-up Subscription:** vrf.chain.link

1. Connect to sepolia testnet with your wallet app
2. Link your wallet to the website
3. Click "Create Subscription" to create a subscription
4. Fund it with minimum 125 LINK tokens, each request only takes around 0.0018 LINK but 170 LINK is listed as max so more than max is needed. You can reduce this if you do not have enough Testnet LINK. Will be covered below in the next steps.

### Step 2: Deploy the Collectible token

1. Compile on remix
2. Change to wallet connect mode on sepolia
3. Set initial supply as `1000000` and deploy

### Step 3: Upload IPFS Images and JSON

1. Create a account on https://pinata.cloud/ipfs
2. Upload the images in the folder called Cards to IPFS
3. Update the CID in the provided JSON files in `blocktcg_metadata_json` with the Cards file CID
4. Upload the entire folder after updating the JSON files
5. Get the `IPFS://[CID]` of your json metadata file

### Step 4: Deploy and set-up CardCollection

1. Compile on remix
2. Set input as `IPFS://[CID]` of your json metadata file
3. Go to contracts and call the `BatchRegisterCards` Function with

```
tokenIDs: [1,2,3,4,5,6,7,8,9,10,11,12]

names:
[
  "AI Defender",
  "Cyber Firewall",
  "Cyber Hacker",
  "Data Overload",
  "Digital Virus",
  "Encryption Barrier",
  "Phishing Trap",
  "Absolute Security",
  "False Trust",
  "Last Stand",
  "Network Control",
  "Omega"
]

rarities: [0,0,0,0,0,0,0,1,1,1,1,2]

maxSupplies: [20,20,20,20,20,20,20,8,8,8,8,2]
```

### Step 5: Deploy and Set-Up Dropmanager With VRF

1. Compile on remix
2. Set the input as follows

```
collectionAddress    = [deployed CardCollection address]
paymentTokenAddress  = [deployed CollectibleToken address]
vrfCoordinator       = [Copy from vrf.chain.link]
vrfSubscriptionId    = [your subscription ID from vrf.chain.link]
vrfKeyHash           = [Copy from vrf.chain.link] it will be the 500gwei lane
vrfCallbackGasLimit  = 1200000
vrfRequestConfirmations = 3
vrfEnableNativePayment  = false (Pay with link, true mean pay with ETH)
treasuryAddress      = [your wallet address]
initialPackPrice     = 10000000000000000000 (10 CARD tokens)
```

> To use 150gwei lane use this hash instead: `0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae`

> Reduce callback gas limit here to `500000`, but ensure only 1 pack is bought per time if not enough Sepolia LINK tokens

If you followed the changes stated, the max cost would be reduced by half to 80, so 81 Chainlink deposit is enough. Only 0.0018 will be used per transaction.

### Step 6: Authorize the drop manager

1. Call `setDropManager` in CardCollection deployed contract
2. Provide the DropManager contract address

### Step 7: Add drop contract as consumer

1. Go to vrf.chain.link
2. Open your subscriptions
3. Paste in your deployed Drop manager contract address
4. Confirm and wait for it to be processed

### Step 8: Pool Seeding

1. In the drop manager contract call the `BatchSeedPool` Function
2. Fill the input with

```
cardIDs: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
copies:  [20, 20, 20, 20, 20, 20, 20, 8, 8, 8, 8, 2]
```

### Step 9: Token Minting (Optional: only if needed)

1. If not using the wallet that deployed token contract, mint tokens
2. If using the wallet that deployed token contract no minting needed, token already in your wallet

### Step 10: Approval of CARD spending

1. Call the `approve` function in the collectible token contract
2. Provide dropmanager address and the value `50000000000000000000` to approve 50 CARD spending (You can decide how much you wish to spend)

### Step 11: Buy Packs

1. Call the `buyPack` function in the DropManager contract
2. Put `1` and execute
3. Check vrf.chain.link to see if your fulfillment is done (usually takes around 30 seconds)
4. Once done, you have received your 5 ERC1155s
5. Check your cards with `BalanceOfBatch`

```
accounts: [Paste your wallet here 12 times seperated by commas]
ids:      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
```

6. If it shows 5 cards, you have successfully minted

### Step 12: Marketplace

1. **Deployment:** Deploy the marketplace contract with the specific ERC1155 and ERC20 contract addresses.
2. **Listing:** Seller calls `list()` to put their cards on the market (cards are transferred to marketplace escrow).
3. **Viewing Listings:** Call `getListing()` to display active items, prices, and available amounts.
4. **Purchase:** Buyer calls `buy()` to execute the trade, automatically handling the transfer of cards, payment, and commission fees.
5. **Unlisting (Optional):** If the seller changes their mind before the cards are sold, they can call `unlist()` to cancel the listing and retrieve their unsold cards from the marketplace escrow.

## How To View React Frontend
### 1. Install Node.js https://nodejs.org/en/download
### 2. Install Project Dependencies**
Run the following commands to install project dependencies in the BlockTCG folder:
```
cd BlockTCG
npm install
```
### 3. Start frontend in development mode**
From the nested BlockTCG folder (BlockTCG/BlockTCG):
```
# Start frontend in development mode
npm run dev
```
