![evo bridge](data/evo_layer_bridge.svg)
\pagebreak

# \textcolor{red}{Evo Bridge Layer (IBridge)}

The **Evo Post Quantum Bridge (EPQB)** is a bridge layer of **Evo Framework AI** designed to facilitate secure, authenticated communication in distributed peer-to-peer networks. 

Built from the ground up with quantum-resistance in mind, this system leverages NIST-standardized post-quantum cryptographic algorithms to establish a future-proof security architecture. 

**EPQB** implements a hierarchical trust model with specialized cryptographic roles, robust certificate management, and defense-in-depth security measures to protect against both classical and quantum threats. This system is particularly suitable for applications requiring long-term security assurances, distributed trust, and resilient communication channels in potentially hostile network environments.

This cryptographic architecture provides a quantum-resistant foundation for distributed systems communication, combining NIST-standardized post-quantum algorithms with robust protocol design. The system enables secure peer authentication, confidential data exchange, and scalable trust management through three core mechanisms:

- **Hierarchical Trust** via certificate-chained identities
- **Layered Cryptography** combining PQ KEM and symmetric encryption  
- **Defense-in-Depth** through multiple verification stages

The design emphasizes maintainability through modular cryptographic primitives and provides comprehensive protection against both classical and quantum computing threats. Future enhancements would focus on automated key rotation and distributed trust mechanisms.

By implementing this system in accordance with NIST guidelines and recommendations, organizations can establish a cryptographic foundation that meets current security standards while remaining resistant to future quantum computing attacks.
\pagebreak

## Technical Overview
This document describes a post-quantum cryptographic system designed for secure peer-to-peer communication in distributed networks. The architecture employs a hierarchical trust model with specialized cryptographic roles and modern NIST-standardized algorithms.

![bridge_epqb](data/bridge_epqb.svg)

\pagebreak
## Bridge Entities

The **Evo Bridge EPQB** architecture is built upon four fundamental cryptographic entities that work together to provide secure, quantum-resistant peer-to-peer communication. Each entity serves a specific role in the distributed trust model and cryptographic protocol stack.

> NB: Beta Version Only PkKyberDilitium is supported

### Enum Entity Types

![enum_peer_crypto_schema](data/enum_peer_crypto_schema.svg)


![enum_peer_visibility_schema](data/enum_peer_visibility_schema.svg)


### Core Entity Types

#### EPeerSecret - Private Cryptographic Identity

![e_peer_secret_schema](data/e_peer_secret_schema.svg)

The foundational private entity containing all secret cryptographic material for a peer. 
The cryptography algorithm is dynamic so is possible to migrate to other more secure PQ algorithm if is founded security issue

**Cryptographic Components:**
- **Enum Peer Crypto (enu_peer_crypto)**: The cryptography algorithm for example 0->PqKyberDilitium (Kyber-1024, Dilithium-5)
- **Secret Key (sk)**: The Secret key for KEM
- **Secret Key Sign (sk_sign)**:  he Secret key for sign
- **Private Bridge Configuration**: Local network settings, security policies, and operational parameters
- **Unique Identifier (id)**: Cryptographically derived from hash_256(pk + pk_sign) ensuring tamper-proof identity binding

**Security Properties:**

- Never transmitted across the network
- Stored in secure memory regions with automatic cleanup
- Protected by hardware security modules (HSMs) when available
- Enables quantum-resistant authentication and key exchange

#### EPeerPublic - Public Cryptographic Identity

![e_peer_public_schema](data/e_peer_public_schema.svg)

The public counterpart containing verifiable cryptographic material and network configuration.

**Cryptographic Components:**

- **Enum Peer Crypto (enu_peer_crypto)**: The cryptography algorithm for example 0->PqKyberDilitium (Kyber-1024, Dilithium-5)
- **Public Key (pk)**: Derived from the corresponding secret key sk, enables secure key encapsulation
- **Public Key (pk_sign)**: Derived from sk_sign, enables signature verification
- **Public Bridge Configuration**: Network endpoints, supported protocols, and capability advertisements
- **Derived Identifier**: Matches EPeerSecret.id through hash_256(pk + pk_sign) for identity verification

**Network Capabilities:**

- Distributed through certificate infrastructure
- Enables peer discovery and capability negotiation
- Supports multiple transport protocols simultaneously
- Provides cryptographic binding between identity and capabilities

