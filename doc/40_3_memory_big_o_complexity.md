# Appendix: Memory Management System - Big O Complexity Analysis

## Operation Complexity Table

| Operation   | Volatile Memory | Persistent Memory | Hybrid Memory |
|-------------|-----------------|-------------------|---------------|
| **SET**     | O(1)            | O(1)              | O(1)          |
| **GET**     | O(1)            | O(1)              | O(1)          |
| **DEL**     | O(1)            | O(1)              | O(1)          |
| **GET_ALL** | O(n)            | O(n)              | O(n)          |
| **DEL_ALL** | O(1)            | O(n)              | O(n)          |

## Detailed Complexity Analysis by Memory Type

### Volatile Memory Operations

| Operation | Time Complexity | Space Complexity | Implementation Details |
|-----------|----------------|------------------|------------------------|
| **SET** | O(1) | O(1) | MapEntity<IEntity> with pre-hashed SHA256 keys<br>No hash computation overhead<br>Thread-safe atomic operations |
| **GET** | O(1) | O(1) | Direct MapEntity<IEntity> lookup with pre-hashed keys<br>Cache-friendly memory access<br>SIMD-optimized retrieval |
| **DEL** | O(1) | O(1) | MapEntity<IEntity> entry removal with pre-hashed keys<br>Immediate memory deallocation<br>No tombstone overhead |
| **GET_ALL** | O(n) | O(n) | Iterate all MapEntity<IEntity> entries<br>Zero-copy data access<br>Streaming results |
| **DEL_ALL** | O(1) | O(1) | Clear MapEntity<IEntity> metadata<br>Bulk memory deallocation<br>Reset data structures |

### Persistent Memory Operations

| Operation   | Time Complexity | Space Complexity | Implementation Details                                                                    |
|-------------|-----------------|------------------|-------------------------------------------------------------------------------------------|
| **SET**     | O(1)            | O(1)             | Direct file write using pre-calculated path<br>MEMENTO_PATH/{version}/hash_split/entity.evo<br>No directory traversal needed |
| **GET**     | O(1)            | O(1)             | Direct file read using pre-calculated path<br>SHA256 key provides exact file location<br>Single filesystem operation |
| **DEL**     | O(1)            | O(1)             | Direct file deletion using pre-calculated path<br>No index updates required<br>Single filesystem operation |
| **GET_ALL** | O(n)            | O(n)             | Directory traversal of version folder<br>Sequential file reads<br>Parallel I/O optimization |
| **DEL_ALL** | O(n)            | O(1)             | Recursive directory removal of version<br>Must delete all n files individually<br>Then remove empty directories |

### Hybrid Memory Operations

| Operation | Time Complexity | Space Complexity | Implementation Details |
|-----------|----------------|------------------|------------------------|
| **SET** | O(1) | O(1) | Immediate volatile MapEntity<IEntity> write O(1)<br>Async persistent file write O(1)<br>Cache coherence maintenance |
| **GET** | O(1) | O(1) | MapEntity<IEntity> lookup first O(1)<br>Fallback to direct file read O(1)<br>Cache population on miss |
| **DELETE** | O(1) | O(1) | Immediate MapEntity<IEntity> removal O(1)<br>Async file deletion O(1)<br>Invalidation propagation |
| **GET_ALL** | O(n) | O(n) | MapEntity<IEntity> scan + directory traversal<br>Merge volatile and persistent data<br>Deduplication logic |
| **DEL_ALL** | O(n) | O(1) | MapEntity<IEntity> clear O(1)<br>Recursive directory removal O(n)<br>Transaction coordination |

## EVO Framework File System Complexity

### SHA256-Based File Operations with Pre-Hashed Keys

| Operation | Time Complexity | Space Complexity | File System Impact |
|-----------|----------------|------------------|-------------------|
| **Entity Lookup** | O(1) | O(1) | Direct path calculation from pre-hashed SHA256<br>MEMENTO_PATH/{version}/hash_split/entity.evo<br>No directory traversal or search needed |
| **Entity Storage** | O(1) | O(1) | Direct file creation at calculated path<br>Directory auto-creation if needed<br>Single filesystem write operation |
| **Entity Deletion** | O(1) | O(1) | Direct file removal at calculated path<br>No index updates required<br>Single filesystem delete operation |
| **Version Scan** | O(n) | O(1) | Directory tree traversal of version folder<br>Parallel directory reading<br>Sequential file enumeration |
| **Version Migration** | O(n) | O(n) | File-by-file copying between versions<br>Atomic version switching<br>Bulk filesystem operations |

