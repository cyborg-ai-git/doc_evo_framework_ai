# Reinforcement Learning for Language Models: A Recap of Key Methods

Reinforcement Learning from Human Feedback (RLHF) and related techniques are crucial for aligning large language models (LLMs) with human preferences and improving their performance on specific tasks, especially complex reasoning. This document provides an overview of a standard approach (No RL, or supervised fine-tuning), the widely used Proximal Policy Optimization (PPO), and the more recent, memory-efficient Group Relative Policy Optimization (GRPO).

## Proximal Policy Optimization (PPO)

PPO is currently the de facto standard for applying reinforcement learning to LLMs. It operates on an actor-critic principle:

* **Actor (Policy Model)**: The main language model that generates responses.
* **Critic (Value Model)**: A separate model trained to predict the "value" or expected future reward of a given state or token sequence.

PPO calculates an advantage score for actions based on the critic's output. It uses a special clipping mechanism to ensure the model's updates remain stable and do not stray too far from the previous version of the model.

## Group Relative Policy Optimization (GRPO)

GRPO is an efficient alternative designed specifically to address the memory constraints of training large models. Its primary innovation is the elimination of the separate critic model.

* Instead of a value network, GRPO generates a "group" of possible responses for each prompt.
* The average reward of this group serves as the baseline for comparison.
* Responses with scores above the average receive a positive update, while those below receive a negative update.

This simple yet effective approach saves significant GPU memory and has proven highly effective for sparse-reward tasks like math problem-solving.

## Comparison Table: No RL vs. GRPO vs. PPO

| Feature | No RL (Supervised Fine-Tuning) | PPO (Proximal Policy Optimization) | GRPO (Group Relative Policy Optimization) |
|---------|--------------------------------|-------------------------------------|-------------------------------------------|
| **RL Application** | No | Yes (Actor-Critic) | Yes (Policy Optimization) |
| **Reward Mechanism** | Implicitly via data quality | Explicit reward model & value network | Explicit reward model & group average |
| **Critic/Value Network** | Not applicable | Required (separate model) | Not required (memory efficient) |
| **Memory Cost** | Lowest | Highest (requires two models) | Moderate (only one model) |
| **Primary Use Case** | Baseline model alignment & general capability | Standard RLHF for alignment & diverse tasks | Efficient RL for complex, sparse-reward tasks |
| **Advantage Estimation** | N/A | Based on critic's learned value | Based on empirical group average |