#### EPeerCertificate - Authenticated Identity Credential

![e_peer_certificate_schema](data/e_peer_certificate_schema.svg)

A digitally signed certificate that establishes trust and authenticity for peer identities.

**Certificate Structure:**

- **EPeerPublic Data**: Complete public identity information
- **Master Peer Signature**: Dilithium-5 signature providing authenticity guarantee
- **Certificate Metadata**: Contains issuance and expiration timestamps, certificate serial number and version, alternative distribution channels (IPFS hashes, backup repositories), revocation check endpoints, and certificate chain information

**Trust Model:**

- Hierarchical trust anchored by Master Peer
- Supports certificate chaining for scalable trust delegation
- Includes revocation mechanisms for compromised identities


#### EApiBridge - Secure Communication Container

![e_api_bridge_schema](data/e_api_bridge_schema.svg)

The standardized message format for all peer-to-peer communications.

**Message Structure:**

- **Event Type**: Categorizes the communication (request, response, notification)
- **Source/Destination IDs**: 32-byte peer identifiers for routing
- **Cryptographic Payload**: Encrypted data using Aes256_Gcm
- **Authentication Data**: Poly1305 MAC for message integrity
- **Protocol Metadata**: Version, flags, and extension headers

**Security Features:**

- End-to-end encryption with forward secrecy
- Message authentication and integrity protection
- Replay attack prevention through nonce management
- Support for both synchronous and asynchronous communication patterns

#### Blockchain-Based Decentralization

The identity system leverages blockchain technology to achieve true decentralization.

**Decentralization Benefits:**
- **Infrastructure Independence**: No reliance on centralized DNS or certificate authorities
- **Global Accessibility**: Peer identities remain valid across different network infrastructures
- **Censorship Resistance**: Distributed identity resolution prevents single points of control
- **Migration Flexibility**: Seamless movement between hosting providers including local development environments, cloud platforms (AWS, Google Cloud, Azure), edge computing providers (Fly.io, Cloudflare Workers), AI/ML platforms (HuggingFace, Google Colab), and decentralized hosting (IPFS, Arweave)

**Identity Resolution Process:**

1. **Peer Discovery**: Query Master Peer or distributed registry with target peer ID
2. **Certificate Retrieval**: Obtain authenticated EPeerCertificate for the target peer  
3. **Capability Negotiation**: Determine optimal transport protocol and connection parameters
4. **Secure Connection**: Establish quantum-resistant encrypted channel using retrieved public keys

This architecture enables a truly decentralized, secure, and flexible communication system where peers can maintain persistent identities while adapting to changing network conditions and infrastructure requirements.

## CIA Triad Implementation

The Cryptographic Entity Management System is designed with the foundational principles of information security - Confidentiality, Integrity, and Availability (CIA) - as core architectural considerations. Each element of the CIA triad is addressed through specific cryptographic mechanisms and protocol designs.

### Confidentiality

Confidentiality ensures that information is accessible only to authorized entities and is protected from disclosure to unauthorized parties.

**Implementation Mechanisms:**

- **Quantum-Resistant Encryption:** Kyber-1024 key encapsulation mechanism provides post-quantum protection for key exchange, ensuring confidentiality even against quantum computing attacks.

- **Strong Symmetric Encryption:** Aes256_Gcm authenticated encryption with unique per-packet nonces secures all data in transit.

- **Layered Encryption Model:** Session keys derived from KEM exchanges provide an additional layer of confidentiality protection.

- **Private Key Protection:**
  - Master Peer private keys stored in Hardware Security Modules (HSMs)
  - Peer private keys never transmitted across the network
  - Key material access strictly controlled

- **Certificate Privacy:** Certificate retrieval requires authenticated sessions, preventing unauthorized access to identity information.

**Confidentiality Assurance Level:** The system provides NIST Level 5 protection (highest NIST security level) against both classical and quantum adversaries.

### Integrity

Integrity ensures that information is accurate, complete, and has not been modified by unauthorized entities.

**Implementation Mechanisms:**

- **Digital Signatures:** Dilithium-5 signatures provide quantum-resistant integrity protection for certificates and critical communications.

- **Message Authentication:** Poly1305 message authentication code (MAC) validates the integrity of each encrypted packet.

