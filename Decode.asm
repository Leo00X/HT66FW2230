;*******************************************************************************************
;*****	                               History	                                       *****
;*******************************************************************************************
;V1.0 - WPC Qi Certification Source Code by Edward in HOLTEK Semiconductor Inc. on 2014/12/25
; // 版本 V1.0 - HOLTEK Semiconductor Inc. 的 Edward 于 2014 年 12 月 25 日编写的 WPC Qi 认证源代码



;*******************************************************************************************
;*****	                           Including File	                               *****
;*******************************************************************************************
#INCLUDE 	HT66FW2230.inc				; // 包含 HT66FW2230 微控制器的寄存器定义文件
#INCLUDE	TxUserDEF2230v302.inc		; // 包含用户自定义的常量和宏定义



;*******************************************************************************************
;*****	                        Function / Parameter Claim	                       *****
;*******************************************************************************************
PUBLIC		PT_DecodeCommand			; // 声明公共函数：在功率传输阶段解码命令
PUBLIC		EndPowCMD0x02Decode			; // 声明公共函数：解码“结束充电” (0x02) 命令
PUBLIC		ConErrCMD0x03Decode			; // 声明公共函数：解码“控制错误” (0x03) 命令
PUBLIC		RecPowCMD0x04Decode			; // 声明公共函数：解码“接收功率” (0x04) 命令
PUBLIC		PowContlHoldCMD0x06Decode	; // 声明公共函数：解码“功率控制保持” (0x06) 命令
PUBLIC		ConfigCMD0x51Decode			; // 声明公共函数：解码“配置” (0x51) 命令

; // 声明外部函数（在其他文件中定义）
EXTERN		FOD_TempertureSensor62				:	near	; // 异物检测(FOD)相关的温度传感器读取函数
EXTERN		FOD_TempTime					:	near	; // FOD 相关的温度时间处理函数
EXTERN		PreCarry					:	near	; // 多字节运算前准备进位标志
EXTERN		PostCarry					:	near	; // 多字节运算后处理进位标志
EXTERN		FOD_ReceivePowCheck				:	near	; // FOD 相关的接收功率检查
EXTERN		FOD_SenPriCoilCurrWay65Double			:	near	; // FOD 相关的主线圈电流采样（两次采样）
EXTERN		FOD_FObjectDetect2				:	near	; // FOD 相关的异物检测函数2

