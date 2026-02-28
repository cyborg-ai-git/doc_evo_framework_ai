# **EATS Tool Migra -- In-Memory Tool Selection for Evo AI Agents**

## Context

**Package:** `evo_ai_tool_migra`
**Layer:** EATS (Evo AI Tokenization System)
**Purpose:** Fast, LLM-free tool routing for autonomous agent workflows

> Within the Evo framework, AI agents must select the correct tool from a registry of available capabilities before invoking it. Traditional approaches rely on an LLM round-trip to interpret the user query and map it to a tool name. This introduces latency, token cost, and a dependency on external inference services.
>
> `evo_ai_tool_migra` eliminates this dependency by providing 8 in-memory search approaches that run locally with zero network calls. The library covers the full spectrum from sub-microsecond exact lookup to sub-2ms GPU-accelerated semantic search.

---

## Problem Statement

### LLM-Based Tool Selection: Current Limitations

When an AI agent receives a user query and must decide which tool to invoke, the standard approach is:

```
User Query -> LLM Inference -> Tool Name -> Tool Execution -> Response
```

**Issues with this approach:**

- **Latency**: An LLM round-trip adds 200-2000 ms per tool selection, depending on model size and provider
- **Token cost**: Every tool selection consumes input tokens (tool descriptions) and output tokens (tool name), accumulating cost at scale
- **Network dependency**: Requires active connection to an inference endpoint; fails offline
- **Non-determinism**: LLM outputs vary across runs; the same query may select different tools
- **Scaling ceiling**: Adding more tools increases the prompt size, degrading selection accuracy and speed

### In-Memory Alternative

```
User Query -> Local Index Lookup -> Tool Name -> Tool Execution -> Response
```

**Advantages:**

- **Deterministic**: Same query always returns the same ranked results
- **Offline**: Runs entirely in-process, no network required
- **Fast**: 280 ns to 1.2 ms depending on approach and hardware
- **Scalable**: Linear scaling to thousands of tools without accuracy degradation
- **Cost-free**: Zero token consumption for tool selection

---

## Search Approaches

`evo_ai_tool_migra` provides 8 distinct approaches, each optimised for different query patterns and latency requirements.

### 1. Tag Search

**Type:** Exact match
**Data structure:** HashMap mapping tag names to tool indices
**Complexity:** O(q) where q = query tokens

Builds a hash map from curated tag names to tool indices. Query words are matched directly against tag names. Tools matching more tags score higher. Does not understand synonyms or context -- the query must contain exact tag names.

**Best for:** Structured input from UI dropdowns, predefined categories, programmatic tool dispatch.

### 2. Keyword Search (Inverted Index)

**Type:** Lexical
**Data structure:** Inverted index with Porter stemming
**Complexity:** O(q) lookup per query

Tokenises and stems all tool descriptions into a HashMap where each stem maps to a list of tools containing it, with frequency counts. Search tokenises the query, looks up each stem, and ranks tools by total hit frequency.

**Best for:** Fast general-purpose search where query terms overlap with tool descriptions.

### 3. Trie Search (Prefix + Fuzzy)

**Type:** Lexical
**Data structure:** Prefix tree (trie)
**Complexity:** O(m) per word, where m = word length

Inserts all stemmed words from tool descriptions into a trie. Supports prefix matching (autocomplete) and fuzzy matching with configurable edit distance (handles typos via substitution, insertion, deletion).

**Best for:** Autocomplete interfaces, typo-tolerant search, partial input matching.

### 4. TF-IDF Search

**Type:** Statistical
**Data structure:** TF-IDF weighted vector space
**Complexity:** O(n * q) where n = tools

Computes a TF-IDF vector for each tool description. Rare words (appearing in few tools) get higher weight than common words (appearing in many tools). Search vectorises the query and ranks by cosine similarity.

**Best for:** Relevance-ranked search where distinguishing terms matter more than common ones.

### 5. BM25 Search