- **Certificate Chain Validation:** Comprehensive validation of certificate chains ensures the integrity of peer identities.

- **Hash Algorithm Options:** Multiple hash algorithm options (BLAKE3) for identity derivation and integrity validation.

- **Integrity Proofs:** SHA-256/512 integrity proofs included in certificate packages and critical communications.

- **Monotonic Counters:** EAction headers include monotonic counters to prevent message replay or reordering attacks.

**Integrity Verification Process:**
1. Signature verification using Master Peer's public key
2. Certificate chain validation
3. Message authentication code verification
4. Integrity proof validation
5. Counter and nonce validation

### Availability

Availability ensures that authorized users have reliable and timely access to information and resources.

**Implementation Mechanisms:**

- **Distributed Certificate Registry:** Certificate information are now distributed across GitHub repositories and IPFS (soon will migrate to EvoDPQ) ensures high availability even if individual nodes fail.

- **Decentralized Trust Model:** Master Peer architecture can be extended to multiple Master Peers for redundancy.

- **Robust Protocol Design:** Communication protocols designed to handle network interruptions and reconnections gracefully.

- **Certificate Caching:** Peers can cache validated certificates to continue operations during temporary Master Peer unavailability or direct coneection Peer to Peer.

- **Protocol Resilience:** Automatic session rekeying and reconnection capabilities maintain availability during network disruptions.

- **Denial of Service Protection:**
  - Computational puzzles can be integrated to prevent resource exhaustion attacks
  - Rate limiting mechanisms prevent flooding attacks
  - Authentication required before resource-intensive operations

**Availability Enhancement Features:**
- Emergency certificate revocation via Online Certificate Status Protocol Plus Plus (OCSPP)
- Historical key maintenance for continued validation of legacy communications
- Peer recovery mechanisms after temporary disconnection

### CIA Triad Balance

The system maintains a careful balance between the three elements of the CIA triad:

- **Confidentiality vs Availability Trade-offs:** Strong authentication requirements enhance confidentiality but are designed with fallback mechanisms to maintain availability during disruptions.

- **Integrity vs Performance Balance:** Comprehensive integrity verification is optimized for minimal latency impact.

- **Security Level Customization:** The system allows selection of cryptographic parameters based on specific confidentiality, integrity, and availability requirements.

## Bridge System Architecture

### Core Components

![Bridge Actors](data/bridge_actors.svg)

#### Master Peer 

The Master Peer serves as the trust anchor and certificate authority within the system.

**Cryptographic Capabilities:**
- Kyber-1024 (NIST Level 5) for key encapsulation
- Dilithium-5 (NIST Level 5) for digital signatures

**Maintains:**
- Peer certificate registry
- Fully distributed IPFS (InterPlanetary File System)
- Public key directory
- Cryptographic material storage

> Master Peer are multiple to make it decentralized system and Peer* check the nearest to make the fastest connection

#### Peer 

Regular Peers are standard network participants with established identities.

**Cryptographic Capabilities:**
- Kyber-1024 for key exchange
- Aes256_Gcm for symmetric encryption

**Contains:**
- Unique cryptographic identity (32-byte hash using BLAKE3)
- Public/private key pair
- Certificate chain
- Embedded MasterPeers public key (Kyber) and signature public key (Dilithium)
- Expose api


### Relay Peer
Relay peer is important to Nat peer that can not tunnelling connection, the relay peer , check if peer is an enemy banned so block the connection otherwise, send the EApiEvent to the correct peer, only the destination peer can decrypt correctly the data
Relay peer also not expose your address so the peer can be totally anonymus for safe privacy

> Every Peer can be also a Relay Peer to create  decentralized sun mesh network (...)


#### Network Action (EAction)

Network Actions represent standardized communication protocol units.

**Structure:**
- 32-byte unique identifier
- Action type code
- Cryptographic payload
- Source/destination identifiers
- Encrypted data payload

## Cryptographic Workflows

### Peer Registration Protocol

#### Phase 1: Identity Establishment
- Peer generates Kyber-1024 key pair
  - Uses NIST-standardized key generation procedures
  - Follows guidance from NIST SP 800-56C Rev. 2 for key derivation
- Derives 32-byte Peer ID using one of:
  - BLAKE3 (Public Key)
