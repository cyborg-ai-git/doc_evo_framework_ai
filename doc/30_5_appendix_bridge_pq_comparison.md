# Cryptographic Signatures Comparison

| Method | Security Level | Public Key (bytes) | Private Key (bytes) | Signature (bytes) |
|--------|:--------------:|:------------------:|:-------------------:|:-----------------:|
| ECDSA | 1 | 65 | 32 | 71 |
| ML-DSA-44 | 2 | 1312 | 2560 | 2420 |
| ML-DSA-65 | 3 | 1952 | 4032 | 3309 |
| ML-DSA-87 | 5 | 2592 | 4896 | 4627 |
| Falcon-512 | 1 | 897 | 1281 | 752 |
| Falcon-1024 | 5 | 1793 | 2305 | 1462 |
| SPHINCS+-SHA2-128f-simple | 1 | 32 | 64 | 17088 |
| SPHINCS+-SHA2-128s-simple | 1 | 32 | 64 | 7856 |
| SPHINCS+-SHA2-192f-simple | 3 | 48 | 96 | 35664 |
| SPHINCS+-SHA2-192s-simple | 3 | 48 | 96 | 16224 |
| SPHINCS+-SHA2-256f-simple | 5 | 64 | 128 | 49856 |
| SPHINCS+-SHA2-256s-simple | 5 | 64 | 128 | 29792 |
| SPHINCS+-SHAKE-128f-simple | 1 | 32 | 64 | 17088 |
| SPHINCS+-SHAKE-128s-simple | 1 | 32 | 64 | 7856 |
| SPHINCS+-SHAKE-192f-simple | 3 | 48 | 96 | 35664 |
| SPHINCS+-SHAKE-192s-simple | 3 | 48 | 96 | 16224 |
| SPHINCS+-SHAKE-256f-simple | 5 | 64 | 128 | 49856 |
| SPHINCS+-SHAKE-256s-simple | 5 | 64 | 128 | 29792 |

## Notes

- **Security Level**: NIST security categories (1, 2, 3, 5)
- **Key/Signature Sizes**: All values in bytes
- **ECDSA**: Traditional elliptic curve digital signature algorithm
- **ML-DSA**: Module-Lattice-Based Digital Signature Algorithm (CRYSTALS-Dilithium)
- **Falcon**: Fast-Fourier lattice-based signatures
- **SPHINCS+**: Stateless hash-based signatures with SHA2/SHAKE variants
- **f/s variants**: "f" = fast signing, "s" = small signatures

### Protocol Security

**Key Compromise Protection:**
- Master Peer signing keys stored in HSM
- Peer private keys never transmitted
- Implementation follows NIST SP 800-57 Part 2 Rev. 1 for key management in system contexts

**Replay Prevention:**
- Monotonic counters in EAction headers
- Time-based nonces in KEM exchanges
- Unique ChaCha20 nonces for every packet provide additional protection
- Implementation follows NIST SP 800-38D guidelines

**Side-Channel Resistance:**
- Constant-time Kyber implementations
- Memory-safe encryption contexts
- Follows countermeasure recommendations from NIST SP 800-90A Rev. 1

### Defense-in-Depth Measures

**Layered Encryption:**
- Kyber-1024 for key establishment
- ChaCha20 for bulk encryption with per-packet unique nonces
- Poly1305 for message integrity
- Implementation follows NIST SP 800-175B Rev. 1 guidelines for using cryptographic mechanisms

**Certificate Chain Validation:**
- Signature verification
- Trust anchor validation
- Peer ID consistency checks
- Complies with NIST SP 800-52 Rev. 2 recommendations for TLS implementations

**Hash Algorithm Flexibility:**
- Support for multiple NIST-approved hash algorithms:
  - BLAKE3
- Hash algorithm selection based on security requirements and computational resources

## Operational Characteristics

### Key Management

**Master Peer Keys:**
- Kyber keypair rotated quarterly
- Dilithium keypair rotated annually
- Historical keys maintained for validation
- Key rotation practices follow NIST SP 800-57 Part 1 Rev. 5 recommendations

**Peer Keys:**
- Certificate validity until emergency revocation via OCSPP
- Implementation follows NIST SP 800-63-3 digital identity guidelines

## Threat Model Considerations

### Protected Against
- Quantum computing attacks
- MITM attacks
- Replay attacks
- Key compromise impersonation
- Chosen ciphertext attacks (CCA-secure KEM)
- Nonce reuse attacks (via per-packet unique nonces)
- Threat modeling follows NIST SP 800-154 guidance

### Operational Assumptions
- Master Peer integrity maintained
- Secure time synchronization exists
- Peer implementations prevent memory leaks
- Cryptographic primitives remain uncompromised
- Implementation follows NIST SP 800-53 Rev. 5 security controls

## Protocol Flow Diagrams

### Certificate Issuance Sequence

```
[PeerA]                    [Master Peer]
|--- AKE Request ----------->|
|<-- Session Confirm --------|
|--- Api request  ---------->| <- Each packet with unique ChaCha20 nonce
|<-- PeerA Certificate ------| <- Each packet with unique ChaCha20 nonce
```
![sequence_diagram_0.svg](data/sequence_diagram_0.svg)
\pagebreak

