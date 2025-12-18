# LLM Tool Calling - Limits, Performance & Best Practices

## Overview

Tool calling allows LLMs to invoke external functions with structured JSON arguments. This document covers practical limits, performance considerations, and common issues.

---

## Tool Limits by Provider

### Hard Limits

| Provider | Max Tools | Max Parallel Calls | Notes |
|----------|-----------|-------------------|-------|
| OpenAI (GPT-4o) | 128 | 128 | Enforced API limit |
| OpenAI (GPT-4) | 128 | 128 | Enforced API limit |
| Anthropic (Claude) | No hard limit | 1 | Sequential only |
| Google (Gemini) | 128 | Multiple | Similar to OpenAI |
| Ollama (local) | Context dependent | 1 | Limited by context window |
| Groq | 128 | Multiple | Fast inference |

### Practical Limits (Recommended)

| Tool Count | Performance | Accuracy | Use Case |
|------------|-------------|----------|----------|
| 1-10 | Excellent | 99%+ | Simple agents |
| 11-30 | Very Good | 95%+ | Standard applications |
| 31-50 | Good | 90%+ | Complex workflows |
| 51-100 | Moderate | 80-90% | Large systems |
| 100+ | Degraded | <80% | Not recommended |

---

## Context Window Consumption

### Token Cost per Tool

Each tool definition consumes tokens from the context window:

| Component | Tokens (approx) |
|-----------|-----------------|
| Tool name | 5-10 |
| Description | 20-50 |
| Parameters (simple) | 30-50 |
| Parameters (complex) | 100-300 |
| **Total per tool** | **50-400** |

### Example Calculation

```
10 tools × 100 tokens = 1,000 tokens
50 tools × 150 tokens = 7,500 tokens
100 tools × 200 tokens = 20,000 tokens
```

