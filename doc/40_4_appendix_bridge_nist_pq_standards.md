> TODO: to move in dedicated section

# NIST Post-Quantum Cryptography Standards

## Key Encapsulation Mechanisms (KEM)

| Algorithm | FIPS Standard | Status | Type | Security Level | Public Key Size | Private Key Size | Ciphertext Size | Shared Secret | Mathematical Foundation |
|-----------|---------------|--------|------|----------------|-----------------|------------------|-----------------|---------------|------------------------|
| **ML-KEM-512** | FIPS 203 | ✅ Standardized (Aug 2024) | KEM | ~AES-128 | 800 bytes | 1632 bytes | 768 bytes | 256 bits | Module-Lattice (LWE) |
| **ML-KEM-768** | FIPS 203 | ✅ Standardized (Aug 2024) | KEM | ~AES-192 | 1184 bytes | 2400 bytes | 1088 bytes | 256 bits | Module-Lattice (LWE) |
| **ML-KEM-1024** | FIPS 203 | ✅ Standardized (Aug 2024) | KEM | ~AES-256 | 1568 bytes | 3168 bytes | 1568 bytes | 256 bits | Module-Lattice (LWE) |
| **HQC** | FIPS 206 (Draft) | 🔄 Selected (Mar 2025) | KEM | Various | TBD | TBD | TBD | TBD | Code-based |

## Digital Signature Algorithms

| Algorithm | FIPS Standard | Status | Type | Security Level | Public Key Size | Private Key Size | Signature Size | Mathematical Foundation |
|-----------|---------------|--------|------|----------------|-----------------|------------------|----------------|------------------------|
| **ML-DSA-44** | FIPS 204 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-128 | 1312 bytes | 2560 bytes | 2420 bytes | Module-Lattice |
| **ML-DSA-65** | FIPS 204 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-192 | 1952 bytes | 4032 bytes | 3309 bytes | Module-Lattice |
| **ML-DSA-87** | FIPS 204 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-256 | 2592 bytes | 4896 bytes | 4627 bytes | Module-Lattice |
| **SLH-DSA-128s** | FIPS 205 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-128 | 32 bytes | 64 bytes | 7856 bytes | Hash-based (SPHINCS+) |
| **SLH-DSA-128f** | FIPS 205 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-128 | 32 bytes | 64 bytes | 17088 bytes | Hash-based (SPHINCS+) |
| **SLH-DSA-192s** | FIPS 205 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-192 | 48 bytes | 96 bytes | 16224 bytes | Hash-based (SPHINCS+) |
| **SLH-DSA-192f** | FIPS 205 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-192 | 48 bytes | 96 bytes | 35664 bytes | Hash-based (SPHINCS+) |
| **SLH-DSA-256s** | FIPS 205 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-256 | 64 bytes | 128 bytes | 29792 bytes | Hash-based (SPHINCS+) |
| **SLH-DSA-256f** | FIPS 205 | ✅ Standardized (Aug 2024) | Digital Signature | ~AES-256 | 64 bytes | 128 bytes | 49856 bytes | Hash-based (SPHINCS+) |
| **FN-DSA** | FIPS 206 (Draft) | 🔄 Planned (Late 2024) | Digital Signature | Various | TBD | TBD | TBD | FFT over NTRU-Lattice (FALCON) |

## Additional Candidate Algorithms (Under Evaluation)

| Algorithm | Status | Type | Mathematical Foundation | Notes |
|-----------|--------|------|------------------------|-------|
| **BIKE** | 🔄 Round 4 Candidate | KEM | Code-based | Under further evaluation |
| **Classic McEliece** | 🔄 Round 4 Candidate | KEM | Code-based | Under further evaluation |
| **SIKE** | ❌ Broken | KEM | Isogeny-based | Cryptanalyzed and removed |

## Key Information

### Status Legend
- ✅ **Standardized**: Officially approved and published as FIPS standard
- 🔄 **Selected/Planned**: Chosen for standardization, standard in development
- 🔄 **Under Evaluation**: Still being evaluated in NIST's process
- ❌ **Broken**: Cryptanalyzed and found vulnerable

### Algorithm Name Changes
- **CRYSTALS-Kyber** → **ML-KEM** (Module-Lattice-based Key Encapsulation Mechanism)
- **CRYSTALS-Dilithium** → **ML-DSA** (Module-Lattice-based Digital Signature Algorithm)
- **SPHINCS+** → **SLH-DSA** (Stateless Hash-based Digital Signature Algorithm)
- **FALCON** → **FN-DSA** (FFT over NTRU-Lattice-based Digital Signature Algorithm)

### Security Level Equivalents
- **Level 1**: ~AES-128 (128-bit security)
- **Level 3**: ~AES-192 (192-bit security)
- **Level 5**: ~AES-256 (256-bit security)

### Naming Convention Notes
- **s** suffix = Small signature size (slower signing/verification)
- **f** suffix = Fast signing/verification (larger signature size)
- Numbers (512, 768, 1024, etc.) typically indicate security parameter sets

### Implementation Timeline
- **August 13, 2024**: FIPS 203, 204, and 205 officially published
- **March 2025**: HQC selected as fifth algorithm for backup KEM standard
- **Late 2024**: FALCON (FN-DSA) standard expected to be published

### Recommended Usage
- **Primary KEM**: ML-KEM (FIPS 203) for general encryption
- **Primary Signature**: ML-DSA (FIPS 204) for most digital signature applications
- **Backup Signature**: SLH-DSA (FIPS 205) for cases requiring hash-based security
- **Backup KEM**: HQC will serve as alternative to ML-KEM with different mathematical foundation

\pagebreak