; // 声明外部变量（在其他文件中定义）
EXTERN		a_DataHeader					:	byte	; // 存储接收到的数据包头
EXTERN		a_DataMessageB0					:	byte	; // 存储接收到的数据包的第一个消息字节
EXTERN		a_to7                                   	:	byte	; // 通用临时寄存器
EXTERN		a_temp1                                 	:	byte	; // 通用临时寄存器
EXTERN		fg_0x02PowDownChargeComplete    		:	bit		; // 标志位：因充电完成而结束充电
EXTERN		fg_0x02PowDownReconfigure       		:	bit		; // 标志位：因重新配置而结束充电
EXTERN		fg_0x02PowDownNoResponse        		:	bit		; // 标志位：因无响应而结束充电
EXTERN		fg_EndPowDown					:	bit		; // 标志位：结束充电
EXTERN		fg_CEinput					:	bit		; // 标志位：收到了控制错误(CE)包
EXTERN		fg_0x04ReceiPowCNTHflag				:	bit		; // 标志位：接收功率计数器的高位溢出标志
EXTERN		fg_PCH0x06Abnor					:	bit		; // 标志位：功率控制保持包(0x06)异常
EXTERN		fg_RPNoStable					:	bit		; // 标志位：接收功率(RP)不稳定
EXTERN		fg_VinLow					:	bit		; // 标志位：输入电压(Vin)过低
EXTERN		fg_FODEfficLow					:	bit		; // 标志位：FOD 效率过低
EXTERN		fg_ReCordTemp					:	bit		; // 标志位：记录温度
EXTERN		fg_CalTempTimeHigh				:	bit		; // 标志位：计算温度时间过长
EXTERN		fg_PowOver5wLEDsw				:	bit		; // 标志位：功率超过5W的LED切换标志
EXTERN          fg_RxTI						:	bit		; // 标志位：接收器是 TI (德州仪器) 设备
EXTERN		a_CSP0x05_B0					:	byte	; // 存储能力包(0x05)的数据
EXTERN		a_PCHO0x06_B0					:	byte	; // 存储功率控制保持包(0x06)的数据
EXTERN		a_Config0x51_B0					:	byte	; // 存储配置包(0x51)的字节0
EXTERN		a_0x03ContlErr			        	:	byte	; // 存储控制错误(0x03)的值
EXTERN		a_0x04ReceivedPow				:	byte	; // 存储接收功率(0x04)的值
EXTERN		a_0x06TdelayML			        	:	byte	; // 存储功率控制保持的延时(低位)
EXTERN		a_0x06TdelayMH					:	byte	; // 存储功率控制保持的延时(高位)
EXTERN		a_StatusEndPower				:	byte	; // 存储结束充电的状态码
EXTERN		a_0x51PowMax					:	byte	; // 存储配置包(0x51)中的最大功率
EXTERN		a_0x04ReceiPowCNTH				:	byte	; // 接收功率(0x04)包的超时计数器高位
EXTERN		a_0x04ReceiPowCNTL		        	:	byte	; // 接收功率(0x04)包的超时计数器低位
EXTERN		a_Carry						:	byte	; // 用于数学运算的进位/借位标志
EXTERN		a_r_RPowCNT					:	byte	; // 接收功率包的计数器 (用于FOD)
EXTERN		a_TempH						:	byte	; // 存储温度的高位字节
EXTERN		a_TempL						:	byte	; // 存储温度的低位字节


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
Decode		.Section 	'code'
;========================================================
;Function : PT_DecodeCommand
;Note     : Call Function Type for Decode Command 
;input 	  : (1) a_DataHeader
;	    (2) a_DataMessageB0
;output   : (1) fg_EndPowDown
;	    (2) a_CSP0x05_B0
;	    (3) fg_CEinput
;========================================================
	PT_DecodeCommand:	; // 功率传输阶段的命令解码
			SNZ	fg_VinLow					; // 检查输入电压是否过低 (Skip if Not Zero)
			JMP	PT_EPTP0x02					; // 如果电压正常 (fg_VinLow=0)，跳转到 PT_EPTP0x02
			
	PT_PowOver5wLEDstart:	; // 处理功率超过5W时的LED显示逻辑
			SNZ	fg_PowOver5wLEDsw			; // 检查LED切换标志
			JMP	PT_PowOver5wLEDoff			; // 如果标志为0，跳转去关闭LED
			;JMP	PT_PowOver5wLEDon
	PT_PowOver5wLEDon:
			SET	PB.3					;;Red LED	; // 打开红色LED
			CLR	fg_PowOver5wLEDsw			; // 清除切换标志 (下次会关闭)
			JMP	PT_EPTP0x02					; // 跳转到结束充电包检查
	PT_PowOver5wLEDoff:	
			CLR	PB.3					;;Red LED	; // 关闭红色LED
			SET	fg_PowOver5wLEDsw			; // 设置切换标志 (下次会打开)
			;JMP	PT_EPTP0x02
	PT_EPTP0x02:
			SNZ	fg_VinLow					; // 再次检查Vin是否过低
			SET	PB.3					;;Red LED	; // 如果电压过低 (fg_VinLow=1)，强制点亮红色LED (表示错误)

			MOV	A, a_DataHeader				; // 加载接收到的包头
			XOR	A, 002H						; // 检查是否为 "End Power Transfer" (0x02) 包
			SNZ	STATUS.2					; // 检查零标志位 (如果不为0，说明不是0x02包)
			JMP	PT_CEP0x03					; // 不是0x02包，跳转到检查0x03包

			CALL	EndPowCMD0x02Decode		; // 是0x02包，调用 0x02 包的处理函数
			CLR	fg_CEinput					; // 清除控制错误标志
			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_CEP0x03:
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 003H						; // 检查是否为 "Control Error" (0x03) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_RPP0x04					; // 不是0x03包，跳转到检查0x04包
		
			CALL	ConErrCMD0x03Decode		; // 是0x03包，调用 0x03 包的处理函数 (保存控制错误值)
			SET	fg_CEinput					; // 设置标志，表示收到了一个CE包 (PID控制会用到)
			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_RPP0x04:
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 004H						; // 检查是否为 "Received Power" (0x04) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_CSP0x05					; // 不是0x04包，跳转到检查0x05包
		
			CLR	fg_CEinput					; // 是0x04包，清除CE标志 (因为收到了RP包，说明通信正常)
			CALL	RecPowCMD0x04Decode		; // 调用 0x04 包的处理函数 (保存接收功率值，并重置超时计数器)
			;;;~~~ FOD Temp Alarm function~~~
			CALL	FOD_TempertureSensor62			;; d50mV=62H, d100mV=C4H, d150mV=127H ; // 调用FOD温度检测
			SZ	fg_ReCordTemp				; // 检查是否需要记录温度
			JMP	PT_RPP0x04_CalTemp			; // 如果 fg_ReCordTemp=0，跳转
			
			CALL	FOD_TempTime				; // 否则 (fg_ReCordTemp=1)，调用FOD温度时间处理
	PT_RPP0x04_CalTemp:
			SDZ	a_r_RPowCNT				; // 递减FOD相关的RP包计数器，若减到0则跳过
			JMP	PT_RPP0x04_NoFOD			; // 如果计数器不为0，跳转到NoFOD (跳过温度比较)
			
			MOV	A, 008H						; // 计数器到0了，重置为8
			MOV	a_r_RPowCNT, A
			CALL	PreCarry					; // 准备减法 (清a_Carry)
			MOV	A, a_to7					; // a_to7/a_temp1 是 Sensoring10_8 的结果 (当前温度)
			SUB	A, a_TempL					; // 减去上次记录的温度 (a_TempL, a_TempH)
			MOV	A, a_temp1
			SBC	A, a_TempH	
			CALL	PostCarry				; // 获取借位 (a_Carry=1 表示 当前温度 < 记录温度)
			SZ	a_Carry						; // 检查 a_Carry 是否为0 (即 当前温度 >= 记录温度)
			JMP	PT_RPP0x04a				; < // a_Carry=1 (当前 < 记录)，跳转

			SET	fg_CalTempTimeHigh			; >= // a_Carry=0 (当前 >= 记录)，设置温度升高标志
	PT_RPP0x04a:
			CALL	FOD_TempTime				; // 调用FOD温度时间处理
			SZ	a_0x04ReceivedPow			; // 检查接收到的功率值是否为0
			JMP	PT_RPP0x04_FOD				; // 不为0，跳转去做FOD检查

			JMP	PT_RPP0x04_NoFOD			; // 为0，跳过FOD检查
	PT_RPP0x04_FOD:
			CALL	FOD_ReceivePowCheck		; // 检查接收功率的稳定性
			SZ	fg_RPNoStable				; // 检查不稳定标志 (1=不稳定)
			JMP	PT_RPP0x04_NoFOD			; // 如果不稳定，跳过FOD
			
			CALL	FOD_SenPriCoilCurrWay65Double ; // 采样线圈电流 (用于FOD计算)
			SZ	fg_FODEfficLow				; // 检查FOD效率是否过低
			JMP	PT_RPP0x04_NoFOD			; // 如果效率低 (FOD)，跳过下面的检测 (可能已在FOD_SenPriCoilCurrWay65Double中处理)

			CALL	FOD_FObjectDetect2			; // 执行FOD检测算法2
	PT_RPP0x04_NoFOD:
			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_CSP0x05:
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 005H						; // 检查是否为私有包 "Proprietary" (0x05)
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_Unknown					; // 不是0x05包，跳转到未知包处理
			
			MOV	A, a_DataMessageB0			; // 是0x05包
			MOV	a_CSP0x05_B0, A				; // 保存消息字节0到 a_CSP0x05_B0
			CLR	fg_CEinput					; // 清除CE标志
			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_Unknown:
			CLR	fg_CEinput					; // 清除CE标志
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 001H						; // 检查是否为 "Signal Strength" (0x01) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_Unknown1					; // 不是0x01包，跳转到下一个检查
			
			SNZ	fg_RxTI					; // 是0x01包。检查是否是TI设备
			SET	fg_EndPowDown				; // 如果是TI设备，则设置结束充电标志 (0x01包在功率传输阶段是异常的)

			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_Unknown1:
			CLR	fg_CEinput					; // 清除CE标志
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 006H						; // 检查是否为 "Power Control Hold-off" (0x06) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_Unknown2					; // 不是0x06包，跳转到下一个检查
			
			SNZ	fg_RxTI					; // 是0x06包。检查是否是TI设备
			SET	fg_EndPowDown				; // 如果是TI设备，设置结束充电标志 (0x06包在功率传输阶段是异常的)

			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_Unknown2:
			CLR	fg_CEinput					; // 清除CE标志
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 051H						; // 检查是否为 "Configuration" (0x51) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_Unknown3					; // 不是0x51包，跳转到下一个检查

			SNZ	fg_RxTI					; // 是0x51包。检查是否是TI设备
			SET	fg_EndPowDown				; // 如果是TI设备，设置结束充电标志 (0x51包在功率传输阶段是异常的)

			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_Unknown3:
			CLR	fg_CEinput					; // 清除CE标志
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 071H						; // 检查是否为 "Identification" (0x71) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_Unknown4					; // 不是0x71包，跳转到下一个检查

			SNZ	fg_RxTI					; // 是0x71包。检查是否是TI设备
			SET	fg_EndPowDown				; // 如果是TI设备，设置结束充电标志 (0x71包在功率传输阶段是异常的)

			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_Unknown4:
			CLR	fg_CEinput					; // 清除CE标志
			MOV	A, a_DataHeader				; // 加载包头
			XOR	A, 081H						; // 检查是否为 "Extended Identification" (0x81) 包
			SNZ	STATUS.2					; // 检查零标志位
			JMP	PT_UnknownOther				; // 不是0x81包，跳转到未知包处理

			SNZ	fg_RxTI					; // 是0x81包。检查是否是TI设备
			SET	fg_EndPowDown				; // 如果是TI设备，设置结束充电标志 (0x81包在功率传输阶段是异常的)

			JMP	PT_DeComEnd					; // 跳转到解码结束
	PT_UnknownOther:
			CLR	fg_CEinput					; // 其他未知包头，清除CE标志
	PT_DeComEnd:
			CLR 	WDT						; // 清狗
			RET								; // 返回


