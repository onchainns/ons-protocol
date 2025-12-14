# ons-protocol

Onchain Name Service (ONS) is an open protocol for registering and resolving
human-readable onchain names.

ONS is designed as a neutral, chain-agnostic naming layer that can be integrated
by wallets, applications, and protocols across ecosystems.

This repository contains the core protocol contracts, specifications, and
reference documentation.

---

## Goals

- Simple, human-readable onchain identifiers
- Chain-agnostic by design
- Open and permissionless protocol
- Minimal assumptions about wallets or frontends
- Composable with existing onchain infrastructure

---

## Scope

ONS defines a minimal naming primitive focused on:

- On-demand registration of `.onchain` names
- Deterministic resolution to onchain addresses
- One primary address per chain
- Time-bound registrations with renewal
- Separation of registry and resolver concerns

UI, indexing, and third-party integrations are intentionally kept out of the
core protocol.

For full details, see:
- [V1 Scope](V1_SCOPE.md)
- [Registry](REGISTRY.md)
- [Resolution](RESOLUTION.md)
- [Pricing](PRICING.md)

---

## Status

ONS v1 defines a stable, minimal protocol surface.

Future versions may introduce additional capabilities without breaking
existing names or ownership semantics.

---

## Contributing

Contributions, discussions, and feedback are welcome.

Please open an issue to propose changes or improvements before submitting
pull requests.

---

## License

MIT License.
