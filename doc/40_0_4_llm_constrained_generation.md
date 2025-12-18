# LLM Constrained Generation - How It Works

## Overview

Constrained generation (also called "structured output" or "guided generation") forces the LLM to output only valid JSON that matches a specific schema. LLM implements this using **grammar-based token masking**.

---

## The Problem: Free Text Generation

Without constraints, LLMs generate tokens freely and may produce invalid JSON:

**User prompt:** "List files in the current directory"

**Unconstrained output (problematic):**
```
Sure! I'll help you list the files. Here's what I found:
- file1.txt
- file2.rs
Let me know if you need more help!
```

This is natural language, not parseable JSON.

---

## The Solution: Constrained Generation

With a schema constraint, LLM **masks invalid tokens** at each generation step.

### Step-by-Step Process

**Given this tool schema:**
```json
{
  "type": "function",
  "function": {
    "name": "list_files",
    "parameters": {
      "type": "object",
      "properties": {
        "path": {
          "type": "string",
          "description": "Directory path"
        },
        "recursive": {
          "type": "boolean",
          "description": "Include subdirectories"
        }
      },
      "required": ["path"]
    }
  }
}
```

**LLM converts this to a grammar that enforces:**
```
output = "{" + properties + "}"
properties = "path" : string [, "recursive" : boolean]
string = '"' + characters + '"'
boolean = "true" | "false"
```

---

## Token-by-Token Generation

### Generation Step 1: Start of JSON

**LLM's raw token probabilities:**
```json
{
  "Sure": 0.25,
  "I": 0.20,
  "{": 0.15,
  "The": 0.18,
  "Here": 0.12,
  "Let": 0.10
}
```

**After grammar constraint (must start with `{`):**
```json
{
  "Sure": 0.0,
  "I": 0.0,
  "{": 1.0,
  "The": 0.0,
  "Here": 0.0,
  "Let": 0.0
}
```

**Output:** `{`

---

### Generation Step 2: First Key

**Current output:** `{`

**Grammar says:** Next must be `"` to start a property key

**LLM's raw probabilities:**
```json
{
  "\"path\"": 0.40,
  "\"recursive\"": 0.25,
  "\"name\"": 0.15,
  "path": 0.10,
  "hello": 0.10
}
```

**After constraint (must be valid key from schema):**
```json
{
  "\"path\"": 0.62,
  "\"recursive\"": 0.38,
  "\"name\"": 0.0,
  "path": 0.0,
  "hello": 0.0
}
```

**Output:** `{"path"`

---

### Generation Step 3: Colon Separator

**Current output:** `{"path"`

**Grammar says:** Must be `:`

**All probabilities forced to:**
```json
{
  ":": 1.0,
  ",": 0.0,
  "}": 0.0,
  "=": 0.0
}
```

**Output:** `{"path":`

---

### Generation Step 4: String Value

**Current output:** `{"path":`

**Grammar says:** Must be `"` to start string value

**LLM's raw probabilities for the actual value:**
```json
{
  "\".\"": 0.35,
  "\"/home\"": 0.25,
  "\"./src\"": 0.20,
  "\"/tmp\"": 0.15,
  "null": 0.05
}
```

**After constraint (must be string, not null):**
```json
{
  "\".\"": 0.41,
  "\"/home\"": 0.29,
  "\"./src\"": 0.24,
  "\"/tmp\"": 0.18,
  "null": 0.0
}
```

**Output:** `{"path":"."`

---

### Generation Step 5: Continue or End

**Current output:** `{"path":"."`

**Grammar says:** Must be `,` (more properties) or `}` (end object)

**LLM's probabilities:**
```json
{
  ",": 0.40,
  "}": 0.60
}
```

**Output:** `{"path":"."}`

---

## Final Constrained Output

```json
{
  "path": "."
}
```

**100% valid JSON, guaranteed to match schema.**

---

## How LLM Implements This

### 1. Schema to Grammar Conversion

LLM converts JSON Schema to a context-free grammar:

**Input Schema:**
```json
{
  "type": "object",
  "properties": {
    "path": {"type": "string"},
    "recursive": {"type": "boolean"}
  },
  "required": ["path"]
}
```

**Internal Grammar (simplified):**
```
root        → "{" members "}"
members     → pair ("," pair)*
pair        → key ":" value
key         → "\"path\"" | "\"recursive\""
value       → string | boolean
string      → "\"" chars "\""
boolean     → "true" | "false"
```