- Creates self-signed identity claim

#### Phase 2: Certificate Issuance
- Peer initiates Key Encapsulation Mechanism (KEM) with Master Peer:
  - Generates Kyber ciphertext + shared secret
  - Encrypts identity package using Aes256_Gcm with implementation following RFC 8439
- Master Peer:
  - Decapsulates shared secret
  - Decrypts and validates identity claim
  - Issues Dilithium-signed certificate containing:
    - Peer ID
    - Public key
    - Master Peer ID
    - Expiration metadata
    - Certificate format compliant with X.509v3 extensions

### Peer-to-Peer Communication Protocol

#### Direct Communication Flow

**Certificate Verification**
- Validate Dilithium signature using Master Peer's public key (embedded in each peer for pinning)
- Verify certificate chain integrity
- Check revocation status (implied via registry)
- Implementation follows NIST SP 800-57 Part 1 Rev. 5 guidelines for key management

**Session Establishment**
- Initiator performs Kyber KEM with recipient's certified public key
- Generate 256-bit shared secret
- Derive session keys using SHA-512 according to NIST FIPS 202
- Session key derivation follows NIST SP 800-108 Rev. 1 recommendations

**Secure Messaging**
- Encrypt payloads with Aes256_Gcm
- A unique, random 96-bit (12-byte) nonce is generated for every packet sent
  - Nonces are never reused within the same session
  - Generated using a cryptographically secure random number generator
  - Each packet contains its own unique nonce to prevent replay attacks
- Message authentication via Poly1305 tags
- Session rekeying every 1MB data or 24 hours
- Follows NIST SP 800-38D recommendations for authenticated encryption

### Certificate Retrieval Protocol

#### Request Phase
- Requester initiates KEM with Master Peer 
- Encrypts certificate query using established secret

#### Validation Phase
- Master Peer verifies query authorization
- Retrieves requested certificate from registry
- Signs response package with Dilithium
- Implements NIST SP 800-130 recommendations for key management infrastructure

#### Delivery Phase
- Encrypts certificate package with session keys
- Includes integrity proof via SHA-512/256 (NIST FIPS 180-4)

## Security Properties

### Cryptographic Foundations

