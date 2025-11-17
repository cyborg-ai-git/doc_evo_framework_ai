# **EATS for entity**
## Overview

EATS (Evo Ai Tokens System) is a high-performance, token-efficient serialization framework designed specifically for communication with Large Language Models (LLMs). It provides a compact, delimiter-based format that minimizes token usage while maintaining fast serialization/deserialization speeds and robust error handling.


### Key Features

- **40 - 50% Token Reduction** compared to JSON format
- **Fast Performance**: 6 µs serialization, 17 µs deserialization (*beta)
- **Robust Parsing**: UTF-8 safe, level-based nesting, comprehensive error handling
- **Generic Design**: Works with any entity type implementing IAiEntity trait
- **Backward Compatible**: Supports both legacy names and compact IDs

---

## Architecture

![EATS Architecture Overview](data/eats_architecture_overview.svg)

The system consists of four main layers:

### 1. Entity Layer
Defines the entity structures and the IAiEntity trait that all serializable entities must implement.

### 2. Serialization Layer
Handles conversion from entity structures to compact string format using inline functions for optimal performance.

### 3. Format Layer
Implements the delimiter-based format with level-based nesting support.

### 4. Deserialization Layer
Parses compact strings back into entity structures with robust error handling.

---

## Serialization Format

![EATS Format Structure](data/eats_format_structure.svg)

### Main Entity Line Format

```
EntityID|InstanceID|Field1|Field2|...|FieldN|
```

**Components:**

1. **Entity ID** (7 hex characters)
   - Derived from EVO_VERSION hash
   - Unique identifier for entity type
   - Example: `8qa30seqbYE`
   - Token cost: ~6 token

2. **Instance ID** (base64 characters)
   - Unique identifier for this specific entity instance
   - Can be empty (`||`) for auto-generation
   - Example: `s4WcOuKu2flddJ3bwApAhQdqsj/pdnSHQNA2ad0Gbeo=`
   - Token cost: 30-40 tokens 
   - Output Token cost: **0** tokens (auto-generation)

3. **Timestamp** (u64)
   - Unix timestamp in nanoseconds
   - Automatically generated
   - Example: `1763212259692436780`
   - Token cost: **0** tokens

4. **Fields** (variable)
   - Entity-specific field values
   - Primitives: unquoted (e.g., `true`, `42`, `3.14`)
   - Strings: quoted (e.g., `"Hello"`)
   - Binary: base64 encoded (e.g., `AQIDBAU=`)
   - Enums: variant name (e.g., `VAl02`)

5. **End Delimiter** (`|`)
   - Marks end of main entity line

### Nested Entity Format

```
Level|Key|EntityID|InstanceID|Timestamp|Fields...|
```

**Example:**
```
1|attribute_entity1|37a7ab1|xyz789...|1763212260|true|"Nested"|
```

- **Level**: Nesting depth (1-255)
   - 1 = direct child
   - 2 = grandchild
   - etc.
- **Key**: Attribute name in parent entity
- **Rest**: Same format as main entity line

### Map Entity Format

```
Level|MapKey|EntityID|InstanceID|Timestamp|Fields...|
```

Multiple lines with same level and key for multiple map entries.

**Example:**
```
1|attribute_map0|37a7ab1|aaa111...|1763212261|true|"Map Entry 1"|
1|attribute_map0|37a7ab1|bbb222...|1763212262|false|"Map Entry 2"|
```

---

## Complete Example

### Entity Structure
```
ETest0 (root)
├── Fields: bool, byte, double, string, etc.
├── attribute_entity1: ETest1
│   └── attribute_entity2: ETest2
│       └── attribute_entity1: ETest1
├── attribute_entity2: ETest2
├── attribute_map0: [ETest1, ETest1]
└── attribute_map1: [ETest2, ETest2]
```

