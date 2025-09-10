# Rust Concurrency Primitives: Mutex, RwLock, std, parking_lot, and Tokio Benchmarks

A detailed comparison of synchronization primitives in Rust, including benchmarks and recommendations.

---

## Table of Contents
1. [Mutex vs RwLock](#mutex-vs-rwlock)
2. [std vs parking_lot](#std-vs-parking_lot)
3. [Tokio Async Primitives](#tokio-async-primitives)
4. [Benchmarks](#benchmarks)
5. [Recommendations](#recommendations)
6. [References](#references)

---

## Mutex vs RwLock

### Key Differences
| Aspect                | `Mutex`                              | `RwLock`                              |
|-----------------------|--------------------------------------|---------------------------------------|
| **Best For**          | Write-heavy workloads               | Read-heavy workloads                  |
| **Access**            | Exclusive (1 writer)                | Multiple readers or 1 writer          |
| **Overhead**          | Low                                  | Higher (reader/writer state tracking) |
| **Starvation Risk**   | None (fair scheduling)              | Writers starve on Linux               |
| **Platform Behavior** | Consistent across OSes              | Linux: Reader bias; BSD/OSX: Writer bias |

**Notes**:
- `RwLock` on Linux prioritizes readers, leading to potential writer starvation (e.g., 8 readers + 4 writers took **42s** vs **0.01s** on BSD/OSX [[1]](#references)).
- `Mutex` uses OS primitives like `futex` on Linux for efficient blocking [[2]](#references).

---

## std vs parking_lot

### Performance Comparison
| Scenario               | `std::sync`                          | `parking_lot`                        |
|------------------------|--------------------------------------|---------------------------------------|
| **Uncontended Speed**  | Slower (OS syscalls)                 | Faster (user-space thread parking)   |
| **Contended Speed**    | Better under high contention         | Degrades under extreme contention    |
| **Platform Support**   | Broad (Linux, Windows, etc.)        | Limited (e.g., no stable WASM)       |
| **RwLock Performance** | Moderate (OS-dependent)             | Better in mixed read/write scenarios |

**Benchmarks** (Contention Impact):
- **High Contention (ARM Linux)**:  
  `parking_lot::Mutex` took **39s** vs `std::sync::Mutex` at **1.4s** [[3]](#references).
- **Mixed Read/Write Workloads**:  
  `parking_lot::RwLock` achieved **51,372 kHz writes** vs `std::sync::RwLock` at **40,466 kHz** [[4]](#references).

---

## Tokio Async Primitives

### Tokio Mutex/RwLock Characteristics
| Aspect                | `tokio::sync::Mutex`                 | `tokio::sync::RwLock`                |
|-----------------------|--------------------------------------|---------------------------------------|
| **Best For**          | Async contexts, IO-bound tasks      | Async read-heavy workloads            |
| **Fairness**          | FIFO queue (prevents starvation)     | Write-preferring fairness             |
| **Overhead**          | Higher (async scheduling)           | Higher (async-aware tracking)         |

**Advantages**:
- Non-blocking across `.await` boundaries.
- Avoids thread starvation with FIFO queuing (e.g., **0.55ms** task spawn in release mode [[5]](#references)).