### Directory Structure Impact on Performance (Hash Split Strategy)

| Directory Level | Entities per Directory | Lookup Performance | Scalability Limit | Path Format |
|----------------|------------------------|-------------------|-------------------|-------------|
| **Level 2** (/version/aa/) | ~10,000 | O(1) direct access | 2.56M entities/version | `/{version}/aa/hash.evo` |
| **Level 3** (/version/aa/bb/) | ~10,000 | O(1) direct access | 655M entities/version | `/{version}/aa/bb/hash.evo` |
| **Level 4** (/version/aa/bb/cc/) | ~5,000 | O(1) direct access | 167B+ entities/version | `/{version}/aa/bb/cc/hash.evo` |

## Concurrency Impact on Complexity

### Thread-Safe Operations with MapEntity<IEntity> and Direct File Access

| Operation | Single-threaded | Multi-threaded | Contention Handling |
|-----------|----------------|----------------|-------------------|
| **Volatile SET** | O(1) | O(1) + minimal lock overhead | MapEntity<IEntity> with RwLock<br>Atomic operations for pre-hashed keys |
| **Volatile GET** | O(1) | O(1) | Read-mostly optimization<br>Shared read access to MapEntity<IEntity> |
| **Persistent SET** | O(1) | O(1) + file lock | Direct file write with OS-level locking<br>No database synchronization overhead |
| **Persistent GET** | O(1) | O(1) | Concurrent file reads<br>No locking required for reads |

## Memory Access Patterns

### Cache Performance Characteristics with Pre-Hashed Keys

| Access Pattern | Cache Behavior | Time Complexity | Optimization Strategy |
|----------------|----------------|-----------------|----------------------|
| **Sequential Access** | High hit rate | O(1) per access | MapEntity<IEntity> iteration order<br>Bulk operations with pre-hashed keys |
| **Random Access** | Consistent O(1) | O(1) | Pre-hashed SHA256 eliminates hash computation<br>Direct MapEntity<IEntity> access |
| **Batch Operations** | Optimal locality | O(n) with minimal constants | Operation batching with pre-calculated paths<br>Parallel file I/O |

## Storage Engine Specific Complexities

### EVO Framework vs Traditional Database Backends

| Database Type | SET      | GET      | DELETE   | GET_ALL | DELETE_ALL |
|---------------|----------|----------|----------|---------|------------|
| **EVO Framework** | O(1) | O(1) | O(1) | O(n) | O(n) |
| **MongoDB**   | O(log n) | O(log n) | O(log n) | O(n)    | O(n) |
| **Redis**     | O(1)     | O(1)     | O(1)     | O(n)    | O(1) |
| **Cassandra** | O(1)     | O(log n) | O(1)     | O(n)    | O(n) |
| **CouchDB**   | O(log n) | O(log n) | O(log n) | O(n)    | O(n) |

### Vector Database Operations

| Operation | Time Complexity | Space Complexity | Implementation Details |
|-----------|----------------|------------------|------------------------|
| **Vector Insert** | O(log n) | O(d) | d = vector dimensions<br>Index updates required |
| **Similarity Search** | O(log n) | O(k) | k = number of results<br>Approximate nearest neighbor |
| **Batch Vector Insert** | O(n log n) | O(n×d) | Bulk index reconstruction<br>Optimized for throughput |
| **Vector Update** | O(log n) | O(d) | Index modification<br>Embedding recalculation |

## Optimization Strategies Impact

### EVO Framework Performance Optimization Techniques

| Technique | Complexity Improvement | Trade-offs | EVO Implementation |
|-----------|----------------------|------------|-------------------|
| **Pre-Hashed SHA256 Keys** | Eliminates hash computation overhead | Fixed key size (32 bytes) | Built-in with TypeID system |
| **Direct Path Calculation** | Avoids directory traversal O(log n) → O(1) | Requires structured naming | MEMENTO_PATH/{version}/hash_split/ |
| **MapEntity<IEntity>** | Optimal hash table performance | Memory overhead ~1.3x | Native MapEntity<IEntity> implementation |
| **File System Sharding** | Distributes directory load | Directory management complexity | Automatic hash-based splitting |

