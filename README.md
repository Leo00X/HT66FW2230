# 无线充电发射器固件

这是一个基于合泰 (Holtek) HT66FW2230 微控制器的无线充电发射器（Tx）固件项目。它实现了 Qi 无线充电标准的核心功能，包括设备检测、通信、功率控制和异物检测 (FOD)。

## 项目结构

该项目包含以下主要文件：

* `LibWPTX2230v302.asm`: 主程序文件，包含初始化例程、中断服务程序 (ISR) 和主要的 Qi 状态机（选择、Ping、配置、功率传输）。
* `TxUserDEF2230v302.inc`: 配置文件，用于定义系统的所有关键参数和阈值，如电压限制、电流限制、定时器周期和 PID 增益。
* `TxUserVAR2230v302.asm`: 全局变量定义文件，用于在 RAM 中分配所有标志位和数据缓冲区。
* `PID.asm`: 实现 PID（比例-积分-微分）控制算法，用于根据接收器（Rx）的反馈动态调整输出功率。
* `Detection.asm`: 包含用于检测物体放置（`ObjectDetection`）和物体移除（`ObjectDetectLeave`）以及输入电压（`DetectVin`）的子程序。
* `Isen.asm`: 包含用于测量主线圈电流的函数，包括对 ADC 读数进行平均（`PID_Isen65AvgTwo`）和检查过流/欠流状态（`PID_SenPriCoilCurrWay65`）。
* `ReciPackageDataUnit.asm`: 负责处理来自接收器的低级通信。它包括检测前导码（`ReciPackageDataUnitPreee1`）和解码完整的 ASK 编码数据包（`ReciPackageDataUnit`）。
* `PackageData.asm`: 包含 `ExtractPacData` 函数，该函数在接收到完整的数据包后，会验证其校验和，并将数据解析到相应的变量中（如 `a_DataHeader`, `a_DataMessageB0` 等）。
* `Decode.asm`: 负责解析已验证的数据包。根据包头（Header），它会调用特定的函数来处理控制错误（0x03）、接收功率（0x04）、结束充电（0x02）等命令。
* `Math.asm`: 提供项目所需的数学运算库，包括8位、16位和24位的有符号加、减、乘、除法。
* `DemoFun.asm`: 管理用于接收 Qi 通信信号的解调器硬件和中断。
* `Other.asm`: 包含各种工具函数，如 `ADCData`（执行单次 ADC 转换）、`Sensoring10_8`（获取10次 ADC 采样并取平均值）和 `DemoCLR`（清除接收缓冲区）。

## 功能特性

* **Qi 协议兼容**：实现了选择、Ping、配置和功率传输阶段的状态机。
* **闭环功率控制**：使用 PID 算法根据接收器的控制错误（CE）包动态调整输出功率（通过调整 PLL 频率）。
* **异物检测 (FOD)**：在功率传输期间监控接收功率、线圈电流和温度，以检测潜在的异物（基于 `Decode.asm` 和 `Isen.asm` 中的逻辑）。
* **安全保护**：
    * **过流保护 (OCP)**：使用硬件中断（`ISR_OCP`）在检测到过流时立即停止 PWM。
    * **输入电压检测 (Vin)**：在启动和运行期间持续监控输入电压（`DetectVin`）。
* **通信**：通过 ASK（幅移键控）解调来自接收器的数据包（`ReciPackageDataUnit.asm`）。

## 如何编译

本项目旨在使用 Holtek 的 HT-IDE3000 (V8.x) 开发环境进行编译和链接。

1.  打开 `LibWPTX2230v302.pjt` 项目文件。
2.  确保 `TxUserDEF2230v302.inc` 文件已根据您的特定硬件（线圈、MOSFETs、分压电阻等）进行了正确配置。
3.  确保 `V302_20150112.lib` 库文件已正确链接。
4.  执行 "Build" 或 "Rebuild" 操作以生成可执行文件。

## 硬件配置

固件配置用于 **HT66FW2230** 微控制器。关键的引脚分配（在 `LibWPTX2230v302.asm` 中定义）包括：

* **AN3 (PA3)**: 用于输入电压 (Vin) 检测。
* **AN9 (OCP 引脚)**: 用于电流感应 (Isen)。
* **PWM00 / PWM01 / PWM02 / PWM03**: 用于驱动 H 桥以激励主线圈。
* **DEMO (PB5)** / **INT1 (PB4)**: 用于从接收器接收 ASK 信号（具体取决于 `DemoFun.asm` 中的配置）。
* **PB2 / PB3**: 用于状态指示的 LED（例如，绿色/红色）。
