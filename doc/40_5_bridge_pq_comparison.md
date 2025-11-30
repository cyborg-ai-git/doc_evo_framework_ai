# # Appendix: Cryptographic Signatures Comparison

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



\pagebreak