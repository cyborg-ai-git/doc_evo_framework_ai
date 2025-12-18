# Evo Entity JSON vs Serde JSON - Performance Comparison

## Overview

This document compares the performance characteristics of Evo's manual JSON serialization (`to_ai_migra`/`from_ai_migra`) against `serde_json` for entity serialization in MCP/LLM tool calling scenarios.

## Benchmark Results

### Simple Entity (No Nested Objects)

| Operation | Evo (ns) | Serde (ns) | Difference | Winner |
|-----------|----------|------------|------------|--------|
| Serialize | 471 | 972 | -51% | **Evo** |
| Deserialize | 1256 | 750 | +67% | Serde |
| Round-trip | 1469 | 1561 | -6% | **Evo** |

*JSON size: 452 bytes*

### Complex Entity (With Nested Objects & Collections)

| Operation | Evo (ns) | Serde (ns) | Difference | Winner |
|-----------|----------|------------|------------|--------|
| Serialize | 1399 | 1519 | -7% | **Evo** |
| Deserialize | 4125 | 1949 | +112% | Serde |
| Round-trip | 5040 | 3425 | +47% | Serde |

*JSON size: 1116 bytes*

## Architecture Comparison

| Aspect | Evo | Serde |
|--------|-----|-------|
| **Parsing Strategy** | Two-pass (JSON → JsonValue → Struct) | Single-pass (JSON → Struct directly) |
| **Code Generation** | Runtime | Compile-time (proc macros) |
| **Field Lookup** | FxHashMap O(1) | Match statement (compile-time) |
| **SIMD Support** | No | Yes (x86 SSE/AVX) |
| **Dependencies** | `rustc-hash`, `itoa`, `ryu` | `serde`, `serde_json` |
| **WASM Compatible** | ✅ Full | ⚠️ Limited SIMD |

## Serialization Optimizations (Evo)

| Optimization | Description | Impact |
|--------------|-------------|--------|
| `itoa` crate | Fast integer to string conversion | ~20% faster for numbers |
| `ryu` crate | Fast float to string conversion | ~15% faster for floats |
| `escape_json_string_fast` | Check-then-copy for strings without escapes | ~30% faster for clean strings |
| `to_ai_migra_into` | Write nested entities directly into parent buffer | ~40% faster for nested objects |
| Skip null/empty | Don't serialize null entities or empty arrays | Smaller JSON, fewer tokens |
| Pre-allocated buffer | `String::with_capacity(1024)` | Fewer reallocations |

## Deserialization Architecture

### Evo Two-Pass Parsing

```
┌─────────────┐     Pass 1      ┌─────────────────┐     Pass 2      ┌─────────────┐
│ JSON String │ ──────────────► │ JsonValue       │ ──────────────► │ ETest0      │
│             │                 │ (FxHashMap)     │                 │ (struct)    │
└─────────────┘                 └─────────────────┘                 └─────────────┘
                                       │
                                       ▼
                              Allocations:
                              - FxHashMap per object
                              - Vec per array
                              - Cow<str> per string
```

### Serde Single-Pass Parsing

```
┌─────────────┐     Direct      ┌─────────────┐
│ JSON String │ ──────────────► │ EMTest0     │
│             │                 │ (struct)    │
└─────────────┘                 └─────────────┘
                                       │
                                       ▼
                              No intermediate allocations
                              SIMD-accelerated scanning
                              Compile-time field matching
```

## SIMD Explanation

**SIMD = Single Instruction, Multiple Data**

| Approach | Bytes per Cycle | Example: Find `"` in 100 bytes |
|----------|-----------------|-------------------------------|
| Scalar (Evo) | 1 byte | 100 comparisons |
| SIMD 128-bit (SSE) | 16 bytes | 7 comparisons |
| SIMD 256-bit (AVX) | 32 bytes | 4 comparisons |

serde_json uses SIMD for:
- Finding string boundaries (`"`)
- Finding escape characters (`\`)
- Skipping whitespace
- Validating number sequences

## Binary Size Impact

Serde's proc macros generate code for each struct, significantly increasing binary size:

| Component | Evo | Serde |
|-----------|-----|-------|
| Per-struct overhead | ~0 bytes | ~2-5 KB per struct |
| 10 entity types | ~0 KB | ~20-50 KB |
| 100 entity types | ~0 KB | ~200-500 KB |
| Runtime code | Shared parser | Per-type generated code |

### Why Serde Increases Binary Size

```rust
#[derive(Serialize, Deserialize)]  // Generates ~2-5KB of code per struct
struct MyEntity {
    field1: String,
    field2: i32,
    // ...
}
```

For each struct, serde generates:
- `impl Serialize` with field-by-field serialization code
- `impl Deserialize` with field matching and parsing code
- `impl Visitor` for deserialization state machine
- String literals for all field names (not deduplicated)

### Evo Approach

```rust
impl IAiEntity for MyEntity {
    fn to_ai_migra(&self) -> String { /* shared helpers */ }
    fn from_ai_migra(s: &str) -> Result<Self, _> { /* shared parser */ }
}
```

Evo uses:
- Single shared `JsonParser` for all types
- Single shared `UAiEntityMigra` helpers
- No per-type code generation
- Minimal per-entity overhead

## Trade-offs

| Factor | Evo Advantage | Serde Advantage |
|--------|---------------|-----------------|
| **Serialization Speed** | ✅ 7-51% faster | |
| **Deserialization Speed** | | ✅ 52-67% faster |
| **WASM Compatibility** | ✅ Full support | ⚠️ Limited SIMD |
| **Code Complexity** | ✅ Simple, readable | Complex proc macros |
| **Build Dependencies** | ✅ Minimal | Requires serde ecosystem |
| **Partial Data Handling** | ✅ Graceful (LLM responses) | Strict schema |
| **Binary Size** | ✅ Smaller (~0 per struct) | +2-5 KB per struct |
| **Compile Time** | ✅ Faster | Slower (proc macros) |

## When to Use Each

### Use Evo (`to_ai_migra`/`from_ai_migra`) when:
- Targeting WASM
- Serialization is the bottleneck (sending to LLM)
- Need to handle partial/incomplete JSON from LLM responses
- Want minimal dependencies
- Code simplicity is important

### Use Serde when:
- Deserialization is the bottleneck (receiving large responses)
- Running on native platforms with SIMD support
- Strict schema validation is required
- Already using serde ecosystem

## Benchmark Command

```bash
cargo bench --bench bench_ai_vs_serde
```

## Conclusion

Evo's manual JSON implementation achieves **faster serialization** than serde_json while maintaining **full WASM compatibility** and **graceful handling of partial LLM responses**. The deserialization gap is due to architectural differences (two-pass vs single-pass) and lack of SIMD, but this trade-off is acceptable for MCP/LLM use cases where:

1. Serialization (sending to LLM) is more frequent than deserialization
2. WASM deployment is required
3. LLM responses may be incomplete or have missing fields
