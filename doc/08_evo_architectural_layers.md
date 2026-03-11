# Architectural Layers

![architectural layers](data/evo_framework.svg)

## Evo Framework AI — Design Pattern Reference

The Evo Framework AI defines the standard
### Layer Architecture

| Layer | Interface | Purpose | Pattern |
|-------|-----------|---------|---------|
| **Entity** | `IEntity` | Zero-copy data containers (Header + Body) | Flyweight, Prototype |
| **Control** | `IControl` | Business logic, message flow | Mediator, Command |
| **Api** | `IApi` | Secure interfaces, lifecycle | Singleton, Facade |
| **Ai** | `IAi` | LLM integration, privacy filtering | Strategy, Adapter |
| **Memory** | `IMemory` | Volatile + persistent storage | Memento, Repository |
| **Bridge** | `IBridge` | P2P Post Quantum bridge transport abstraction | Bridge, Observer |
| **GUI** | `IGui` | Platform-agnostic UI | Composite |
| **Utility** | `U*` | Mediator/facade helpers | Mediator, Facade |
| **Event** | `U*` | Event driven | Stategy, Observer |

### Naming Conventions (MANDATORY)

| Prefix | Meaning | 
|--------|---------|
| `E*` | Entity — data container | 
| `U*` | Utility — stateless helper | 
| `C*` | Control/Core — business logic | 
| `B*` | Bridge — transport impl |
| `M*` | Memory/Manager — state | 
| `Enum*` | Enumeration — type discriminator | 
| `I*` | Interface — trait | 
| `Type*` | Type alias |
| `Event*` | Event enum |


\pagebreak