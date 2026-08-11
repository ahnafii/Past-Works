# Roblox Shop System

A portfolio-quality, reusable Roblox shop system built around a server-authoritative purchase pipeline and a Studio-installed GUI.

## Design goals

This project intentionally avoids the usual neon/glass-heavy Roblox shop look. The visual language uses a dark neutral surface, restrained teal interaction color, compact cards, strong information hierarchy, and rarity accents only where they help scanning.

The design process follows Roblox's current UI guidance: mobile-first composition, readable text, familiar conventions, responsive sizing, consistent visual language, and minimal unnecessary motion. Roblox recommends designing UI around mobile devices because a majority of sessions are mobile, and recommends testing layouts against core UI and reserved touch zones. See the Creator Hub references below.

## Features

- Featured, Weapons, Tools, Consumables, and Miscellaneous categories
- Live case-insensitive item search
- Price, rarity, alphabetical, and featured sorting
- Item detail panel with stats and ownership
- Confirmation modal before purchase
- Server-authoritative purchase validation
- Currency abstraction (`Coins`, `Gems`, and easy extension)
- Stackable and non-stackable items
- Ownership limits
- Optional per-server stock limits
- Purchase rate limiting
- Defensive remote argument validation
- Persistent currencies/inventory through DataStoreService
- Responsive desktop, tablet, and mobile layouts
- Empty search/category state
- Purchase success/failure toasts
- Open/close transitions and interaction feedback
- Data-driven item catalog
- Dedicated Command Bar GUI installer

## Repository layout

```text
ShopSystem/
├── README.md
├── CommandBar/
│   └── CreateShopGUI.lua
├── Shared/
│   ├── ShopConfig.lua
│   └── ItemCatalog.lua
├── Server/
│   └── ShopServer.server.lua
└── Client/
    └── ShopClient.client.lua
```

## Installation

### 1. Install the GUI

Open Roblox Studio and open the **Command Bar**.

Paste the entire contents of:

`CommandBar/CreateShopGUI.lua`

Run it once.

The script removes an existing `StarterGui.ShopGui` and recreates the complete editable interface as normal Roblox Instances. The runtime LocalScript does **not** construct the main interface.

### 2. Install shared modules

Create this structure in `ReplicatedStorage`:

```text
ReplicatedStorage
└── ShopSystem
    └── Shared
        ├── ShopConfig (ModuleScript)
        └── ItemCatalog (ModuleScript)
```

Copy the contents of the two repository modules into their corresponding ModuleScripts.

### 3. Install the server script

Create:

```text
ServerScriptService
└── ShopSystem
    └── Server
        └── ShopServer.server.lua
```

Paste `Server/ShopServer.server.lua` into that Script.

The server creates the required `ReplicatedStorage.ShopRemotes` folder automatically.

### 4. Install the client script

Create:

```text
StarterPlayer
└── StarterPlayerScripts
    └── ShopSystem
        └── Client
            └── ShopClient.client.lua
```

Paste `Client/ShopClient.client.lua` into that LocalScript.

> The client script assumes the shared modules are installed at `ReplicatedStorage.ShopSystem.Shared`. The GUI itself must already exist in `StarterGui` from the Command Bar installer.

### 5. Test DataStores safely