### EATS Format (Compact)
```
611dd51|s4WcOuKu2flddJ3bwApAhQdqsj/pdnSHQNA2ad0Gbeo=|1763331862842012977|true|42|AQIDBAU=|3.14159|0|1|2.71828|-123|"English"|-9876543210|QkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkI=|"Test String \n\n|| \n\n"|456|9876543210|
1|attribute_entity1|37a7ab1|aQquXtE79XzOxqySj1sxnU+HSzIWc7YNOkqnyrnzBrI=|1763331862842034494|true|"Nested String 1"|"Entity1 Name"|
2|attribute_entity2|c9d5c5d|BBfDPGvX7f99MLw02rfYKV37LzQELuq1tr9hzMiDq1A=|1763331862842035543|"Deeply Nested String"|
3|attribute_entity1|37a7ab1|0VQYo47eX6jduNXbu8KH3IAWbYUacGRBNXhenTnhP6I=|1763331862842036218|false|"Deep String"|"Deep Entity"|
1|attribute_entity2|c9d5c5d|dQG09T8zJ2BTUeUIo6N/WqTiZStSOgFGcHeD1C1cXo8=|1763331862842042154|"Entity2 String"|
1|attribute_map0|37a7ab1|9UJOepfYliyvrpuG00yEw/LgBl1gG6ugXZ7JPozOJ6Q=|1763331862842043131|true|"Map Entity 1A"|"Map1A"|
1|attribute_map0|37a7ab1|VBEDSHOu9CAFm5nE8fTeLC0t/LGxelpGDYS0f5t1+pI=|1763331862842052072|false|"Map Entity 1B"|"Map1B"|
1|attribute_map1|c9d5c5d|/O2T4GE9OGkcFWaO9TA/4d5M+6ntovwYFSM1kO3M1Uc=|1763331862842053981|"Map Entity 2A"|
1|attribute_map1|c9d5c5d|6R4XHjrmZjbA51kg7/rJj5awEmr3JSeXVeQCXtIf6kA=|1763331862842073264|"Map Entity 2B"|
```

**EATS Statistics:**
- **Characters**: 1,362
- **Bytes**: 1,166
- **Tokens**: 633
- **Lines**: 9

