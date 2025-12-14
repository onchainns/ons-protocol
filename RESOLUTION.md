# Resolution

Resolution defines how a name maps to data.

For example:
alice.onchain → wallet address

## Resolver

A resolver is a contract that returns records for a name.
Resolvers do not own names.
Resolvers can be updated without transferring ownership.

## v1 Resolution

- One primary address per chain
- Deterministic resolution
- No off-chain dependencies