;========================================================
;Function : EndPowCMD0x02Decode
;Note     : Call Function Type for Data-Decode of End Power(0x02)
;input    : a_DataMessageB0(a_EPTP0x02_B0)
;output   : 
;	  : fg_0x02PowDownChargeComplete [1= true]
;	  : fg_0x02PowDownReconfigure [1= true]
;	  : fg_0x02PowDownNoResponse [1= true]
;========================================================
	EndPowCMD0x02Decode:
			CLR 	WDT						; // 清狗
			SZ	a_DataMessageB0				; // 检查消息字节 (结束原因) 是否为 0
			JMP	EndPowerUnit01				; // 不为0，跳转

			SET	fg_EndPowDown				; // 为 0 (原因：Unknown)，设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit01:		
			MOV	A, a_DataMessageB0
			XOR	A, 001						; // 检查是否为 0x01 (Charge Complete)
			SNZ	STATUS.2
			JMP	EndPowerUnit02

			SET	fg_0x02PowDownChargeComplete	; // 是 0x01，设置充电完成标志
			SET	fg_EndPowDown				; // 设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit02:		
			MOV	A, a_DataMessageB0
			XOR	A, 002						; // 检查是否为 0x02 (Internal Fault)
			SNZ	STATUS.2
			JMP	EndPowerUnit03

			SET	fg_EndPowDown				; // 是 0x02，设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit03:		
			MOV	A, a_DataMessageB0
			XOR	A, 003						; // 检查是否为 0x03 (Over Temperature)
			SNZ	STATUS.2
			JMP	EndPowerUnit04

			SET	fg_EndPowDown				; // 是 0x03，设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit04:		
			MOV	A, a_DataMessageB0
			XOR	A, 004						; // 检查是否为 0x04 (Over Voltage)
			SNZ	STATUS.2
			JMP	EndPowerUnit05

			SET	fg_EndPowDown				; // 是 0x04，设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit05:		
			MOV	A, a_DataMessageB0
			XOR	A, 005						; // 检查是否为 0x05 (Over Current)
			SNZ	STATUS.2
			JMP	EndPowerUnit06

			SET	fg_EndPowDown				; // 是 0x05，设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit06:		
			MOV	A, a_DataMessageB0
			XOR	A, 006						; // 检查是否为 0x06 (Battery Failure)
			SNZ	STATUS.2
			JMP	EndPowerUnit07

			SET	fg_EndPowDown				; // 是 0x06，设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit07:		
			MOV	A, a_DataMessageB0
			XOR	A, 007						; // 检查是否为 0x07 (Reconfigure)
			SNZ	STATUS.2
			JMP	EndPowerUnit08

			SET	fg_0x02PowDownReconfigure	; // 是 0x07，设置重新配置标志
			JMP	EndPowerUnitEnd
	EndPowerUnit08:
			MOV	A, a_DataMessageB0
			XOR	A, 008						; // 检查是否为 0x08 (No Response)
			SNZ	STATUS.2
			JMP	EndPowerUnit09

			SET	fg_0x02PowDownNoResponse	; // 是 0x08，设置无响应标志
			SET	fg_EndPowDown				; // 设置结束充电标志
			JMP	EndPowerUnitEnd
	EndPowerUnit09:		
	EndPowerUnitEnd:
			SET	a_StatusEndPower			; // 设置一个总的结束电源状态
			RET