### JSON Format (pretty print)
```json
{
   "type": "8qa30seqbYE",
   "id": "s4WcOuKu2flddJ3bwApAhQdqsj/pdnSHQNA2ad0Gbeo=",
   "time": 1763331862842012977,
   "attribute_bool": 1,
   "attribute_byte": 42,
   "attribute_bytes": "AQIDBAU=",
   "attribute_double": 3.14159,
   "attribute_enum0": "VAl02",
   "attribute_enum1": "VAl12",
   "attribute_float": 2.718280076980591,
   "attribute_int": -123,
   "attribute_language": "English",
   "attribute_long": -9876543210,
   "attribute_sha256": "QkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkJCQkI=",
   "attribute_string": "Test String \n\n|| \n\n",
   "attribute_uint": 456,
   "attribute_ulong": 9876543210,
   "attribute_entity1": {
      "type": "c9d5c5d",
      "id": "aQquXtE79XzOxqySj1sxnU+HSzIWc7YNOkqnyrnzBrI=",
      "time": 1763331862842034494,
      "attribute_bool": 1,
      "attribute_string": "Nested String 1",
      "name": "Entity1 Name",
      "attribute_entity2": {
         "_type": "37a7ab1",
         "id": "BBfDPGvX7f99MLw02rfYKV37LzQELuq1tr9hzMiDq1A=",
         "time": 1763331862842035543,
         "attribute_string": "Deeply Nested String",
         "attribute_entity1": {
            "_type": "c9d5c5d",
            "id": "0VQYo47eX6jduNXbu8KH3IAWbYUacGRBNXhenTnhP6I=",
            "time": 1763331862842036218,
            "attribute_bool": 0,
            "attribute_string": "Deep String",
            "name": "Deep Entity",
            "attribute_entity2": null
         }
      }
   },
   "attribute_entity2": {
      "type": "37a7ab1",
      "id": "dQG09T8zJ2BTUeUIo6N/WqTiZStSOgFGcHeD1C1cXo8=",
      "time": 1763331862842042154,
      "attribute_string": "Entity2 String",
      "attribute_entity1": null
   },
   "attribute_map0": {
      "9UJOepfYliyvrpuG00yEw/LgBl1gG6ugXZ7JPozOJ6Q=": {
         "type": "c9d5c5d",
         "id": "9UJOepfYliyvrpuG00yEw/LgBl1gG6ugXZ7JPozOJ6Q=",
         "time": 1763331862842043131,
         "attribute_bool": 1,
         "attribute_string": "Map Entity 1A",
         "name": "Map1A",
         "attribute_entity2": null
      },
      "VBEDSHOu9CAFm5nE8fTeLC0t/LGxelpGDYS0f5t1+pI=": {
         "_type": "c9d5c5d",
         "id": "VBEDSHOu9CAFm5nE8fTeLC0t/LGxelpGDYS0f5t1+pI=",
         "time": 1763331862842052072,
         "attribute_bool": 0,
         "attribute_string": "Map Entity 1B",
         "name": "Map1B",
         "attribute_entity2": null
      }
   },
   "attribute_map1": {
      "/O2T4GE9OGkcFWaO9TA/4d5M+6ntovwYFSM1kO3M1Uc=": {
         "type": "37a7ab1",
         "id": "/O2T4GE9OGkcFWaO9TA/4d5M+6ntovwYFSM1kO3M1Uc=",
         "time": 1763331862842053981,
         "attribute_string": "Map Entity 2A",
         "attribute_entity1": null
      },
      "6R4XHjrmZjbA51kg7/rJj5awEmr3JSeXVeQCXtIf6kA=": {
         "type": "37a7ab1",
         "id": "6R4XHjrmZjbA51kg7/rJj5awEmr3JSeXVeQCXtIf6kA=",
         "time": 1763331862842073264,
         "attribute_string": "Map Entity 2B",
         "attribute_entity1": null
      }
   }
}

```

**JSON Statistics:**
- **Characters**: 2729
- **Tokens**: **1146**

### Format Comparison

| Metric                | EATS             | JSON             | Savings        |
|-----------------------|------------------|------------------|----------------|
| **Characters**        | 1166             | 2729             | **58% fewer**  |
| **Bytes**             | 1166             | 2729             | **58% fewer**  |
| **Tokens**            | 633              | 1166             | **46% fewer**  |

**Key Advantages of EATS:**
1. **No field names** - Schema provides structure (saves ~30%)
2. **Compact entity IDs** - `611dd51` vs `evo_entity_test.ETest0` (saves 50% per type)
3. **Single delimiter** - `|` vs JSON syntax `{}:,` (saves 75% on structure)
4. **No whitespace** - Compact format (saves 10-15%)
5. **Flat nesting** - Level-based lines vs nested objects (saves 20%)
6. **No null values** - Omitted fields vs explicit `null` (saves 5-10%)

**Token Efficiency Breakdown:**
- **Entity type names**: JSON uses 25+ chars (`evo_entity_test.ETest0`), EATS uses 7 chars (`611dd51`)
- **Field names**: JSON repeats field names for every entity, EATS omits them entirely
- **Structural tokens**: JSON uses `{`, `}`, `:`, `,`, `"` extensively, EATS uses only `|`
- **Whitespace**: JSON typically formatted with indentation, EATS is compact

---

## Serialization Process

![EATS Serialization Flow](data/eats_serialization_flow.svg)

### Steps

1. **Initialize**: Create empty string buffer
2. **Write Entity ID**: Append compact hex ID (7 chars)
3. **Write Instance ID**: Append entity's unique ID (or empty)
4. **Write Timestamp**: Append entity's timestamp (or empty)
5. **Write Fields**: Append each field value with delimiter
6. **Write End Delimiter**: Mark end of main line
7. **Write Nested Entities**: For each nested entity, recursively serialize at level+1
8. **Write Maps**: For each map entry, serialize at level+1
9. **Return**: Complete compact string