**Type:** Statistical (probabilistic)
**Data structure:** BM25 scoring with document length normalisation
**Complexity:** O(n * q)
**Parameters:** k1=1.2 (term saturation), b=0.75 (length normalisation)

Industry-standard ranking function (Okapi BM25) used by Elasticsearch and Lucene. Extends TF-IDF with document length normalisation (shorter descriptions are not penalised) and term frequency saturation (diminishing returns from repeated words).

**Best for:** General-purpose ranked search. Gold standard for text retrieval across all tool registry sizes.

### 6. Embedding Search (Bag-of-Words)

**Type:** Vector similarity
**Data structure:** BoW vectors with TF-IDF weights
**Complexity:** O(n * d) where d = vocabulary size

Builds a global vocabulary from all tool descriptions. Each tool becomes a vector where each dimension is the TF-IDF weight for that vocabulary word. Search vectorises the query and computes cosine similarity against all tool vectors. No ML model required.

**Best for:** Lightweight vector similarity when an ML model cannot be loaded.

### 7. Ensemble Search (Reciprocal Rank Fusion)

**Type:** Multi-signal fusion
**Data structure:** Combines all 6 approaches above
**Complexity:** O(6 * above)

Runs all 6 approaches, then merges ranked results using Reciprocal Rank Fusion (RRF). Each approach contributes a score of `weight / (rrf_k + rank)`. Default weights: BM25=1.5x, TF-IDF=1.2x, Tag=1.3x, others=1.0x.

**Best for:** Maximum accuracy on ambiguous or multi-intent queries. Most robust approach overall.

### 8. Neural Embedding (ONNX Runtime)

**Type:** Semantic (transformer)
**Data structure:** 384-dimensional dense vectors from sentence transformers
**Complexity:** O(n) cosine similarity after one-time model inference

True semantic embedding using transformer neural networks via ONNX Runtime. Tokenises text with a BPE tokenizer, runs inference through a 12-layer transformer, applies mean pooling, and L2-normalises. Understands meaning: "What is the temperature outside?" correctly routes to a weather tool even without the word "weather" in the query.

**Supported models:**

| Model | Parameters | Dimension | Prefix Required |
|-------|-----------|-----------|-----------------|
| all-MiniLM-L6-v2 | 22.7M | 384 | No |
| e5-small-v2 | 33M | 384 | Yes (query/passage) |

**Supported execution providers (GPU acceleration):**

| Device | Feature Flag | Requirement |
|--------|-------------|-------------|
| CPU | `ort` | Always available |
| CUDA | `cuda` | NVIDIA GPU + CUDA toolkit |
| TensorRT | `tensorrt` | NVIDIA GPU + TensorRT libraries |
| WebGPU (Vulkan) | `webgpu` | Vulkan driver + Dawn library |

**Best for:** Natural language queries where vocabulary differs from tool descriptions. Interactive agents, chatbots, free-form user input.

---

## Performance Benchmarks

> Platform: Linux 6.17.0-14-generic
> GPU: NVIDIA GeForce RTX 4070, CUDA 12.8, driver 570.195.03
> Benchmarks: Criterion.rs

### Single Query Latency (100 tools)

| Approach | Latency | Relative to Tag |
|----------|---------|-----------------|
| Tag | 280 ns | 1x |
| Keyword | 1.7 us | 6x |
| Trie | 2.4 us | 9x |
| TF-IDF | 5.1 us | 18x |
| BM25 | 6.7 us | 24x |
| Embedding (BoW) | 55 us | 196x |
| Ensemble (RRF) | 63 us | 225x |
| E5 Neural (CPU) | 4.1 ms | 14,643x |
| MiniLM Neural (CPU) | 19 ms | 67,857x |
| E5 Neural (CUDA) | 1.56 ms | 5,571x |
| MiniLM Neural (CUDA) | 1.26 ms | 4,500x |
| E5 Neural (TensorRT) | 1.87 ms | 6,679x |
| MiniLM Neural (TensorRT) | 1.39 ms | 4,964x |

