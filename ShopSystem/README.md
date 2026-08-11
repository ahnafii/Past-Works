# Roblox Shop System

A reusable, server-authoritative Roblox shop system designed as a portfolio-quality systems piece. The project uses Rojo for code synchronization and a standalone Roblox Studio Command Bar installer for the editable GUI hierarchy.

## What makes this implementation different

The shop is deliberately not a runtime-generated UI demo. The Command Bar installer creates the complete visual hierarchy as real Studio Instances. The LocalScript only reads and updates those existing objects.

The visual direction was rebuilt around:

- Strong information hierarchy
- Real item artwork instead of text glyphs or emoji-style symbols
- Large, readable item imagery
- Restrained rarity accents
- Compact tabs and controls
- Clear purchase hierarchy
- Solid surfaces and subtle borders instead of excessive gradients/glows
- Responsive desktop, tablet, and mobile behavior
- Short, purposeful transitions

Roblox's UI guidance emphasizes responsive layouts, dynamic sizing, legibility, visual hierarchy, familiar conventions, and consistent imagery across input types. This project follows those principles rather than treating desktop as the only target.

## Features

- Featured, Weapons, Tools, Consumables, and Miscellaneous categories
- Live case-insensitive search
- Price low-to-high, price high-to-low, rarity, alphabetical, and featured sorting
- Prebuilt item-card pool with no runtime GUI construction
- Item detail panel
- Real Roblox image/decal and `rbxthumb` item artwork
- Currency images for Coins and Gems
- Ownership state
- Stackable and non-stackable items
- Configurable maximum ownership
- Optional server-instance stock
- Purchase confirmation modal
- Purchase success/failure notifications
- Server-authoritative purchase validation
- Remote request rate limiting
- Defensive remote argument validation
- Persistent currency and inventory using DataStoreService
- Responsive mobile detail view
- Escape-to-close support
- Touch-friendly controls
- Rojo 7.7.0 project configuration
- Aftman toolchain pinning

## Repository layout

```text
Past-Works/
├── aftman.toml
├── default.project.json
└── ShopSystem/
    ├── README.md
    ├── CommandBar/
    │   └── CreateShopGUI.lua
    ├── Shared/
    │   ├── ShopConfig.lua
    │   └── ItemCatalog.lua
    ├── Server/
    │   └── ShopServer.server.lua
    ├── Client/
    │   └── ShopClient.client.lua
    ├── ClientShared/
    │   ├── ShopConfig.lua
    │   └── ItemCatalog.lua
    └── ServerShared/
        ├── ShopConfig.lua
        └── ItemCatalog.lua
```

`Shared/` is the authoritative catalog/configuration source. The `ClientShared` and `ServerShared` files are compatibility bridge modules and are not part of the Rojo runtime tree.

## Rojo setup

The repository pins **Rojo 7.7.0** in `aftman.toml` so the CLI version is reproducible. Rojo's Studio plugin should use the same stable version.

From the repository root:

```powershell
aftman install
rojo --version
rojo serve
```

Then connect to the running server from the Rojo Studio plugin.

`default.project.json` maps:

```text
ReplicatedStorage
└── ShopSystem
    └── Shared
        ├── ShopConfig
        └── ItemCatalog

ServerScriptService
└── ShopSystem
    └── ShopServer

StarterPlayer
└── StarterPlayerScripts
    └── ShopSystem
        └── ShopClient
```

The client and server both resolve shared modules from `ReplicatedStorage.ShopSystem.Shared`. This keeps one authoritative runtime copy of the catalog and configuration.

## GUI installation

The GUI is intentionally separate from Rojo's runtime tree.

1. Open Roblox Studio.
2. Open the Command Bar.
3. Open `ShopSystem/CommandBar/CreateShopGUI.lua` in VS Code.
4. Copy the entire file into the Command Bar.
5. Run it once.
6. Confirm `StarterGui.ShopGui` exists.

The installer creates the entire editable hierarchy, including the item-card pool, detail view, confirmation modal, toast slots, responsive layout objects, constraints, strokes, corners, padding, and scrolling containers.

The client does **not** use `Instance.new` to construct the shop UI at runtime.

## Adding an item

Add one entry to `Shared/ItemCatalog.lua`:

```lua
my_item = {
    Id = "my_item",
    Name = "My Item",
    Description = "A useful item.",
    Category = "Tools",
    Price = 400,
    Currency = "Coins",
    Rarity = "Uncommon",
    Icon = "rbxassetid://YOUR_IMAGE_ASSET_ID",
    Stackable = false,
    MaxOwned = 1,
    Featured = true,
    Stats = {
        Power = 20,
    },
},
```

No purchase logic needs to be edited. The server resolves the authoritative item, price, currency, ownership rules, and stock from the shared catalog.

### Item artwork

`Icon` accepts normal Roblox image/decal content IDs. For a model or gear asset where a thumbnail is preferable, use Roblox's thumbnail content format:

```lua
Icon = "rbxthumb://type=Asset&id=123456789&w=420&h=420",
```

The demo catalog uses real Roblox assets rather than emoji or placeholder glyphs. Replace them with artwork owned by the game when adapting the system for a commercial project.

## Categories

Categories live in `ShopConfig.Categories`.

`Featured` is a virtual category and displays items with `Featured = true`.

To add a category:

