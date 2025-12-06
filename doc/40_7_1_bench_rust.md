# Evo Framework Benchmarks

## Time Units Reference Guide

### Quick Reference Table

| Unit        | Symbol  | Seconds        | Scientific Notation |
|-------------|---------|----------------|---------------------|
| Second      | s       | 1              | 10⁰ s               |
| Millisecond | ms      | 0.001          | 10⁻³ s              |
| Microsecond | μs (us) | 0.000001       | 10⁻⁶ s              |
| Nanosecond  | ns      | 0.000000001    | 10⁻⁹ s              |
| Picosecond  | ps      | 0.000000000001 | 10⁻¹² s             |

### Conversion Table

### From Seconds

| From  | To Milliseconds | To Microseconds | To Nanoseconds   | To Picoseconds       |
|-------|-----------------|-----------------|------------------|----------------------|
| 1 s   | 1,000 ms        | 1,000,000 μs    | 1,000,000,000 ns | 1,000,000,000,000 ps |

> Benchmark
> 
> (x86_64) linux ubuntu
> 
> rust cargo 1.93.0-nightly (9fa462fe3 2025-11-21)
> 
> **Note:** Measurements below ~1ns are subject to noise (CPU cache, branch prediction, 
> frequency scaling). Ratios < 1.0x or differences < 5% at sub-nanosecond scale are not 
> statistically significant and should be considered equivalent performance.


## evo_bench/bench_error

| #   | Test                       | Time (ns)  | vs sync_empty  |
|-----|----------------------------|------------|----------------|
| 1   | sync_empty                 | 0.3586     | 1.0000x        |
| 2   | UStruct::sync_empty        | 0.3586     | ~1.0000x       |
| 3   | sync_enum_error_code       | 0.3586     | ~1.0000x       |
| 4   | sync_enum_error_str_short  | 0.6053     | 1.6881x        |
| 5   | sync_enum_error_byte_short | 10.8178    | 30.1684x       |
| 6   | sync_enum_error_short      | 9.6042     | 26.7841x       |
| 7   | sync_enum_error_long       | 17.5196    | 48.8584x       |
| 8   | sync_e_error               | 92.3265    | 257.4780x      |
| 9   | sync_e_error_backtrace     | 139.1996   | 388.1967x      |
| 10  | anyhow_error               | 93.2758    | 260.1256x      |
| 11  | downcast_sync_error        | 2.5068     | 6.9908x        |
| 12  | backtrace_to_string        | 45.2856    | 126.2915x      |
| 13  | do_backtrace               | 103.9981   | 290.0277x      |
| 14  | async_empty                | 85.8516    | 239.4210x      |
| 15  | UStruct::async_empty       | 68.8505    | 192.0088x      |
| 16  | async_enum_error_code      | 61.7288    | 172.1479x      |
| 17  | async_enum_error_short     | 73.9644    | 206.2702x      |
| 18  | async_enum_error_long      | 87.0316    | 242.7119x      |
| 19  | async_e_error              | 139.5208   | 389.0926x      |
| 20  | async_e_error_backtrace    | 161.2403   | 449.6633x      |
| 21  | downcast_async_error       | 1.8797     | 5.2420x        |


> TODO: to migrate all tests in new standard
## evo_core_id



| Bench | Time |
|-------|------|
| **id_rand** | 33.013 ns **34.448 ns** 35.943 ns |
| **id_seq** | 14.865 ns **15.190 ns** 15.558 ns |
| **id_str_hash** | 104.56 ns **109.05 ns** 114.04 ns |
| **id_str** | 11.719 ns **12.004 ns** 12.341 ns |
| **id_hex** | 16.546 ns **16.718 ns** 16.916 ns |
| **id_u64** | 10.023 ns **10.509 ns** 11.070 ns |
| **id_to_hex** | 32.204 ns **32.435 ns** 32.687 ns |
| **id_to_short** | 39.644 ns **40.077 ns** 40.581 ns |
| **id_to_utf8** | 253.31 ns **261.43 ns** 270.75 ns |
| **id_to_vec** | 250.45 ns **255.06 ns** 260.99 ns |

## evo_bench/bench_async

| Bench | Time |
|-------|------|
| **create_sync_error** | 81.580 ns **82.570 ns** 83.569 ns |
| **create_async_error** | 246.00 ns **251.45 ns** 257.17 ns |
| **sync_ok** | 7.1418 ns **7.1632 ns** 7.1853 ns |
| **sync_e_error** | 103.88 ns **104.64 ns** 105.41 ns |
| **sync_no_error** | 384.77 ps **388.58 ps** 392.80 ps |
| **async_no_error** | 117.85 ns **119.23 ns** 120.68 ns |
| **async_anyhow** | 243.81 ns **249.08 ns** 254.56 ns |
| **async_e_error** | 230.85 ns **237.60 ns** 244.81 ns |
| **async_ok** | 111.91 ns **112.30 ns** 112.71 ns |
| **downcast_sync_error** | 1.9418 ns **1.9547 ns** 1.9684 ns |
| **downcast_async_error** | 1.9487 ns **1.9662 ns** 1.9847 ns |