### CPU vs CUDA vs TensorRT: Single Embedding

| Model | CPU | CUDA | TensorRT | CUDA Speedup | TRT Speedup |
|-------|-----|------|----------|-------------|-------------|
| all-MiniLM-L6-v2 | 18.70 ms | 1.22 ms | 1.24 ms | **15.3x** | **15.1x** |
| e5-small-v2 | 4.13 ms | 1.63 ms | 1.47 ms | **2.5x** | **2.8x** |

### CPU vs CUDA vs TensorRT: Build Index

| Tools | CPU | CUDA | TensorRT |
|-------|-----|------|----------|
| 5 | 155 ms | 6.6 ms | 7.4 ms |
| 15 | 488 ms | 24.9 ms | 26.8 ms |
| 50 | 3.28 s | 133 ms | 202 ms |

### CPU vs CUDA vs TensorRT: Batch Embedding (5 texts)

| Device | Latency | Speedup |
|--------|---------|---------|
| CPU | 211 ms | -- |
| CUDA | 20.3 ms | **10.4x** |
| TensorRT | 15.1 ms | **13.9x** |

### Scaling (BM25 single query "weather forecast")

| Tools | Keyword | BM25 |
|-------|---------|------|
| 50 | 1.3 us | 9.0 us |
| 500 | 7.0 us | 89 us |
| 1,000 | 16.9 us | 81.7 us |
| 5,000 | 32.9 us | 340 us |

---

## Final Comparison Table

| Approach | Build Index | Search (CPU) | Search (CUDA) | Search (TRT) | Semantic | Best For |
|----------|------------|-------------|---------------|-------------|----------|----------|
| **Tag** | 145 us | **280 ns** | -- | -- | No | Categorical O(1) lookup |
| **Keyword** | 1.28 ms | 1.7 us | -- | -- | No | Fast exact-stem search |
| **Trie** | 2.88 ms | 2.4 us | -- | -- | No | Prefix + fuzzy / autocomplete |
| **TF-IDF** | 1.79 ms | 5.1 us | -- | -- | No | Relevance-weighted ranking |
| **BM25** | 1.27 ms | 6.7 us | -- | -- | No | General-purpose ranked search |
| **Embedding (BoW)** | 2.42 ms | 55 us | -- | -- | Partial | Vector similarity, no model |
| **Ensemble (RRF)** | 6.25 ms | 63 us | -- | -- | No | Max accuracy, multi-signal |
| **E5 Neural** | ~865 ms | 4.1 ms | 1.56 ms | 1.87 ms | Yes | Fast semantic on CPU |
| **MiniLM Neural** | ~488 ms | 19 ms | **1.26 ms** | **1.39 ms** | Yes | Semantic + GPU acceleration |

> All non-neural approaches are sub-millisecond for typical workloads (15-100 tools).
> CUDA and TensorRT bring neural search into the sub-1.5 ms range.
> Build index is a one-time cost; search latency is per-query.

---

## Analysis

### Three Performance Tiers

**Tier 1 -- Sub-microsecond (>10,000 queries/sec):**
Tag search at 280 ns dominates when tools have well-defined categories and queries use known tag names. Keyword search at 1.7 us is the next step up, adding stemming support. These approaches are suitable for real-time pipelines, autocomplete, and high-frequency dispatch.

**Tier 2 -- Microsecond range (1,000-100,000 queries/sec):**
BM25 (6.7 us) offers the best accuracy-to-speed ratio for text-based queries. Ensemble (63 us) provides maximum accuracy by combining all signals. For most agent workloads with fewer than 500 tools, any approach in this tier is fast enough that tool selection is not a bottleneck.

