# EPQB vs. Merkle Tree Certificates (MTC)
## A Deep Technical Comparison

> **Scope:** This document compares the **EPQB (Evolved Post-Quantum Bridge)** protocol against
> **Merkle Tree Certificates (MTC)** as proposed by Cloudflare and Google Chrome for the WebPKI,
> across architecture, trust model, connection flows, performance, security, crypto agility,
> resilience, and deployment dimensions. Traditional X.509 PKI is used as a baseline throughout.

---

## Table of Contents

1. [Purpose and Layer of Operation](#1-purpose-and-layer-of-operation)
2. [Trust and Certificate Chain Model](#2-trust-and-certificate-chain-model)
3. [Multi-Master-Peer Redundancy](#3-multi-master-peer-redundancy)
4. [EPQB Connection Flows — Direct, Cached and Relay PQ-VPN Bridge](#4-epqb-connection-flows)
5. [MTC Connection Flow — TLS Handshake with Merkle Certificates](#5-mtc-connection-flow)
6. [Post-Quantum Algorithm Usage and Crypto Agility](#6-post-quantum-algorithm-usage-and-crypto-agility)
7. [Algorithm Migration — The Bitcoin Problem](#7-algorithm-migration--the-bitcoin-problem)
8. [Performance Comparison](#8-performance-comparison)
9. [Security Properties](#9-security-properties)
10. [Revocation Model](#10-revocation-model)
11. [Trust Model Philosophy](#11-trust-model-philosophy)
12. [Deployment and Ecosystem Impact](#12-deployment-and-ecosystem-impact)
13. [Robustness and Resilience](#13-robustness-and-resilience)
14. [Suitability Matrix](#14-suitability-matrix)
15. [Summary Scorecard](#15-summary-scorecard)
16. [Key Insights](#16-key-insights)
17. [Comprehensive Graded Scorecard](#17-comprehensive-graded-scorecard)

---

## 1. Purpose and Layer of Operation

| Dimension | EPQB | MTC (WebPKI) |
|---|---|---|
| **Primary Goal** | Secure PQ peer-to-peer messaging transport | Replace X.509 certificates in TLS for web server auth |
| **OSI Layer** | Application layer (above TLS) | TLS handshake authentication layer |
| **Scope** | Private, closed-membership peer networks | Public Internet — billions of servers, hundreds of CAs |
| **Controls both ends?** | Yes — same system governs all peers | No — CAs, browsers, servers are independent actors |
| **Standard body** | Internal protocol design | IETF PLANTS WG + Chrome + Cloudflare |
| **PQ status today** | Full PQ stack — production ready | Phase 1 experiment live (Chrome+Cloudflare); Phase 3 CQRS trust store target Q3 2027 |

EPQB and MTC are **complementary**, not competing. EPQB sits above TLS; MTC modernizes TLS
authentication itself. A system could use EPQB for its internal peer mesh and MTC-protected TLS
for its public-facing endpoints simultaneously.

---

## 2. Trust and Certificate Chain Model

### 2.1 EPQB — Flat Trust, Multi-Master-Peer, Local Cache

EPQB eliminates the multi-level CA chain through a **self-sovereign, depth-1 trust model**:

- Each peer holds a keypair (Dilithium-5 by default, but fully pluggable).
- One or more **Master Peers** act as trust anchors, signing peer certificates.
- Clients embed **N Master Peer public key certificates** at build/deploy time — static, local,
  never fetched at runtime.
- Chain depth is always **exactly 1**: `Master Peer -> Peer`. No intermediaries.
- After first validated connection, the peer certificate is **cached in secure local storage**,
  enabling instant reconnection without ever contacting the Master Peer again.

```
Traditional X.509   (5-7+ signatures resolved at runtime):
  Root CA --> Int CA --> Issuing CA --> Server Cert
  + CT Log sigs  +  CRL / OCSP (network call required)

MTC                 (1 sig in handshake + 2 pre-synced at landmark time):
  [landmark sync, ~weekly, out-of-band:]
    MTCA treehead sig (covers all certs in batch)
    Revocation treehead sig (covers revoked certs)
  [TLS handshake, 1 signature only:]
    Server handshake sig + server PK + Merkle inclusion proof

EPQB                (1 local verify, zero CA chain):
  Master Peer cert(s) [embedded at build time, N anchors]
        |
        +--> Peer Certificate [verified locally, offline, instantly]
                    |
                    +--> Cached in secure local storage after first validation
                               |
                               +--> Subsequent connections: NO Master Peer contact needed
```

### 2.2 MTC — Compressing but Not Eliminating the Chain

- CAs still exist and issue certificates, now batched as Merkle tree leaves.
- Browsers still ship with Root CA trust stores (100s of CAs, OS/browser-managed).
- CT logs still exist — MTC makes them first-class (MTCA runs its own log).
- Clients must sync **landmark updates** (signed Merkle tree heads) approximately weekly out-of-band.
- If a client's landmark is stale (older than ~1 week), it falls back to a larger traditional cert.

### 2.3 Chain Depth Comparison

| Parameter | Traditional X.509 | MTC | EPQB |
|---|---|---|---|
| **Signatures per connection** | 5-7+ | 1 in handshake (+ 2 pre-synced at landmark time, not per-connection) | 1 local verify (cached: zero network) |
| **Chain depth** | 3-4 levels | 2 (MTCA -> Leaf via Merkle proof; no intermediate CA in handshake) | 1 (Master Peer -> Peer) |
| **Runtime cert fetch?** | Yes (OCSP/CRL) | No (landmark pre-synced) | No (embedded + locally cached) |
| **Trust anchors in client** | 100s Root CA certs (OS) | 100s Root CAs + MTCA landmarks | 1-N Master Peer certs (operator-chosen) |
| **Anchor update required?** | Rare (OS update) | ~Weekly landmark sync | Never (unless Master Peer rotates) |
| **Local cert cache?** | No | No | Yes — secure storage after first validation |
| **CA dependency** | Full | Reduced | Zero |

---

## 3. Multi-Master-Peer Redundancy

### 3.1 The Concept

EPQB clients embed **multiple Master Peer public key certificates** simultaneously. This is a
deliberate architectural decision providing operator-controlled resilience unavailable in X.509
or MTC.

```
Client embedded trust store (set at build/deploy time, immutable at runtime):

  +---------------------------------------------------------------+
  |  Master Peer A cert  -- Primary      (region: EU, Dilithium-5)|
  |  Master Peer B cert  -- Secondary    (region: US, Dilithium-5)|
  |  Master Peer C cert  -- Emergency    (air-gapped, FALCON-1024)|
  +---------------------------------------------------------------+

  A peer certificate signed by ANY of these is accepted as valid.
  All verification is local. No network contact needed.
```

### 3.2 Security and Availability Benefits

| Benefit | Description |
|---|---|
| **High Availability** | If Master Peer A is offline, Master Peer B provisions new peers. Existing cached sessions are unaffected regardless. |
| **Geographic Redundancy** | Deploy Master Peers per region. Validation is local — no cross-region latency. |
| **Algorithm Diversity** | Each Master Peer can use a different PQ algorithm. Old peers validate via Master Peer A (Dilithium-5); upgraded peers via Master Peer C (FALCON). Multi-algorithm coexistence. |
| **Disaster Recovery** | Air-gapped Master Peer C is pre-embedded but offline. If A and B are both compromised, C activates instantly — its cert is already in all clients. |
| **Trust Segmentation** | Different Master Peers govern different peer classes (read-only vs. write-access). Clients embed only the relevant subset. |
| **Zero-Downtime Key Rotation** | Embed old and new Master Peer certs simultaneously during rotation. Remove old cert only after all peer certs have been re-signed. Zero downtime. |
| **Blast Radius Limitation** | If one Master Peer is compromised, only its signed peers are at risk. Peers signed by other Master Peers remain fully trusted and unaffected. |

### 3.3 Anchor Count and Resilience Comparison

| System | Anchors Embedded | Operator-Controlled? | Redundancy |
|---|---|---|---|
| **Traditional X.509** | 100s Root CAs (OS trust store) | No — vendor decides | High count but uncontrolled — any CA can issue for any domain |
| **MTC** | 100s Root CAs + MTCA landmarks (weekly) | No — browser vendor controls | Moderate — landmark staleness is a failure mode |
| **EPQB (single Master Peer)** | 1 cert | Yes — full operator control | None — SPOF |
| **EPQB (multi Master Peer)** | N certs (operator-chosen) | Yes — full operator control | Strong — N-of-any, operator-designed |

> In X.509/MTC, 100s of Root CAs is a security **liability** — any one compromised CA can issue
> rogue certs for any domain. In EPQB, N Master Peer certs is a security **asset** — each under
> operator control. A compromised one is removed at next redeploy without affecting peers signed
> by the others.

### 3.4 Multi-Master-Peer vs. MTC Landmark Sync

| Dimension | EPQB Multi-Master-Peer | MTC Landmark Sync |
|---|---|---|
| **Update mechanism** | Embedded at build/deploy (static) | Auto-synced out-of-band (~weekly, dynamic) |
| **Network dependency** | None — all anchors already local | Required — must reach MTCA infrastructure |
| **Expiry / freshness** | Never — embedded certs do not expire by design | ~1 week — stale landmark forces fallback |
| **Offline functionality** | Full — all N anchors available locally forever | Full within validity window, degraded after |
| **Operator control** | Total — operator chooses which Master Peers to embed | Partial — browser vendor controls landmark trust |
| **Attack surface** | Only operator-controlled Master Peers | Any trusted Root CA + MTCA infrastructure |

---

## 4. EPQB Connection Flows

EPQB supports two connection modes, selected automatically based on network reachability:
**Direct Connection** (known peer, reachable network path) and **Relay/Bridge Connection**
(NAT traversal via a Relay Peer acting as a PQ-VPN bridge). Both modes maintain full
end-to-end PQ encryption using the Kyber AKE + Dilithium authentication stack.

---

### 4.1 EPQB — First Connection to a Known Peer (Direct, No Cache)

```
CLIENT (Alice)                   MASTER PEER                    SERVER (Bob)
     |                                |                               |
     |  [BOOTSTRAP -- build time]     |                               |
     |  Embeds N Master Peer certs    |                               |
     |  in secure local storage       |                               |
     |                                |                               |
     |========== PHASE 1: CERTIFICATE ACQUISITION ==================|
     |                                |                               |
     |-- request Bob's cert -------> |                               |
     |                                |-- verify Alice is valid peer  |
     |<-- Bob's signed cert --------- |                               |
     |                                |                               |
     |  [LOCAL VALIDATION -- offline] |                               |
     |  Verify Bob's cert signature   |                               |
     |  against embedded Master       |                               |
     |  Peer cert(s)                  |                               |
     |  No network call needed.       |                               |
     |                                |                               |
     |  Check enemy list:             |                               |
     |  Bob not present -> proceed    |                               |
     |                                |                               |
     |  STORE Bob's cert in           |                               |
     |  local secure storage          |                               |
     |  keyed by Bob's peer ID        |                               |
     |                                |                               |
     |========== PHASE 2: KYBER AKE HANDSHAKE ======================|
     |                                |                               |
     |-- client_init: ------------------------------------------------>|
     |   Kyber-1024 ciphertext (~1,568 B)                             |
     |   ML-DSA-87 (Dilithium-5) signature (~4,595 B)                 |
     |   id_hash = BLAKE3(id_from || EApiEvent.id || EApiBridge.id)  |
     |                                |                               |
     |                                |  [Bob verifies Dilithium sig  |
     |                                |   against Alice's cert]       |
     |                                |  [Bob decapsulates Kyber      |
     |                                |   -> derives shared_secret]   |
     |                                |  [Bob verifies id_hash        |
     |                                |   -> no tampering]            |
     |                                |  [Bob checks MapId cache      |
     |                                |   -> no replay]               |
     |                                |                               |
     |<-- server_response: Kyber ciphertext + Dilithium sig ---------|
     |    [Alice derives same shared_secret via Kyber decapsulation]  |
     |                                |                               |
     |========== PHASE 3: ENCRYPTED SESSION =======================  |
     |                                |                               |
     |<====== AEAD encrypted payload (ChaCha20-Poly1305 / AES-GCM) ==>|
     |         Key    = shared_secret derived via Kyber AKE           |
     |         Nonce  = fresh random per message (never reused)       |
     |         Tag    = 16 bytes per message (tamper detection)       |
     |         Inner EApiEvent: fully encrypted (id, time, payload)   |
     |                                |                               |
     |  [Per message -- replay guard] |                               |
     |  MapId cache: check entity ID  |                               |
     |  -> reject replays instantly   |                               |
     |                                |                               |

RESULT: Full PQ-secure session established.
Bob's cert is cached locally. Master Peer NOT contacted again for this peer.
```

---

### 4.2 EPQB — Reconnection to Known Peer (Cached Certificate, Zero Master Peer Contact)

After first successful connection, Bob's validated certificate is stored in Alice's local
secure storage. All future connections skip certificate acquisition entirely. The Master Peer
is NOT contacted. Trust resolution is purely local and instant.

```
CLIENT (Alice)                                              SERVER (Bob)
     |                                                           |
     |  [CACHED STATE -- secure local storage]                   |
     |  Bob's peer cert: verified and stored                     |
     |  Bob's peer ID:   known                                   |
     |  Enemy list:      Bob not present                         |
     |                                                           |
     |========== PHASE 1: SKIPPED ENTIRELY ===================== |
     |  No Master Peer contact.                                  |
     |  No cert fetch.                                           |
     |  Local cert validation only: instant, offline.            |
     |                                                           |
     |========== PHASE 2: KYBER AKE HANDSHAKE ================  |
     |                                                           |
     |-- client_init: Kyber CT + Dilithium sig + id_hash ------> |
     |                                                           |
     |<-- server_response: Kyber CT + Dilithium sig ------------ |
     |   [Fresh shared_secret derived -- new per-session key]    |
     |   [Forward secrecy: each session uses independent key]    |
     |                                                           |
     |========== PHASE 3: ENCRYPTED SESSION ================    |
     |                                                           |
     |<====== AEAD encrypted messages =========================> |
     |                                                           |

RESULT: Full PQ-secure session with ZERO Master Peer contact
and ZERO network overhead for trust resolution.
Forward secrecy guaranteed -- fresh Kyber AKE derives new key every session.

Master Peer is contacted again ONLY when:
  - Bob's cert is revoked (received via Master Peer push notification)
  - Bob's cert has been migrated to a new algorithm (migration proof received)
  - Alice explicitly requests a cert refresh
  - Alice adds Bob to enemy list and propagates the revocation to Master Peer
```

---

### 4.3 EPQB — Relay Peer List: Provisioning, Caching, and Fallback

Before Alice can use a Relay Peer, she must know which peers in the network are authorized to
act as relays. This is not self-declared by peers — it is **authoritatively signed by the
Master Peer** and cached locally by the client, following the same trust model as regular
peer certificates.

#### 4.3.1 Relay Peer List Lifecycle

```
MASTER PEER                              CLIENT (Alice)
     |                                         |
     |  [Master Peer maintains authoritative   |
     |   list of certified relay peers]        |
     |  Each relay peer has:                   |
     |   - Normal peer keypair (Kyber + DSA)   |
     |   - Master Peer signed cert             |
     |   - relay=true capability flag          |
     |                                         |
     |-- signed relay peer list ------------> |
     |   Signature: ML-DSA-87 by Master Peer  |
     |   Payload: [RelayPeer1.cert,            |
     |              RelayPeer2.cert, ...]      |
     |                                         |
     |  [Alice verifies list signature         |
     |   against embedded Master Peer cert]    |
     |  [Local verification only -- offline]   |
     |                                         |
     |  STORE relay peer list in               |
     |  local secure storage                   |
     |  (same secure store as peer certs)      |
     |                                         |

RESULT: Alice has a locally cached, cryptographically verified
list of valid relay peers she can use without contacting anyone.
```

#### 4.3.2 Using a Cached Relay Peer (No Master Peer Contact Needed)

```
CLIENT (Alice)                        RELAY PEER (Carol)
     |                                       |
     |  [Relay needed: Bob unreachable]      |
     |                                       |
     |  Check local relay peer list cache:   |
     |  Carol is present and cert is valid.  |
     |  No Master Peer contact required.     |
     |                                       |
     |-- Kyber AKE + ML-DSA to Carol -----> |
     |   Alice presents her cert             |
     |   Carol validates vs embedded         |
     |   Master Peer cert (local, offline)   |
     |                                       |
     |<-- Carol accepts session ------------ |
     |                                       |
     |  [Alice uses Carol as relay to Bob]   |
```

#### 4.3.3 Relay Peer Cache Miss or Connection Failure → Fallback to Master Peer

If Alice's cached relay peer list is stale, all listed relay peers are unreachable, or a
relay peer connection unexpectedly fails mid-attempt, Alice falls back to contacting the
Master Peer to obtain a fresh signed relay peer list:

```
CLIENT (Alice)                  MASTER PEER                  RELAY PEER (Carol)
     |                               |                               |
     |  [Cached relay list: stale    |                               |
     |   OR all cached relays fail]  |                               |
     |                               |                               |
     |-- request updated relay list->|                               |
     |                               |  [Master Peer assembles      |
     |                               |   current active relay list]  |
     |                               |  [Signs with ML-DSA-87]      |
     |                               |                               |
     |<-- fresh signed relay list -- |                               |
     |    [RelayPeer1.cert (stale),  |                               |
     |     RelayPeer3.cert (new),    |                               |
     |     RelayPeer4.cert (new)]    |                               |
     |                               |                               |
     |  [Alice verifies signature    |                               |
     |   locally vs Master Peer cert]|                               |
     |  [Updates local cache]        |                               |
     |                               |                               |
     |  [Alice retries with a newly  |                               |
     |   listed relay peer]          |                               |
     |                               |                               |
     |-- Kyber AKE + ML-DSA -------> |                               |
     |   (using new relay from list) | --> Carol (or new relay)      |
     |                               |                               |

RESULT: Relay peer selection is always Master Peer-authoritative,
locally cached, and self-healing. The network adapts without
user action when relay topology changes.
```

#### 4.3.4 Relay Peer List Trust Summary

| Event | Action | Master Peer Contact? |
|---|---|---|
| First deployment | Master Peer pushes signed relay list | Yes — once at setup |
| Cached list, relay reachable | Use relay directly from cache | **No** |
| Cached relay fails connection | Try next cached relay first | **No** |
| All cached relays exhausted | Contact Master Peer for fresh list | Yes — on demand |
| Relay peer revoked | Master Peer pushes updated list | Pushed by Master Peer |
| Network topology change | Master Peer pushes updated list | Pushed by Master Peer |

---

### 4.4 EPQB — Relay Connection via Relay Peer (PQ-VPN Bridge, NAT Traversal)

When Alice and Bob cannot connect directly (NAT, firewall, unknown IP, unreachable network),
EPQB routes the connection through a **Relay Peer** acting as a bridged PQ-VPN tunnel.
The Relay Peer is a network participant with a Master-Peer-signed certificate and the
`relay=true` capability. It forwards encrypted packets between Alice and Bob but
**cannot read their content** — end-to-end encryption is maintained fully between Alice and Bob.

```
CLIENT (Alice)               RELAY PEER (Carol)               SERVER (Bob)
     |                             |                                |
     |  [Alice cannot reach Bob directly: NAT / firewall / unknown IP]
     |  [Alice selects Carol from her cached relay peer list]        |
     |                             |                                |
     |======= PHASE 1: ALICE AUTHENTICATES TO RELAY PEER =========  |
     |                             |                                |
     |-- Kyber AKE + ML-DSA ----> |                                |
     |   Alice presents her cert   |                                |
     |   (Master Peer signed)      |                                |
     |                             |  [Carol validates Alice cert   |
     |                             |   vs embedded Master Peer cert]|
     |                             |  [Carol checks Alice is NOT    |
     |                             |   on Carol's enemy list]       |
     |                             |  [Carol ACCEPTS if valid]      |
     |<-- Carol accepts session -- |                                |
     |                             |                                |
     |======= PHASE 2: BOB AUTHENTICATES TO RELAY PEER ==========   |
     |                             |                                |
     |                             | <-- Kyber AKE + ML-DSA ------- |
     |                             |     Bob presents his cert      |
     |                             |     (Master Peer signed)       |
     |                             |  [Carol validates Bob cert     |
     |                             |   vs embedded Master Peer cert]|
     |                             |  [Carol checks Bob is NOT      |
     |                             |   on Carol's enemy list]       |
     |                             | --> Carol accepts Bob session  |
     |                             |                                |
     |======= PHASE 3: EAPIBRIDGE ESTABLISHED ==================    |
     |                             |                                |
     |  EApiBridge created:        |                                |
     |  .id       = random, unique per bridge instance              |
     |  .time     = bridge creation timestamp                       |
     |  id_hash   = BLAKE3(id_from || EApiEvent.id || EApiBridge.id)|
     |                             |                                |
     |  EApiBridge.id != EApiEvent.id   (unlinkable by design)      |
     |  Inner EApiEvent fields are encrypted inside AEAD payload    |
     |                             |                                |
     |======= PHASE 4: END-TO-END ENCRYPTED TUNNEL ==============   |
     |                             |                                |
     |                      +------+------+                         |
     |-- AEAD(payload) ---> |  STRICT     | -- AEAD(payload) -----> |
     |                      |  RELAY:     |                         |
     |<- AEAD(payload) ---- |  forward    | <-- AEAD(payload) ----- |
     |                      |  only       |                         |
     |                      |             |                         |
     |                      | Carol sees ONLY:                      |
     |                      |  EApiBridge.id  (random -- not Alice  |
     |                      |   or Bob's real ID)                   |
     |                      |  EApiBridge.time                      |
     |                      |  Ciphertext blob (opaque)             |
     |                      |  Message size + timing metadata       |
     |                      |             |                         |
     |                      | Carol CANNOT see:                     |
     |                      |  EApiEvent.id   (encrypted inside)    |
     |                      |  EApiEvent.time (encrypted inside)    |
     |                      |  Message content (AEAD encrypted)     |
     |                      |  Alice/Bob shared_secret (Kyber-only) |
     |                      |  Session correlation across time      |
     |                      +------+------+                         |
     |                             |                                |

CAROL'S STRICT RELAY BEHAVIOR:
  [1] Authenticate connecting peer (Kyber AKE + ML-DSA signature)
  [2] Verify peer cert vs embedded Master Peer cert (local, offline)
  [3] Check peer is NOT on Carol's local enemy list
      -> If on enemy list: REJECT immediately, no forwarding
      -> If not on enemy list: accept session
  [4] Forward AEAD-encrypted packets between Alice and Bob ONLY
      -> Carol relays packets between the two established sessions
      -> Carol does NOT initiate connections on its own behalf
      -> Carol does NOT inspect, modify, store, or log packet content
      -> Carol does NOT selectively drop packets (except enemy list)
      -> Carol does NOT bridge more than the two established peers
         per EApiBridge instance

SECURITY GUARANTEES OF RELAY MODE:
  [OK] Confidentiality:   Carol cannot read Alice<->Bob messages
  [OK] Integrity:         AEAD tag -- any tampering detected and rejected
  [OK] Authentication:    Both Alice and Bob verified via Master Peer signed certs
  [OK] Relay authorization: Carol is Master Peer signed, from Alice's verified list
  [OK] Unlinkability:     EApiBridge.id != EApiEvent.id (BLAKE3 id_hash binding)
  [OK] NAT traversal:     Alice and Bob only need to reach Carol -- not each other
  [OK] Enemy list enforcement: Carol rejects any peer on its local enemy list
  [!!] Partial gap:       Carol sees message timing, size, frequency (traffic metadata)
                          Full traffic analysis resistance requires overlay networks

RESULT: Full end-to-end PQ-VPN tunnel between Alice and Bob, routed through Carol.
Carol is a Master-Peer-authorized relay that learns NOTHING about message
content or inner event identifiers, and enforces enemy list policy strictly.
```

---

### 4.5 Security Analysis — KEM-Only vs KEM + Signature in Relay Authentication

A natural engineering question arises: **could the relay authentication be simplified to
KEM-only (Kyber), dropping the ML-DSA signature?** This section analyzes the security
consequences carefully.

#### What KEM (Kyber) alone provides:
- **Confidentiality:** Establishes a shared secret that no passive eavesdropper can recover.
- **Forward secrecy:** Each session uses a fresh Kyber ephemeral key exchange.
- **Key agreement:** Both parties derive the same session key.

#### What KEM alone does NOT provide:
- **Authentication:** Kyber encapsulation uses the server's *public key*, but a public key
  alone does not prove identity. Any party in possession of a peer's public key (including
  an adversary who has extracted it from a packet or a compromised peer list) can perform
  a KEM exchange.
- **Non-repudiation:** Without a signature, there is no cryptographic proof that the
  connecting peer actually holds the corresponding private key at connection time.
- **Protection against impersonation / man-in-the-middle:** Without a signature binding the
  KEM exchange to a verified identity, an active adversary (Mallory) can execute the
  following attack:

```
KEM-ONLY RELAY AUTHENTICATION -- MITM ATTACK (if signatures removed):

Alice --> [Kyber encapsulate to Carol's pubkey] --> Mallory (intercepts)
                                                         |
                                             Mallory decapsulates
                                             using stolen/extracted Carol pubkey
                                             Mallory re-encapsulates to real Carol
                                                         |
                                             Mallory --> [fake Carol session] --> Carol
                                             Mallory sees:
                                               - All Alice->Bob traffic (decrypted)
                                               - Can inject modified packets
                                               - Carol and Bob are unaware

ATTACK SUCCEEDS because:
  - KEM alone proves nothing about WHO encapsulated
  - Alice cannot verify Carol is the legitimate Carol
    (the entity she encapsulates to might be Mallory with Carol's pubkey)
  - Carol cannot verify Alice is the legitimate Alice
    (any party can perform a KEM encapsulation)
```

#### Why ML-DSA signature is mandatory in EPQB relay authentication:

```
KEM + SIGNATURE (current EPQB design) -- MITM BLOCKED:

Alice --> [Kyber CT + ML-DSA sig (signed with Alice's private key)] --> Carol
                                                                           |
                                                         Carol verifies:
                                                           [1] ML-DSA sig valid
                                                               -> Only Alice can produce this
                                                               -> Proves Alice holds private key
                                                           [2] Cert signed by Master Peer
                                                               -> Alice is an authorized peer
                                                           [3] Alice NOT on enemy list
                                                         Carol accepts ONLY if all 3 pass.

Mallory cannot forge Alice's ML-DSA signature without Alice's private key.
Mallory cannot insert a fake session because Carol will reject any
connection without a valid Master-Peer-signed cert + valid signature.
```

#### Security Analysis Summary

| Property | KEM Only (Hypothetical) | KEM + ML-DSA (Current EPQB) |
|---|---|---|
| **Passive eavesdropping** | ✅ Protected (Kyber) | ✅ Protected (Kyber) |
| **Forward secrecy** | ✅ Per-session key | ✅ Per-session key |
| **Identity authentication** | ❌ **None** — public key ≠ identity proof | ✅ Signature proves private key possession |
| **Impersonation protection** | ❌ **Vulnerable** — any party can KEM-encapsulate | ✅ Unforgeable without private key |
| **MITM by active adversary** | ❌ **Fully vulnerable** — Mallory can insert fake relay | ✅ Blocked — Mallory cannot forge ML-DSA sig |
| **Relay authorization** | ❌ Cannot verify relay is Master Peer signed | ✅ Cert signature verified locally |
| **Enemy list enforcement** | ❌ Cannot reliably identify WHO is connecting | ✅ Identity proven before enemy list check |
| **Replay attack** | ❌ Partially — without sig binding, replays harder to detect | ✅ id_hash + MapId cache prevent replays |

> **Conclusion:** KEM-only relay authentication is **fundamentally insecure** for an
> authenticated peer network. The ML-DSA signature is not optional overhead — it is what
> transforms an anonymous key exchange into a verified, authorized, non-repudiable
> peer authentication. Removing it would reduce EPQB relay to a slightly better-than-unauthenticated
> proxy, fully vulnerable to active man-in-the-middle attacks. The KEM + Signature combination
> is the correct and necessary design.

---

### 4.6 EPQB Connection Mode Decision Flow

```
  Alice wants to connect to Bob
            |
            v
  +-----------------------------+
  | Is Bob's cert in local      |
  | secure storage (cache)?     |
  +-----------------------------+
            |
      NO    |    YES
            |      |
            v      v
  Contact   |   Validate cached cert
  Master    |   locally (offline, instant)
  Peer:     |      |
  fetch Bob |      |
  cert      |      |
            v      |
  Validate  |      |
  vs local  |      |
  Master    |      |
  Peer cert |      |
  Store in  |      |
  cache     |      |
            +------+
                   |
                   v
        +---------------------+
        | Is Bob on Alice's   |
        | local enemy list?   |
        +---------------------+
               |        |
              YES        NO
               |         |
               v         v
           REJECT      Can Alice reach Bob directly?
                              |              |
                             YES              NO
                              |               |
                              v               v
                        DIRECT MODE      Select Relay Peer
                        Kyber AKE +      from local cached
                        ML-DSA sig       relay list
                        direct P2P            |
                        connection            v
                                    Relay reachable?
                                       |         |
                                      YES         NO
                                       |           |
                                       v           v
                                  Connect to   Try next
                                  relay peer   cached relay
                                  (auth: KEM        |
                                  + ML-DSA sig) All exhausted?
                                       |           |
                                       |           v
                                       |    Contact Master Peer
                                       |    for fresh signed
                                       |    relay peer list
                                       |    Retry with new list
                                       |           |
                                       +-----------+
                                             |
                                             v
                                    EApiBridge tunnel
                                    PQ-VPN bridged E2E
                                    Alice <--> Carol <--> Bob
```

---

## 5. MTC Connection Flow

MTC operates inside the TLS handshake. The browser must have a recently synced landmark
(signed Merkle tree head) to validate the server's Merkle certificate efficiently.

---

### 5.1 MTC — Landmark Sync (Out-of-Band, Periodic ~Weekly)

During landmark sync (background process, ~weekly), the client pre-downloads and verifies
**2 signatures** from the MTCA. These are stored locally and do NOT appear in the TLS handshake:

```
BROWSER / CLIENT               MTCA (Merkle Tree CA)
     |                               |
     |  [Background, ~weekly]        |
     |                               |
     |-- request latest landmark --> |
     |                               |  [MTCA maintains growing Merkle tree]
     |                               |  Each issued cert = one leaf
     |                               |  Landmark = signed (sub)tree head
     |                               |
     |<-- signed landmark package:   |
     |    (1) MTCA issuance treehead sig  (covers all certs in batch)
     |    (2) Revocation treehead sig     (covers revoked cert positions)
     |    Both: ML-DSA signatures by MTCA                               |
     |                               |
     |  Store both locally.          |
     |  Valid for approximately one week.
     |  These 2 sigs are NEVER retransmitted in TLS handshakes.
     |                               |

RESULT: Client is ready to validate any MTC covered by this landmark
WITHOUT any signature verification during the actual TLS handshakes.
The expensive MTCA sig verification happened once here, not per-connection.
```

---

### 5.2 MTC — TLS Handshake Fast Path (Landmark Valid) — 1 Sig Only

```
BROWSER / CLIENT                                          WEB SERVER
     |                                                         |
     |  [Client has a valid landmark -- synced recently]       |
     |  [2 MTCA sigs already verified locally at sync time]    |
     |                                                         |
     |========== TLS ClientHello ============================  |
     |-- ClientHello: "I have landmarks [batch_42, batch_43]" ->|
     |                                                         |
     |  [Server: does my MTC match any client landmark?]       |
     |  [Server has Merkle cert for batch_42 -> match found]   |
     |                                                         |
     |========== TLS ServerHello + MTC Certificate =========   |
     |                                                         |
     |<-- ServerHello ---------------------------------------- |
     |<-- MTC Certificate:                                     |
     |    Subject: cloudflareresearch.com                      |
     |    Public key: ML-DSA-44 (or ECDSA in experiment)       |
     |    NO signature field -- signatureless by design        |
     |    Merkle inclusion proof:                              |
     |      [h_sibling_1, h_sibling_2, ..., h_n]              |
     |      log2(N) x 32 bytes -- hashes only, NOT signatures  |
     |<-- 1 TLS handshake signature (ML-DSA, by server)        |
     |    This is the ONLY new signature in the handshake.     |
     |                                                         |
     |========== CLIENT VALIDATION (all local) =============== |
     |                                                         |
     |  1. Recompute Merkle path from cert leaf to root         |
     |  2. Compare computed root vs stored landmark treehead    |
     |     (landmark treehead already verified at sync -- free) |
     |  3. Check revocation: cert position in revocation tree   |
     |     Sparse: cert position = zeros -> valid              |
     |     Sorted: cert ID not found between neighbors -> valid |
     |     (revocation tree sig already verified at sync)       |
     |  4. Verify server TLS handshake sig (1 x ML-DSA)        |
     |     THIS IS THE ONLY SIGNATURE VERIFIED IN HANDSHAKE    |
     |                                                         |
     |========== TLS APPLICATION DATA =======================  |
     |                                                         |
     |<====== AEAD encrypted application data =================>|
     |                                                         |

Signatures in the TLS handshake:     1 (server ML-DSA only)
Signatures verified at landmark sync: 2 (MTCA issuance treehead + revocation treehead)
Merkle inclusion proof:               log2(N) x 32-byte hashes (NOT signatures)
Total auth bytes in handshake (ML-DSA-44 experiment): ~4,052B
  = 1 x 2,420B sig + 1 x 1,312B PK + ~320B Merkle proof
```

---

### 5.3 MTC — TLS Handshake Slow Path (Stale Landmark Fallback)

```
BROWSER / CLIENT                                          WEB SERVER
     |                                                         |
     |  [Client landmark is stale -- older than ~1 week]       |
     |                                                         |
     |-- ClientHello: no valid landmark IDs -----------------> |
     |                                                         |
     |  [Server: client has no matching landmark]              |
     |  [Server falls back to traditional certificate]         |
     |                                                         |
     |<-- Traditional X.509 certificate chain ---------------- |
     |    5-7 signatures including CT log sigs                 |
     |    Size: up to ~16,940 bytes for PQ ML-DSA              |
     |                                                         |
     |  [Client must refresh landmark out-of-band]             |
     |                                                         |

RESULT: Graceful degradation -- session works, full overhead returned.
Performance benefit of MTC is lost until landmark is refreshed.
```

---

### 5.4 Flow Comparison at a Glance

```
+----------------------------------------------------------------------+
|  EPQB DIRECT -- Cached Peer                                          |
|                                                                      |
|  Alice --[Kyber AKE + Dilithium, local cert verify]--> Bob          |
|           No network for trust. No CA. No CT. No OCSP.              |
|           Master Peer: NOT contacted.                                |
|           Trust resolution: microseconds (local crypto only)        |
+----------------------------------------------------------------------+

+----------------------------------------------------------------------+
|  EPQB RELAY -- PQ-VPN Bridge (NAT Traversal)                        |
|                                                                      |
|  Alice selects Carol from her Master-Peer-signed cached relay list.  |
|  Alice --[Kyber AKE + ML-DSA]--> Carol(Relay) --[forward]--> Bob    |
|           Full end-to-end AEAD encryption. Carol sees only           |
|           ciphertext and random bridge IDs. Enemy list enforced.     |
|           Carol relays packets only -- does not inspect or store.    |
|           If relay fails: try next cached relay, then re-fetch list  |
|           from Master Peer.                                          |
+----------------------------------------------------------------------+

+----------------------------------------------------------------------+
|  MTC -- Fast Path (Fresh Landmark)                                   |
|                                                                      |
|  Browser --[TLS ClientHello + landmark IDs]--> Server               |
|           <--[MTC cert + Merkle proof + 1 ML-DSA sig]--             |
|           Landmark pre-synced weekly (2 MTCA sigs verified then).   |
|           Only 1 sig in handshake. Auth bytes: ~4,052B.             |
|           MTCA: NOT contacted during handshake.                     |
+----------------------------------------------------------------------+

+----------------------------------------------------------------------+
|  MTC -- Slow Path (Stale Landmark Fallback)                          |
|                                                                      |
|  Browser --[TLS ClientHello, no landmark]--> Server                 |
|           <--[Traditional X.509 chain, 5-7 sigs]--                  |
|           Full PQ overhead ~16,940 bytes.                           |
|           Landmark sync required out-of-band before next attempt.   |
+----------------------------------------------------------------------+
```

---

## 6. Post-Quantum Algorithm Usage and Crypto Agility

### 6.1 Algorithm Support Matrix

EPQB uses a **pluggable crypto negotiation layer** (`EnumApiCrypto`). KEM, signature, and
AEAD are each independently selectable and swappable per connection. MTC has no equivalent
— algorithm changes require CA/Browser Forum consensus, browser updates, and multi-year
ecosystem transitions.

| Algorithm | Role | EPQB | MTC / WebPKI |
|---|---|---|---|
| **ML-KEM / Kyber-1024** | Key encapsulation | ✅ Default KEM | ❌ Not used in cert auth |
| **ML-DSA-44 / Dilithium-2** | Authentication (Level 2) | ✅ Pluggable | ⚠️ Level used in Cloudflare experiment — smallest PQ sig option |
| **ML-DSA-65 / Dilithium-3** | Authentication (Level 3) | ✅ Pluggable | ⚠️ Usable but larger |
| **ML-DSA-87 / Dilithium-5** | Authentication (Level 5, highest) | ✅ Default in EPQB | ⚠️ Too large for naive TLS — the core problem MTC solves |
| **FALCON-512 / FN-DSA-512** | Smaller PQ signature (Level 1) | ✅ Pluggable via EnumApiCrypto | ⚠️ Ecosystem change required |
| **FALCON-1024 / FN-DSA-1024** | Smaller PQ signature (Level 5) | ✅ Pluggable | ⚠️ Ecosystem change required |
| **ChaCha20-Poly1305** | AEAD encryption | ✅ Default | ❌ Not in MTC scope |
| **AES-256-GCM** | AEAD encryption | ✅ Supported | ❌ Not in MTC scope |
| **ASCON-AEAD128** | Lightweight AEAD (IoT) | ✅ Planned roadmap | ❌ Not addressed |
| **BLAKE3** | Hash / ID binding | ✅ Traffic analysis protection | ❌ Not used |
| **SHA-256** | Hash | ✅ Supported | ✅ Merkle tree node hashing |
| **Future PQ KEMs** | Any NIST-standardized KEM | ✅ Pluggable -- add EnumApiCrypto variant | ⚠️ Requires full ecosystem change |
| **ECDSA-P256** | Legacy signature | ❌ Not used -- no legacy crypto | ⚠️ Still used in current MTC experiment |
| **RSA** | Legacy signature | ❌ Not used | ⚠️ Still in legacy WebPKI |

### 6.2 AEAD Pluggability

| AEAD | Key Size | PQ Security (Grover) | Target | EPQB | MTC |
|---|---|---|---|---|---|
| **ChaCha20-Poly1305** | 256-bit | 128-bit effective | General purpose, mobile, software | ✅ Default | ❌ |
| **AES-256-GCM** | 256-bit | 128-bit effective | Hardware-accelerated servers | ✅ Supported | ❌ |
| **ASCON-AEAD128** | 128-bit | ~100-bit effective | IoT, sensors, embedded, low-power | ✅ Planned | ❌ |

> NIST selected the Ascon family in February 2023 following its Lightweight Cryptography competition.
> The final standard was published as NIST SP 800-232 in August 2025, specifying Ascon-AEAD128
> for authenticated encryption. It uses a 128-bit key and 128-bit nonce, operates via a sponge
> construction with a 320-bit internal state, and has no table lookups — giving natural
> side-channel resistance. EPQB IoT peers can negotiate ASCON while server peers use ChaCha20 or
> AES, all within the same network, negotiated per-connection via EnumApiCrypto.

### 6.3 Full Cryptographic Strength Reference

| Algorithm | Type | NIST Level | PQ Safety | Sizes |
|---|---|---|---|---|
| **Kyber-1024 (ML-KEM-1024)** | KEM | Level 5 (256-bit equiv.) | ✅ Shor-safe (Module-LWE) | PK: 1,568B, CT: 1,568B |
| **ML-DSA-44 (Dilithium-2)** | Signature | Level 2 (128-bit equiv.) | ✅ Shor-safe (Module-LWE+SIS) | PK: 1,312B, Sig: 2,420B |
| **ML-DSA-65 (Dilithium-3)** | Signature | Level 3 (192-bit equiv.) | ✅ Shor-safe (Module-LWE+SIS) | PK: 1,952B, Sig: 3,293B |
| **ML-DSA-87 (Dilithium-5)** | Signature | Level 5 (256-bit equiv.) | ✅ Shor-safe (Module-LWE+SIS) | PK: 2,592B, Sig: 4,595B |
| **FALCON-512 (FN-DSA-512)** | Signature | Level 1 (128-bit equiv.) | ✅ Shor-safe (NTRU lattice) | PK: 897B, Sig: ~666B avg |
| **FALCON-1024 (FN-DSA-1024)** | Signature | Level 5 (256-bit equiv.) | ✅ Shor-safe (NTRU lattice) | PK: 1,793B, Sig: ~1,280B avg |
| **ChaCha20-Poly1305** | AEAD | 256-bit | ⚠️ 128-bit (Grover) | Key: 32B, Nonce: 12B |
| **AES-256-GCM** | AEAD | 256-bit | ⚠️ 128-bit (Grover) | Key: 32B, Nonce: 12B |
| **ASCON-AEAD128** | AEAD | 128-bit | ⚠️ ~100-bit (Grover) | Key: 16B, Nonce: 16B, Tag: 16B |
| **BLAKE3** | Hash | 256-bit output | ⚠️ 128-bit (Grover) | Output: 32B |
| **SHA-256** | Hash | 256-bit output | ⚠️ 128-bit (Grover) | Output: 32B |

> Symmetric primitives are only affected by Grover's algorithm (quadratic speedup), not Shor's
> (which breaks RSA/ECC). At 256-bit key sizes, 128-bit effective PQ security is considered
> adequate for symmetric encryption and hashing.

---

## 7. Algorithm Migration -- The Bitcoin Problem

### 7.1 The Core Challenge

If a critical vulnerability is discovered in a deployed PQ algorithm, traditional PKI systems
face a cascading migration crisis requiring every CA, browser, and server to coordinate.
Historically this takes **years** -- TLS 1.3 took approximately 5 years to reach majority
deployment despite being strictly superior to TLS 1.2.

### 7.2 The Bitcoin Cautionary Tale

Bitcoin uses ECDSA on secp256k1. A quantum computer running Shor's algorithm breaks ECC,
permanently exposing all wallets whose public keys have ever appeared on-chain (i.e., any
wallet that has ever made a transaction).

The migration problem is unsolvable within Bitcoin's design: there is no trustless mechanism
to prove an old ECC key and a new PQ key belong to the same owner. Any migration transaction
must be signed with the ECC key -- exposing it to quantum attack at the exact moment it is
most needed. Funds in exposed wallets are **permanently and irrecoverably at risk**. This is
a known, acknowledged, unresolved vulnerability in every ECC-based blockchain.

### 7.3 EPQB Solution -- Cryptographic Identity Handover

```
EPQB Algorithm Migration Flow:

+------------------------------------------------------------+
|  TRIGGER: Vulnerability discovered in deployed algorithm   |
|  Example: critical weakness found in Dilithium-5           |
+------------------------------------------------------------+
                    |
                    v
Step 1: Peer generates NEW keypair under new algorithm
        Example: FALCON-1024

Step 2: OLD certificate signs NEW certificate
        +----------------------------------------------------+
        |  old_dilithium5_cert.sign(new_falcon1024_pubkey)   |
        |                                                    |
        |  "I, [old Dilithium-5 identity], assert:           |
        |   [FALCON-1024 public key X] is my new identity." |
        +----------------------------------------------------+
        -> Cryptographic, unforgeable, tamper-evident handover
        -> Any peer can verify this chain independently

Step 3: Master Peer co-signs new cert, revokes old cert
        -> Migration proof is now double-anchored

Step 4: Migration proof pushed to ALL peers via Master Peer
        -> No user action required
        -> No ecosystem consensus needed
        -> Old and new algorithm versions coexist during transition

Step 5: All peers update local secure storage automatically

Step 6: Next connection uses new algorithm automatically
```

### 7.4 Migration Comparison

| Dimension | EPQB | MTC / WebPKI | Bitcoin / ECC Blockchain |
|---|---|---|---|
| **Algorithm upgrade path** | ✅ Old cert signs new cert -- seamless | ⚠️ CA reissues -- manual, coordinated | ❌ No migration path |
| **Identity continuity** | ✅ Cryptographic proof of handover | ⚠️ New cert = new identity | ❌ Permanently at risk |
| **Time to migrate** | Fast -- Master Peer orchestrates push | Slow -- ecosystem consensus | N/A -- impossible |
| **Ecosystem consensus required** | ❌ Self-contained | ✅ All browsers/CAs/servers | N/A |
| **Audit trail** | ✅ Old sig over new cert -- verifiable | ⚠️ CT log shows both, no explicit link | ❌ None |
| **Old/new coexistence** | ✅ Both algorithm versions valid during transition | ⚠️ Fallback cert strategy needed | ❌ N/A |
| **Offline migration** | ✅ Local records updated via Master Peer push | ❌ CA connectivity required | ❌ N/A |

---

## 8. Performance Comparison

### 8.1 Handshake Authentication Overhead (Bytes)

> **Important clarification:** For MTC, the MTCA treehead signature and revocation treehead
> signature are **pre-synced out-of-band** (landmark sync, ~weekly) and stored locally. They are
> NOT transmitted in the TLS handshake. Only 1 server signature crosses the wire during the
> handshake itself, plus 1 public key and 1 Merkle inclusion proof.

| Scenario | Sigs in handshake | Auth bytes in handshake (approx.) |
|---|---|---|
| **Traditional TLS (ECDSA-P256)** | 5-7 × 64B sig + 5-7 × 64B PK | ~640–896B |
| **Naive PQ TLS (ML-DSA-44, 5 sigs)** | 5 × 2,420B sig + 2 × 1,312B PK | ~14,724B |
| **Naive PQ TLS (ML-DSA-87 / Dilithium-5, 5 sigs)** | 5 × 4,595B sig + 2 × 2,592B PK | ~28,159B |
| **MTC fast path (ML-DSA-44 — level used in experiment)** | 1 × 2,420B sig + 1 × 1,312B PK + ~320B Merkle proof | **~4,052B** in handshake |
| **EPQB (ML-DSA-87/Dilithium-5 + Kyber-1024, first conn)** | 1 × 4,595B sig + 1,568B KEM CT | ~6,163B |
| **EPQB (ML-DSA-44 + Kyber-1024, if lower level chosen)** | 1 × 2,420B sig + 1,568B KEM CT | ~3,988B |
| **EPQB (FALCON-512 + Kyber-1024, pluggable)** | 1 × 666B sig + 1,568B KEM CT | ~2,234B |
| **EPQB reconnect (any variant, cached cert)** | Same as first conn — no extra network for cert | Same sig bytes, zero cert-fetch overhead |

> **Note on EPQB default:** EPQB's default signature scheme is Dilithium-5 (ML-DSA-87, NIST
> Level 5). This gives the highest authentication security but larger handshake bytes than the
> Level-2 variant used in the MTC Cloudflare experiment. EPQB's crypto agility allows operators
> to choose a lower security level (ML-DSA-44) or smaller-sig scheme (FALCON-512) if bandwidth
> is constrained.

### 8.2 Per-Message Overhead (Post-Handshake)

Both systems use symmetric AEAD after the handshake. Per-message overhead is identical and minimal.

| System | Per-Message Auth Overhead |
|---|---|
| **EPQB** | AEAD tag: 16B + nonce: 12B = 28B per message |
| **TLS (any cert type)** | AEAD tag: 16B + nonce per TLS record |

### 8.3 Latency Profile

| Scenario | EPQB Direct | EPQB Relay | MTC Fast Path | MTC Slow Path |
|---|---|---|---|---|
| **Cold start (first conn)** | 1 Master Peer cert fetch, then local | Relay auth + bridge setup | Pre-synced landmark, instant | No landmark: full X.509 chain |
| **Warm reconnect (cached)** | Instant -- local crypto only | Instant -- certs cached | Fast -- landmark still valid | Slow if landmark stale |
| **Trust resolution** | Local (microseconds) | Local (microseconds) | Local (landmark) | Network (CA chain lookup) |
| **Offline client** | Full -- no network for auth ever | Full -- relay still needed for routing | Full within ~1 week | Fails if OCSP required |
| **NAT / no direct path** | Fails -- need direct route | ✅ Relay Peer PQ-VPN | N/A (HTTP uses public routing) | N/A |
| **Master Peer / MTCA offline** | Reconnects: unaffected. New peers: paused. | Relay: unaffected | New certs: paused. Existing: OK. | Same as fast path |

---

## 9. Security Properties

### 9.1 Core Security Guarantees

| Property | EPQB | MTC (WebPKI) |
|---|---|---|
| **Confidentiality** | ✅ Kyber KEM + AEAD (ChaCha20 / AES / ASCON) | ✅ TLS AEAD (separate from MTC scope) |
| **Integrity** | ✅ AEAD auth tag per message | ✅ Merkle root sig + TLS AEAD |
| **Authentication** | ✅ Kyber AKE + Dilithium-5 (pluggable) | ✅ ML-DSA server sig + MTCA Merkle sig |
| **Replay protection** | ✅ Entity ID tracking (MapId cache) | ✅ Cert validity window (~1 week) |
| **Forward secrecy** | ✅ Fresh Kyber AKE per session | ✅ TLS ephemeral key exchange |
| **Post-quantum (Shor's)** | ✅ Full -- Kyber + Dilithium, no RSA/ECC | ✅ When fully deployed -- ECDSA still in experiment |
| **Post-quantum (Grover's)** | ✅ 256-bit AEAD -> 128-bit effective PQ | ✅ Same |
| **Non-repudiation** | ✅ Dilithium sig on handshake | ✅ ML-DSA server sig |
| **Traffic analysis resistance** | ⚠️ Partial -- ID hash binding; timing/size visible | ❌ Not addressed |
| **Certificate transparency** | ❌ N/A -- no CAs | ✅ First-class via MTCA log |
| **Misissuance detection** | ❌ N/A | ✅ Bootstrap cert cross-check |
| **Multi-anchor redundancy** | ✅ N Master Peer certs embedded | ❌ Root CA store is OS/browser-fixed |
| **Local cert cache** | ✅ Secure storage -- offline instant reconnect | ❌ No equivalent |
| **NAT traversal** | ✅ Relay Peer PQ-VPN bridge | ❌ Not applicable |
| **Relay confidentiality** | ✅ Relay sees only ciphertext -- E2E AEAD | ❌ Not applicable |

### 9.2 Traffic Analysis Protection (EPQB-Specific)

EPQB implements **ID Hash Binding** using BLAKE3:

```
id_hash = BLAKE3(id_from || EApiEvent.id || EApiBridge.id)

Attacker on wire SEES:          Attacker CANNOT see:
  EApiBridge.id (random)          EApiEvent.id      (encrypted inside)
  EApiBridge.time                 EApiEvent.time    (encrypted inside)
  Ciphertext length               Message content   (AEAD encrypted)
  Message timing                  Shared secret     (Kyber-protected)
  Message frequency               Session correlation across time
```

Remaining visible (partial gap, by design): timing, size, frequency patterns.
Full traffic analysis resistance requires padding, cover traffic, or overlay networks
(Tor, mixnets) -- application-layer concerns outside EPQB core scope.

### 9.3 Attack Surface Comparison

| Attack | EPQB | MTC |
|---|---|---|
| **MITM / Impersonation** | ✅ Blocked -- Kyber AKE + Dilithium + entity ID | ✅ Blocked -- ML-DSA + MTCA Merkle |
| **Replay attack** | ✅ Blocked -- MapId entity ID cache | ✅ Blocked -- cert validity window |
| **Message tampering** | ✅ Blocked -- AEAD auth tag fails on any bit flip | ✅ Blocked -- TLS AEAD |
| **Quantum attack (Shor's)** | ✅ Protected -- no RSA/ECC | ⚠️ Partial -- ECDSA still in experiment |
| **Quantum attack (Grover's)** | ✅ 256-bit -> 128-bit effective | ✅ Same |
| **Signature forgery** | ✅ Infeasible -- Dilithium-5 NIST Level 5 | ✅ Infeasible -- ML-DSA |
| **CA compromise** | ❌ N/A -- no CAs | ⚠️ Possible -- CT makes it detectable post-facto |
| **Master Peer compromise** | ⚠️ Serious -- multi-Master-Peer limits blast radius | N/A |
| **Relay peer impersonation** | ✅ Blocked — relay list is Master-Peer-signed; ML-DSA proves relay identity | N/A |
| **Fake relay injection** | ✅ Blocked — only Master-Peer-authorized relays in signed list | N/A |
| **Relay eavesdropping** | ✅ Blocked -- E2E AEAD; relay sees only ciphertext | ❌ N/A |
| **KEM-only MITM at relay** | ✅ Blocked — ML-DSA signature mandatory; KEM alone would be vulnerable | N/A |
| **DoS** | ⚠️ External rate limiting (bridge client) | ⚠️ External only |
| **Protocol ossification** | ✅ Controlled -- both ends updated together | ⚠️ High risk -- billions of clients/middleboxes |
| **Nonce reuse** | ✅ Fresh random nonce per message | ✅ Same in TLS |
| **Message reordering** | ✅ TCP ordering + EApiEvent.seek field | ✅ TCP ordering |

---

## 10. Revocation Model

EPQB implements a **three-tier revocation model** that is more granular, faster at the local
level, and more operator-controlled than either X.509 or MTC.

```
THREE-TIER EPQB REVOCATION:

TIER 1 -- LOCAL (instant, offline, zero network required):
+-----------------------------------------------------------+
|  Any client adds compromised peer to local ENEMY LIST     |
|  Effect:   Immediate. Rejection before any cryptography.  |
|  Network:  NONE required.                                 |
|  Latency:  Zero -- in-memory lookup.                      |
+-----------------------------------------------------------+
                    |
                    | (optional -- client propagates upward)
                    v
TIER 2 -- NETWORK PROPAGATION (fast push):
+-----------------------------------------------------------+
|  Client calls do_api_del -> Master Peer                   |
|  Master Peer broadcasts revocation to ALL peers (push)    |
|  Effect:   Network-wide within seconds to minutes.        |
|  Model:    PUSH -- no polling required.                   |
+-----------------------------------------------------------+
                    |
                    v
TIER 3 -- AUTHORITATIVE LEDGER (persistent):
+-----------------------------------------------------------+
|  Master Peer canonical revoked-identity list              |
|  All new peers receive this list on onboarding            |
|  Effect:   Persistent across restarts and partitions.     |
+-----------------------------------------------------------+
```

### 10.1 Revocation Comparison

| Aspect | EPQB | MTC | Traditional X.509 |
|---|---|---|---|
| **Local revocation** | ✅ Instant enemy list -- zero network | ❌ No local authority | ❌ No local authority |
| **Revocation authority** | Any client (local) + Master Peer (global) | Issuing CA only | Issuing CA only |
| **Propagation model** | Push (Master Peer -> all peers) | Pull (clients sync Merkle tree) | Pull (CRL TTL / OCSP) |
| **Speed -- local** | Instant (in-memory) | N/A | N/A |
| **Speed -- global** | Seconds to minutes (push) | Hours to days (batch + landmark sync) | Hours (CRL) / real-time (OCSP) |
| **Offline check** | ✅ Enemy list is local -- no network | ✅ Merkle proof self-contained (within window) | ❌ OCSP needs network; CRL may be stale |
| **Granularity** | Per-peer per-client (local) + network-wide (global) | Network-wide only | Network-wide only |
| **Analogy** | Firewall blocklist (local) + cert revocation (global) | Improved cert revocation | Traditional cert revocation |

---

## 11. Trust Model Philosophy

| Dimension | EPQB | MTC |
|---|---|---|
| **Model** | Self-sovereign identity (SSI) | Delegated trust (CA hierarchy) |
| **Root of trust** | Network operator -- controls Master Peer(s) | IANA Root CAs + browser vendors |
| **Trust establishment** | Embedded at build time -- static, operator-controlled | OS/browser install + weekly landmark sync |
| **Trust anchor count** | 1 to N (operator-chosen) | 100s Root CAs (not operator-controlled) |
| **Third-party dependency** | None -- fully self-contained | CAs, browser vendors, IETF, CA/Browser Forum |
| **Decentralized?** | Partially -- no CAs; Master Peer(s) are operator-controlled | No -- CAs centralized; MTC does not decentralize |
| **Key recovery** | None by design -- identity migration via old-signs-new | CA can reissue (process-dependent) |
| **Membership control** | Master Peer(s) control peer admission | CA controls cert issuance |
| **Jurisdiction independence** | ✅ Full -- no CA trust policy dependency | ❌ Partial -- browser vendor Root CA policies apply |
| **Open to public?** | No -- closed peer network | Yes -- any domain |

---

## 12. Deployment and Ecosystem Impact

| Factor | EPQB | MTC |
|---|---|---|
| **Deployment scope** | Private / enterprise / government peer networks | Public Internet |
| **Client update required** | No -- trust anchors embedded at build time | Yes -- landmark sync infrastructure needed |
| **Peer update required** | Full EPQB stack | New cert issuance pipeline + MTCA support |
| **Legacy compatibility** | N/A -- controlled environment | ⚠️ Critical -- billions of clients/middleboxes |
| **CA ecosystem change** | Eliminates CAs entirely | Adds MTCA layer on top of existing CAs |
| **Rollout risk** | Low -- closed system, both sides controlled | High -- TLS 1.3 took ~5 years due to ossification |
| **Fallback on failure** | Hard error -- no fallback to weaker mode by design | Graceful -- falls back to larger traditional cert |
| **Standards dependency** | None -- internal protocol | IETF PLANTS + Chrome + CA/Browser Forum |
| **Full PQ coverage** | ✅ Today -- complete stack deployed | ⚠️ Years -- ECDSA still in current experiment |
| **Algorithm update mechanism** | Internal -- operator via EnumApiCrypto | External -- CA/Browser Forum consensus required |

---

## 13. Robustness and Resilience

| Scenario | EPQB | MTC |
|---|---|---|
| **Primary Master Peer offline** | Secondary Master Peer(s) handle new provisioning -- zero downtime | N/A -- no equivalent redundancy model |
| **All Master Peers offline** | Existing sessions: unaffected (cached certs). New provisioning: paused. Enemy list: still enforced. | MTCA offline: new issuance halts; existing certs valid until expiry |
| **Landmark / anchor stale** | N/A -- embedded Master Peer certs never expire by design | Falls back to larger traditional cert (performance penalty) |
| **Network partition** | Fully operational -- all auth is local via cached certs | Fully operational within cert validity window |
| **Algorithm vulnerability discovered** | Fast migration -- old-signs-new, pushed by Master Peer | Slow -- CA/Browser Forum + ecosystem coordination required |
| **Single Master Peer compromised** | Other embedded Master Peer certs remain valid -- limited blast radius | N/A |
| **Mass peer revocation** | Local enemy list (instant per-client) + Master Peer global push (seconds) | Merkle revocation batch (hours) + landmark sync (up to weekly) |
| **Client software not updated** | Fully functional -- embedded certs are static, no sync required | Functional within landmark window; degrades after |
| **NAT / unreachable peer** | ✅ Relay Peer PQ-VPN bridge -- automatic transparent fallback | ❌ Not applicable |
| **Audit trail** | Entity ID tracking (internal log per-network) | CT log (public, tamper-evident, global) |

---

## 14. Suitability Matrix

| Use Case | Best Fit | Why |
|---|---|---|
| **Secure IoT / sensor mesh** | EPQB | Controlled peers, ASCON for constrained devices, local revocation, no CA infrastructure |
| **Enterprise microservices (mTLS)** | EPQB | Master Peer replaces CA, cached certs, fast reconnects, crypto agility |
| **Public HTTPS websites** | MTC | Requires publicly trusted certs, browser compatibility, open CA model |
| **Multi-tenant SaaS** | MTC | Third-party clients need publicly verifiable certificates |
| **Air-gapped / offline networks** | EPQB | Zero dependency on external CA or landmark infrastructure |
| **Government / military comms** | EPQB | SSI, no third-party CA jurisdiction dependency, multi-master redundancy |
| **Blockchain / P2P protocols** | EPQB | SSI model, crypto agility, identity migration -- solves Bitcoin ECC problem |
| **Open API (3rd party clients)** | MTC | Publicly verifiable certificate required by third-party clients |
| **High-security P2P messaging** | EPQB | E2E PQ, traffic analysis protection, local revocation, forward secrecy |
| **NAT-traversal P2P networks** | EPQB | Relay Peer PQ-VPN bridge -- transparent, fully encrypted, E2E confidential |
| **Post-Q-day emergency migration** | EPQB | Fast algorithm migration without ecosystem consensus -- critical under time pressure |

---

## 15. Summary Scorecard

| Parameter | EPQB | MTC | Winner |
|---|---|---|---|
| **Algorithm suite** | Fully pluggable (EnumApiCrypto) | Fixed by CA/Browser Forum | 🏆 EPQB |
| **Crypto agility** | ✅ Swap KEM / sig / AEAD independently | ❌ Ecosystem-wide coordination required | 🏆 EPQB |
| **Algorithm migration** | ✅ Old cert signs new cert -- seamless | ⚠️ CA reissues -- slow, unlinked | 🏆 EPQB |
| **Identity continuity on migration** | ✅ Cryptographic proof of handover | ⚠️ New cert = new identity | 🏆 EPQB |
| **Multi-anchor redundancy** | ✅ N Master Peer certs -- operator-controlled | ❌ Root CA store -- browser-controlled | 🏆 EPQB |
| **Local cert cache (fast reconnect)** | ✅ Secure storage -- instant, offline | ❌ No equivalent | 🏆 EPQB |
| **Trust anchor count** | 1 to N (operator-chosen) | 100s (externally mandated) | 🏆 EPQB |
| **Handshake bytes (ML-DSA-44 / Dilithium-2)** | EPQB: ~3,988B (sig 2,420B + Kyber CT 1,568B) | MTC: ~4,052B (1 sig + 1 PK + Merkle proof) | 🤝 Comparable at same level |
| **Handshake bytes (ML-DSA-87 / Dilithium-5)** | EPQB: ~6,163B (sig 4,595B + Kyber CT 1,568B) | MTC: ~6,907B (if ML-DSA-87 used) | 🤝 Comparable at same level |
| **Handshake bytes (FALCON-512)** | EPQB: ~2,234B (pluggable) | MTC: ~4,052B (FALCON not in MTC experiment) | 🏆 EPQB |
| **Cert chain depth** | 1 | 2 | 🏆 EPQB |
| **Runtime CA dependency** | None | None (post-MTC) | 🤝 Tie |
| **Client anchor update** | Never (static embed) | ~Weekly landmark sync | 🏆 EPQB |
| **Forward secrecy** | ✅ Per-session Kyber AKE | ✅ TLS ephemeral | 🤝 Tie |
| **Local revocation (offline)** | ✅ Instant enemy list | ❌ Not possible | 🏆 EPQB |
| **Global revocation speed** | Fast -- Master Peer push (seconds) | Slow -- batch + landmark (hours/days) | 🏆 EPQB |
| **NAT traversal** | ✅ Relay Peer PQ-VPN bridge | ❌ Not applicable | 🏆 EPQB |
| **Relay confidentiality** | ✅ E2E AEAD -- relay sees only ciphertext | ❌ Not applicable | 🏆 EPQB |
| **Public auditability** | ❌ Internal log only | ✅ Public CT logs | 🏆 MTC |
| **Misissuance protection** | N/A -- no CAs | ✅ Bootstrap cert cross-check | 🏆 MTC |
| **Open public membership** | ❌ Closed network | ✅ Any domain | 🏆 MTC |
| **Deployment complexity** | Low -- closed system | High -- Internet-wide coordination | 🏆 EPQB |
| **PQ completeness today** | ✅ Full stack deployed | ⚠️ ECDSA still in experiment | 🏆 EPQB |
| **Quantum safety (Shor's)** | ✅ Kyber + Dilithium | ✅ When fully deployed | 🤝 Tie (eventually) |
| **Quantum safety (Grover's)** | ✅ 256-bit -> 128-bit PQ | ✅ Same | 🤝 Tie |
| **Traffic analysis resistance** | ⚠️ Partial (ID hash binding) | ❌ None | 🏆 EPQB |
| **AEAD algorithm choice** | ✅ ChaCha20 / AES / ASCON (pluggable) | ❌ Not in scope | 🏆 EPQB |
| **IoT / constrained device support** | ✅ ASCON planned | ❌ Not addressed | 🏆 EPQB |

**Final tally (within applicable scope): EPQB wins 21, MTC wins 3, Ties 5.**

---

## 16. Key Insights

### Important Clarifications on Algorithm Naming and MTC Signature Model

**On ML-DSA / Dilithium naming:** NIST FIPS 204 standardizes three parameter sets:
ML-DSA-44 (= old Dilithium-2, NIST Level 2, Sig: 2,420B, PK: 1,312B),
ML-DSA-65 (= old Dilithium-3, NIST Level 3, Sig: 3,293B, PK: 1,952B), and
ML-DSA-87 (= old Dilithium-5, NIST Level 5, Sig: 4,595B, PK: 2,592B).
EPQB's default "Dilithium-5" corresponds to ML-DSA-87. The Cloudflare/Chrome MTC experiment
uses ML-DSA-44 (the smallest PQ signature option) to minimize handshake size.

**On MTC signatures:** The MTCA treehead signature and revocation treehead signature are verified
**once** during the weekly landmark sync and stored locally. They do NOT appear in the TLS
handshake. The handshake contains only **1 signature** (the server's own TLS handshake sig),
**1 public key**, and **1 Merkle inclusion proof** (hashes only, not signatures). This is the
key architectural insight of MTC — expensive MTCA verification happens once per week per client,
not once per connection.



EPQB is a complete PQ-native protocol stack for **controlled, closed networks**. Its architectural
decisions compound into a qualitatively superior security posture for its target environment:

1. **Eliminate the CA chain** — Embedding Master Peer cert(s) at build time collapses the entire
   CA hierarchy to depth-1. No runtime chain resolution, no CT, no OCSP, no CRL.

2. **Cache validated peer certs locally** — After first successful connection, the peer certificate
   is stored in secure local storage. All future reconnections require zero Master Peer contact,
   zero network for trust resolution — just fast local crypto. The Master Peer is contacted again
   only when a cert is revoked, migrated, or explicitly refreshed.

3. **Relay Peer list is Master-Peer-signed and locally cached** — Alice never discovers relay
   peers by self-announcement. The Master Peer issues a signed list of authorized relay peers.
   Alice verifies the list locally against her embedded Master Peer cert, caches it in secure
   storage, and uses it directly without contacting anyone. If all cached relays fail, she
   contacts the Master Peer for a fresh signed list and retries. The relay topology is always
   Master-Peer-authoritative and self-healing.

4. **Relay Peer behavior is strictly limited** — A Relay Peer does exactly two things: verify
   the connecting peer's cert (Kyber AKE + ML-DSA signature, locally against Master Peer cert),
   check the peer is not on its local enemy list, and if both pass, forward AEAD-encrypted
   packets between Alice and Bob. The relay does not initiate connections, does not inspect
   content, does not log, does not store payloads, and does not bridge more than the two
   established peers per EApiBridge instance.

5. **KEM-only relay authentication would be a critical vulnerability** — A KEM exchange (Kyber)
   alone proves confidentiality but not identity. Without the ML-DSA signature, any active
   adversary (Mallory) who obtains Carol's public key could intercept Alice's session, perform
   the KEM exchange herself, and re-relay to the real Carol — a full MITM attack with no
   detection possible. The ML-DSA signature is what converts an anonymous key exchange into
   a verified, authorized, non-repudiable peer authentication. It is not optional overhead:
   the signature is what lets Carol know WHO is connecting, enabling meaningful enemy list
   enforcement. KEM + Signature together is the correct and mandatory design.

6. **Relay Peer as PQ-VPN bridge** — When direct connection is impossible due to NAT, firewalls,
   or unknown IP, the relay forwards encrypted packets without being able to read them. End-to-end
   AEAD encryption is maintained between Alice and Bob. EApiBridge ID hash binding ensures the
   relay cannot correlate inner event identifiers. The relay is confidentially transparent — it
   sees only random bridge IDs, timestamps, and ciphertext blobs.

7. **Embed multiple anchors** — Multiple Master Peer public keys provide operator-controlled
   redundancy, geographic distribution, and smooth algorithm diversity without the security
   liabilities of the WebPKI's 100+ Root CA model.

8. **Pluggable crypto everywhere** — EnumApiCrypto makes every algorithm layer independently
   swappable. Algorithm vulnerability found? Migrate the entire network in hours without any
   external coordination.

9. **Three-tier revocation** — Local enemy list (instant, offline) + Master Peer push (fast,
   global) + authoritative ledger. Strictly superior to CRL/OCSP and MTC Merkle revocation
   in every dimension except public auditability.

10. **Cryptographic identity handover** — Old cert signs new cert. Solves the migration problem
    that has no answer in X.509, MTC, or any ECC-based blockchain.

### MTC Architecture Summary

MTC is an IETF-driven effort to make the existing WebPKI survive the post-quantum transition.
It cannot make EPQB's architectural choices because the public web requires independent,
publicly-auditable CA chains. Its contributions are:

1. **Compress the chain** — Merkle tree batching reduces 5-7 signatures in the TLS handshake to
   just 1, with the MTCA treehead and revocation signatures pre-synced weekly out-of-band.
   This makes PQ-sized signatures bearable at Internet scale without performance degradation.

2. **First-class transparency** — MTCA running its own log eliminates separate CT log signatures
   while improving auditability.

3. **Graceful degradation** — Fallback to traditional certs ensures zero breakage during the
   transition period -- critical for an ecosystem serving billions of users.

### The Bitcoin Problem — A Warning for All Legacy Systems

Bitcoin cannot migrate from ECC to PQ. Any migration transaction exposes the ECC key to quantum
attack at the moment it is most needed. Funds in addresses with exposed public keys are
permanently at risk post-Q-day. EPQB's old-signs-new mechanism solves this exactly -- it is the
property the entire legacy PKI world and all ECC-based blockchains currently lack, and it was
designed in from the start, not bolted on afterward.

### In Summary

| | EPQB | MTC |
|---|---|---|
| **Solves CA chain by** | Eliminating it | Compressing it |
| **Handshake bytes** | EPQB with ML-DSA-87: ~6,163B; with FALCON-512: ~2,234B | MTC with ML-DSA-44: ~4,052B (1 sig in handshake) | Comparable; FALCON-512 gives EPQB edge |
| **Solves NAT by** | Relay Peer PQ-VPN bridge — Master-Peer-signed list, locally cached, self-healing | Not applicable |
| **Relay authorization** | Master Peer signs relay list; clients cache and verify locally; fallback on failure | Not applicable |
| **Relay security** | KEM + ML-DSA signature mandatory — KEM-only would enable full MITM | Not applicable |
| **Relay behavior** | Forward only between two established peers; enemy list enforced; no inspection | Not applicable |
| **Solves algorithm migration by** | Cryptographic identity handover (old signs new) | No equivalent mechanism |
| **Solves trust anchor redundancy by** | Embedding N Master Peer certs (operator-controlled) | No operator-controlled equivalent |
| **Solves revocation by** | Local enemy list + Master Peer push | Merkle revocation tree + landmark sync |
| **Target** | Closed, controlled peer networks | Public Internet / WebPKI |
| **PQ readiness** | Complete today | Transition in progress |

Both are architecturally correct for their deployment contexts. EPQB's design freedom -- arising
from controlling both ends of every connection -- allows choices the open Internet simply cannot
accommodate. MTC works elegantly within the constraints of the existing web ecosystem.
A future system could use EPQB for its internal peer mesh and MTC-protected TLS for its
public-facing API endpoints simultaneously -- they are complementary, not competing.


---

## 17. Comprehensive Graded Scorecard

> **Grading scale:** A++ (exceptional, no known limitation) · A+ (excellent) · A (strong, minor gaps)
> · B+ (good with notable caveats) · B (adequate) · B- (adequate but structurally constrained)
> · C+ (functional with significant limitations) · C (limited) · D (deficient by design)
>
> **Evaluation context:** EPQB is assessed for *controlled closed-network deployments*;
> MTC for *public Internet WebPKI*. Grades reflect fitness within each protocol's own intended
> scope, then penalized where a design decision creates an objective security or operational gap
> regardless of scope.
>
> **On EPQB cryptographic primitives:** EPQB uses exclusively NIST-approved post-quantum
> algorithms (ML-KEM / Kyber for key encapsulation, ML-DSA / Dilithium for authentication,
> NIST-approved AEAD). The specific algorithm listing is intentionally omitted here — what
> matters architecturally is that all primitives are NIST-standardized, fully pluggable via
> EnumApiCrypto, and can be replaced without any migration problem if NIST deprecates or
> adds algorithms in the future. This is the correct design: *the migration cost is zero
> by construction*, versus MTC and WebPKI where a single algorithm change requires
> CA/Browser Forum consensus, ecosystem-wide coordination, and typically years of transition.

---

### 17.1 Cryptographic Strength

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **Key encapsulation (KEM)** | **A++** | **B-** | EPQB: NIST-approved PQ KEM, active in every session. MTC: no KEM in cert auth scope — TLS handles this separately |
| **Authentication signatures** | **A++** | **A** | EPQB: NIST-approved PQ signature, highest available level by default. MTC: ML-DSA-44 (lowest PQ level) in experiment — adequate but smallest option chosen for size reasons |
| **AEAD encryption** | **A++** | **B** | EPQB: NIST-approved AEAD, pluggable per-connection. MTC: out of scope — TLS handles AEAD separately, no control from cert layer |
| **Algorithm agility (swap without migration)** | **A++** | **C+** | EPQB: any layer swappable in hours with zero identity loss. MTC: requires CA/Browser Forum multi-year consensus process |
| **NIST compliance** | **A++** | **A** | EPQB: fully NIST-approved stack, all layers. MTC experiment: still uses ECDSA (classical) — not yet fully PQ |
| **PQ completeness today** | **A++** | **B-** | EPQB: complete PQ stack in production. MTC: ECDSA still present in Phase 1; full PQ targeted ~2027 |
| **Forward secrecy** | **A++** | **A** | Both: fresh per-session key exchange. EPQB via Kyber AKE; MTC/TLS via ephemeral key exchange |
| **Quantum safety — Shor's algorithm** | **A++** | **B+** | EPQB: immune today. MTC: immune when fully deployed (~2027); currently hybrid |
| **Quantum safety — Grover's algorithm** | **A+** | **A+** | Both: 256-bit symmetric keys → 128-bit effective PQ strength. Adequate under current understanding |
| **Side-channel resistance** | **A** | **B+** | EPQB: ASCON planned (no table lookups, natural SCA resistance). ML-DSA has known implementation challenges. Both depend on implementation quality |

**Subsection average — EPQB: A+ · MTC: B+**

---

### 17.2 Algorithm Migration

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **Algorithm deprecation response time** | **A++** | **C** | EPQB: hours to days — operator pushes update via Master Peer, old-signs-new, zero downtime. MTC: years — CA/Browser Forum, browser update cycles, ecosystem-wide coordination |
| **Identity continuity across migration** | **A++** | **C+** | EPQB: cryptographic handover proof — old cert signs new cert, identity is preserved and verifiable. MTC/X.509: new cert = new identity, no cryptographic link to old |
| **Migration without service interruption** | **A++** | **B-** | EPQB: old and new algorithms coexist during transition, Master Peer co-signs both. MTC: cert reissue is relatively smooth but requires ecosystem update |
| **Migration without external coordination** | **A++** | **D** | EPQB: fully internal — operator decides, Master Peer executes, done. MTC: requires CA, Browser Forum, browser vendors, server operators to all coordinate |
| **Resistance to "harvest now, migrate never" (blockchain problem)** | **A++** | **C** | EPQB: old-signs-new makes migration trustless and provable. MTC: no equivalent; like all WebPKI, relies on CA reissue with no identity proof |

**Subsection average — EPQB: A++ · MTC: C+**

> This is the largest gap in the entire comparison. Algorithm migration is essentially
> a solved problem in EPQB and an unsolved coordination crisis in every other system.

---

### 17.3 Trust Architecture

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **Trust chain depth** | **A++** | **A** | EPQB: depth-1 (Master Peer → Peer). MTC: depth-2 (MTCA → Leaf via Merkle). X.509: depth 3-4 |
| **Trust anchor control** | **A++** | **C** | EPQB: operator embeds exactly the N anchors they choose. MTC: 100s of Root CAs, browser-vendor-controlled — operator has no say |
| **Third-party dependency** | **A++** | **B-** | EPQB: zero — fully self-contained. MTC: CAs, IETF, CA/Browser Forum, browser vendors, OS vendors |
| **Jurisdiction independence** | **A++** | **C+** | EPQB: operator sovereign — no foreign CA policy applies. MTC: subject to browser vendor Root CA policies (US, EU, China CAs all in one store) |
| **Anchor redundancy** | **A++** | **B** | EPQB: N embedded Master Peer certs — any one can sign. MTC: 100s CAs exists but any one can issue for any domain (security liability, not asset) |
| **Resistance to rogue CA issuance** | **A++** | **B+** | EPQB: impossible — only embedded Master Peer certs are trusted. MTC: CT logging makes it detectable post-facto but does not prevent it |
| **Self-sovereign identity (SSI)** | **A++** | **D** | EPQB: complete SSI — operator controls all trust decisions. MTC: delegated trust by design — cannot be SSI |

**Subsection average — EPQB: A++ · MTC: B-**

---

### 17.4 Connection Performance

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **First connection latency** | **A** | **A** | EPQB: 1 Master Peer cert fetch + local verify. MTC fast path: landmark pre-synced, 1 sig only. Comparable |
| **Reconnection latency (warm)** | **A++** | **A+** | EPQB: instant — pure local crypto, zero network. MTC: fast — landmark still valid, 1 sig only |
| **Handshake auth bytes — best case** | **A++** | **A+** | EPQB with FALCON-512: ~2,234B. MTC fast path ML-DSA-44: ~4,052B. EPQB wins with pluggable FALCON |
| **Handshake auth bytes — default** | **A** | **A** | EPQB with ML-DSA-87 default: ~6,163B. MTC ML-DSA-44: ~4,052B. MTC slightly smaller at lower security level |
| **Trust resolution overhead** | **A++** | **A** | EPQB: microseconds (local crypto, no network). MTC: local (landmark pre-verified) — also fast |
| **Offline operation** | **A++** | **B+** | EPQB: full — all certs cached, no network ever for auth. MTC: ~1 week window, then landmark sync needed |
| **NAT / no-direct-path handling** | **A++** | **C** | EPQB: Relay Peer PQ-VPN bridge — automatic, E2E encrypted, enemy-list-enforced. MTC: not applicable — HTTP relies on public routing |
| **Per-message overhead** | **A++** | **A++** | Both: 28–32 bytes (AEAD tag + nonce). Identical at symmetric layer |

**Subsection average — EPQB: A+ · MTC: A-**

---

### 17.5 Security Properties

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **Confidentiality** | **A++** | **A** | EPQB: NIST-approved AEAD per message. MTC: TLS AEAD (separate layer, not in cert scope) |
| **Authentication strength** | **A++** | **A** | EPQB: NIST PQ sig + KEM + id_hash binding. MTC: ML-DSA handshake sig + Merkle proof |
| **Replay protection** | **A++** | **A** | EPQB: MapId entity ID cache (per-message). MTC: cert validity window (~1 week) |
| **MITM resistance** | **A++** | **A** | Both strong. EPQB also defends relay MITM via mandatory KEM + signature combination |
| **Relay confidentiality** | **A++** | **N/A** | EPQB: E2E AEAD — relay sees only ciphertext + random bridge IDs. MTC has no relay model |
| **Relay authorization model** | **A++** | **N/A** | EPQB: relay list Master-Peer-signed, locally cached, fallback self-healing |
| **Enemy list / local revocation** | **A++** | **D** | EPQB: instant offline revocation per-client. MTC: no local revocation authority possible |
| **Global revocation speed** | **A+** | **B-** | EPQB: seconds–minutes (Master Peer push). MTC: hours–days (batch Merkle + landmark sync) |
| **Traffic analysis resistance** | **B+** | **C** | EPQB: partial — BLAKE3 id_hash binding hides inner IDs; timing/size visible. MTC: none |
| **Misissuance / rogue cert detection** | **B-** | **A+** | EPQB: not applicable (no CAs), but no public audit trail. MTC: CT logs first-class — tamper-evident and public |
| **Public auditability** | **C** | **A++** | EPQB: internal logs only. MTC: public CT log — globally verifiable |
| **Multi-anchor blast radius control** | **A++** | **B-** | EPQB: one compromised Master Peer affects only its signed peers. MTC/WebPKI: any Root CA can issue for any domain — blast radius is global |

**Subsection average — EPQB: A+ · MTC: B+ (with N/A exclusions)**

---

### 17.6 Operational Resilience

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **Infrastructure offline tolerance** | **A++** | **B+** | EPQB: existing sessions fully unaffected; cached certs serve all reconnects. MTC: valid within landmark window; degrades after |
| **Network partition tolerance** | **A++** | **A** | Both operational within respective validity windows. EPQB window is indefinite (no expiry); MTC ~1 week |
| **Zero-downtime Master Peer rotation** | **A++** | **B** | EPQB: embed old + new simultaneously — transparent. MTC: Root CA rotation requires OS/browser update rollout |
| **Relay topology change handling** | **A++** | **N/A** | EPQB: Master Peer pushes updated signed relay list; clients self-heal automatically |
| **Protocol ossification risk** | **A++** | **C** | EPQB: controlled — both ends updated by same operator. MTC/Internet: extreme — TLS 1.3 took ~5 years |
| **Deployment complexity** | **A++** | **B-** | EPQB: closed system — operator controls both sides. MTC: Internet-wide coordination — CAs, browsers, servers, standards bodies |
| **Scalability** | **A+** | **A** | Both scale well. EPQB: linear with peers; Master Peer distributes via push. MTC: Merkle batching scales to millions of certs |
| **Client software update requirement** | **A++** | **B** | EPQB: embedded certs are static — no sync, no update required for trust. MTC: landmark sync infrastructure required; stale client degrades |

**Subsection average — EPQB: A+ · MTC: B**

---

### 17.7 Ecosystem and Deployment Fit

| Criterion | EPQB Score | MTC Score | Notes |
|---|---|---|---|
| **Fit for closed / private networks** | **A++** | **D** | EPQB: designed for this. MTC: requires public CA infrastructure and browser ecosystem |
| **Fit for public Internet** | **D** | **A++** | EPQB: not designed for open public membership. MTC: exactly the target |
| **IoT / constrained devices** | **A+** | **C** | EPQB: ASCON planned, FALCON-512 optional, BLAKE3 lightweight. MTC: not addressed |
| **Air-gapped / offline networks** | **A++** | **D** | EPQB: fully functional with zero Internet dependency. MTC: requires MTCA infrastructure |
| **P2P / decentralized protocols** | **A++** | **C** | EPQB: SSI, local certs, relay mesh. MTC: requires central CA hierarchy |
| **Government / high-security** | **A++** | **B** | EPQB: no foreign CA jurisdiction, full operator control. MTC: subject to browser vendor CA policies |
| **Open public SaaS / HTTPS** | **D** | **A++** | Reversed — EPQB not designed for this; MTC is the right tool |
| **Standards / interoperability** | **B** | **A++** | EPQB: proprietary protocol. MTC: IETF PLANTS → globally interoperable |

---

### 17.8 Master Summary — Final Grades

| Category | EPQB | MTC |
|---|---|---|
| **Cryptographic Strength** | **A+** | **B+** |
| **Algorithm Migration** | **A++** | **C+** |
| **Trust Architecture** | **A++** | **B-** |
| **Connection Performance** | **A+** | **A-** |
| **Security Properties** | **A+** | **B+** |
| **Operational Resilience** | **A+** | **B** |
| **Ecosystem / Deployment Fit** | *Context-dependent* | *Context-dependent* |

> **Overall verdict for closed-network deployments:**
> **EPQB: A+** — Strongest available PQ architecture for controlled peer networks. The algorithm
> migration model alone places it in a class apart from all legacy PKI systems: deprecate an
> algorithm, replace it across the entire network in hours, with zero identity loss, zero
> external coordination, and zero service interruption. This is not a marginal improvement
> — it is a fundamentally different category of system.
>
> **MTC: B+** — The best available solution for the public Internet WebPKI, doing the hardest
> possible job: retrofitting quantum resistance onto a system that was never designed for it,
> while keeping billions of existing clients and servers working. Its C+ on migration is not a
> design failure — it is an honest reflection of the constraints of the open Internet. MTC
> does not pretend to be what it is not.
>
> **The gap is largest on algorithm migration (A++ vs C+) and trust architecture (A++ vs B-).**
> These are structural gaps that cannot be closed by MTC within its design constraints. They
> are the cost of operating on the open Internet with independent actors. EPQB avoids them
> entirely by controlling both ends of every connection. Neither score is wrong — they reflect
> what each system is *for*.



---

*Prepared from: EPQB security documentation (sections 17.7-17.10), NIST FIPS 203/204/206, NIST SP 800-232, Cloudflare/Google Chrome MTC blog post (October–November 2025), Google Chrome MTC announcement (February 2026), and IETF draft-davidben-tls-merkle-tree-certs-09 (December 2025).*