### Secure Messaging Sequence

#### Case 1: Certificate Retrieval and Direct Communication
First, PeerB requests PeerA's certificate from the Master Peer:

```
[PeerB]                    [Master Peer]
|--- AKE Request ----------->|
|<-- Session Confirm --------|
|--- Api request  ---------->| <- Each packet with unique ChaCha20 nonce
|<-- PeerA Certificate ------| <- Each packet with unique ChaCha20 nonce
```
![sequence_diagram_1.svg](data/sequence_diagram_1.svg)
\pagebreak
Then, direct communication between PeerB and PeerA occurs:

```
[PeerB]                    [PeerA]
|--- AKE Request ----------->|
|<-- Session Confirm --------|
|--- Api request  ---------->| <- Each packet with unique ChaCha20 nonce
|<-- Encrypted Response -----|  <- Each packet with unique ChaCha20 nonce
```
![sequence_diagram_1_1.svg](data/sequence_diagram_1_1.svg)
\pagebreak
#### Case 2: Direct Communication
Direct communication between PeerB and PeerA when certificate is already available:

```
[PeerB]                     [PeerA]
|--- AKE Request ----------->|
|<-- Session Confirm --------|
|--- Api request  ---------->| <- Each packet with unique ChaCha20 nonce
|<-- Encrypted Response -----|  <- Each packet with unique ChaCha20 nonce
```
![sequence_diagram_2.svg](data/sequence_diagram_2.svg)
\pagebreak

## Testing and Validation

### Verification Scenarios

![d0.svg](data/d0.svg)

**Direct Certificate Validation**
- Signature verification success/failure cases
- Certificate expiration tests
- Revocation list checks
- Testing methodology aligned with NIST SP 800-56A Rev. 3 recommendations

![d1.svg](data/d1.svg)

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

![d3.svg](data/d3.svg)

**Nonce Generation Testing**
- Statistical distribution of generated nonces
- Verification of nonce uniqueness across large message samples
- Performance testing of secure random number generation
  \pagebreak
## Certificate Pinning and Trust Anchors

### Master Peer Certificate Pinning

The system implements robust certificate pinning to establish an immutable trust anchor, mitigating man-in-the-middle and certificate substitution attacks.

#### Embedded Certificates

![d4.svg](data/d4.svg)

All peers in the network have the Master Peer's cryptographic certificates embedded directly within their software or firmware:

- **Kyber-1024 Public Certificate:** Embedded as a hardcoded constant, providing the quantum-resistant encryption trust anchor
- **Dilithium-5 Public Certificate:** Embedded to verify all Master Peer signatures, establishing signature validation trust
- **Certificate Fingerprints:** SHA3-256 fingerprints of both certificates stored for integrity verification

#### Security Benefits

![d6.svg](data/d6.svg)

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

![d5.svg](data/d5.svg)

In the rare case of Master Peer key compromise, the system supports secure certificate rotation:

- Multi-signature approval process required for accepting new Master certificates
- Out-of-band verification channels established for certificate rotation
- Tiered approach to certificate acceptance based on threshold signatures
- Follows NIST SP 800-57 guidelines for cryptographic key transition
## Memory Management and Session Security

### Connection State Management

#### Master Peer Memory Optimization

![d7.svg](data/d7.svg)

The Master Peer implements efficient memory management by maintaining only essential connection information in active memory:

- **Minimalist Connection Map:** Only stores the 32-byte TypeID and current shared secret key for active connections
- **Resource Release:** Automatically releases memory for inactive connections after timeout periods
- **Connection Lifecycle Management:** Implements state transition monitoring to ensure proper resource cleanup
- **Serialized Persistence:** Only critical authentication data is persisted to storage; ephemeral session data remains in memory only

This approach significantly reduces the memory footprint, particularly in high-connection-volume environments, while maintaining necessary security context for active communications.

#### Peer Connection Caching

![d9.svg](data/d9.svg)

Regular Peers implement similar memory optimization strategies:

- **Limited Connection Cache:** Maintains only active connection information (32-byte TypeID and shared key)
- **Selective Persistence:** Only stores long-term cryptographic identities and certificates on disk
- **Memory-Efficient Design:** Session keys and temporary cryptographic material held in secure memory regions
- **Garbage Collection:** Automated cleanup processes reclaim memory from expired sessions

### Dynamic Session Security

#### Secret Renegotiation Protocol

![d8.svg](data/d8.svg)

To enhance forward secrecy and mitigate passive monitoring, the system implements dynamic session renegotiation:

- **Random Renegotiation Triggers:**
  - Time-based: Session keys renegotiated after configurable intervals (default: 1 hour)
  - Random-based: Spontaneous renegotiation initiated with 0.1% probability per message exchange

- **Renegotiation Process:**
  - Initiated via special EAction type
  - New Kyber KEM exchange performed within existing encrypted channel
  - Seamless key transition without communication interruption
  - Previous session keys securely erased from memory

- **Security Benefits:**
  - Minimizes effective cryptographic material available to attackers
  - Provides continual forward secrecy guarantees
  - Creates moving target defense against cryptanalysis attempts
  - Follows NIST SP 800-57 recommendations for cryptoperiod management

\pagebreak