### 2. Token Masking During Generation

At each step, LLM:
1. Gets LLM's next-token probability distribution
2. Identifies which tokens are valid according to grammar state
3. Sets probability of invalid tokens to 0
4. Renormalizes remaining probabilities
5. Samples from valid tokens only

---

## Comparison: With vs Without Constraints

### Without Constraints (format: null)

**Request:**
```json
{
  "model": "llama3",
  "messages": [
    {"role": "user", "content": "List files in current directory"}
  ]
}
```

**Possible outputs:**
```
"Sure, I can help with that! Use the ls command..."
"Here are the files: file1.txt, file2.rs..."
"{"path": "."}"
"I'll list the files for you:\n1. README.md\n2. ..."
```

**Success rate for valid JSON:** ~20-40%

---

### With Constraints (format: schema)

**Request:**
```json
{
  "model": "llama3",
  "messages": [
    {"role": "user", "content": "List files in current directory"}
  ],
  "format": {
    "type": "object",
    "properties": {
      "path": {"type": "string"}
    },
    "required": ["path"]
  }
}
```

**Output (always):**
```json
{"path": "."}
```

**Success rate for valid JSON:** 100%

---

## Tool Calling in LLM

When you provide tools, LLM uses the same constrained generation:

**Request with tools:**
```json
{
  "model": "llama3",
  "messages": [
    {"role": "user", "content": "List files in /home"}
  ],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "16349718268121886623",
        "description": "Execute terminal command",
        "parameters": {
          "type": "object",
          "properties": {
            "program": {"type": "string"},
            "params": {"type": "string"}
          },
          "required": ["program"]
        }
      }
    },
    {
      "type": "function", 
      "function": {
        "name": "284588174146306401",
        "description": "List files in directory",
        "parameters": {
          "type": "object",
          "properties": {
            "path": {"type": "string"}
          },
          "required": ["path"]
        }
      }
    }
  ]
}
```

**LLM's internal process:**

1. Builds grammar that allows calling ANY of the provided tools
2. Grammar enforces tool call structure:
```
tool_call → {"name": tool_name, "arguments": arguments}
tool_name → "16349718268121886623" | "284588174146306401"
arguments → (schema for selected tool)
```

3. LLM chooses which tool based on context
4. Arguments are constrained to match that tool's schema

**Response:**
```json
{
  "message": {
    "role": "assistant",
    "tool_calls": [
      {
        "function": {
          "name": "284588174146306401",
          "arguments": "{\"path\":\"/home\"}"
        }
      }
    ]
  }
}
```

---

## Limitations of Constrained Generation

### What Works

```json
{
  "type": "object",
  "properties": {
    "name": {"type": "string"},
    "count": {"type": "integer"},
    "active": {"type": "boolean"},
    "tags": {
      "type": "array",
      "items": {"type": "string"}
    }
  }
}
```

### What Does NOT Work

**1. $ref references:**
```json
{
  "$defs": {
    "Person": {"type": "object", "properties": {"name": {"type": "string"}}}
  },
  "properties": {
    "user": {"$ref": "#/$defs/Person"}
  }
}
```
❌ LLM cannot resolve `$ref` - must inline the schema

**2. Complex conditionals:**
```json
{
  "if": {"properties": {"type": {"const": "A"}}},
  "then": {"required": ["fieldA"]},
  "else": {"required": ["fieldB"]}
}
```
❌ Not supported

**3. Pattern validation:**
```json
{
  "type": "string",
  "pattern": "^[a-z]+@[a-z]+\\.[a-z]+$"
}
```
❌ Regex patterns not enforced during generation

---

## Performance Impact

| Mode | Speed | JSON Valid | Flexibility |
|------|-------|------------|-------------|
| Unconstrained | Fast | ~30% | Any output |
| Constrained | ~10-20% slower | 100% | Schema only |

The slowdown comes from:
- Grammar state tracking
- Token probability masking
- Additional memory for grammar rules

---

## Summary

1. **Constrained generation** forces LLM to output valid JSON
2. Works by **masking invalid tokens** at each generation step
3. LLM converts JSON Schema to internal grammar rules
4. **100% valid JSON** but limited to simple schemas
5. **No support for $ref** - must use flat, inline schemas
6. Tool calling uses same mechanism with tool-specific grammars
