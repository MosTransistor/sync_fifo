# sync_fifo
[Verilog] different types of sync_fifo, using different data storage methods

# 概述/Overview
常见的同步FIFO设计，不同的存储数据方式
1. 使用Register存储数据
2. 使用RAM存储数据
    * 2.1 使用单口RAM
    * 2.2 使用伪双口RAM
    * 2.3 数据加上ECC保护，解决时序风险
>The common synchronous FIFO design, different ways of storing data
>1. use register to storage data
>2. use RAM to storage data
>   * 2.1 use single port RAM
>   * 2.2 use two port RAM (one port for reading, another one for writing)
>   * 2.3 data with ECC protection, No timing risk