**Impact on conversation:**
- GPT-4o (128k context): 100 tools = ~15% of context
- Llama 3 (8k context): 100 tools = ~250% (won't fit!)
- Claude 3.5 (200k context): 100 tools = ~10% of context

---

## Performance Impact

### Latency by Tool Count

| Tools | Selection Time | Total Latency Impact |
|-------|----------------|---------------------|
| 5 | ~50ms | Negligible |
| 20 | ~100ms | Minimal |
| 50 | ~200ms | Noticeable |
| 100 | ~500ms | Significant |

### Memory Usage (Ollama/Local)

| Tools | Additional VRAM | Notes |
|-------|-----------------|-------|
| 10 | ~50MB | Minimal impact |
| 50 | ~200MB | Moderate |
| 100 | ~500MB | May cause swapping |

---

## Common Issues

### 1. Tool Hallucination

**Problem:** LLM invents tool names or parameters that don't exist.

**Causes:**
- Too many similar tools
- Vague descriptions
- Missing required parameters in schema

**Solutions:**
- Use unique, descriptive names
- Add clear descriptions
- Use constrained generation (Ollama `format` parameter)
- Validate tool calls before execution

### 2. Wrong Tool Selection

**Problem:** LLM picks incorrect tool for the task.

**Causes:**
- Overlapping tool descriptions
- Ambiguous user request
- Too many tools to choose from

**Solutions:**
- Make descriptions mutually exclusive
- Add examples in system prompt
- Use tool categories/namespaces
- Implement fallback/default tool

### 3. Parameter Errors

**Problem:** LLM provides wrong parameter types or values.

**Causes:**
- Complex nested schemas
- Unclear parameter descriptions
- Missing `required` field

**Solutions:**
- Keep schemas flat (no `$ref`)
- Use simple types (string, number, boolean)
- Always specify `required` array
- Add parameter examples in description

### 4. Infinite Tool Loops

**Problem:** Agent keeps calling tools without completing task.

**Causes:**
- No termination condition
- Tool returns unclear results
- Missing "done" tool

**Solutions:**
- Add max iteration limit
- Include "task_complete" tool
- Return clear success/failure messages
- Implement conversation history pruning

---

## MCP vs OpenAI Tool Format

### Format Comparison

| Aspect | MCP Format | OpenAI Format |
|--------|------------|---------------|
| Purpose | Server-to-server | LLM tool calling |
| Schema location | `inputSchema` | `parameters` |
| Wrapper | None | `type: function`, `function: {}` |
| `$ref` support | Yes | No (must inline) |
| Used by | MCP servers | OpenAI, Ollama, Anthropic |

### MCP Format (Model Context Protocol)

```json
{
    "name": "list_files",
    "description": "List files in directory",
    "inputSchema": {
        "type": "object",
        "properties": {
            "path": {
                "type": "string",
                "description": "Directory path"
            }
        },
        "required": ["path"]
    }
}
```

### OpenAI Format (LLM Tool Calling)

```json
{
    "type": "function",
    "function": {
        "name": "list_files",
        "description": "List files in directory",
        "parameters": {
            "type": "object",
            "properties": {
                "path": {
                    "type": "string",
                    "description": "Directory path"
                }
            },
            "required": ["path"]
        }
    }
}
```

### Key Differences Table

| Feature | MCP | OpenAI |
|---------|-----|--------|
| Root key for schema | `inputSchema` | `parameters` |
| Requires `type: function` | No | Yes |
| Requires `function` wrapper | No | Yes |
| Supports `$ref` | Yes | No |
| Supports `$defs` | Yes | No |
| Used for constrained generation | No | Yes |

### When to Use Each

| Use Case | Format |
|----------|--------|
| MCP server definition | MCP |
| Ollama tool calling | OpenAI |
| OpenAI API | OpenAI |
| Anthropic API | OpenAI (adapted) |
| Claude MCP integration | MCP |
| Local LLM (llama.cpp) | OpenAI |

---

## MCP Server Limits

### Protocol Limits

MCP (Model Context Protocol) has no hard-coded limits, but practical constraints exist:

| Aspect | Limit | Notes |
|--------|-------|-------|
| Tools per server | No limit | Practical: ~100 |
| Servers per client | No limit | Practical: ~10-20 |
| Total tools (all servers) | No limit | Context window is the limit |
| Tool name length | No limit | Keep under 64 chars |
| Description length | No limit | Keep under 500 chars |
| Parameter count | No limit | Keep under 20 |

### MCP Server Recommendations

| Server Count | Tools per Server | Total Tools | Use Case |
|--------------|------------------|-------------|----------|
| 1-3 | 10-20 | 10-60 | Simple integration |
| 4-10 | 5-15 | 20-150 | Standard application |
| 10+ | 3-10 | 30-100+ | Enterprise (use dynamic loading) |

### MCP vs Direct Tool Calling

| Aspect | MCP | Direct Tool Calling |
|--------|-----|---------------------|
| Architecture | Client ↔ Server | LLM ↔ Application |
| Transport | stdio, HTTP, WebSocket | API call |
| Tool discovery | Dynamic (`tools/list`) | Static (compile time) |
| Authentication | Server handles | Application handles |
| Scaling | Multiple servers | Single application |
| Latency | +10-50ms (IPC overhead) | Minimal |
| Use case | IDE plugins, external services | Embedded agents |

### MCP Resource Limits

| Resource Type | Recommended Max | Notes |
|---------------|-----------------|-------|
| Resources | 100 per server | URIs for context |
| Prompts | 50 per server | Reusable templates |
| Tools | 100 per server | Callable functions |
| Subscriptions | 20 per client | Real-time updates |

### MCP Performance Considerations

| Factor | Impact | Mitigation |
|--------|--------|------------|
| Server startup | 100-500ms | Keep servers running |
| Tool list fetch | 10-50ms | Cache tool definitions |
| Tool execution | Varies | Async execution |
| Multiple servers | Additive latency | Parallel initialization |

### MCP Memory Usage

| Configuration | Memory (approx) |
|---------------|-----------------|
| 1 server, 10 tools | ~20MB |
| 5 servers, 50 tools | ~100MB |
| 10 servers, 100 tools | ~250MB |

---

## Numeric Tool IDs (u64)

### Why Use u64 Instead of String Names

Using numeric IDs (u64) for tool names provides significant advantages:

| Aspect | String Name | u64 ID |
|--------|-------------|--------|
| Tokens consumed | 10-30 tokens | 6-7 tokens |
| Example | `"create_linkedin_post"` | `"16349718268121886614"` |
| Parsing | String comparison | Direct u64 parse |
| Memory (HashMap key) | 24+ bytes | 8 bytes |
| Hash computation | String hash | Identity (u64 is hash) |
| Collision risk | Possible | None (unique IDs) |

### Token Savings

```
String name: "list_files_in_directory" = ~8 tokens
u64 ID:      "284588174146306401"      = ~6 tokens

With 50 tools:
- String names: ~400 tokens
- u64 IDs: ~300 tokens
- Savings: ~100 tokens (25%)
```

### Implementation Pattern

```rust
// Constants for tool IDs
pub const ACTION_QUERY_FILE: u64 = 284588174146306401;
pub const ACTION_GET_FILE: u64 = 11006331612292911892;
pub const ACTION_SET_FILE: u64 = 8595572317688138765;

// Tool schema uses u64 as string
{
    "type": "function",
    "function": {
        "name": "284588174146306401",  // u64 as string
        "description": "List files in directory",
        "parameters": { ... }
    }
}

// Parsing is simple
let tool_id: u64 = tool_name.parse().unwrap();

// HashMap lookup is O(1) with u64 key
let handler = map_tools.get(&tool_id);
```

### Memory Comparison

| Tools | String Keys (HashMap) | u64 Keys (HashMap) |
|-------|----------------------|-------------------|
| 10 | ~400 bytes | ~80 bytes |
| 50 | ~2,000 bytes | ~400 bytes |
| 100 | ~4,000 bytes | ~800 bytes |

### Benefits Summary

1. **Fewer tokens** - 6-7 tokens vs 10-30 for descriptive names
2. **Faster parsing** - `str.parse::<u64>()` vs string comparison
3. **Less memory** - 8 bytes vs 24+ bytes per key
4. **No collisions** - Unique u64 IDs guaranteed
5. **Simpler routing** - Direct numeric lookup in HashMap
6. **Type safety** - Compile-time u64 constants

### Generating Tool IDs

```rust
// Option 1: Random u64
let id = rand::random::<u64>();

// Option 2: Hash of tool name (deterministic)
use std::hash::{Hash, Hasher};
let mut hasher = std::collections::hash_map::DefaultHasher::new();
"list_files".hash(&mut hasher);
let id = hasher.finish();

// Option 3: Timestamp-based (unique per creation)
let id = std::time::SystemTime::now()
    .duration_since(std::time::UNIX_EPOCH)
    .unwrap()
    .as_nanos() as u64;
```

---

## Best Practices

### Tool Design

1. **One tool = One action**
   - Bad: `file_operations` (does read, write, delete)
   - Good: `file_read`, `file_write`, `file_delete`

2. **Clear, unique descriptions**
   - Bad: "Handles files"
   - Good: "Read text content from a file at the specified path"

3. **Simple parameter schemas**
   - Avoid nested objects
   - Use primitive types
   - Always include descriptions

4. **Consistent naming**
   - Use snake_case or camelCase consistently
   - Group related tools with prefixes: `file_read`, `file_write`

### Performance Optimization

1. **Dynamic tool loading**
   - Only send relevant tools per request
   - Use tool categories

2. **Caching**
   - Cache tool schemas (they're static)
   - Cache common tool call results

3. **Batching**
   - Group related operations
   - Use parallel tool calls when supported

### Error Handling

1. **Validate before execution**
   - Check tool name exists
   - Validate parameter types
   - Check required parameters

2. **Return structured errors**
   ```json
   {
       "success": false,
       "error": "File not found",
       "path": "/invalid/path"
   }
   ```

3. **Implement retries**
   - Retry on transient failures
   - Max 3 retries with backoff

---

## Constrained Generation

### How It Works

Constrained generation forces LLM to output valid JSON matching the tool schema:

1. LLM generates token probabilities
2. Grammar masks invalid tokens (probability → 0)
3. Only valid tokens can be selected
4. Result: 100% valid JSON

### Supported Features

| Feature | Supported | Notes |
|---------|-----------|-------|
| `type: object` | ✅ | Required for tools |
| `type: string` | ✅ | Most common |
| `type: number` | ✅ | Integers and floats |
| `type: boolean` | ✅ | true/false |
| `type: array` | ✅ | With `items` |
| `required` | ✅ | Enforced |
| `enum` | ✅ | Limited choices |
| `$ref` | ❌ | Must inline |
| `$defs` | ❌ | Must inline |
| `pattern` | ❌ | Not enforced |
| `if/then/else` | ❌ | Not supported |

### Performance Impact

| Mode | Speed | JSON Valid Rate |
|------|-------|-----------------|
| Unconstrained | Fast | ~30-50% |
| Constrained | 10-20% slower | 100% |

---

## Summary

| Aspect | Recommendation |
|--------|----------------|
| Max tools | 50 for best accuracy |
| Tool schema | OpenAI format for LLMs |
| Parameters | Keep flat, no `$ref` |
| Descriptions | Clear, unique, with examples |
| Error handling | Validate + structured errors |
| Performance | Dynamic loading + caching |
\pagebreak