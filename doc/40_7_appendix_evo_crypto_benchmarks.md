# Evo_core_crypto Benchmarks
> #### Machine:
> Ubuntu 25.04 intel i9

> #### Notes
> Times shown as min-max range from benchmark results
> Outlier percentages indicate measurement variability
> 
> ⚠️ Warnings suggest benchmark configuration improvements for more accurate results

> TODO: to add diagrams benches

## ASCON Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Encrypt** | 613.83 ns - 614.93 ns | 9/100 (9.00%) - 3 high mild, 6 high severe |
| **Decrypt** | 213.98 ns - 219.88 ns | 20/100 (20.00%) - 6 high mild, 14 high severe |
| **Both** | 856.96 ns - 880.64 ns | 14/100 (14.00%) - 4 low mild, 1 high mild, 9 high severe |

## BLAKE3 Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Hash** | 100.94 ns - 102.90 ns | 20/100 (20.00%) - 8 low severe, 5 high mild, 7 high severe |

## ChaCha20-Poly1305 Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Encrypt** | 1.7346 µs - 1.7478 µs | 29/100 (29.00%) - 11 low severe, 2 low mild, 16 high mild |
| **Decrypt** | 1.3791 µs - 1.3947 µs | 13/100 (13.00%) - 11 high mild, 2 high severe |
| **Both** | 3.1864 µs - 3.2243 µs | No significant outliers |

## Dilithium (Post-Quantum Digital Signatures) Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Keypair Generation** | 231.09 µs - 232.82 µs | 1/100 (1.00%) - 1 high mild |
| **Signing** | 833.38 µs - 838.50 µs | 14/100 (14.00%) - 3 high mild, 11 high severe |
| **Verification** | 232.82 µs - 234.74 µs | 7/100 (7.00%) - 6 low mild, 1 high severe |
| **Full Cycle** | 1.1054 ms - 1.1298 ms | 5/100 (5.00%) - 1 low severe, 2 low mild, 2 high mild |

## Falcon (Post-Quantum Digital Signatures) Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Keypair Generation** | 2.2570 s - 2.3940 s | 10/100 (10.00%) - 8 low severe, 1 high mild, 1 high severe |
| **Signing** | 2.4926 ms - 2.5206 ms | No significant outliers |
| **Verification** | 146.43 µs - 149.57 µs | 11/100 (11.00%) - 6 high mild, 5 high severe |
| **Full Flow** | 2.5396 s - 2.6750 s | 10/100 (10.00%) - 7 low severe, 1 low mild, 2 high mild |

## Kyber AKE (Authenticated Key Exchange) Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Full Exchange** | 874.80 µs - 902.66 µs | No significant outliers |
| **Client Init** | 157.23 µs - 169.91 µs | 5/100 (5.00%) - 1 high mild, 4 high severe |
| **Server Receive** | 339.66 µs - 351.47 µs | 1/100 (1.00%) - 1 high mild |
| **Client Confirm** | 172.11 µs - 178.23 µs | 5/100 (5.00%) - 1 high mild, 4 high severe |

## Kyber KEM (Key Encapsulation Mechanism) Benchmarks

| Operation | Time | Outliers |
|-----------|------|----------|
| **Keypair Generation** | 75.143 µs - 76.749 µs | 1/100 (1.00%) - 1 high mild |
| **Encapsulation** | 80.078 µs - 85.529 µs | 17/100 (17.00%) - 1 high mild, 16 high severe |
| **Decapsulation** | 83.928 µs - 86.152 µs | 11/100 (11.00%) - 3 high mild, 8 high severe |
| **Full KEM Exchange** | 328.78 µs - 339.83 µs | 21/100 (21.00%) - 11 high mild, 10 high severe |

## Performance Summary

### Fastest Operations (by median time)
1. **BLAKE3 Hash**: ~102 ns
2. **ASCON Decrypt**: ~217 ns
3. **ASCON Encrypt**: ~614 ns
4. **ASCON Both**: ~868 ns

### Post-Quantum Cryptography Performance
- **Kyber** (Key Exchange): Most practical for real-time applications (75-350 µs range)
- **Dilithium** (Signatures): Moderate performance (230 µs - 1.1 ms range)
- **Falcon** (Signatures): Significantly slower, especially key generation (2+ seconds)

\pagebreak