## Memory Footprint Analysis

### Space Complexity by Data Structure in EVO Framework

| Structure Type | Space Complexity | Overhead Factor | Use Case | EVO Implementation |
|----------------|------------------|----------------|----------|-------------------|
| **MapEntity<IEntity>** | O(n) | 1.3× | Volatile memory primary storage | MapEntity<IEntity> with SHA256 keys |
| **Direct File Storage** | O(n) | 1.0× | Persistent storage without indexing | Raw entity serialization in .evo files |
| **SHA256 Keys** | O(n) | 32 bytes per key | Pre-hashed entity identification | TypeID with embedded SHA256 |
| **Directory Structure** | O(log n) | Minimal | File system organization | Hash-split directory hierarchy |
| **Vector Index** | O(n×d) | 2.0-10.0× | Similarity search acceleration | Optional vector database integration |

## EVO Framework Architecture Advantages

### Performance Benefits of Pre-Hashed SHA256 Keys

| Advantage | Traditional Database | EVO Framework | Performance Gain |
|-----------|---------------------|---------------|------------------|
| **Hash Computation** | O(k) per operation | O(1) - pre-computed | Eliminates hash overhead |
| **Key Lookup** | O(log n) B-tree | O(1) MapEntity<IEntity> | ~10-100x faster |
| **Index Maintenance** | O(log n) updates | O(1) - no indexes | No index overhead |
| **Memory Overhead** | 2-3x for indexes | 1.3x MapEntity<IEntity> only | ~50% less memory |

### Direct File System Access Benefits

| Operation | Traditional Approach | EVO Framework | Complexity Improvement |
|-----------|---------------------|---------------|----------------------|
| **Entity Location** | Database query O(log n) | Path calculation O(1) | O(log n) → O(1) |
| **Storage Write** | Transaction + index O(log n) | Direct file write O(1) | O(log n) → O(1) |
| **Storage Read** | Query + deserialize O(log n) | Direct file read O(1) | O(log n) → O(1) |
| **Bulk Operations** | Multiple transactions O(n log n) | Directory operations O(n) | O(n log n) → O(n) |

### MapEntity<IEntity> Implementation Advantages

| Feature | Benefit | Complexity Impact |
|---------|---------|------------------|
| **Memory Safety** | No buffer overflows | Maintains O(1) guarantees |
| **Zero-Cost Abstractions** | No runtime overhead | Pure O(1) performance |
| **SIMD Optimizations** | Vectorized operations | Improved constant factors |
| **Cache-Friendly Layout** | Better memory locality | Reduced cache misses |

### File System Path Strategy Analysis

**Path Format**: `MEMENTO_PATH/{entity_evo_version}/hash_split/entity_serialized_bytes`

| Path Component | Purpose | Complexity Contribution |
|----------------|---------|------------------------|
| **MEMENTO_PATH** | Base directory | O(1) - constant |
| **entity_evo_version** | Version isolation | O(1) - direct access |
| **hash_split** | Load distribution | O(1) - calculated from hash |
| **entity_serialized_bytes** | Entity filename | O(1) - SHA256 hex + .evo |

**Total Path Calculation**: O(1) - All components computed directly from entity metadata

## File System DEL_ALL Complexity Analysis

### Why DEL_ALL is O(n) for File Systems

| File System Operation | Complexity | Reason |
|----------------------|------------|---------|
| **Empty Directory Removal** | O(1) | Single system call (rmdir) |
| **Non-Empty Directory Removal** | O(n) | Must delete all n files first |
| **Recursive Directory Removal** | O(n) | Traverses and deletes each file individually |

### Directory Removal Functions

| Function Type | Use Case | Internal Behavior | Complexity |
|---------------|----------|------------------|------------|
| **Empty Directory Removal** | Empty directory only | Single system call (rmdir) | O(1) |
| **Recursive Directory Removal** | Directory with contents | Recursively deletes each file and subdirectory | O(n) |

**Conclusion**: File system DEL_ALL operations are inherently O(n) because the OS must process each file individually, even when using convenient directory removal functions which internally iterate through all files.

\pagebreak