;========================================================
;Function : ConErrCMD0x03Decode
;Note     : Call Function Type for Data-Decode of -128~127 Control Error(0x03)
;input    : a_DataMessageB0
;output   : a_0x03ContlErr
;========================================================
	ConErrCMD0x03Decode:
			MOV	A, a_DataMessageB0			; // 获取消息字节 (控制错误值)
			MOV	a_0x03ContlErr, A			; // 存储到 a_0x03ContlErr 变量
	ConErrCMD0x03DecodeEnd:
			CLR 	WDT
			RET


;========================================================
;Function : RecPowCMD0x04Decode
;Note     : Call Function Type for Data-Decode of Received Power(0x04)
;input    : (1) a_DataMessageB0
;output   : (1) a_0x04ReceivedPow
;	  : a_0x04ReceiPowCNTL
;	  : a_0x04ReceiPowCNTH
; 	  : fg_0x04ReceiPowCNTHflag
;========================================================
	RecPowCMD0x04Decode:
			CLR 	WDT						; // 清狗
			MOV	A, a_DataMessageB0			; // 获取消息字节 (接收功率值)
			MOV	a_0x04ReceivedPow, A		; // 存储到 a_0x04ReceivedPow 变量
			MOV	A, c_IniReceiPowCNTL		; // 加载接收功率包超时定时器(STM0)的低位初始值
			MOV	a_0x04ReceiPowCNTL, A
			MOV	A, c_IniReceiPowCNTH		; // 加载高位初始值
			MOV	a_0x04ReceiPowCNTH, A
			SZ	a_0x04ReceiPowCNTH			; // 检查高位是否为0
			SET	fg_0x04ReceiPowCNTHflag	; // 如果不为0，设置高位标志

			RET


