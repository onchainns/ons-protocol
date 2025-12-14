# Payments & Treasury

ONS v1 operates as a protocol-managed naming registry.

All registration and renewal fees are paid directly to a protocol treasury
address responsible for maintaining registry infrastructure, development,
and ongoing operations.

## Accepted Payment Asset

- ONS v1 accepts payments in ETH only.

ETH is used as the settlement asset due to:
- Native compatibility with EVM-based smart contracts
- Predictable execution and gas accounting
- Reduced complexity for pricing, refunds, and auditing

Support for additional payment assets (ERC20s, stablecoins, or cross-chain
payments) may be introduced in future versions without impacting existing
names.

## Treasury Model

- Registration and renewal fees are sent on-chain to a designated treasury address
- The treasury is used to fund:
  - Protocol maintenance
  - Infrastructure and deployments
  - Development and upgrades

ONS v1 does not introduce governance tokens, DAOs, or revenue-sharing
mechanisms.

## Neutrality & Guarantees

- Users are purchasing time-bound name registrations
- No ownership, equity, or governance rights are implied
- Fees grant the right to use a name for a fixed duration, subject to renewal
- Protocol rules are enforced on-chain and apply equally to all users

## Future Evolution

Treasury structure, governance, and fee routing may evolve in future protocol
versions. Such changes will not retroactively alter ownership or resolution
of existing names.

This document describes the payment model for ONS v1 only.