**Tier 3 -- Millisecond range (700-800 queries/sec on GPU):**
Neural models deliver true semantic understanding. On CPU, E5 runs at 4.1 ms and MiniLM at 19 ms. With CUDA or TensorRT, MiniLM drops to 1.2-1.4 ms -- fast enough for real-time interactive agents. The build-index step is expensive (hundreds of milliseconds on CPU, tens of milliseconds on GPU) but is a one-time cost.

### GPU Acceleration: CUDA vs TensorRT

Both NVIDIA execution providers deliver 15-18x speedup over CPU for MiniLM:

- **Single query latency**: Nearly identical (CUDA 1.22 ms, TensorRT 1.24 ms)
- **Batch operations**: TensorRT edges ahead (13.9x vs 10.4x speedup over CPU)
- **Build index**: CUDA is faster for large tool sets (133 ms vs 202 ms at 50 tools) due to TensorRT engine compilation overhead
- **Practical difference**: Negligible for real-time single-query workloads; TensorRT has an advantage in batch/throughput scenarios

E5-small-v2 benefits less from GPU acceleration (2-3x) because it is already fast on CPU (4.1 ms). For GPU workloads, MiniLM + CUDA (1.22 ms) outperforms E5 + CPU (4.1 ms).

### BM25 vs Neural: When to Cross the Boundary

BM25 operates at 6.7 us and correctly identifies the right tool in all 49 single-tool disambiguation tests. It fails only when the query uses entirely different vocabulary from the tool description (e.g., "What is the temperature outside?" for a tool named "get_weather" with description "Get weather forecast").

Neural models solve this specific problem at 600-2800x the latency cost. The decision boundary is:

- **BM25 sufficient**: Query terms overlap with tool descriptions (programmatic dispatch, keyword-driven UI, API routing)
- **Neural required**: Queries are free-form natural language with unpredictable vocabulary (chatbots, voice assistants, general-purpose agents)

### Ensemble as a Middle Ground

Ensemble (RRF) at 63 us combines BM25, TF-IDF, Keyword, Tag, Trie, and Embedding signals. It handles ambiguous multi-intent queries better than any single approach and runs 65x faster than E5 Neural on CPU. For applications where natural language understanding is desirable but GPU hardware is unavailable, Ensemble is the recommended approach.

### Scaling Characteristics

All approaches scale linearly with the number of registered tools:

- **Tag**: O(1) per tag lookup, scales to tens of thousands of tools with no measurable degradation
- **BM25**: 6.7 us at 100 tools, 340 us at 5,000 tools -- still sub-millisecond
- **Neural build index**: Proportional to tool count (6.6 ms/tool on CUDA, 66 ms/tool on CPU for MiniLM). Build once, search at constant cost
- **Neural search**: Constant after build (dominated by query embedding, not tool count)

---

## Conclusion

`evo_ai_tool_migra` provides Evo AI agents with deterministic, offline, cost-free tool selection across 8 approaches spanning 5 orders of magnitude in latency (280 ns to 19 ms on CPU).

**Key findings:**

- **BM25 is the default recommendation** for most agent workloads. It runs at 6.7 us, requires zero configuration, and handles all structured and semi-structured queries correctly
- **Ensemble (RRF) maximises accuracy** for ambiguous inputs at 63 us -- negligible overhead for the accuracy gain
- **Neural models (E5/MiniLM) are necessary** only when queries use vocabulary unrelated to tool descriptions. With GPU, neural search drops to 1.2 ms, making it viable for real-time agents
- **CUDA and TensorRT perform nearly identically** for single queries (~1.2 ms). TensorRT has a slight edge on batch throughput
- **No LLM round-trip is needed** for tool selection. The 200-2000 ms and token cost of an LLM call is replaced by a 280 ns to 1.2 ms local computation

Within the EATS pipeline, `evo_ai_tool_migra` sits between query parsing and tool invocation. The agent receives a tokenised query, selects the top-k tools via in-memory search, and proceeds directly to execution -- eliminating the most expensive step in the traditional LLM-based tool calling chain.

\pagebreak