;========================================================
;Function : PowContlHoldCMD0x06Decode
;Note     : Call Function Type for Data-Decode of Power Control Hold-off(0x06)
;input    : a_PCHO0x06_B0
;output = : a_0x06TdelayML
;	  : a_0x06TdelayMH
;	  : fg_PCH0x06Abnor
;========================================================
	PowContlHoldCMD0x06Decode:
			CLR 	WDT						; // 清狗
			MOV	A, a_PCHO0x06_B0			; // 获取消息字节 (保持时间)
			SUB	A, 005H						; // 检查是否小于最小值 5ms
			SNZ	STATUS.0					; // 检查借位 (C=0表示A<5)
			JMP	PCHCMD0x06Abnormal			; // 小于5ms，跳转到异常
			
			MOV	A, a_PCHO0x06_B0			; // 再次获取消息字节
			SUB	A, 0CEH						; // 检查是否大于最大值 206ms (0xCE)
			SZ	STATUS.0					; // 检查借位 (C=1表示A>=CE)
			JMP	PCHCMD0x06Abnormal			; // 大于206ms，跳转到异常

	PowContlHoldCMD0x06Decode2:		
			;;; 5ms <= Tdelay <= 205ms
			;;; 014h=20, 50us x (20*5) = 5000us = 5.00ms, 50us x (20*205) = 205000us = 205ms
			;;;;013h=19, 50us x (19*5) = 4750us = 4.75ms, 50us x (19*205) = 194000us = 194ms
			; // Tdelay (ms) 乘以 20 (0x14) 得到 CTM (50us) 的计数值
			MOV	A, 014H						; // 加载 20 (0x14)
			ADD	A, a_0x06TdelayML			; // 累加到 Tdelay 低位
			MOV	a_0x06TdelayML, A
			MOV	A, 000H						; // 加载 0
			ADC	A, a_0x06TdelayMH			; // 累加到 Tdelay 高位 (带进位)
			MOV	a_0x06TdelayMH, A
	PowContlHoldCMD0x06Decode1:
			SDZ	a_PCHO0x06_B0			; // 将保持时间值减 1
			JMP	PowContlHoldCMD0x06Decode2	; // 循环累加，直到 a_PCHO0x06_B0 为 0

			RET								; // 返回
	PCHCMD0x06Abnormal:
			SET	fg_PCH0x06Abnor				; // 设置异常标志
			RET
;========================================================
;Function : ConfigCMD0x51Decode
;Note     : Call Function Type for Data-Decode of Configuration(0x51)
;input    : a_Config0x51_B0
;output   : a_0x51PowMax [Power max (w) when PowClass=0]
;========================================================
	ConfigCMD0x51Decode:
			;; --- Maximum Power ---
			MOV	A, 03FH						; // 掩码，取低6位
			AND	A, a_Config0x51_B0			; // a_Config0x51_B0 存储了消息字节0
			MOV	a_0x51PowMax, A				; // 存储最大功率值 (单位是 0.5W)
			;; a_0x51PowMax/2 = a_0x51PowMax/2^1 ; // 将单位从 0.5W 转换成 1W
			CLR	c
			RRC	a_0x51PowMax
	ConfigCMD0x51DecodeEnd:		 
			RET

END