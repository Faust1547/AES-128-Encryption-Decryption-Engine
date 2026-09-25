## Hierarchy
``` text
Results
├── README.md
├── Post-sim Result
│   └── Post-sim Result.png
├── VLSI Implement (TSMC 90 nm 1P9M)
│   ├── Area
│   ├── Chip
│   ├── LVS
│   ├── Power
│   └── Timing
└── VLSI Implement (TSMC 16 nm ADFP)
    ├── Area
    ├── Chip
    ├── LVS
    ├── Power
    └── Timing
```
## RTL Simulation
透過 Testbench 驗證 AES-128 加密與解密功能，比對預期結果與實際輸出，並展示六組測試案例之 Post-simulation 通過結果。

## Physical Implementation
| Specification | TSMC 90 nm 1P9M | TSMC N16 ADFP |
|---|---|---|
| Frequency | 200 MHz | 1.25 GHz |
| Timing Closure | Setup / Hold Met | Setup / Hold Met|
| Dynamic Power | 17.7559 mW | 10.6 mW |
| Cell Leakage Power | 461.4556 μW | 0.582 μW | 
| Core Area | 557,343.647 μm² | 10,777.54 μm² |
| Chip Area | 1,044,749.730 μm² | 21,025.00 μm² |
| LVS | Correct | Correct |
