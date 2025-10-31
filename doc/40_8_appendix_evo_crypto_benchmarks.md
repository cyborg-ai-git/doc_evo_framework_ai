# Evo_core_crypto Benchmarks
> #### Machine:
> Ubuntu 25.04 intel i9

> #### Notes
> Times shown as min-max range from benchmark results
> Outlier percentages indicate measurement variability
> 
> ⚠️ Warnings suggest benchmark configuration improvements for more accurate results

> TODO: to add diagrams benches
> 
> TODO: to add diagrams memory

## HASH - BLAKE3 Benchmarks

| Operation     | Time                             |
|---------------|----------------------------------|
| **Hash 256**  | 95.373 ns **95.887 ns** 96.416 n |

## HASH - Sha3 Benchmarks

| Operation     | Time                              |
|---------------|-----------------------------------|
| **Hash 256**  | 461.99 ns **462.61 ns** 463.67 ns |
| **Hash 256**  | 461.41 ns **465.55 ns** 470.46 ns |


## AEAD - ASCON 128 Benchmarks

| Operation   | Time                  |
|-------------|-----------------------|
| **Encrypt** | 613.83 ns - 614.93 ns |
| **Decrypt** | 213.98 ns - 219.88 ns |
| **Both**    | 856.96 ns - 880.64 ns |


## AEAD - ChaCha20-Poly1305 Benchmarks

| Operation   | Time                              |
|-------------|-----------------------------------|
| **Encrypt** | 1.8954 µs **1.9027 µs** 1.9106 µs |
| **Decrypt** | 1.4742 µs **1.4813 µs** 1.4895 µs |
| **Both**    | 3.4124 µs **3.4328 µs** 3.4536 µs |

## AEAD - Aes gcm 256

| Operation   | Time                              |
|-------------|-----------------------------------|
| **Encrypt** | 424.32 ns **424.38 ns** 424.46 ns |
| **Decrypt** | 337.19 ns **339.24 ns** 341.40 ns |
| **Both**    | 760.15 ns **763.68 ns** 767.56 ns |


## Dilithium (Post-Quantum Digital Signatures) Benchmarks

| Operation              | Time                  |
|------------------------|-----------------------|
| **Keypair Generation** | 231.09 µs - 232.82 µs |
| **Signing**            | 833.38 µs - 838.50 µs |
| **Verification**       | 232.82 µs - 234.74 µs |
| **Full Cycle**         | 1.1054 ms - 1.1298 ms |

## Falcon (Post-Quantum Digital Signatures) Benchmarks

| Operation              | Time                  |
|------------------------|-----------------------|
| **Keypair Generation** | 2.2570 s - 2.3940 s   |
| **Signing**            | 2.4926 ms - 2.5206 ms |
| **Verification**       | 146.43 µs - 149.57 µs |
| **Full Flow**          | 2.5396 s - 2.6750 s   |

## Kyber AKE (Authenticated Key Exchange) Benchmarks

| Operation          | Time                  |
|--------------------|-----------------------|
| **Full Exchange**  | 874.80 µs - 902.66 µs |
| **Client Init**    | 157.23 µs - 169.91 µs |
| **Server Receive** | 339.66 µs - 351.47 µs |
| **Client Confirm** | 172.11 µs - 178.23 µs |

## Kyber KEM (Key Encapsulation Mechanism) Benchmarks

| Operation              | Time                  |
|------------------------|-----------------------|
| **Keypair Generation** | 75.143 µs - 76.749 µs |
| **Encapsulation**      | 80.078 µs - 85.529 µs |
| **Decapsulation**      | 83.928 µs - 86.152 µs |
| **Full KEM Exchange**  | 328.78 µs - 339.83 µs |

## Performance Summary

### Fastest Operations (by median time)
1. **BLAKE3 Hash**: ~95 ns
2. **ASCON_128 Decrypt**: ~217 ns 
3. **ASCON_128 Encrypt**: ~614 ns
4. **ASCON_128 Both**: ~868 ns

### Post-Quantum Cryptography Performance
- **Kyber** (Key Exchange): Most practical for real-time applications (75-350 µs range)
- **Dilithium** (Signatures): Moderate performance (230 µs - 1.1 ms range)
- **Falcon** (Signatures): Significantly slower, especially key generation (2+ seconds)

\pagebreak