### Performance

- **Entity Creation**: 1.45 µs
- **Serialization**: 6.59 µs
- **Total**: ~8 µs for complex entity with nesting

---

## Deserialization Process

![EATS Deserialization Flow](data/eats_deserialization_flow.svg)

### Steps

1. **Split by Lines**: Separate main line from nested entities
2. **Parse Main Line**:
   - Split by delimiter (`|`)
   - Validate field count
   - Parse Entity ID (accept both hex ID and legacy name)
   - Parse Instance ID (generate if empty)
   - Parse Timestamp (default to 0 if empty)
   - Parse each field using appropriate parser
3. **Parse Nested Entities**:
   - For each line, check level and key
   - If matches expected level+1, recursively parse
   - Set nested entity in parent
4. **Parse Maps**:
   - Collect all lines with same level and key
   - Parse each as entity
   - Add to map collection
5. **Validate**: Ensure main entity line was found
6. **Return**: Reconstructed entity

### Performance

- **Deserialization**: 21.14 µs
- **Nested Parsing**: 12.81 µs
- **Map Parsing**: 16.03 µs

### Error Handling

The parser provides robust error handling with descriptive messages:

- **Invalid Entity ID**: `INVALID_ENTITY_ID|{id}|`
- **Field Count Mismatch**: `NOT_VALID_PARAMETER_LEN|expected:{n}|got:{m}|`
- **Parse Failure**: `FAILED_TO_PARSE|{value}|`
- **Invalid Bool**: `NOT_VALID_BOOL|value:{v}|`
- **Invalid SHA256**: `INVALID_SHA256_LENGTH|expected:32|got:{n}|`
- **Missing Entity**: `NOT_CONTAIN_LINE{schema}|`

---

## Token Optimization

![EATS Token Optimization](data/eats_token_optimization.svg)

### Optimization Strategies

#### 1. Compact Entity IDs
- **Before**: `"ETest0"` (6 chars, 2 tokens)
- **After**: `611dd51` (7 hex chars, 1 token)
- **Savings**: 50% per entity type

#### 2. Omit Field Names
- Schema provides field order
- LLM knows structure from schema
- **Savings**: ~30% overall

#### 3. Single Delimiter
- Use `|` instead of JSON syntax (`{`, `}`, `:`, `,`)
- **Savings**: 75% on structural tokens

#### 4. Primitives Unquoted
- `true` instead of `"true"`
- `42` instead of `"42"`
- **Savings**: 2 tokens per primitive

#### 5. Base64 for Binary
- `AQIDBAU=` instead of `[1,2,3,4,5]`
- **Savings**: 80% for binary data

#### 6. No Whitespace
- Compact format with no spaces or newlines (except for nesting)
- **Savings**: 10-15% overall

### Token Efficiency Results

| Metric | Value |
|--------|-------|
| **Total Bytes** | 1,435 |
| **Total Characters** | 1,362 |
| **Total Tokens** | 507 |
| **Lines** | 9 |
| **Avg Tokens/Line** | 56 |
| **Compression Ratio** | 2.83 bytes/token |

### Comparison: EATS vs JSON

| Format | Tokens | Bytes | Characters | Savings |
|--------|--------|-------|------------|---------|
| **JSON** | ~875 | 3,847 | 3,847 | - |
| **EATS** | 507 | 1,435 | 1,362 | **42% tokens, 63% bytes** |

**Real-world example** (same complex entity with 3-level nesting and maps):
- JSON requires full package names (`evo_entity_test.ETest0`), field names for every property, and structural syntax
- EATS uses compact 7-char hex IDs (`611dd51`), omits field names, and uses single delimiter
- Result: **42% fewer tokens** for LLM API calls, translating to significant cost savings at scale

---

## Level-Based Nesting

### Why Level-Based?

