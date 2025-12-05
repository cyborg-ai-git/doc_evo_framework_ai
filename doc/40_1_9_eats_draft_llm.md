> Draft
> 
# LLM-ID
## Why Your API IDs Keep Getting Corrupted by Language Models

## The Problem

You've designed a perfect API with unique identifiers, written clear instructions for an LLM to generate API calls, but the output keeps getting corrupted:

```lisp
;; What you expected:
(16349718221886614 ("AI makes learning fun for kids!" "AI" "public"))

;; What the LLM gave you:
(16341886614 ("AI learning fun for kids content" "AI" "public"))
          ^ Missing the first character!

```

**This document explains why this happens and how to fix it.**

---

## Why LLMs Struggle With IDs

### 1. LLMs Are Probabilistic Text Predictors, Not Databases

Large Language Models work by:
- Predicting the next most likely token
- Using patterns learned from training data
- Approximating outputs based on probability distributions

They are **NOT**:
- ❌ Copy-paste machines
- ❌ Perfect memorizers
- ❌ Databases with exact recall

### 2. Tokenization Breaks Up IDs Unpredictably

```
Your ID: "Cw5RIF6jiba"

Claude (advanced tokenizer):
Tokens: ["Cw5", "RIF", "6j", "iba"]
→ 4 tokens to track ✅

Smaller model (basic tokenizer):
Tokens: ["C", "w", "5", "R", "I", "F", "6", "j", "i", "b", "a"]
→ 11 tokens to track ❌
```

**More tokens = more opportunities for errors!**

### 3. Long Numbers Have No Semantic Meaning

```
Semantic (LLM-friendly):
"CREATE_LINKEDIN_POST" → recognizable words
"API_12345" → clear pattern with prefix

Non-semantic (LLM-hostile):
"16349718268121886614" → random noise to the model
"Cw5RIF6jiba" → slightly better (base64 pattern)
```

LLMs are trained on natural language. Numbers and random strings are the **hardest** content for them to reproduce accurately.

### 4. Attention Mechanism Limitations

When generating output, weaker models may:
- ❌ Lose track of exact strings from earlier in context
- ❌ Regenerate IDs from "memory" (unreliable)
- ❌ Drop or change characters at token boundaries

Stronger models (GPT-4, Claude) are better at this, but still imperfect.

### 5. Ambiguous Characters

These characters look similar and get confused:
- `O` (letter) vs `0` (zero)
- `I` (letter) vs `l` (lowercase L) vs `1` (one)
- `C` vs `c` (case sensitivity)

---

## Troubleshooting

### Problem: First Character Dropped

```lisp
Expected: Cw5RIF6jiba
Got:      w5RIF6jiba
```

**Solutions:**
1. Add prefix: `API_Cw5RIF6jiba`
2. Use angle brackets: `<Cw5RIF6jiba>`
3. Switch to descriptive names: `CREATE_LI_POST`

---

### Problem: Digits Changed in Long Numbers

```lisp
Expected: 16349718268121886614
Got:      16349718221886614 (dropped digits)
```

**Solutions:**
1. **Best:** Use short numbers (1001, 1002) and map internally
2. Use hex (shorter): `0xE2F3A1B2C3D4E5F6`
3. Add hyphens: `1634-9718-2681-2188-6614`
4. **Avoid long numbers entirely!**

---

### Problem: LLM Adds Explanations

```lisp
Expected: (1001 ("AI content" "AI" "public"))
Got:      Here's the API call: (1001 ("AI content" "AI" "public"))
```

**Solutions:**
1. Strengthen instructions:
```lisp
;; CRITICAL: Output ONLY the S-expression
;; NO explanations, NO markdown, NO extra text
;; Just: (API_ID ("value1" ...))
```

2. Add negative examples:
```lisp
;; WRONG: "Here is the output: (1001 ...)"
;; RIGHT: (1001 ...)
```

---

### Problem: Wrong Parameter Order

```lisp
Expected: (1001 ("content" "hashtags" "public"))
Got:      (1001 ("hashtags" "content" "public"))
```

**Solutions:**
1. Make order explicit in examples:
```lisp
;; Entity (2001) has parameters in this order:
;; 1. content (STRING)
;; 2. hashtags (STRING)  
;; 3. visibility (STRING)
;;
;; Output: (1001 ("content_value" "hashtag_value" "visibility_value"))
;;                 ^1st parameter  ^2nd parameter  ^3rd parameter
```

---

## Model-Specific Considerations

### GPT-4 / Claude (Advanced Models)
- ✅ Can handle base64-like IDs with prefixes
- ✅ Good at following complex instructions
- ✅ Strong attention to examples
- ⚠️ Still benefits from simple formats

### GPT-3.5 / Smaller Models
- ⚠️ Use simple numbers or SNAKE_CASE only
- ⚠️ Keep instructions very short and clear
- ⚠️ Provide 3+ examples
- ⚠️ Expect some errors, build validation

### Local Models (*.gguf ...)
- ❌ Avoid anything except numbers or clear words
- ❌ Use prefix patterns religiously
- ❌ Always implement fuzzy matching
- ✅ Test thoroughly before production

---

## Quick Reference

| Your Constraint | Recommended Format | Example |
|----------------|-------------------|---------|
| Must use existing UUIDs | Prefixed + validation | `API_Cw5RIF6j` |
| Need human readability | SNAKE_CASE names | `CREATE_LI_POST` |
| Maximum reliability | Short numbers | `1001`, `1002` |
| Weak/local models | Numbers + prefix | `API_1001` |
| Legacy system compat | Hyphenated UUIDs | `96af-1eed-23de` |

---

## Summary

**The Golden Rules:**

1. **Simple is better than complex** - LLMs prefer recognizable patterns
2. **Short is better than long** - Fewer characters = fewer errors
3. **Semantic is better than random** - Words > Numbers > Random strings
4. **Boundaries help** - Prefixes, hyphens, brackets reduce errors
5. **Always validate** - Even best prompts need parser safety nets
6. **Design for weakest model** - If it works on Llama 7B, it'll work everywhere

**Priority Order:**
1. Short numbers (1001) with internal mapping
2. Descriptive names (CREATE_POST)
3. Prefixed IDs (API_Cw5R)
4. Hyphenated UUIDs (96af-1eed-23de)
5. Raw base64/UUIDs (avoid!)
6. Long numbers (never use!)

---

## Further Reading

- [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [OpenAI Best Practices](https://platform.openai.com/docs/guides/prompt-engineering)
- Levenshtein Distance for fuzzy matching
- Token counting tools for your specific model

---

*Document Version 1.0 - Last Updated: December 2024*