1. Add it to `ShopConfig.Categories`.
2. Add a matching prebuilt button to `CreateShopGUI.lua`.
3. Set the item's `Category` to that exact name.

## Currencies

Currencies are configured in `ShopConfig.Currencies`:

```lua
Credits = {
    DisplayName = "Credits",
    Icon = "rbxassetid://YOUR_CURRENCY_IMAGE",
    Color = Color3.fromRGB(120, 190, 255),
},
```

Then add a starting balance to `ShopConfig.DefaultCurrency` and use `Currency = "Credits"` on catalog items.

The server checks that the currency exists before accepting a purchase.

## Security model

The client sends only an item ID and quantity. It does not send an accepted price, currency, balance, or ownership state.

The server validates:

- Item ID type and length
- Quantity type, integer status, minimum, and maximum
- Purchase frequency
- Item existence
- Currency configuration
- Ownership
- Stack and ownership limits
- Optional stock
- Authoritative price
- Authoritative currency balance

Only after validation does the server mutate the player's economy state.

Malformed or exploit-style requests such as negative quantities, fractional quantities, unknown item IDs, fake prices, fake currencies, and rapid remote calls are rejected.

## Persistence

The sample uses `DataStoreService` with `UpdateAsync` for player currency and inventory. Loaded values are sanitized before becoming trusted state.

For a large live game with trading or a high-value economy, use a mature session-locking/profile-data architecture. The shop intentionally keeps the persistence layer understandable for portfolio and commission reuse rather than pretending to be a complete player-data framework.

## Responsive behavior

### Desktop

- Two-column item grid
- Persistent detail panel
- Full currency wallet
- Large market window

### Tablet

- Two-column item grid with a narrower detail panel
- Reduced overall window footprint

### Mobile

- Two-column touch-friendly cards
- Detail view becomes a focused full-panel screen
- Back control returns to the item grid
- Header wallet condenses into readable balance text
- Window constraints are reduced for small viewports

The project is intended to be tested with Roblox Studio's Device Emulator rather than assuming a single desktop resolution.

## UI interaction model

- Category buttons update immediately.
- Search filters as the player types.
- Sort cycles through useful ordering modes.
- Hover changes are subtle and disabled for touch layouts.
- Selecting a card updates the detail panel.
- Purchase opens a confirmation step.
- The server validates the transaction.
- Success and failure feedback appears in a prebuilt toast slot.
- Escape closes the modal first, then the shop.

## Demo content

The sample catalog contains coherent fictional gear and supplies:

- Iron Sword
- Emberblade
- Hunter's Bow
- Frost Staff
- Shadow Dagger
- Explorer's Lantern
- Grappling Hook
- Health Potion
- Focus Elixir
- Traveler's Pack
- Guild Token

Each item has a category, description, price, rarity, image, and optional stats.

## Testing checklist

### UI / UX

- [ ] Run the Command Bar installer
- [ ] Confirm all GUI objects exist in StarterGui
- [ ] Open and close the shop
- [ ] Escape closes modal/shop correctly
- [ ] Switch categories
- [ ] Search live
- [ ] Clear search
- [ ] Test every sorting mode
- [ ] Select every demo item
- [ ] Verify item images load
- [ ] Test long names and descriptions
- [ ] Test empty results
- [ ] Test desktop, tablet, and mobile layouts
- [ ] Test touch activation
- [ ] Check Roblox core UI safe areas

### Economy

- [ ] Successful purchase
- [ ] Insufficient currency
- [ ] Already owned item
- [ ] Stack limit
- [ ] Invalid item ID
- [ ] Invalid quantity
- [ ] Quantity above maximum
- [ ] Rapid purchase requests
- [ ] Out-of-stock item
- [ ] Multiple players purchasing independently
- [ ] Rejoin persistence
- [ ] Server shutdown save

### Security

Attempt to invoke the purchase remote manually with:

- Fake price values
- Fake currency names
- Negative quantity
- Fractional quantity
- Huge quantity
- Unknown item IDs
- Malformed argument types
- Repeated rapid requests

None of these client-controlled values should be able to bypass server validation.

## Production adaptation notes

- Replace demo artwork with assets owned or licensed by the game.
- Use a global stock architecture if limited stock must be shared across servers.
- Pair the economy with session locking for high-value live games.
- Connect the shop opening action to the game's own NPC, button, prompt, or gameplay interaction instead of automatically opening it on join.
- Increase the prebuilt card pool in the Command Bar installer if a game needs more than `ShopConfig.MaxVisibleCards` visible results.

## Research references

The visual and responsive direction was informed by Roblox Creator Hub guidance on UI objects, adaptive design, visual hierarchy, safe areas, mobile input, dynamic sizing, and asset content IDs.

- Roblox Creator Hub — UI
- Roblox Creator Hub — Adaptive design guidelines
- Roblox Creator Hub — Design for Roblox
- Roblox Creator Hub — Wireframe your layouts
- Roblox Creator Hub — Assets
- Roblox Creator Hub — Securing the client-server boundary
- Roblox Creator Hub — Remote events and callbacks
- Roblox Creator Hub — Data stores

## Portfolio note

This project is intended to demonstrate real Roblox systems work: data-driven architecture, server authority, defensive networking, reusable configuration, persistent state, responsive UI, and a deliberately designed presentation layer. It is not intended to be a generic template with a runtime-generated mock interface.
