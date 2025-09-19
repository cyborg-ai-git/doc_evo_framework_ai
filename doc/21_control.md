# Evo Control Layer (IControl)

![evo control](data/evo_layer_control.svg)

The Control layer manages the application's core logic, handling message flow and inter-component communication. It supports multiple communication paradigms:

Supported Communication Modes:
- Asynchronous messaging
- Synchronous request-response
- Remote invocation with precise synchronization

> TODO:add uml diagrams...

#### Extended Control Components

Two critical extensions enhance the base Control layer:

**CApi: Ultrafast Peer Communication**
- Optimized for high-performance, low-latency communication
- Native serialization of entities
- Minimal overhead data transmission
- Support for streaming and real-time data exchange

**CAi: AI Model Integration**
- Unified interface for AI model management
- Support for multiple data types:
    - Text processing
    - Audio analysis
    - Video understanding
    - Image recognition
    - Generic file processing
- Optimized model loading and inference
- Hardware acceleration support

\pagebreak