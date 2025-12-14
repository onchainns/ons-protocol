# ONS v1 Scope

ONS v1 defines a minimal, neutral naming primitive.

## Included
- Register `.onchain` names on-demand
- Name ownership represented internally
- One primary address per chain
- Deterministic resolution
- Permissionless registration

## Explicitly Not Included
- Auctions or bidding
- Marketplace features
- Rarity tiers
- Token or governance mechanics
- Subnames
- Profiles or social metadata

## Design Principles
- Protocol neutrality
- Upgradeability without breaking names
- Separation of ownership and resolution
- Simple UX that hides implementation details
## Registration Model

- Names are registered for a fixed duration (time-bound)
- Registrations must be renewed to remain active
- Expired names become available for re-registration
- No perpetual or lifetime ownership guarantees in v1

## Notes on Evolution

This document defines the locked scope of ONS v1.
Clarifications may be added without expanding scope.
New capabilities will be introduced only in future versions.

### Pricing

- Pricing is category-based and enforced at the protocol level
- Names may be explicitly classified into pricing tiers
- Explicit classification always overrides generic pricing rules
- Certain dictionary, brand-like, or high-signal names may be subject to premium pricing
- Pricing applies equally to registration and renewal in v1