For Studio persistence tests, enable **Studio Access to API Services** in a dedicated test place rather than a live production place. Roblox notes that Studio can access the same DataStores as the live application when this setting is enabled, so enabling it against a production experience can overwrite live data.

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
    Icon = "",
    Glyph = "◈",
    Stackable = false,
    MaxOwned = 1,
    Featured = true,
    Stats = {
        Power = 20,
    },
},
```

No purchase logic needs to be changed. The client reads the catalog and the server resolves the authoritative price from the same catalog.

## Categories

Categories are configured in `ShopConfig.Categories` and are matched against the item's `Category` field.

`Featured` is a special virtual category: it displays items whose `Featured` field is `true`.

To add a new category:

1. Add it to `ShopConfig.Categories`.
2. Add a matching button to the Command Bar GUI generator.
3. Set the item's `Category` to that exact name.

For a game-specific version, the generator can be customized to expose only the categories that matter to that game.

## Currencies

Currencies are defined in `ShopConfig.Currencies`:

```lua
Credits = {
    DisplayName = "Credits",
    Symbol = "C",
    Color = Color3.fromRGB(120, 190, 255),
},
```

Then add a starting balance in `ShopConfig.DefaultCurrency` and use `Currency = "Credits"` on an item.

The server verifies that the currency exists before accepting a purchase.

## Security model

The client sends only an item ID and quantity. It never sends a price, currency, ownership state, or balance that the server accepts as truth.

The server validates:

- item ID type and length
- quantity type, integer status, minimum, and maximum
- purchase request frequency
- item existence
- configured currency
- existing ownership
- stack/ownership limits
- configured stock
- authoritative price
- authoritative currency balance

Only after all checks pass does the server mutate the player's state.

The purchase response includes a transaction GUID for client-side feedback/logging, but the client does not decide whether the transaction happened.

## Persistence

The sample implementation stores currencies and inventory using `DataStoreService`. Player state is sanitized when loaded so malformed or outdated values cannot directly become trusted economic state.

The save path uses `UpdateAsync`, which Roblox documents as safer than `SetAsync` when multiple servers may update the same key because it reads the latest value before applying the update.

For a large live game, this sample should be paired with a mature session-locking/profile system rather than treated as a complete player-data framework. Roblox's purchasing/data-store guidance specifically calls out session locking as a protection against cross-server data duplication and conflicting writes.

## UI architecture

The Command Bar installer creates the static composition:

- `ScreenGui`
- modal overlay
- shop window
- header and currency bar
- category navigation
- search and sort controls
- item grid container and scrolling frame
- detail panel
- confirmation modal
- toast container
- layout/constraint/styling instances

The LocalScript handles stateful presentation and interaction: filtering, sorting, responsive adjustments, detail selection, purchase confirmation, and server responses. It does not construct the main shop shell.

Item cards are data-driven because the number and content of catalog items can change. Their visual treatment is kept deliberately lightweight so the UI remains responsive on lower-end devices.

## Responsive behavior

- Desktop: three-column item grid with persistent detail panel.
- Tablet: two-column grid with a slightly wider detail panel.
- Mobile: two-column grid and a focused detail view so the card grid is not squeezed into an unusable side-by-side layout.
- `UISizeConstraint`, scrolling containers, proportional sizing, and dynamic grid columns keep the composition adaptable.

Roblox recommends using safe screen insets and avoiding important controls in the mobile control zones. The generated ScreenGui uses `CoreUISafeInsets` for interactive UI.

## Visual direction

The visual system uses:

- dark neutral surfaces instead of a gradient-heavy backdrop
- one primary action color
- rarity color as an information accent rather than decoration
- restrained borders and corner radii
- compact, readable typography
- clear grouping and spacing
- short easing-based transitions
- familiar close and confirmation conventions

This keeps the shop recognizable as a game interface without copying a specific experience.

## Known limitations / production adaptation points

- Per-item `Stock` is server-instance stock. A globally shared limited stock system should use a suitable cross-server datastore/memory-store design.
- The sample data layer is intentionally small. A production game with trading, multiple inventories, or high-value economies should use a dedicated session-locking player-data architecture.
- Item `Icon` fields are intentionally left open for each game to provide its own art. The demo uses typographic glyphs so the repository has no dependency on third-party image assets.
- The client currently opens the shop automatically on join as a portfolio demonstration. In a real game, expose `openShop()` through the game's own interaction flow instead.

## Test checklist

Use Studio's Device Emulator and server/client test modes.

### UI / UX

- [ ] Open and close shop
- [ ] Escape closes shop/modal appropriately
- [ ] Category switching
- [ ] Live search
- [ ] Empty search state
- [ ] Sorting cycle
- [ ] Item selection
- [ ] Long item names/descriptions
- [ ] Different rarity colors
- [ ] Mobile portrait/landscape where supported
- [ ] Tablet layout
- [ ] Desktop layout
- [ ] Touch activation
- [ ] Gamepad selection/activation where the experience uses UI navigation

### Economy

- [ ] Successful purchase
- [ ] Insufficient currency
- [ ] Already owned item
- [ ] Stack limit
- [ ] Invalid item ID
- [ ] Invalid quantity
- [ ] Quantity above configured maximum
- [ ] Rapid purchase requests
- [ ] Out-of-stock item
- [ ] Multiple players purchasing independently
- [ ] Rejoin persistence
- [ ] Server shutdown save

### Security

Attempt the purchase remote manually from a client with:

- fake price values
- fake currency names
- negative quantity
- fractional quantity
- huge quantity
- unknown item IDs
- malformed argument types
- repeated rapid calls

The server should reject these without mutating economic state.

## Research references

The UI direction was informed by Roblox Creator Hub guidance on prioritization, visual language, conventions, consistency, responsive design, safe screen insets, mobile thumb zones, and cross-platform input.

- Roblox — [Design for Roblox](https://create.roblox.com/docs/production/game-design/design-for-roblox)
- Roblox — [UI and UX design](https://create.roblox.com/docs/production/game-design/ui-ux-design)
- Roblox — [Choose an art style](https://create.roblox.com/docs/tutorials/curriculums/user-interface-design/choose-an-art-style)
- Roblox — [Wireframe your layouts](https://create.roblox.com/docs/tutorials/curriculums/user-interface-design/wireframe-your-layouts)
- Roblox — [On-screen UI containers](https://create.roblox.com/docs/ui/on-screen-containers)
- Roblox — [Adaptive design guidelines](https://create.roblox.com/docs/production/publishing/adaptive-design)
- Roblox — [Securing the client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary)
- Roblox — [Remote events and callbacks](https://create.roblox.com/docs/scripting/events/remote)
- Roblox — [Data stores](https://create.roblox.com/docs/cloud-services/data-stores)
- Roblox — [Implement player data and purchasing systems](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing)

## Portfolio note

This project is intended as a reusable systems piece, not a single-game implementation. The catalog, currency model, rarity palette, category structure, UI hierarchy, and persistence layer are deliberately separated so the core purchase system can be adapted without rewriting the presentation layer.
