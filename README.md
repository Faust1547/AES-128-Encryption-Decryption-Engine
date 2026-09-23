# AES-128 Encryption & Decryption Engine 

## Overview
本專案以 AES-128 對稱式加密演算法為基礎，使用 Verilog 實現 Encryption、Decryption、Key Expansion 與 Galois Field Arithmetic 等核心模組，並完成 RTL 功能驗證。後續進一步採用 TSMC 90 nm 與 N16 ADFP 製程進行實體設計。

## Algorithm

<img width="450" height="500" alt="image" src="https://github.com/user-attachments/assets/7971aa40-9af7-4970-a45d-de43cb052daa" />

## Results
1. RTL Post-sim 執行結果。
2. TSMC 90nm 1P9M 實體設計之時序、面積、功耗紀錄，以及晶片實現結果與 Partition 表示。
3. TSMC 16nm ADFP 實體設計之時序、面積、功耗紀錄，以及數位 IP 實現結果。