* **Post-Quantum Security:** All primitives resist quantum computing attacks
  - Implements NIST-selected post-quantum cryptographic algorithms
  - Kyber: [NIST FIPS 203](https://csrc.nist.gov/pubs/fips/203/ipd)
  - Dilithium: [NIST FIPS 204](https://csrc.nist.gov/pubs/fips/204/ipd)
- **Mutual Authentication:** Dual verification via certificates and session keys
- **Forward Secrecy:** Ephemeral session keys derived from KEM exchanges
- **Cryptographic Agility:** Modular design supports algorithm updates
  - Follows NIST SP 800-131A Rev. 2 guidelines for cryptographic algorithm transitions


### Virtual IPv6 Architecture (VIP6)

#### Decentralized Identity System

The peer **ID** functions as a secure, decentralized addressing system that provides several advantages over traditional networking.

> No more login username or weak password, your password is your e_peer_secret , so is important to not share or expose the EPeerSecret

**Key Characteristics:**
- **Privacy-Preserving**: Unlike IPv6, the ID doesn't expose physical network location or infrastructure details
- **Cryptographically Secure**: Derived from public key material, making spoofing computationally infeasible
- **Location-Independent**: Peers can migrate between networks, cloud providers, or devices without changing identity
- **Multi-Protocol Support**: Single identity works across multiple transport mechanisms

![bridge_vip6_portability](data/bridge_vip6_portability.svg)

**Key Concepts:**
1.  **Static Client Configuration**: **PeerAClient** connects to a stable `PeerID` of **PeerB>> . PeerAClient is unaware of PeerB's physical location or IP address.
2.  **VIP6 Resolution Address**: This layer acts as a dynamic address translator. It resolves the stable `PeerID` to the current physical IP address (IPv4 or IPv6) of PeerB.
3.  **Seamless Migration Scenario**:
- **Azure**: PeerB starts on Azure (IP: `20.x.x.x`). VIP6 resolves the ID to this Azure IP. PeerAClient connects seamlessly.
- **AWS**: PeerB migrates to AWS (IP: `54.x.x.x`). It keeps the same Identity (Keys). VIP6 updates the resolution. PeerAClient connects to the same ID without configuration changes.
- **Google Cloud**: PeerB migrates to Google Cloud (IP: `34.x.x.x`). Again, PeerAClient continues to connect to the same `PeerID`.

VIP6 ensures that **PeerB** is truly portable across different environments (Azure, AWS, GCP, Local) without disrupting connectivity or requiring **PeerAClient** to be reconfigured.

**Supported Transport Protocols:**
- **WebSocket**: Real-time bidirectional communication for web applications (Migration)
- **WebRTC**: Direct peer-to-peer communication with NAT traversal (Migration)
- **Raw TCP/UDP**: Low-level protocols for maximum performance (Migration)
- **HTTP/2 & HTTP/3**: Modern web protocols with multiplexing capabilities (Migration)
- **Mcp**: Ai Model Context Protocol (Migration)
- **EvoPqBridge** *(Coming Soon)*: Custom quantum-resistant protocol optimized for EPQB (Default)


> TODO: to insert diagrams
### Virtual PQVpn
VIP6 automatically translates between IPv4 and IPv6 addresses and creates bridge connections. Nothing to configure.
**EPQB** automatically finds compatible servers and encrypts connections to them
**PQVpn** protects your entire connection with post-quantum encryption from your device all the way to the destination server. Regular VPNs only encrypt the connection between you and the VPN server.

#### Decentralized PQVpn
The **Evo Bridge Layer** work as a virtual vpn , all data are crypted end-to-end , no Man-in-the middle attack are possible, no data exposed for use privacy and security


## **EPQB** Protocol Flow Diagrams

- api: set_peer
- api: get_peer
- api: del_peer

\pagebreak

### Certificate Issuance Sequence (api: set_peer)

```
[PeerA]                                     [Master Peer]
|********* AKE Request + EPeerPublic + sign *********-->| 
|<******-- PeerA Certificate (Master Peer signed) ******|
```

![bridge set_peer](data/bridge_set_peer_mp.svg)

***
\pagebreak

### Secure Messaging Sequence (api:get peer)

#### Case 1: Certificate Retrieval and Direct Communication
First, PeerB requests PeerA's certificate from the Master Peer because don't have PeerA in cache:

```
[PeerB]                                     [Master Peer]
|********* AKE Request + PeerA ID *********************>|
|<******-- PeerA Certificate (Master Peer signed) ******|

```

![bridge get_peer](data/bridge_get_peer_mp.svg)

***

\pagebreak

Then, direct communication between PeerB and PeerA occurs:
```
[PeerB]                                           [PeerA]
|********* AKE Request + PeerB ID + Api Request ******->| (PeerA get certificate of PeerB (case 1/2) )
|<-- Encrypted Response with new Secret Key ************|
```
![bridge direct case 1](data/bridge_direct_1.svg)

\pagebreak

#### Case 2: Direct Communication
Direct communication between PeerB and PeerA when certificate is already available (from cache or other secure channel):

```
[PeerB]                                           [PeerA]
|********* AKE Request + PeerB ID + Api Request ******->|
|<-- Encrypted Response with new Secret Key ************|
```

![bridge direct case 2](data/bridge_direct_2.svg)

***
\pagebreak

#### Case Revoke: Revoke Certificate (api: del_peer)
If at least PeerA's secret_kyber and secret_dilithium keys are compromised, the peer is no longer safe and must revoke the peer certificate so other peers know not to use the certificate, and PeerA becomes untrusted:

```
[PeerA]                                                      [Master Peer]
|********* AKE Request + PeerA ID + Sign with compromized secret ******->|
|<-- Encrypted EApiResult Response ************************************--|
```

![bridge revoke](data/bridge_del_peer_mp.svg)

***

\pagebreak

## Testing and Validation

### Verification Scenarios

**Direct Certificate Validation**

- Signature verification success/failure cases
- Certificate expiration tests
- Revocation list checks
- Testing methodology aligned with NIST SP 800-56A Rev. 3 recommendations


**KEM Session Establishment**

- Successful key exchange
- Invalid ciphertext rejection
- Forward secrecy validation
- Testing follows NIST SP 800-161 Rev. 1 supply chain risk management practices

**Full Protocol Integration**

- Multi-hop certificate chains
- Mass certificate issuance
- Long-duration session stress tests
- Performance testing under NIST SP 800-115 guidelines

**Nonce Generation Testing**

- Statistical distribution of generated nonces
- Verification of nonce uniqueness across large message samples
- Performance testing of secure random number generation

## Certificate Pinning and Trust Anchors

### Master Peer Certificate Pinning

The system implements robust certificate pinning to establish an immutable trust anchor, mitigating man-in-the-middle and certificate substitution attacks.

#### Embedded Certificates


All peers in the network have the Master Peer's cryptographic certificates embedded directly within their software or firmware:

- **Kyber-1024 Public Certificate:** Embedded as a hardcoded constant, providing the quantum-resistant encryption trust anchor
- **Dilithium-5 Public Certificate:** Embedded to verify all Master Peer signatures, establishing signature validation trust
- **Certificate Fingerprints:** SHA-256 fingerprints of both certificates stored for integrity verification

#### Security Benefits

This certificate pinning approach provides several critical security advantages:

- **Trust Establishment:** Creates an unambiguous trust anchor independent of certificate authorities
- **MITM Prevention:** Prevents interception attacks during initial bootstrapping and connection
- **Compromise Resistance:** Makes malicious certificate substitution attacks infeasible, even if network infrastructure is compromised
- **Offline Verification:** Enables certificate chain validation without active network connectivity
- **Quantum-Resistant Trust:** Ensures trust roots maintain security properties against quantum adversaries
- **Implementation follows NIST SP 800-52 Rev. 2 recommendations for certificate validation**

#### Implementation Requirements

The embedded certificates are protected with the following measures:

- **Tamper Protection:** Implemented with software security controls to prevent modification
- **Verification During Updates:** Certificate fingerprints verified during any software/firmware updates
- **Backup Verification Paths:** Alternative verification methods available if primary verification fails
- **Multiple Storage Locations:** Redundant certificate storage prevents single-point failure

#### Emergency Certificate Rotation


In the rare case of Master Peer key compromise, the system supports secure certificate rotation:

- Multi-signature approval process required for accepting new Master certificates
- Out-of-band verification channels established for certificate rotation
- Tiered approach to certificate acceptance based on threshold signatures
- Follows NIST SP 800-57 guidelines for cryptographic key transition

## Memory Management and Session Security

### Connection State Management

#### Master Peer Memory Optimization


The Master Peer implements efficient memory management by maintaining only essential connection information in active memory:

- **Minimalist Connection Map:** Only stores the 32-byte TypeID and current shared secret key for active connections
- **Resource Release:** Automatically releases memory for inactive connections after timeout periods
- **Connection Lifecycle Management:** Implements state transition monitoring to ensure proper resource cleanup
- **Serialized Persistence:** Only critical authentication data is persisted to storage; ephemeral session data remains in memory only

This approach significantly reduces the memory footprint, particularly in high-connection-volume environments, while maintaining necessary security context for active communications.

#### Peer Connection Caching


Regular Peers implement similar memory optimization strategies:

- **Limited Connection Cache:** Maintains only active connection information (32-byte TypeID and shared key)
- **Selective Persistence:** Only stores long-term cryptographic identities and certificates on disk
- **Memory-Efficient Design:** Session keys and temporary cryptographic material held in secure memory regions
- **Garbage Collection:** Automated cleanup processes reclaim memory from expired sessions

### Dynamic Session Security

#### Secret Renegotiation Protocol

To enhance forward secrecy and mitigate passive monitoring, the system implements dynamic session renegotiation:

- **Random Renegotiation Triggers:**
  - Time-based: Secret session keys renegotiated after configurable intervals (default: 1 hour)
  - Random-based: Spontaneous renegotiation initiated with 0.1% probability per message exchange

- **Renegotiation Process:**
  - Initiated via special EApiEvent type
  - New Kyber KEM exchange performed within existing encrypted channel
  - Seamless key transition without communication interruption
  - Previous session keys securely erased from memory

- **Security Benefits:**
  - Minimizes effective cryptographic material available to attackers
  - Provides continual forward secrecy guarantees
  - Creates moving target defense against cryptanalysis attempts
  - Follows NIST SP 800-57 recommendations for cryptoperiod management

\pagebreak