## evo_bench/bench_bytes

| Bench | Time |
|-------|------|
| **read_only_slice** | 661.56 ps **665.60 ps** 669.73 ps |
| **read_only_cow** | 784.34 ps **798.39 ps** 813.31 ps |
| **read_only_vec** | 12.260 ns **12.515 ns** 12.756 ns |
| **conditional_cow** | 20.974 ns **21.436 ns** 21.896 ns |
| **conditional_vec** | 24.434 ns **26.353 ns** 28.245 ns |

## evo_bench/bench_downcast

| Bench | Time |
|-------|------|
| **try_downcast_helper** | 3.0173 ns **3.0689 ns** 3.1332 ns |
| **arc_downcast** | 16.069 ns **16.221 ns** 16.551 ns |

## evo_bench/bench_entity_string_bytes

| Bench | Time |
|-------|------|
| **EUserStr create** | 7.3835 ns **7.4413 ns** 7.5075 ns |
| **EUserString create** | 31.565 ns **31.966 ns** 32.366 ns |
| **EUserCow create** | 9.8721 ns **9.9215 ns** 9.9737 ns |
| **EUserCow create_owned** | 31.582 ns **31.854 ns** 32.127 ns |
| **EUserCowSG create** | 10.533 ns **10.705 ns** 10.898 ns |
| **EUserCowSG create_owned** | 31.810 ns **32.057 ns** 32.319 ns |
| **EUserStr get** | 384.92 ps **389.99 ps** 395.58 ps |
| **EUserString get** | 374.99 ps **377.98 ps** 381.31 ps |
| **EUserCow get** | 384.91 ps **391.90 ps** 399.81 ps |
| **EUserCowSG get** | 377.82 ps **382.89 ps** 388.24 ps |
| **EUserStr clone** | 1.2586 ns **1.3004 ns** 1.3527 ns |
| **EUserString clone** | 30.648 ns **31.053 ns** 31.480 ns |
| **EUserCow clone** | 3.0242 ns **3.3997 ns** 3.8431 ns |
| **EUserCowSG clone** | 2.6061 ns **2.6493 ns** 2.6970 ns |
| **EUserString set** | 52.809 ns **53.791 ns** 54.858 ns |
| **EUserCow set** | 54.016 ns **54.667 ns** 55.387 ns |
| **EUserCowSG set** | 66.395 ns **67.454 ns** 68.508 ns |
| **EUserString mixed** | 30.881 ns **32.943 ns** 35.006 ns |
| **EUserCow mixed** | 3.6448 ns **3.7613 ns** 3.8958 ns |
| **EUserCowSG mixed** | 3.4564 ns **3.5183 ns** 3.5848 ns |
| **pass_str** | 542.48 ps **548.50 ps** 555.96 ps |
| **pass_string** | 576.74 ps **585.34 ps** 593.72 ps |
| **pass_cow** | 1.3720 ns **1.4708 ns** 1.5710 ns |
| **pass_cowsg** | 1.5763 ns **1.7233 ns** 1.8827 ns |

## evo_bench/bench_enum

| Bench | Time |
|-------|------|
| **create_sync_error** | 202.92 ns **209.31 ns** 215.79 ns |
| **create_async_error** | 361.52 ns **368.69 ns** 376.11 ns |
| **sync_ok** | 10.643 ns **10.778 ns** 10.918 ns |
| **sync_e_error** | 167.01 ns **171.81 ns** 176.85 ns |
| **sync_no_error** | 586.44 ps **590.72 ps** 595.40 ps |
| **async_no_error** | 166.36 ns **168.27 ns** 170.23 ns |
| **async_anyhow** | 295.21 ns **297.75 ns** 300.39 ns |
| **async_e_error** | 285.35 ns **289.01 ns** 292.79 ns |
| **async_ok** | 206.10 ns **211.39 ns** 216.82 ns |
| **downcast_sync_error** | 3.4824 ns **3.5718 ns** 3.6671 ns |
| **downcast_async_error** | 4.9386 ns **5.0998 ns** 5.2638 ns |

## evo_bench/bench_fxmap

| Bench | Time |
|-------|------|
| **FxHashMap insert 1000000** | 1.3132 s **1.4174 s** 1.5277 s |
| **FxHashMap box insert 1000000** | 366.53 ms **388.92 ms** 416.48 ms |
| **FxHashMap arc insert 1000000** | 361.69 ms **374.42 ms** 388.78 ms |
| **FxHashMap get mut 1000000** | 76.198 ns **86.002 ns** 98.143 ns |
| **FxHashMap box get mut 1000000** | 135.33 ns **164.99 ns** 198.14 ns |
| **FxHashMap arc get mut 1000000** | 150.44 ns **180.85 ns** 221.06 ns |
| **FxHashMap get 1000000** | 65.603 ns **69.217 ns** 73.757 ns |
| **FxHashMap box get 1000000** | 72.072 ns **79.781 ns** 89.197 ns |
| **FxHashMap arc get 1000000** | 68.359 ns **73.798 ns** 80.552 ns |
| **FxHashMap iteration 1000000** | 3.8876 ms **4.0564 ms** 4.2473 ms |
| **FxHashMap box iteration 1000000** | 4.2626 ms **4.4152 ms** 4.5828 ms |
| **FxHashMap arc iteration 1000000** | 4.6148 ms **4.8108 ms** 5.0427 ms |

