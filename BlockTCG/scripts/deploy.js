const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // ─── 1. Deploy ERC20 Token ───────────────────────────────────────
  const Token = await ethers.getContractFactory("CollectibleToken");
  const token = await Token.deploy(1_000_000); // 1 million CARD tokens
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log("CollectibleToken deployed to:", tokenAddress);

  // ─── 2. Deploy ERC1155 Card Collection ──────────────────────────
  const Cards = await ethers.getContractFactory("CardCollection");
  const cards = await Cards.deploy(
    tokenAddress,
    "ipfs://placeholder/{id}.json"  // replace with real IPFS CID later
  );
  await cards.waitForDeployment();
  const cardsAddress = await cards.getAddress();
  console.log("CardCollection deployed to:", cardsAddress);

  // ─── 3. Register Common Cards (IDs 1–20, max supply: 100 each) ──
  console.log("\nRegistering Common cards...");
  const commonCards = [
    [1,  "Fire Sprite"],
    [2,  "Ice Golem"],
    [3,  "Storm Hawk"],
    [4,  "Earth Titan"],
    [5,  "Water Nymph"],
    [6,  "Wind Dancer"],
    [7,  "Stone Guard"],
    [8,  "Lava Imp"],
    [9,  "Frost Wolf"],
    [10, "Thunder Bee"],
    [11, "Sand Viper"],
    [12, "Mud Troll"],
    [13, "Leaf Sprite"],
    [14, "Cave Bat"],
    [15, "River Eel"],
    [16, "Ember Fox"],
    [17, "Snow Bear"],
    [18, "Vine Creeper"],
    [19, "Rock Crab"],
    [20, "Sea Turtle"],
  ];
  for (const [id, name] of commonCards) {
    await cards.registerCard(id, name, 0, 100); // 0 = Common
    console.log(`  Registered Common #${id}: ${name}`);
  }

  // ─── 4. Register Rare Cards (IDs 21–35, max supply: 30 each) ────
  console.log("\nRegistering Rare cards...");
  const rareCards = [
    [21, "Shadow Dragon"],
    [22, "Thunder Wolf"],
    [23, "Crystal Golem"],
    [24, "Magma Phoenix"],
    [25, "Void Specter"],
    [26, "Storm Serpent"],
    [27, "Iron Colossus"],
    [28, "Lunar Fox"],
    [29, "Tide Leviathan"],
    [30, "Inferno Hawk"],
    [31, "Glacier Bear"],
    [32, "Poison Hydra"],
    [33, "Rune Knight"],
    [34, "Eclipse Panther"],
    [35, "Arcane Golem"],
  ];
  for (const [id, name] of rareCards) {
    await cards.registerCard(id, name, 1, 30); // 1 = Rare
    console.log(`  Registered Rare #${id}: ${name}`);
  }

  // ─── 5. Register Super Rare Cards (IDs 36–45, max supply: 10 each) ─
  console.log("\nRegistering Super Rare cards...");
  const superRareCards = [
    [36, "Celestial Phoenix"],
    [37, "Abyssal Kraken"],
    [38, "Divine Seraph"],
    [39, "Chaos Hydra"],
    [40, "Eternal Dragon"],
    [41, "Void Titan"],
    [42, "Cosmic Serpent"],
    [43, "Sacred Griffin"],
    [44, "Fallen Angel"],
    [45, "Primordial God"],
  ];
  for (const [id, name] of superRareCards) {
    await cards.registerCard(id, name, 2, 10); // 2 = SuperRare
    console.log(`  Registered Super Rare #${id}: ${name}`);
  }

  // ─── Summary ─────────────────────────────────────────────────────
  console.log("\n✅ Deployment complete!");
  console.log("─────────────────────────────────────────");
  console.log("CollectibleToken (CARD):", tokenAddress);
  console.log("CardCollection (Cards): ", cardsAddress);
  console.log("Total cards registered: 45");
  console.log("─────────────────────────────────────────");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});