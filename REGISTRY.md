# ONS Registry

The ONS Registry is the authoritative on-chain record of name ownership
and expiration.

It is responsible only for:
- Name availability
- Ownership
- Expiration state

It does not perform resolution or address mapping.

---

## Registration Model

- Names are registered on-demand by users
- Registration requires payment for a fixed duration (initially 1 year)
- Ownership is time-bound and must be renewed to remain active
- There is no concept of permanent or lifetime ownership in v1

---

## Expiration

- Each name has an expiration timestamp
- When a name expires:
  - Resolution becomes inactive
  - Ownership rights lapse
- Expired names become available for re-registration

---

## Renewal

- Owners may renew a name before or after expiration
- Renewals extend the expiration timestamp
- Renewals do not change ownership history

---

## Ownership Semantics

- Ownership represents the exclusive right to configure resolution
- Ownership does not imply protocol governance or token rights
- Ownership is transferable, but expiration always applies

---

## Design Notes

- The registry is chain-agnostic in concept
- Pricing models are implementation-specific and not defined here
- Future versions may introduce:
  - Grace periods
  - Premium pricing
  - Marketplace mechanics
