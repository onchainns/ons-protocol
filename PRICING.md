# Pricing Model

ONS uses a deterministic, category-based pricing model enforced directly at the protocol level.

Pricing is designed to reflect the real-world value of names while remaining predictable, transparent, and non-speculative.

ONS does not rely on external price oracles, auctions, or secondary market dynamics in v1.

---

## Overview

- Names are registered on-demand under the `.onchain` namespace
- Registration is time-based (annual subscription)
- Renewals use the same pricing rules as initial registration
- Pricing is enforced by smart contracts, not the frontend

---

## Pricing Categories

Names are classified into pricing categories.  
Each category corresponds to a different annual registration and renewal cost.

### Category 1 — Standard / Low-Signal

Applies to:
- Random character strings
- Non-dictionary names
- Low-signal or niche identifiers

These names are intended to remain affordable and accessible.

---

### Category 2 — Dictionary / Common Words

Applies to:
- Common English words
- First names
- General-purpose nouns
- Cities and places

These names carry broader meaning and recognizability and are priced accordingly.

---

### Category 3 — High-Signal / Brand-Like

Applies to:
- Obvious brand-like identifiers
- Finance and technology terms
- Infrastructure-related words
- High-demand, high-recognition names

Examples include widely recognized terms in technology, crypto, finance, and global brands.

These names are intentionally priced higher to reflect their scarcity and signaling value.

---

### Category 4 — Reserved / Protocol-Critical

Applies to:
- Protocol names
- Core infrastructure terms
- Internally reserved identifiers

Names in this category may be unavailable for public registration or subject to special handling.

---

## Classification Rules

- Names may be explicitly classified into a pricing category by the protocol
- Explicit classification always takes priority over generic or fallback rules
- Classification data is stored on-chain and publicly readable
- Pricing categories are applied consistently to both registration and renewal

This approach prevents accidental underpricing of high-signal names and ensures predictable behavior.

---

## Renewals

- Registrations are time-limited and must be renewed
- Renewal pricing follows the same category-based rules as registration
- Names that are not renewed before expiration become available again

ONS does not support lifetime registrations.

---

## Design Principles

- Pricing is policy-driven, not market-driven
- No auctions in v1
- No dynamic oracle-based pricing
- No speculative mechanics

The goal is long-term namespace stability and usability, not short-term extraction.

---

## Future Considerations

Future versions of ONS may introduce:
- Additional pricing mechanics
- Governance-driven classification
- Secondary market integrations
- Auctions or premium decay models

These features are intentionally excluded from v1.