Level-based nesting prevents ambiguity when nested entities have attributes with the same names as their parents.

### Example Problem (Without Levels)

```
ETest0
├── attribute_entity1: ETest1
│   └── attribute_entity1: ETest1  ← Same name!
```

Without level checking, the parser might incorrectly assign the nested `attribute_entity1` to the wrong parent.

### Solution: Level Tracking

Each nested entity line includes its nesting level:

```
611dd51|...|                          ← Level 0 (implicit)
1|attribute_entity1|37a7ab1|...|      ← Level 1 (child of level 0)
2|attribute_entity1|37a7ab1|...|      ← Level 2 (child of level 1)
```

The parser checks both the key name AND the level to ensure correct assignment.

### Maximum Nesting Depth

- **Max Level**: 255
- **Overflow Handling**: Outputs `MAX_LEVEL_REACHED` instead of continuing
- **Prevents**: Infinite recursion and stack overflow

---

## Token Counting

### Accurate Token Estimation

The system includes an accurate token counter that estimates LLM token usage:

```
do_token_count(text: &str) -> usize
```

### Tokenization Rules

1. **Alphanumeric sequences**: ~1 token per 3 characters
2. **Numbers**: 1-2 tokens depending on length
3. **Special characters**: 1-2 token each
4. **Delimiters**: 1 token each
5. **Whitespace**: Ignored

### Token Statistics

```
do_token_stats(text: &str) -> TokenStats
```

Returns comprehensive statistics:
- Byte count
- Character count (UTF-8 aware)
- Token count
- Line count
- Average tokens per line
- Compression ratio (bytes/token)

---

## Performance Characteristics

### Benchmarks (Complex Entity with Nesting)

| Operation | Time | Notes |
|-----------|------|-------|
| Entity Creation | 1.45 µs | Object construction |
| Serialization | 6.59 µs | to_ai() |
| Deserialization | 21.14 µs | from_ai() with parsing |
| Round-trip | 32.74 µs | Full cycle |
| Token Counting | 21.42 µs | Accurate tokenization |
| Nested Parsing | 12.81 µs | 3 levels deep |
| Map Parsing | 16.03 µs | 4 map entities |

### Optimization Techniques

1. **Inline Functions**: All helper functions use `#[inline(always)]`
2. **Zero-Copy Parsing**: Direct string slicing where possible
3. **Single-Pass Validation**: No multiple iterations
4. **Preallocated Buffers**: String capacity estimation
5. **UTF-8 Safe**: Proper multi-byte character handling

---

## Entity ID System

### EVO_VERSION Hash

Each entity type has a unique `EVO_VERSION` constant (u64 hash):

```
ETest0: 6997983723661432662
ETest1: 4010362126130004310
ETest2: 14543748076857083330
ETest3: 15520205264705978858
```

### Compact Hex ID Generation

The system extracts 28 bits (7 hex characters) from the EVO_VERSION:

```
hex_id = format!("{:07x}", (evo_version >> 36) & 0xFFFFFFF)
```

**Results:**

| Entity  | EVO_VERSION          | Hex ID  |
|---------|----------------------|---------|
| ETest0  | 6997983723661432662  | 611dd51 |
| ETest1  | 4010362126130004310  | 37a7ab1 |
| ETest2  | 14543748076857083330 | c9d5c5d |
| ETest3  | 15520205264705978858 | d762d87 |

### Benefits

- **Unique**: 28 bits = 268 million combinations
- **Compact**: 7 characters = 1 token
- **Collision-Resistant**: Hash-based derivation
- **Universal**: Works across packages and systems

---

## Schema System

### Purpose

Schemas provide LLMs with structure information so they can correctly generate and parse entity data.

### Schema Format

```
[EntityID]
id=ID
time=ULONG
field_name=TYPE
optional_field=OPTIONAL TYPE
entity_field=ENTITY EntityID
map_field=MAP EntityID
enum_field=ENUM
```