## evo_bench/bench_map

| Bench | Time |
|-------|------|
| **HashMap insert 1000000** | 253.03 ms **276.83 ms** 305.32 ms |
| **Papaya insert 1000000** | 429.07 ms **450.65 ms** 477.52 ms |
| **Dashmap insert 1000000** | 193.58 ms **202.20 ms** 212.59 ms |
| **FxHashMap insert 1000000** | 122.01 ms **124.65 ms** 127.53 ms |
| **BTreeMap insert 1000000** | 345.83 ms **351.88 ms** 358.71 ms |
| **HashMap get 1000000** | 119.33 ns **121.34 ns** 123.81 ns |
| **BTreeMap get 1000000** | 788.96 ns **867.29 ns** 960.48 ns |
| **FxHashMap get 1000000** | 105.75 ns **127.08 ns** 152.00 ns |
| **DashMap get 1000000** | 165.89 ns **178.02 ns** 193.55 ns |
| **HashMap iteration 1000000** | 3.2336 ms **3.2817 ms** 3.3333 ms |
| **BTreeMap iteration 1000000** | 5.2053 ms **5.3966 ms** 5.6375 ms |
| **FxHashMap iteration 1000000** | 4.1743 ms **4.3449 ms** 4.5548 ms |
| **DashMap iteration 1000000** | 33.693 ms **35.994 ms** 38.459 ms |

## evo_bench/bench_mutex

| Bench | Time |
|-------|------|
| **Mut operations 1000000** | 1.6005 ns **1.6522 ns** 1.7066 ns |
| **Box operations 1000000** | 1.7533 ns **1.8418 ns** 1.9386 ns |
| **Arc operations 1000000** | 51.036 ns **52.695 ns** 54.464 ns |
| **Atomic operations 1000000** | 17.148 ns **17.643 ns** 18.164 ns |
| **Tokio RwLock operations 1000000** | 142.95 ns **145.63 ns** 148.50 ns |
| **ParkingLot RwLock operations 1000000** | 45.545 ns **46.226 ns** 46.920 ns |
| **ParkingLot Mutex operations 1000000** | 52.924 ns **54.835 ns** 56.582 ns |
| **Std RwLock operations 1000000** | 57.107 ns **60.325 ns** 63.748 ns |

## evo_bench/bench_string

| Bench | Time |
|-------|------|
| **read_only_str** | 806.06 ps **827.72 ps** 851.32 ps |
| **read_only_cow** | 1.0592 ns **1.0963 ns** 1.1313 ns |
| **read_only_string** | 15.019 ns **15.755 ns** 16.421 ns |
| **conditional_cow** | 25.156 ns **25.867 ns** 26.683 ns |
| **conditional_string** | 30.651 ns **34.180 ns** 38.144 ns |

## evo_bench/bench_tokio

| Bench | Time |
|-------|------|
| **sync_to_async_within_runtime block_in_place** | 320.50 ns **326.83 ns** 333.39 ns |
| **sync_to_async_outside_runtime static_runtime** | 144.71 ns **145.99 ns** 147.30 ns |
| **sync_to_async_outside_runtime thread_local_runtime** | 152.91 ns **155.61 ns** 158.42 ns |
| **sync_to_async_outside_runtime new_current_thread_runtime** | 1.3621 µs **1.3833 µs** 1.4049 µs |
| **sync_to_async_outside_runtime new_multi_thread_runtime** | 1.5399 ms **1.5567 ms** 1.5740 ms |
| **async_approaches direct_await** | 144.05 ns **145.46 ns** 146.89 ns |
| **async_approaches tokio_spawn** | 14.405 µs **14.579 µs** 14.759 µs |
| **heavy_workload block_in_place_heavy** | 503.60 ns **510.77 ns** 518.31 ns |
| **heavy_workload async_direct_await_heavy** | 370.39 ns **374.98 ns** 379.75 ns |
| **heavy_workload async_spawn_heavy** | 20.069 µs **20.429 µs** 20.804 µs |
| **runtime_creation_overhead current_thread_creation** | 898.12 ns **910.32 ns** 922.32 ns |
| **runtime_creation_overhead multi_thread_creation** | 1.4821 ms **1.4947 ms** 1.5074 ms |
| **concurrent_tasks sequential_await** | 593.57 ns **607.79 ns** 623.02 ns |
| **concurrent_tasks concurrent_spawn** | 24.841 µs **25.566 µs** 26.302 µs |
| **concurrent_tasks join_all** | 281.07 ns **286.74 ns** 293.01 ns |
| **realistic_scenarios library_function_static_runtime** | 127.81 ns **128.44 ns** 129.11 ns |
| **realistic_scenarios nested_call_block_in_place** | 243.58 ns **246.67 ns** 249.93 ns |
| **realistic_scenarios background_task_spawn** | 12.291 µs **12.411 µs** 12.533 µs |

> TODO: to add bench ai, entity, memento...

\pagebreak