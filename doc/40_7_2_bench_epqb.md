## EPQB Benchmark Results 

### Case 1: Certificate Retrieval and Direct Communication

> PeerA and PeerB 
> Entity size represents the payload data before encryption.


### Individual Operations

| #  | Operation                     | Time (µs)   | Time (s)    |
|----|-------------------------------|-------------|-------------|
| 1  | do_create_peer                | 426.3387    | 0.000426339 |
| 2  | do_api_set (register request) | 492.2097    | 0.000492210 |
| 3  | on_api_mp (process set)       | 795.1173    | 0.000795117 |
| 4  | do_api_get (get request)      | 112.5772    | 0.000112577 |
| 5  | on_api_mp (process get)       | 63.5809     | 0.000063581 |
| 6  | on_api_get (parse response)   | 201.7569    | 0.000201757 |
| 7  | do_api (first request)        | 2.6060      | 0.000002606 |
| 8  | on_api (receive event)        | 0.2006      | 0.000000201 |
| 9  | do_api (response)             | 2.5659      | 0.000002566 |
| 10 | on_api (receive response)     | 0.1931      | 0.000000193 |
| 11 | do_api (subsequent request)   | 2.3554      | 0.000002355 |

### Full Steps (Request/Response Sizes)

| #  | Step                         | Time (µs)   | Request (bytes)   | Response (bytes)   | Entity (bytes)   |
|----|------------------------------|-------------|-------------------|--------------------|------------------|
| 12 | Step1: Alice register to MP  | 1285.1092   | 12561             | 3694               | -                |
| 13 | Step2: Bob register to MP    | 1616.5379   | 12561             | 3694               | -                |
| 14 | Step3: Bob get Alice cert    | 178.7860    | 3731              | 9478               | -                |
| 15 | Step4: Bob->Alice first msg  | 7.1777      | 531               | 531                | 80               |
| 16 | Step5: Bob->Alice subsequent | 6.6718      | 531               | 531                | 80               |

### Size Summary

| Step      | Description                   | Request (bytes)   | Response (bytes)   |
|-----------|-------------------------------|-------------------|--------------------|
| 1         | Alice register to MasterPeer  | 12561             | 3694               |
| 2         | Bob register to MasterPeer    | 12561             | 3694               |
| 3         | Bob get Alice certificate     | 3731              | 9478               |
| 4         | Bob->Alice first (with Kyber) | 531               | 531                |
| 5         | Bob->Alice subsequent         | 531               | 531                |
| **Total** | **Full handshake**            | **29915**         | **17928**          |


\pagebreak
