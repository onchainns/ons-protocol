# ONS Architecture Overview

This document outlines the high-level architecture of the Onchain Name Service (ONS) protocol.

The goal of ONS is to provide a minimal, extensible, and chain-agnostic naming primitive that can be implemented across multiple ecosystems.

## Core Components

### 1. Registry
The registry is the canonical source of truth for name ownership.

Responsibilities:
- Track name → owner mappings
- Enforce ownership transfers
- Serve as the base authorization layer

The registry does not enforce pricing, expiration, or UI logic.

---

### 2. Resolver
Resolvers define how names map to onchain or offchain data.

Responsibilities:
- Resolve a name to one or more records (e.g. addresses, content hashes)
- Allow extensible record types
- Remain optional and swappable

Resolvers are separate from ownership logic.

---

### 3. Records
Records are arbitrary key-value mappings associated with a name.

Design goals:
- Extensible without protocol upgrades
- Minimal assumptions about record types
- Compatible with multiple resolution standards

---

## Design Principles

- Minimal core logic
- Separation of concerns
- Chain-agnostic by default
- Composable with existing infrastructure
- No assumptions about frontends or indexing layers

---

## Non-Goals

The ONS core protocol does not include:
- UI or frontend applications
- Indexing services
- Pricing or auction mechanisms
- Governance frameworks
- Token economics

These are intentionally left to higher layers.
