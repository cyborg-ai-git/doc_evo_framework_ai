# Security Analysis: EPQB Protocol
## Evo Post-Quantum Bridge - Comprehensive Security Assessment

## Executive Summary

**Protocol Name:** EPQB (Evo Post-Quantum Bridge)  
**Version:** 1.0  
**Transport:** WebSocket (ws://) - Unencrypted transport for security validation  
**Cryptographic Primitives:**
- Kyber ML-KEM (Post-Quantum Key Encapsulation)
- Crystals-Dilithium ML-DSA (Post-Quantum Digital Signatures)
- ChaCha20-Poly1305 / AES-256-GCM (Authenticated Encryption)
- SHA-256/BLAKE3 (Cryptographic Hashing)

**Security Philosophy:** Zero-trust transport layer. All security guarantees provided by application-layer cryptography.

**Overall Security Rating: 9/10** 🟢

EPQB implements a mutually authenticated, post-quantum secure communication protocol designed to provide complete security even over hostile, unencrypted transport layers.

## Attack Protection Matrix

### Protection Status Legend

| Symbol | Meaning | Description |
|--------|---------|-------------|
| ✅ YES | Fully Protected | EPQB provides complete protection against this attack |
| ⚠️ PARTIAL | Partially Protected | Some protection exists but with limitations |
| ⚠️ EXTERNAL | External Protection | Protection handled by external component (evo_core_bridge_client) |
| ⚠️ DEPENDS | Implementation Dependent | Protection depends on underlying library/hardware |
| ❌ NO | Not Protected | EPQB does not protect against this attack (by design or limitation) |

### Complete Attack Coverage Table

| # | Attack Category | Attack Type | Protected | Protection Mechanism | Notes |
|---|-----------------|-------------|-----------|---------------------|-------|
| **1** | **Passive Attacks** | | | | |
| 1.1 | Eavesdropping | Packet Sniffing | ✅ YES | Kyber KEM + AEAD encryption | All payloads encrypted |
| 1.2 | Eavesdropping | Traffic Analysis | ✅ YES | ID Hash (id_from + event_id + bridge_id) | EApiBridge.id ≠ EApiEvent.id, metadata hidden |
| 1.3 | Eavesdropping | Pattern Analysis | ⚠️ PARTIAL | N/A (by design) | Timing/size/frequency visible (nonce is safe) |
| 1.4 | Cryptanalysis | Brute Force Key Recovery | ✅ YES | 256-bit key strength | Computationally infeasible |
| 1.5 | Cryptanalysis | Quantum Attack (Shor) | ✅ YES | Kyber + Dilithium (PQ-safe) | Post-quantum algorithms |
| 1.6 | Cryptanalysis | Quantum Attack (Grover) | ✅ YES | 256-bit symmetric keys | 128-bit post-quantum security |
| **2** | **Active Attacks** | | | | |
| 2.1 | Message Tampering | Bit Flipping | ✅ YES | AEAD authentication tag | Any modification detected |
| 2.2 | Message Tampering | Ciphertext Substitution | ✅ YES | AEAD authentication tag | Invalid tag = rejection |
| 2.3 | Message Tampering | Truncation Attack | ✅ YES | AEAD + message framing | Incomplete messages rejected |
| 2.4 | Message Injection | Fake Message Injection | ✅ YES | Shared secret required | Cannot create valid ciphertext |
| 2.5 | Message Injection | Malformed Packet Injection | ✅ YES | Deserialization validation | Invalid format rejected |
| 2.6 | Replay Attack | Message Replay | ✅ YES | Entity ID tracking (MapId) | Duplicate IDs rejected |
| 2.7 | Replay Attack | Handshake Replay | ✅ YES | Entity ID + Kyber freshness | Each handshake unique |
| 2.8 | Replay Attack | Session Replay | ✅ YES | Per-session shared secret | Old sessions invalid |
| 2.9 | Reordering Attack | Message Reordering | ✅ YES | EApiEvent.seek + WebSocket/TCP | seek field for cursor position, TCP guarantees order |
| 2.10 | Deletion Attack | Message Dropping | ❌ NO | N/A | DoS possible (availability) |
| **3** | **MITM Attacks** | | | | |
| 3.1 | Impersonation | Client Impersonation | ✅ YES | Dilithium signature + Kyber AKE | Signature required in handshake |
| 3.2 | Impersonation | Server Impersonation | ✅ YES | Kyber AKE implicit auth | Only real server can decrypt |
| 3.3 | Impersonation | Relay/Proxy Impersonation | ✅ YES | End-to-end encryption | Relay cannot read content |
| 3.4 | Interception | Full MITM Interception | ✅ YES | Mutual authentication | Cannot establish valid session |
| 3.5 | Downgrade | Protocol Downgrade | ✅ YES | Fixed algorithm selection | No negotiation to weaken |
| 3.6 | Downgrade | Cipher Suite Downgrade | ✅ YES | Hardcoded PQ algorithms | Cannot force weak crypto |
| **4** | **Authentication Attacks** | | | | |
| 4.1 | Credential Theft | Key Extraction (memory) | ⚠️ PARTIAL | Zeroization recommended | EPQB-003 enhancement |
| 4.2 | Credential Theft | Key Extraction (network) | ✅ YES | Keys never transmitted | Only ciphertexts sent |
| 4.3 | Signature Forgery | Dilithium Forgery | ✅ YES | Post-quantum secure | Computationally infeasible |
| 4.4 | Certificate Attack | Fake Certificate | ✅ YES | Master Peer signature | Certificates are signed |
| 4.5 | Certificate Attack | Expired Certificate | ✅ YES | Last-known + Master Peer fallback | No expiry needed, always fetch latest |
| 4.6 | Identity Spoofing | Peer ID Spoofing | ✅ YES | ID bound to Kyber keys | Cannot fake identity |
| **5** | **Key Exchange Attacks** | | | | |
| 5.1 | KEM Attack | Kyber Ciphertext Manipulation | ✅ YES | IND-CCA2 security | Malformed ciphertext rejected |
| 5.2 | KEM Attack | Key Mismatch Attack | ✅ YES | AEAD decryption fails | Wrong key = auth failure |
| 5.3 | KEM Attack | Small Subgroup Attack | ✅ YES | Kyber lattice-based | Not applicable to lattices |
| 5.4 | Key Derivation | Weak Key Derivation | ✅ YES | Kyber native KDF | Cryptographically strong |
| 5.5 | Forward Secrecy | Session Key Compromise | ✅ YES | Per-session Kyber AKE | Each session independent |
| 5.6 | Forward Secrecy | Long-term Key Compromise | ✅ YES | Per-session random shared secret | Each Kyber AKE generates fresh keys |
| **6** | **Denial of Service** | | | | |
| 6.1 | Resource Exhaustion | Connection Flooding | ⚠️ EXTERNAL | Rate limiting (bridge_client) | Handled in separate crate |
| 6.2 | Resource Exhaustion | Handshake Flooding | ⚠️ EXTERNAL | Rate limiting (bridge_client) | Handled in separate crate |
| 6.3 | Resource Exhaustion | Memory Exhaustion | ⚠️ EXTERNAL | Cache limits | MapId has size limits |
| 6.4 | Computational DoS | Crypto Operation Flooding | ⚠️ EXTERNAL | Rate limiting (bridge_client) | Expensive ops rate-limited |
| 6.5 | Amplification | Response Amplification | ✅ YES | Balanced message sizes | No amplification vector |
| **7** | **Protocol-Level Attacks** | | | | |
| 7.1 | State Confusion | Invalid State Transition | ✅ YES | State machine validation | EnumApiCryptoState checked |
| 7.2 | State Confusion | Premature Message | ✅ YES | State-dependent processing | Wrong state = rejection |
| 7.3 | Version Attack | Protocol Version Mismatch | ✅ YES | Fixed protocol version | No version negotiation |
| 7.4 | Extension Attack | Unknown Extension | ✅ YES | Strict parsing | Unknown fields rejected |
| **8** | **Side-Channel Attacks** | | | | |
| 8.1 | Timing Attack | Crypto Timing Leak | ⚠️ DEPENDS | Library implementation | Depends on crypto library |
| 8.2 | Cache Attack | Cache Timing | ⚠️ DEPENDS | Library implementation | Depends on crypto library |
| 8.3 | Power Analysis | DPA/SPA | ⚠️ DEPENDS | Hardware dependent | Out of protocol scope |
| 8.4 | Fault Injection | Glitching | ⚠️ DEPENDS | Hardware dependent | Out of protocol scope |


### Protection Summary by Category

| Category | Total Attacks | ✅ Protected | ⚠️ Partial/External | ❌ Not Protected |
|----------|---------------|--------------|---------------------|------------------|
| Passive Attacks | 6 | 5 | 1 | 0 |
| Active Attacks | 10 | 9 | 0 | 1 |
| MITM Attacks | 6 | 6 | 0 | 0 |
| Authentication Attacks | 6 | 5 | 1 | 0 |
| Key Exchange Attacks | 6 | 6 | 0 | 0 |
| Denial of Service | 5 | 1 | 4 | 0 |
| Protocol-Level Attacks | 4 | 4 | 0 | 0 |
| Side-Channel Attacks | 4 | 0 | 4 | 0 |
| **TOTAL** | **47** | **36 (77%)** | **10 (21%)** | **1 (2%)** |

---

## Protocol Architecture

### Design Philosophy

EPQB operates on a **zero-trust transport model**:

> **Security Principle: Never Trust The Network**

**Assumptions:**

- Transport provides NO encryption
- Transport provides NO authentication
- Transport provides NO integrity protection
- Attacker can read, modify, drop, replay any packet

**Result:**

- All security MUST come from application layer
- Protocol must be secure over ws:// (plain WebSocket)
- Perfect for testing cryptographic soundness

### Protocol Stack

| Layer | Name | Components |
|-------|------|------------|
| **5** | Application Data | Business logic, user data |
| **4** | EPQB Encryption | ChaCha20-Poly1305 / AES-256-GCM, Fresh nonce per message, Entity ID per message |
| **3** | EPQB Authentication | Mutual Kyber AKE, Dilithium signatures (handshake), Implicit auth (established) |
| **2** | EPQB Message Framing | EApiBridge, EApiEvent, Entity system (unique ID per message) |
| **1** | Transport (HOSTILE) | WebSocket (ws://) - NO SECURITY |

**Layer 1 Attacker Capabilities:**

- Read all packets (plaintext visibility)
- Modify any packet (arbitrary changes)
- Drop packets (selective denial)
- Replay packets (store and resend)
- Inject packets (create fake messages)
- Reorder packets (change sequence)

> **CRITICAL:** Layers 2-5 provide ALL security guarantees. Layer 1 provides ZERO security.

### Core Components

**Entity System:** Each message contains a unique 32-byte cryptographically random ID. This provides the foundation for replay attack protection.

**Kyber Mutual AKE:** Authenticated Key Exchange using post-quantum Kyber algorithm. Both parties derive a shared secret that proves mutual authentication.

**Message Structure:**

- `EApiBridge`: Container with Kyber ciphertext, encrypted payload, and optional signature
- `EApiEvent`: Application payload with sender ID and unique entity ID
- `data_cipher`: Kyber ciphertext (client_init or server_send)
- `data_crypto`: Authenticated encrypted payload
- `data_sign`: Dilithium signature (used in handshake phase)

---

## EPQB Design Advantages

### Cryptographic Algorithm Migration

EPQB supports easy migration if security issues are found:

**Algorithm Agility:**

- ✅ Algorithms are modular and replaceable
- ✅ EnumApiCrypto allows switching crypto suites
- ✅ No protocol redesign needed for algorithm updates
- ✅ Can migrate Kyber → future PQ algorithm if needed
- ✅ Can migrate Dilithium → future PQ signature if needed

**Migration Process:**

1. Add new algorithm to EnumApiCrypto enum
2. Update crypto library implementation
3. Peers negotiate supported algorithms
4. Gradual rollout without breaking existing connections

### Certificate Management (No Expiry Required)

| Aspect | Traditional PKI | EPQB |
|--------|-----------------|------|
| Certificate Expiry | ❌ Requires frequent updates | ✅ No expiry dates required |
| Chain Validation | ❌ Complex multi-level | ✅ Single level |
| Revocation | ❌ CRL/OCSP latency | ✅ Instant via Master Peer |
| Clock Sync | ❌ Required | ✅ Not required |

**Connection Flow:**

| Step | Action | Result |
|------|--------|--------|
| 1 | Check local cache for EPeerPublic | If cached → try direct connection |
| 2 | If no cache or connection fails | Query Master Peer for latest EPeerPublic |
| 3 | Connect using fresh EPeerPublic | Connection established with latest keys |

**Security Benefits:**

- ✅ No expired certificate attacks (no expiry to exploit)
- ✅ Always get latest keys from Master Peer
- ✅ Revocation is instant (Master Peer removes peer)
- ✅ No clock synchronization required
- ✅ Simpler than traditional PKI
- ✅ Reduced attack surface (no expiry validation bugs)

### Simplified Trust Model (No Certificate Chain)

| Model | Chain | Problems/Advantages |
|-------|-------|---------------------|
| **Traditional PKI** | Root CA → Intermediate CA → Intermediate CA → End Entity | ❌ Complex chain validation, ❌ Multiple points of failure, ❌ Large certificate sizes |
| **EPQB** | Master Peer → EPeerPublic | ✅ Single trust anchor, ✅ No intermediate certificates, ✅ Simpler validation |

**EPeerPublic contains:**

- `id`: Peer identifier (derived from public keys)
- `pk`: Kyber public key (for key exchange)
- `pk_sign`: Dilithium public key (for signature verification)
- Signed by Master Peer (proves authenticity)

### Offline Operation & Caching

| Scenario | Behavior |
|----------|----------|
| **Cached EPeerPublic available** | ✅ Direct P2P connection, ✅ No Master Peer query needed, ✅ Works offline |
| **No cache or stale cache** | Query Master Peer once → Cache result → Subsequent connections use cache |
| **Peer key rotation** | Old key fails → Automatic fallback to Master Peer → Get new EPeerPublic → Transparent to application |

> **Result:** Minimal Master Peer dependency after initial setup

### Certificate Revocation (Key Compromise Protection)

**Master Peer Revocation API:** `do_api_del` (UApiMasterPeer::on_api_del)

**Purpose:** Revoke compromised or stolen peer certificates

**Use Cases:**
- Peer secret key compromised/stolen
- Peer device lost or stolen
- Peer wants to rotate keys
- Administrative revocation

**Revocation Flow:**

| Step | Action | Result |
|------|--------|--------|
| 1 | Peer detects key compromise | Peer calls `do_api_del` with signed request (signature proves ownership) |
| 2 | Master Peer processes revocation | Verifies Dilithium signature → Removes EPeerPublic from registry → Returns confirmation |
| 3 | Revocation takes effect immediately | Future queries return "peer not found", cached certs invalid on next MP query |

**Security Properties:**

- ✅ Only certificate owner can revoke (signature required)
- ✅ Instant revocation (no CRL distribution delay)
- ✅ No revocation list to download/check
- ✅ Master Peer is single source of truth
- ✅ Compromised keys cannot re-register (ID bound to keys)
- ✅ Peers can verify revocation status via `do_api_get`

**Verification API:** `do_api_get` (check if certificate still valid)

| Response | Meaning |
|----------|---------|
| Certificate found | Peer is valid, return EPeerPublic |
| Certificate not found | Peer revoked or never existed |

> **High-security mode:** Always query Master Peer before connection. Ensures revoked certificates are never used. Trade-off: extra latency for security.

---

## EPQB vs TLS 1.3 Comparison

### Feature Comparison Table

| Feature | EPQB | TLS 1.3 | Winner |
|---------|------|---------|--------|
| **Quantum Resistance** | ✅ Native (Kyber + Dilithium) | ❌ ECC/RSA vulnerable to Shor | EPQB |
| **Certificate Chain** | ✅ Single trust anchor (Master Peer) | ❌ Root → Intermediate → End Entity | EPQB |
| **Certificate Expiry** | ✅ No expiry required | ❌ Requires expiry management | EPQB |
| **Revocation Check** | ✅ Instant (Master Peer query) | ❌ CRL/OCSP latency | EPQB |
| **Self-Signed Trust** | ✅ Master Peer signs all certs | ❌ Self-signed = untrusted | EPQB |
| **Library Dependencies** | ✅ Minimal (pure crypto libs) | ❌ Heavy (OpenSSL ~500K LOC) | EPQB |
| **Algorithm Agility** | ✅ EnumApiCrypto switchable | ⚠️ Cipher suite negotiation | EPQB |
| **Decentralization** | ✅ P2P with Master Peer registry | ❌ Centralized CA hierarchy | EPQB |
| **Clock Synchronization** | ✅ Not required | ❌ Required for cert validation | EPQB |
| **Offline Operation** | ✅ Cached EPeerPublic works | ❌ May need OCSP/CRL check | EPQB |
| **Protocol Maturity** | ⚠️ New protocol | ✅ Battle-tested since 2018 | TLS 1.3 |
| **Ecosystem Support** | ⚠️ Limited | ✅ Universal browser/server support | TLS 1.3 |
| **Standardization** | ⚠️ Proprietary | ✅ IETF RFC 8446 | TLS 1.3 |

### Detailed Comparison

#### Trust Model

**TLS 1.3 Certificate Chain (Complex):**

| Level | Component | Issues |
|-------|-----------|--------|
| 1 | Root CA (self-signed, pre-installed in OS/browser) | ❌ Root CA compromise = catastrophic |
| 2 | Intermediate CA 1 (cross-signed, validity period) | ❌ Intermediate CA compromise = widespread damage |
| 3 | Intermediate CA 2 (optional) | ❌ More complexity |
| 4 | End Entity Certificate (expires in 1 year) | ❌ Requires renewal automation |

**TLS 1.3 Problems:**

- ❌ Multiple points of failure
- ❌ Complex chain validation logic
- ❌ Revocation (CRL/OCSP) adds latency and complexity

**EPQB Trust Model (Simple):**

| Level | Component | Advantages |
|-------|-----------|------------|
| 1 | Master Peer (single trust anchor, embedded in client) | ✅ Single point of trust |
| 2 | EPeerPublic (peer certificate, no expiry) | ✅ No chain traversal needed |

**EPQB Advantages:**

- ✅ No expiry dates to manage
- ✅ Instant revocation via Master Peer
- ✅ Simpler validation logic
- ✅ Smaller certificate size

#### Quantum Security

| Component | TLS 1.3 | EPQB |
|-----------|---------|------|
| **Key Exchange** | ❌ ECDHE (P-256, X25519) - Shor breaks | ✅ Kyber-1024 (ML-KEM) - Lattice-based, PQ-safe |
| **Key Exchange** | ❌ DHE (finite field) - Shor breaks | ✅ NIST standardized (FIPS 203) |
| **Signatures** | ❌ RSA, ECDSA, Ed25519 - Shor breaks | ✅ Dilithium-5 (ML-DSA) - Lattice-based, PQ-safe |
| **Signatures** | | ✅ NIST standardized (FIPS 204) |

> **Timeline:** Quantum computers expected 2030-2040. Risk: "Harvest now, decrypt later" attacks already ongoing.
>
> **EPQB Result:** Ready for quantum computing era TODAY.

#### Library Dependencies

| Library | Lines of Code | Issues |
|---------|---------------|--------|
| **OpenSSL** | ~500,000 | ❌ Complex build, ❌ Heartbleed history, ❌ Difficult to audit, ❌ Heavy memory |
| **BoringSSL/LibreSSL** | ~200,000+ | ⚠️ Fork maintenance overhead |

> **Attack Surface:** Large codebase = more vulnerabilities

**EPQB Implementation Dependencies:**

| Library | Purpose | Benefit |
|---------|---------|---------|
| pqcrypto-kyber | Key exchange | ✅ Focused, auditable |
| pqcrypto-dilithium | Signatures | ✅ Focused, auditable |
| chacha20poly1305 | AEAD | ✅ Minimal, well-audited |

**EPQB Benefits:**

- ✅ Minimal code footprint
- ✅ Each library does one thing well
- ✅ Easier to audit and verify
- ✅ Smaller attack surface
- ✅ No legacy code baggage

#### Algorithm Agility

| Aspect | TLS 1.3 | EPQB |
|--------|---------|------|
| **Step 1** | IETF standardization (years) | Add new algorithm to EnumApiCrypto enum |
| **Step 2** | Library implementation (months) | Implement crypto wrapper |
| **Step 3** | Server/client updates (months-years) | Deploy to peers |
| **Step 4** | Cipher suite negotiation complexity | Automatic negotiation via enum |
| **Step 5** | Backward compatibility concerns | Gradual rollout, old peers still work |

**Example - Adding PQ to TLS:**

- ❌ Hybrid key exchange proposals still in draft
- ❌ No clear migration path
- ❌ Compatibility issues with existing infrastructure

**Example - EPQB Algorithm Switch:**

- ✅ Add new enum variant
- ✅ Implement wrapper functions
- ✅ No protocol redesign needed

#### Decentralization vs Centralization

**TLS 1.3 / PKI (Centralized):**

| Aspect | Issue |
|--------|-------|
| Trust Hierarchy | ~150 Root CAs trusted by browsers |
| Authority | Any Root CA can sign for any domain |
| Pressure | Government pressure on CAs (surveillance) |
| Conflicts | CA business model conflicts (profit vs security) |
| Risk | Single CA compromise affects millions of sites |

**Historical Incidents:**

- DigiNotar (2011) - Complete CA compromise
- Symantec (2017) - Mass mis-issuance
- Let's Encrypt (2022) - Revocation of 3M certs

**EPQB (Decentralized P2P):**

| Aspect | Benefit |
|--------|---------|
| Registry | Master Peer as registry (not CA) |
| Key Generation | Peers generate own keys (self-sovereign) |
| Storage | Master Peer only stores/serves EPeerPublic |
| Identity | No third-party can sign for your identity |
| Binding | ID cryptographically bound to keys |

**Comparison to Blockchain:**

- ✅ Similar decentralization philosophy
- ✅ Self-sovereign identity (keys = identity)
- ✅ No central authority can forge identity
- ✅ More secure than blockchain (no ECC vulnerability)
- ✅ No consensus overhead (Master Peer is authoritative)
- ✅ Instant finality (no block confirmation wait)

#### Self-Signed Certificate Problem

**TLS 1.3 Self-Signed Issues:**

| Problem | Impact |
|---------|--------|
| Self-signed certs not trusted by browsers | Users must manually add exceptions |
| No way to verify identity without CA | Security gap |
| Internal/private networks | Still need CA infrastructure |

**TLS 1.3 Workarounds:**

- Private CA (complex to manage)
- Let's Encrypt (requires public DNS)
- Ignore warnings (security risk)

**EPQB Solution - No Self-Signed Problem:**

- All peers register with Master Peer
- Master Peer signs EPeerPublic
- Any peer can verify any other peer
- Works for private networks (own Master Peer)
- No browser/OS trust store dependency

**Private Network Deployment:**

1. Deploy your own Master Peer
2. Embed Master Peer public key in clients
3. All internal peers register with your Master Peer
4. Full trust chain without external CA

### Summary: Why EPQB Over TLS 1.3

| Aspect | EPQB Advantage |
|--------|----------------|
| **Future-Proof** | Quantum-resistant from day one, no migration needed |
| **Simplicity** | Single trust anchor vs complex certificate chains |
| **Flexibility** | Easy algorithm switching via EnumApiCrypto |
| **Independence** | No reliance on CA industry or heavy libraries |
| **Decentralization** | P2P model with self-sovereign identity |
| **Operational** | No certificate expiry, instant revocation |
| **Security** | Smaller attack surface, auditable codebase |

**Note:** TLS 1.3 remains the standard for web browsers and general internet traffic. EPQB is designed for peer-to-peer applications, IoT, and systems requiring post-quantum security today.

---

## Detailed Attack Analysis

### 1. Passive Attacks

#### 1.1 Eavesdropping (Packet Sniffing) - ✅ PROTECTED

**Attack:** Attacker reads all traffic on the network

`Alice ────ws://───> [ATTACKER READS] ────ws://───> Bob`

**What Attacker Sees:**

- client_init: Kyber ciphertext (~1568 bytes)
- signature: Dilithium signature (~2420 bytes)
- encrypted_payload: AEAD ciphertext

**What Attacker CANNOT See:**

- ❌ Message contents (encrypted with shared_secret)
- ❌ Shared secrets (Kyber-protected)
- ❌ Private keys (never transmitted)

> **Protection:** Kyber KEM derives shared secret, AEAD encrypts all data
>
> **Result:** CONFIDENTIALITY PRESERVED

#### 1.2 Traffic Analysis Protection - ✅ PROTECTED

**Problem:** If EApiBridge.id == EApiEvent.id, attacker can correlate messages

**Solution: ID Hash Binding**

| Role | Action |
|------|--------|
| **Sender (to_api_bridge)** | `id_hash = BLAKE3(id_from \|\| e_api_event.id \|\| e_api_bridge.id)` - Kyber AKE uses id_hash instead of id_from |
| **Receiver (from_api_bridge)** | 1. Receive id_hash from Kyber AKE → 2. Decrypt payload → 3. Compute expected hash → 4. Verify match → 5. If mismatch → reject |

**Security Benefits:**

- ✅ EApiBridge.id and EApiEvent.id are different (unlinkable)
- ✅ Metadata (id, time) of inner event hidden from attacker
- ✅ Cryptographic binding proves id_from, event_id, bridge_id valid
- ✅ Any tampering with IDs detected via hash mismatch
- ✅ Attacker cannot correlate bridge messages to events

**What Attacker Sees:**

- EApiBridge.id (random, unique per bridge message)
- EApiBridge.time (bridge creation time)
- ❌ Cannot see EApiEvent.id (encrypted inside)
- ❌ Cannot see EApiEvent.time (encrypted inside)
- ❌ Cannot correlate messages across sessions

#### 1.3 Pattern Analysis - ⚠️ PARTIAL (By Design)

> **IMPORTANT:** This is NOT about nonce security!

**AEAD Nonce Security:**

- ✅ Nonce is PUBLIC by design (not a secret)
- ✅ Nonce transmitted in cleartext is SAFE
- ✅ Fresh random nonce per message → SECURE
- ❌ Only danger: reusing same nonce with same key

> EPQB uses fresh random nonce per message → CRYPTOGRAPHICALLY SECURE

**What "Pattern Analysis" actually means - Traffic metadata attacker CAN observe:**

- Message timing (when messages are sent)
- Message frequency (how often peers communicate)
- Message sizes (approximate payload lengths)
- Communication direction (who initiates)
- Session duration (how long peers stay connected)

**Example attack scenarios:**

- 10KB message every hour → likely automated report
- Burst of small messages → likely chat conversation
- Large message after login → likely file download

**Why ⚠️ PARTIAL:**

- ✅ Content is fully encrypted (attacker cannot read)
- ✅ IDs are hidden (Traffic Analysis 1.2 protection)
- ⚠️ Timing patterns visible (when messages sent)
- ⚠️ Size patterns visible (message lengths)
- ⚠️ Frequency patterns visible (communication rate)

**Mitigation (not implemented in EPQB core):**

- Padding messages to fixed sizes
- Adding dummy/cover traffic
- Randomizing timing
- Using overlay networks (Tor, mixnets)

> **Note:** Pattern analysis resistance is typically handled at application layer or by specialized anonymity networks. EPQB focuses on cryptographic security guarantees.

#### 1.5-1.6 Quantum Attacks - ✅ PROTECTED

| Algorithm | Attack | EPQB Status |
|-----------|--------|-------------|
| **Shor's Algorithm** (breaks RSA, ECC) | Kyber | ✅ Lattice-based, NOT vulnerable |
| **Shor's Algorithm** | Dilithium | ✅ Lattice-based, NOT vulnerable |
| **Grover's Algorithm** (speeds up brute force) | ChaCha20-Poly1305 | ✅ 256-bit → 128-bit post-quantum |
| **Grover's Algorithm** | AES-256-GCM | ✅ 256-bit → 128-bit post-quantum |

> **Result:** EPQB is POST-QUANTUM SECURE

### 2. Active Attacks

#### 2.1-2.3 Message Tampering - ✅ PROTECTED

**Attack:** Attacker modifies packets in transit

`Alice ─> [ATTACKER MODIFIES] ─> Bob`

| Tampering Attempt | Result |
|-------------------|--------|
| Flip bits in ciphertext | ❌ AEAD auth tag verification FAILS |
| Replace entire ciphertext | ❌ AEAD auth tag verification FAILS |
| Modify and recalculate auth tag | ❌ Impossible without shared_secret |
| Truncate message | ❌ Message framing validation FAILS |

> **Protection:** AEAD (ChaCha20-Poly1305) provides authenticated encryption
>
> **Result:** INTEGRITY PRESERVED - Any tampering immediately detected

#### 2.6-2.8 Replay Attacks - ✅ PROTECTED

**Attack:** Attacker captures and replays old messages

**Timeline:**

- 10:00 AM - Alice sends legitimate message (Entity ID: 0x3a7f2b...) - [ATTACKER CAPTURES PACKET]
- 10:05 AM - Attacker replays captured message

**Server Validation:**

| Step | Action | Result |
|------|--------|--------|
| 1 | Extract entity ID from message | ID extracted |
| 2 | Check MapId cache: `check_replay_attack(id_event)` | ❌ FOUND! (already processed at 10:00 AM) |
| 3 | Reject | ReplayDuplicateEntity error |

> **Protection:** Entity ID tracking via MapId cache
>
> **Result:** REPLAY ATTACK BLOCKED

#### 2.9 Message Reordering - ✅ PROTECTED

**Attack:** Attacker reorders messages in transit

- Normal: Message 1 → Message 2 → Message 3
- Reordered: Message 3 → Message 1 → Message 2

**EPQB Protection Mechanisms:**

| Layer | Mechanism | Benefit |
|-------|-----------|---------|
| **Transport (WebSocket/TCP)** | TCP guarantees in-order delivery | ✅ Reordering not possible at transport level |
| **Application (EApiEvent.seek)** | seek field provides cursor/sequence position | ✅ Can be used for ordering on unordered transports |

**EApiEvent fields for ordering:**

- `seek`: cursor position / sequence number
- `progress`: progress indicator for multi-part messages
- `length`: total length for chunked transfers
- `time`: timestamp for temporal ordering

**When seek is used (unordered transports like UDP):**

- Receiver can reorder messages by seek value
- Detect missing chunks
- Reassemble large payloads

> **Result:** ORDERING PROTECTED via TCP + seek field available

### 3. MITM Attacks

#### 3.1-3.4 Impersonation & Interception - ✅ PROTECTED

**Attack:** Attacker tries to impersonate Alice to Bob

| Attacker Option | Why It Fails |
|-----------------|--------------|
| Create valid Kyber client_init | ❌ Requires Alice's identity binding, Bob will derive wrong temp_key |
| Forge Dilithium signature | ❌ Requires Alice's private signing key, computationally infeasible |
| Replay Alice's handshake | ❌ Entity ID already processed, cannot derive shared_secret |
| Full MITM (intercept both directions) | ❌ Cannot create valid responses without keys, mutual auth prevents this |

> **Protection:** Kyber AKE + Dilithium signatures + Entity ID tracking
>
> **Result:** IMPERSONATION BLOCKED

### 4. Authentication Attacks

#### 4.3 Signature Forgery - ✅ PROTECTED

**Attack:** Attacker tries to forge Dilithium signature

**Dilithium-5 Security:**

| Property | Value |
|----------|-------|
| Security Level | NIST Level 5 (256-bit equivalent) |
| Based On | Module-LWE and Module-SIS problems |
| Quantum Resistance | Post-quantum secure against known attacks |
| Signature Size | ~2420 bytes |
| Public Key Size | ~1952 bytes |

**Verification in EPQB:**
1. Check signature presence (SignatureMissing error)
2. Verify against sender's public key
3. Reject if invalid (SignatureInvalid error)

> **Protection:** Dilithium-5 post-quantum signatures
>
> **Result:** SIGNATURE FORGERY COMPUTATIONALLY INFEASIBLE

### 5. Key Exchange Attacks

#### 5.1-5.2 KEM Attacks - ✅ PROTECTED

**Kyber-1024 Security:**

| Property | Value |
|----------|-------|
| Security Level | NIST Level 5 (256-bit equivalent) |
| Security Model | IND-CCA2 secure (chosen ciphertext attack resistant) |
| Based On | Module-LWE problem |
| Ciphertext Size | ~1568 bytes |
| Public Key Size | ~1568 bytes |
| Shared Secret | 32 bytes |

**Attack Resistance:**

| Attack | Result |
|--------|--------|
| Ciphertext manipulation | ❌ Decapsulation fails |
| Key mismatch | ❌ AEAD decryption fails |
| Malformed ciphertext | ❌ Rejected by Kyber |

> **Protection:** Kyber IND-CCA2 security + AEAD verification
>
> **Result:** KEM ATTACKS BLOCKED

### 6. Denial of Service

#### 6.1-6.4 Resource Exhaustion - ⚠️ EXTERNAL PROTECTION

**DoS Attack Vectors:**

- Connection flooding
- Handshake flooding (expensive Kyber operations)
- Memory exhaustion (entity ID cache)
- Computational DoS (crypto operations)

**Protection Location:** `evo_core_bridge_client` crate

| Protection | Mechanism |
|------------|-----------|
| Rate limiting | Per IP/peer |
| Connection limits | Max concurrent connections |
| Handshake limits | Max handshake attempts |
| Cache limits | MapId size limits |

> **Note:** DoS protection is handled externally, not in EPQB core

---

## Cryptographic Strength

| Algorithm | Type | Security Level | Quantum Resistant | Key/Signature Size |
|-----------|------|---------------|-------------------|-------------------|
| Kyber-1024 | KEM | 256-bit equivalent | ✅ Yes | PK: 1568B, CT: 1568B |
| Dilithium-5 | Signature | 256-bit equivalent | ✅ Yes | PK: 1952B, Sig: 2420B |
| ChaCha20-Poly1305 | AEAD | 256-bit | ⚠️ 128-bit PQ | Key: 32B, Nonce: 12B |
| AES-256-GCM | AEAD | 256-bit | ⚠️ 128-bit PQ | Key: 32B, Nonce: 12B |
| SHA-256 | Hash | 256-bit | ⚠️ 128-bit PQ | Output: 32B |
| BLAKE3 | Hash | 256-bit | ⚠️ 128-bit PQ | Output: 32B |

**Note:** Symmetric algorithms provide adequate post-quantum security at 256-bit level due to Grover's algorithm only providing quadratic speedup (256-bit → 128-bit effective security).

### Future: ASCON Lightweight Cryptography

**ASCON - NIST Lightweight Cryptography Standard (2023)**

| Property | Description |
|----------|-------------|
| **NIST Standard** | Chosen in 2023 for Lightweight Cryptography |
| **Functionality** | AEAD, hashing, and XOFs |
| **Design** | Sponge construction with SPN (no table lookups) |
| **Target** | Resource-constrained devices (IoT, sensors) |
| **Performance** | Fast in both hardware and software |

**ASCON vs Current EPQB AEAD:**

| Aspect | Current EPQB | ASCON |
|--------|--------------|-------|
| Algorithms | ChaCha20-Poly1305, AES-256-GCM | ASCON-128, ASCON-128a |
| Key Size | 256-bit | 128-bit |
| PQ Security | 128-bit (Grover) | ~100-bit (Grover) |
| Target | General-purpose devices | IoT/embedded |
| Footprint | Standard | ✅ Smaller |
| Side-channel | Depends on implementation | ✅ No table lookups |
| Power | Standard | ✅ Lower consumption |

**ASCON Quantum Security Analysis:**

> **Important Distinction:**
> 
> - ASCON is NOT primary PQC (not lattice-based)
> - NIST PQC focus: Kyber, Dilithium for asymmetric crypto
> - ASCON focus: Lightweight symmetric crypto

**Quantum Resistance:**

- 320-bit internal state provides quantum resilience
- Grover's algorithm less effective than classical attacks
- Ascon-80pq variant: ~100-bit effective PQ security
- Suitable for less critical data in PQ era

> **Note:** NOT designed against Shor's algorithm (symmetric crypto). Shor targets asymmetric crypto (RSA, ECC) - not ASCON.

**EPQB Future Roadmap - ASCON Integration Path:**

1. Add `EnumApiCrypto::PqKDAscon` variant
2. Implement ASCON AEAD wrapper
3. Use for IoT/embedded peer connections
4. Maintain ChaCha20/AES for general-purpose

**Combined Security Stack:**

- ✅ Kyber-1024: Post-quantum key exchange
- ✅ Dilithium-5: Post-quantum signatures
- ✅ ASCON: Lightweight AEAD for constrained devices
- ✅ ChaCha20/AES: General-purpose AEAD

> **Result:** Complete PQ-ready stack for all device classes

| Algorithm | Type | Use Case | Quantum Security | NIST Status |
|-----------|------|----------|------------------|-------------|
| Kyber-1024 | KEM | Key Exchange | ✅ PQ-Safe (Shor) | FIPS 203 |
| Dilithium-5 | Signature | Authentication | ✅ PQ-Safe (Shor) | FIPS 204 |
| ChaCha20-Poly1305 | AEAD | General Encryption | ⚠️ 128-bit PQ (Grover) | RFC 8439 |
| AES-256-GCM | AEAD | General Encryption | ⚠️ 128-bit PQ (Grover) | FIPS 197 |
| ASCON | AEAD | Lightweight/IoT | ⚠️ ~100-bit PQ (Grover) | LWC Standard 2023 |

**Key Takeaway:** ASCON provides excellent security and efficiency for lightweight applications. EPQB's modular design (EnumApiCrypto) allows easy integration of ASCON for IoT deployments while maintaining Kyber + Dilithium for post-quantum asymmetric security.

---

## Security Guarantees

### What EPQB Guarantees

| Property | Guarantee | Mechanism |
|----------|-----------|-----------|
| **Confidentiality** | Only intended recipients can read messages | Kyber KEM + AEAD encryption |
| **Integrity** | Any tampering is detected and rejected | AEAD authentication tag |
| **Authentication** | Both parties cryptographically verified | Kyber AKE + Dilithium signatures |
| **Replay Protection** | Each message processed only once | Entity ID tracking (MapId) |
| **Forward Secrecy** | Per-session keys via Kyber AKE | Session-specific shared secrets |
| **Post-Quantum Security** | Resistant to quantum computer attacks | Kyber + Dilithium algorithms |
| **Non-repudiation** | Sender cannot deny sending (handshake) | Dilithium signatures |

### What EPQB Does NOT Guarantee

| Property | Status | Details |
|----------|--------|---------|
| **Availability** | ❌ Not Protected | DoS attacks possible (rate limiting handled externally in evo_core_bridge_client) |

### What EPQB DOES Guarantee (Clarifications)

| Property | Status | Details |
|----------|--------|---------|
| **Forward Secrecy** | ✅ Protected | EPQB randomly changes shared secret key per session via Kyber AKE. Each session derives fresh keys. |
| **Message Ordering** | ✅ Protected | Implemented via `EApiEvent.seek` (cursor position) and `EApiEvent.time` (timestamp). |
| **Metadata Privacy** | ✅ Protected | ID Hash binding (1.2) ensures EApiBridge.id ≠ EApiEvent.id. Inner event metadata is encrypted and hidden. |
| **Secret Key Compromise** | ⚠️ Revocation Only | If peer's secret key is compromised, the only option is to revoke the certificate via Master Peer (`do_api_del`). Similar to blockchain wallet - if private key is stolen, you can only abandon that wallet/identity. No automatic recovery possible by design (self-sovereign identity). |

---

## Summary

EPQB provides comprehensive protection against the vast majority of cryptographic attacks:

- **77% (36/47)** of analyzed attacks are fully protected
- **21% (10/47)** have partial or external protection
- **2% (1/47)** not protected (message dropping - availability issue)

The protocol achieves strong security guarantees through:

- **Post-quantum cryptography** (Kyber + Dilithium)
- **Authenticated encryption** (ChaCha20-Poly1305 / AES-256-GCM)
- **Replay protection** (Entity ID tracking)
- **Mutual authentication** (Kyber AKE + Dilithium signatures)

\pagebreak