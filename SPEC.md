# ONS Protocol Specification

This document defines the high-level specification for the Onchain Name Service (ONS) protocol.

ONS is a minimal, chain-agnostic naming protocol designed to register, manage, and resolve human-readable onchain identifiers.

The protocol prioritizes simplicity, composability, and long-term extensibility while remaining neutral to specific execution environments or application layers.

## Design Principles

- Onchain-first ownership and resolution
- Chain-agnostic architecture
- Minimal core with extensible records
- No required frontend, indexer, or UI assumptions
- Composable with existing onchain infrastructure

## Scope

This specification covers:

- Name registration and ownership semantics
- Resolution primitives
- Record extensibility model

User interfaces, indexing services, offchain resolution, and third-party integrations are intentionally excluded from the core protocol.

## Status

This specification is in early development.

Details may evolve as the protocol design matures and implementations are explored.