**Note:** Schemas use compact 7-character hex Entity IDs (e.g., `611dd51`) instead of entity names for optimal token efficiency.

### Example Schema

```
[611dd51]
id=ID
time=ULONG
attribute_bool=BOOL
attribute_byte=BYTE
attribute_double=DOUBLE
attribute_entity1=ENTITY 37a7ab1
attribute_entity2=ENTITY c9d5c5d
attribute_enum0=ENUM 
attribute_enum1=ENUM
attribute_float=FLOAT
attribute_int=INT
attribute_long=LONG
attribute_map0=MAP 37a7ab1
attribute_map1=MAP c9d5c5d
attribute_sha256=SHA256
attribute_uint=UINT
attribute_ulong=ULONG
```

### Type Mappings

| Schema Type | Rust Type      | Serialization        | Token Cost |
|-------------|----------------|----------------------|------------|
| BOOL        | bool           | `true`/`false`       | 1          |
| BYTE        | u8             | `42`                 | 1          |
| INT         | i32            | `-123..`             | 2          |
| UINT        | u32            | `456..`              | ~3         |
| LONG        | i64            | `-9876543210`        | ~5         |
| ULONG       | u64            | `9876543210`         | ~4         |
| FLOAT       | f32            | `2.71828`            | ~4         |
| DOUBLE      | f64            | `3.14159`            | ~4         |
| STRING      | String         | `"...text"`          | Variable   |
| BYTES       | Vec<u8>        | `...AQIDBAU=`        | Variable   |
| SHA256      | [u8; 32]       | `4242...` (64 hex)   | ~40        |
| SHA512      | [u8; 64]       | `4242...` (128 hex)  | ~80        |
| ID          | [u8; 32]       | `abc123...` (base64) | ~35        |
| ENUM        | Enum (u8)      | `0`                  | 1          |
| ENTITY      | Option<Arc<T>> | Nested line          | Variable   |
| MAP         | MapEntity<T>   | Multiple lines       | Variable   |

---


## Best Practices

### For Serialization

1. **Use Compact IDs**: Always use hex entity IDs for new code
2. **Minimize Nesting**: Keep entity hierarchies shallow when possible
3. **Batch Operations**: Serialize multiple entities together
4. **Reuse Buffers**: Pass mutable String to avoid allocations

### For Deserialization

1. **Validate Early**: Check entity ID before parsing fields
2. **Handle Errors**: Always check Result types
3. **Use Levels**: Always pass correct level parameter
4. **Default Values**: Handle empty ID and timestamp gracefully

### For LLM Communication

1. **Include Schema**: Always provide schema to LLM first
2. **Validate Output**: Parse LLM-generated strings carefully
3. **Error Recovery**: Handle parse errors gracefully
4. **Token Budget**: Monitor token usage with do_token_count()

---

## Future Enhancements

### Base62 Encoding

Potential further optimization using base62 encoding:

- **SHA256**: 64 hex chars → 43 base62 chars (31% reduction)
- **Entity ID**: 7 hex chars → 5 base62 chars (29% reduction)
- **Trade-off**: More complex encoding/decoding

### Binary Format

Optional binary serialization for maximum speed:

- **Pros**: Faster parsing, smaller size
- **Cons**: Not human-readable, not LLM-friendly

### Compression

Optional compression for large entity graphs:

- **Pros**: Smaller payload
- **Cons**: CPU overhead, not suitable for LLMs

---

## EATS Conclusion

The EATS Entity serialization provides an optimal balance of:

- **Token Efficiency**: 40 - 50%  reduction vs JSON
- **Performance**: Sub-microsecond serialization
- **Robustness**: Comprehensive error handling
- **Flexibility**: Generic design for any entity type
- **Compatibility**: Supports legacy formats

This makes it ideal for high-performance LLM communication where token costs and latency are critical factors.

---

> EATS is now in beta version the preformances and tokens count will be optimized with new **eats_finetunes** direct binary entities

\pagebreak