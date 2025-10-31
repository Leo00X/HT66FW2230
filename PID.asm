;*******************************************************************************************
;*****	                               History	                                       *****
;*******************************************************************************************
;V1.0 - WPC Qi Certification Source Code by Edward in HOLTEK Semiconductor Inc. on 2014/12/25
; // 版本 V1.0 - HOLTEK Semiconductor Inc. 的 Edward 于 2014 年 12 月 25 日编写的 WPC Qi 认证源代码



;*******************************************************************************************
;*****	                           Including File	                               *****
;*******************************************************************************************
#INCLUDE 	HT66FW2230.inc ; // 包含 HT66FW2230 单片机的头文件，定义寄存器地址和位名称
#INCLUDE	TxUserDEF2230v302.inc ; // 包含用户自定义的常量和宏定义



;*******************************************************************************************
;*****	                        Function / Parameter Claim	                       *****
;*******************************************************************************************
PUBLIC			PT_PIDandPWM ; // 声明 PT_PIDandPWM 子程序为公共，用于功率传输阶段的 PID 计算和 PWM 控制
PUBLIC			ReSetPLL205 ; // 声明 ReSetPLL205 子程序为公共，用于将 PLL 频率重置到 205kHz
PUBLIC			DTdecPWinc ; // 声明 DTdecPWinc 子程序为公共，用于减少死区时间，增加 PWM 占空比 (频率可能变化)
PUBLIC			DTincPWdec ; // 声明 DTincPWdec 子程序为公共，用于增加死区时间，减少 PWM 占空比 (频率可能变化)
PUBLIC			PLLCompare ; // 声明 PLLCompare 子程序为公共，用于比较当前 PLL 频率和目标值

; // 声明外部函数（在其他文件中定义）
EXTERN			CLRMath					:	near ; // 清除数学运算相关变量
EXTERN			SignedSub_8Bit				:	near ; // 8位有符号减法
EXTERN			SignedAdd_16Bit				:	near ; // 16位有符号加法
EXTERN			SignedMul_16Bit				:	near ; // 16位有符号乘法
EXTERN			SignedSub_24Bit				:	near ; // 24位有符号减法
EXTERN			SignedAdd_24Bit				:	near ; // 24位有符号加法
EXTERN			SignedMul_24Bit				:	near ; // 24位有符号乘法
EXTERN			SignedDiv_24Bit				:	near ; // 24位有符号除法
EXTERN			PreCarry				:	near ; // 多字节运算前准备进位标志
EXTERN			PostCarry				:	near ; // 多字节运算后处理进位标志
EXTERN			PID_SenPriCoilCurrWay65Double		:	near ; // 两次采样主线圈电流 (可能是为了提高精度)
EXTERN			DetectVin				:	near ; // 检测输入电压
EXTERN			PT_SvParaSelect				:	near ; // 根据状态选择 PID 控制参数 Sv

; // 声明外部变量（在其他文件中定义）
EXTERN			a_ParPLLFH				:	byte ; // PLL 频率高位字节
EXTERN			a_ParPLLFL				:	byte ; // PLL 频率低位字节
EXTERN			a_StatusCntInt1				:	byte ; // 中断状态计数器 (可能用于 Kp 系数选择)
EXTERN			a_ADRHbuffer				:	byte ; // ADC 结果高位缓冲区
EXTERN			a_ADRLbuffer			        :	byte ; // ADC 结果低位缓冲区
EXTERN			a_data0					:	byte ; // 通用数据缓冲 0
EXTERN			a_data1				        :	byte ; // 通用数据缓冲 1
EXTERN			a_data2					:	byte ; // 通用数据缓冲 2
EXTERN			a_data4					:	byte ; // 通用数据缓冲 4
EXTERN			a_data5				        :	byte ; // 通用数据缓冲 5
EXTERN			a_data6					:	byte ; // 通用数据缓冲 6
EXTERN			a_to0					:	byte ; // 通用临时存储 0
EXTERN			a_to1				        :	byte ; // 通用临时存储 1
EXTERN			a_to2                                   :	byte ; // 通用临时存储 2
EXTERN			a_to3                                   :	byte ; // 通用临时存储 3
EXTERN			a_to4                           	:	byte ; // 通用临时存储 4
EXTERN			a_to5                           	:	byte ; // 通用临时存储 5
EXTERN			a_to6                           	:	byte ; // 通用临时存储 6
EXTERN			a_to7                                   :	byte ; // 通用临时存储 7
EXTERN			a_temp2                         	:	byte ; // 通用临时变量 temp2
EXTERN			a_temp1                                 :	byte ; // 通用临时变量 temp1
EXTERN			a_temp0                                 :	byte ; // 通用临时变量 temp0
EXTERN			fg_start				:	bit ; // PID 启动标志
EXTERN			fg_IterationStart			:	bit ; // PID 迭代开始标志
EXTERN			a_IL              	   		:	byte ; // PID 积分项低位
EXTERN			a_IM0                 		        :	byte ; // PID 积分项中位 0
EXTERN			a_IM1                 		        :	byte ; // PID 积分项中位 1
EXTERN			a_VL				        :	byte ; // PID 当前控制值低位
EXTERN			a_VM0				        :	byte ; // PID 当前控制值中位 0
EXTERN			a_VM1				        :	byte ; // PID 当前控制值中位 1
EXTERN			a_EL				        :	byte ; // PID 误差项低位
EXTERN			a_EM				        :	byte ; // PID 误差项中位
EXTERN			a_EH				        :	byte ; // PID 误差项高位
EXTERN			a_Sv				        :	byte ; // PID 控制参数 Sv (可能与比例或积分系数有关)
EXTERN			a_LoopIteration				:	byte ; // PID 内部循环迭代计数器
EXTERN		    	fg_RXCoilD				:	bit ; // D 型接收线圈标志
EXTERN		    	fg_IsenSmall				:	bit ; // 电流过小标志
EXTERN		    	fg_IsenBig				:	bit ; // 电流过大标志
EXTERN		    	fg_CEThr				:	bit ; // 控制错误阈值相关标志
EXTERN		    	fg_CEThrPana				:	bit ; // 针对松下设备的控制错误阈值标志
EXTERN			fg_VinLow				:	bit ; // 输入电压过低标志
EXTERN			fg_PLL205				:	bit ; // PLL 频率为 205kHz 标志
EXTERN			fg_DTCPR				:	bit ; // 占空比控制相关标志
EXTERN			fg_DTCPRmin			        :	bit ; // 达到最小占空比标志
EXTERN			fg_PLLThr				:	bit ; // PLL 频率阈值相关标志
EXTERN			a_PCHO0x06_B0				:	byte ; // 功率控制保持包 (0x06) 数据字节 0
EXTERN			a_ExIP0x81_B4                   	:	byte ; // 扩展身份包 (0x81) 数据字节 4
EXTERN			a_ExIP0x81_B5                   	:	byte ; // ... 字节 5
EXTERN			a_ExIP0x81_B6                   	:	byte ; // ... 字节 6 (可能存储上一次电流采样值低位)
EXTERN			a_ExIP0x81_B7                           :	byte ; // ... 字节 7 (可能存储上一次电流采样值高位)
EXTERN			a_0x03ContlErr			        :	byte ; // 控制错误包 (0x03) 数据
EXTERN			a_StatusEndPower			:	byte ; // 结束充电状态 / PID 目标值中间字节
EXTERN			a_OptConfiCNT			        :	byte ; // 可选配置计数 / PID 目标值低字节
EXTERN			a_ParPLLFHpre				:	byte ; // 上一次 PLL 频率高位
EXTERN			a_ParPLLFLpre			        :	byte ; // 上一次 PLL 频率低位
EXTERN		    	a_Carry					:	byte ; // 进位标志/变量

;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
PID		.Section 	'code' ; // 定义代码段名称为 PID
;========================================================
;Function : PT_PIDandPWM // 函数：功率传输阶段的 PID 控制与 PWM 输出
;Note     : Call Function Type for PID and PWM Control // 注释：调用 PID 和 PWM 控制函数类型
;		input = (1) a_0x03ContlErr // 输入：控制错误值 (来自接收端的 0x03 包)
;		output = (1) // 输出：(无直接寄存器输出，但会修改 PLL 频率和 PWM 占空比)
;			 (2) a_CEP0x03_B0 // (注：此输出注释似乎与代码不符，代码中修改的是 a_PCHO0x06_B0 等)
;			 (3) a_RPP0x04_B0 // (注：此输出注释似乎与代码不符)
;			 (4) a_CSP0x05_B0 // (注：此输出注释似乎与代码不符)
;		Paramenter = 	a_ExIP0x81_B7 (Record) // 参数：使用 a_ExIP0x81_B7/B6 记录上一次的电流采样值
;========================================================
	PT_PIDandPWM:
			CLR WDT ; // 清除看门狗
			CLR	a_StatusCntInt1				;;a_r_Kp10_8_6_4 // 清除状态计数器 (可能用于选择 Kp)

	;~~~80hTd(j) = [80h + CE(j)]*Ta(j-1)~~~ // 计算目标电流值 Td(j)，乘以 0x80 (128) 是为了放大，方便整数运算
	; Ta(j-1) 是上一次的实际电流采样值
	PT_PIDCalculation0:
			CLR	a_temp2 ; // 清除临时变量
			CLR	a_temp1
			CLR	a_temp0
			CALL	CLRMath ; // 清除数学运算寄存器
			MOV	A, a_0x03ContlErr ; // 获取控制错误 CE(j)
			MOV	a_data0, A
			MOV	A, 000H
			MOV	a_data4, A
			CALL	SignedSub_8Bit				; ~~~ CE from 8bit to 16bit ~~~(16us) // 将 8 位有符号 CE 扩展为 16 位存入 a_temp1, a_temp0
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A
			
			;~~~~[80h+CE(j)]   (20us)~~~~ // 计算 [0x80 + CE(j)]
			CALL	CLRMath
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, 080H ; // 加载 0x80
			MOV	a_data4, A
			CALL	SignedAdd_16Bit ; // 执行 16 位有符号加法
			MOV	A, a_to2 ; // 保存结果到 a_temp2, a_temp1, a_temp0 (结果可能是 17 位)
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A
			CALL	CLRMath
			SZ	fg_start ; // 检查是否是 PID 首次启动
			JMP	PT_PIDCalc1 ; // 不是首次启动，跳转去使用上一次的电流值 Ta(j-1)

			;JMP	PT_PIDCalc0
	PT_PIDCalc0: ; // PID 首次启动
			MOV	A, a_ADRHbuffer 			;;Ta(0) =Ta(1)	;ADRH // 使用当前的电流采样值作为 Ta(0)
			MOV	a_data1, A
			MOV	A, a_ADRLbuffer
			MOV	a_data0, A
			JMP	PT_PIDCalcEnd
	PT_PIDCalc1:
			MOV	A, a_ExIP0x81_B7 			;;Ta(j-1) 	;ADRH // 获取上一次的电流采样值 Ta(j-1) 高位
			MOV	a_data1, A
			MOV	A, a_ExIP0x81_B6					;ADRL // 获取上一次的电流采样值 Ta(j-1) 低位
			MOV	a_data0, A
	PT_PIDCalcEnd:
			MOV	A, a_temp1				; ~~~ [80h+CE(j)] ~~~ // 获取 [0x80 + CE(j)] 的结果
			MOV	a_data5, A
			MOV	A, a_temp0
			MOV	a_data4, A
			CALL	SignedMul_16Bit				;; ~~~ Target 80hTd(j) = Ta(j-1)*[80h + CE(j)] ~~~(66us) // 计算 16 位乘法得到目标电流值 80hTd(j) (结果是 32 位)
			MOV	A, a_to2 ; // 保存 32 位结果的高 16 位到 a_PCHO0x06_B0 和 a_StatusEndPower
			MOV	a_PCHO0x06_B0, A			; a_PCHO0x06_B0 = 80hTd(j) high byte
			MOV	A, a_to1
			MOV	a_StatusEndPower, A			; a_StatusEndPower = 80hTd(j) Middle byte
			MOV	A, a_to0 ; // 保存 32 位结果的低 16 位到 a_OptConfiCNT (只取了最低字节)
			MOV	a_OptConfiCNT, A			; a_OptConfiCNT = 80hTd(j) Low byte
			SNZ	fg_CEThrPana ; // 检查松下设备 CE 阈值标志 (可能用于跳过某些计算)
			JMP	PT_PIDCalcEnd1
		
			SNZ	fg_PLLThr ; // 检查 PLL 阈值标志 (可能用于跳过某些计算)
			JMP	PT_PIDCalcEnd1
		     		
	     		; // --- 以下部分代码似乎是根据 CE 的正负，对目标电流值 Td(j) 进行微调，但具体逻辑需要结合上下文 ---
	     		MOV		A, 000H				;;200mA=0C8h, 150mA=096h, 110mA=06Eh, 250mA=0FAh // 加载一个阈值的高位 (可能对应 200mA)
			MOV	a_to7, A
			MOV	A, 0C8H ; // 加载阈值的低位
			MOV	a_to6, A
			SZ	a_0x03ContlErr.7 ; // 检查控制错误 CE(j) 的符号位 (最高位)
			JMP	PT_PIDCalcN ; // 如果 CE(j) < 0 (符号位为 1)，跳转

			;JMP	PT_PIDCalcP
	PT_PIDCalcP: ; // CE(j) >= 0 的情况
			MOV	A, a_ExIP0x81_B6			;; Low Byte // 获取上一次电流值 Ta(j-1) 低位
			ADD	A, a_to6 ; // Ta(j-1) + 阈值低位
			MOV	a_data0, A  				;;Saving // 保存结果到 a_data0
			MOV	A, a_ExIP0x81_B7			;; High Byte // 获取上一次电流值 Ta(j-1) 高位
			ADC	A, a_to7 ; // Ta(j-1) + 阈值高位 + 进位
			MOV	a_data1, A  				;;Saving // 保存结果到 a_data1
			JMP	PT_PIDCalcPN
	PT_PIDCalcN: ; // CE(j) < 0 的情况				
			MOV	A, a_ExIP0x81_B6			;; Low Byte // 获取上一次电流值 Ta(j-1) 低位
			SUB	A, a_to6 ; // Ta(j-1) - 阈值低位
			MOV	a_data0, A  				;;Saving
			MOV	A, a_ExIP0x81_B7			;; High Byte
			SBC	A, a_to7 ; // Ta(j-1) - 阈值高位 - 借位
			MOV	a_data1, A  				;;Saving
	PT_PIDCalcPN:
			MOV	A, 000H					; ~~~ [80h] ~~~ // 加载 0x80
			MOV	a_data5, A
			MOV	A, 080H
			MOV	a_data4, A
			CALL	SignedMul_16Bit				;; ~~~ Target 80hTd(j) = Ta(j-1)*[80h] ~~~(66us) // 计算 Ta(j-1) * 0x80 (不含 CE 的目标值?)
			CALL	PreCarry ; // 准备多字节减法
			MOV	A, a_OptConfiCNT			;; Low Byte // 获取之前计算的含 CE 的 Td(j) 低字节
			SUB	A, a_to0 ; // (含 CE 的 Td) - (不含 CE 的 Td) 低位
			MOV	A, a_StatusEndPower			;; Mid Byte
			SBC	A, a_to1 ; // ... 中位
			MOV	A, a_PCHO0x06_B0			;; High Byte
			SBC	A, a_to2 ; // ... 高位
			CALL	PostCarry ; // 处理借位
			SZ	a_0x03ContlErr.7 ; // 再次检查 CE 符号
			JMP	PT_PIDCalcNN ; // CE < 0 跳转

			JMP	PT_PIDCalcPP
	PT_PIDCalcPP: ; // CE >= 0
			SZ	a_Carry ; // 检查减法结果是否 < 0 (a_Carry=1 表示结果 < 0)
			JMP	PT_PIDCalcEnd1				; < // 如果差值 < 0，跳转到结束

			JMP	PT_PIDCalcEndMax			; >= // 如果差值 >= 0，跳转去设置 Td 为最大值？(逻辑似乎有点反)
	PT_PIDCalcNN: ; // CE < 0
			SZ	a_Carry ; // 检查减法结果是否 < 0
			JMP	PT_PIDCalcEndMax			; < // 如果差值 < 0，跳转去设置 Td 为最大值？

			JMP	PT_PIDCalcEnd1				; >= // 如果差值 >= 0，跳转到结束
	PT_PIDCalcEndMax: ; // (这个标签的逻辑可能需要结合具体应用场景理解，可能是在特定条件下限制 Td 的最大值)
			MOV	A, a_to2 ; // 将 Ta(j-1) * 0x80 的结果作为 Td(j)？
			MOV	a_PCHO0x06_B0, A			; a_PCHO0x06_B0 = 80hTd(j) high byte
			MOV	A, a_to1
			MOV	a_StatusEndPower, A			; a_StatusEndPower = 80hTd(j) Middle byte
			MOV	A, a_to0
			MOV	a_OptConfiCNT, A			; a_OptConfiCNT = 80hTd(j) Low byte
			;JMP	PT_PIDCalcEnd1
	PT_PIDCalcEnd1:
			CALL	PT_SvParaSelect ; // 根据当前状态选择 PID 参数 Sv
			MOV	A, a_ADRHbuffer 			;;;~~~ to as Ta(j-1)~~~ // 将当前的电流采样值保存起来，作为下一次计算的 Ta(j-1)
			MOV	a_ExIP0x81_B7,A				;ADRH
			MOV	A, a_ADRLbuffer
			MOV	a_ExIP0x81_B6,A				;ADRL
	
	
	PT_PIDInteration: ; // PID 迭代计算部分
			;--80hE(j,i) = [80hTd(j) - 80hTa(j,i-1)] ----- // 计算当前迭代的误差 E(j,i)，同样乘以 0x80
			; Ta(j,i-1) 是上一次迭代的实际电流采样值
			SNZ	fg_IterationStart ; // 检查是否是迭代的第一次
			JMP	PT_PIDInteration1 ; // 不是第一次，跳转

			CALL	PID_SenPriCoilCurrWay65Double ; // 第一次迭代，采样当前电流 Ta(j,0)
			CALL	PT_SvParaSelect ; // 选择 Sv 参数
	PT_PIDInteration1:
			CALL	CLRMath
			SZ	fg_IterationStart ; // 再次检查是否是第一次迭代
			JMP	PT_PIDIter1 ; // 不是第一次

			;JMP	PT_PIDIter0
	PT_PIDIter0: ; // 第一次迭代
			MOV	A, a_ADRHbuffer 			;;Ta(j,0)=Ta(j) ;ADRH // 使用刚刚采样的电流值 Ta(j,0)
			MOV	a_data1, A
			MOV	A, a_ADRLbuffer				;;ADRL
			MOV	a_data0, A
			JMP	PT_PIDIterEnd
	PT_PIDIter1: ; // 非第一次迭代	
			MOV	A, a_ExIP0x81_B5 			;;Ta(j,i-1) ;ADRH // 获取上一次迭代的电流值 Ta(j,i-1)
			MOV	a_data1, A
			MOV	A, a_ExIP0x81_B4			;;ADRL
			MOV	a_data0, A
			;JMP	PT_PIDIterEnd
	PT_PIDIterEnd:
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, 080H ; // 加载 0x80
			MOV	a_data4, A
			CALL	SignedMul_16Bit				; ~~~ 80h*Ta(j,i-1) ~~~(66us) =>850us // 计算 80h * Ta(j,i-1)
			MOV	A, a_to2 ; // 保存结果到 a_temp2, a_temp1, a_temp0
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A
			MOV	A, a_ADRHbuffer ; // 将当前的电流值保存到 a_ExIP0x81_B5/B4，作为下一次迭代的 Ta(j,i-1)
			MOV	a_ExIP0x81_B5, A
			MOV	A, a_ADRLbuffer
			MOV	a_ExIP0x81_B4, A
			CALL	CLRMath
			MOV	A, a_PCHO0x06_B0			; ~~~ 80hTd(j) ~~~~ // 获取目标电流值 Td(j)
			MOV	a_data2, A
			MOV	A, a_StatusEndPower
			MOV	a_data1, A
			MOV	A, a_OptConfiCNT
			MOV	a_data0, A
			MOV	A, a_temp2				; ~~~ 80h*Ta(j,i-1) ~~~ // 获取 80h * Ta(j,i-1)
			MOV	a_data6, A
			MOV	A, a_temp1
			MOV	a_data5, A
			MOV	A, a_temp0
			MOV	a_data4, A
			CALL	SignedSub_24Bit				; ~~~80hE(j,i) = [80hTd(j) - 80h*Ta(j,i-1)] ~~~(20us) // 计算 24 位减法得到误差 80hE(j,i)
			MOV	A, a_to2 ; // 保存误差到 a_EH, a_EM, a_EL
			MOV	a_EH, A
			MOV	A, a_to1
			MOV	a_EM, A
			MOV	A, a_to0
			MOV	a_EL, A

			;-------80hI(j,i) = 80hI(j,i-1) + [Ki(0.05)*80hE(j,i)*Tinner] // 计算积分项 I(j,i)
			;-------80hI(j,i) = 80hI(j,i-1) + [80hE(j,i)*Tinner]/14h // Tinner 是积分时间，Ki 是积分系数，这里 Ki*Tinner/14h 是一个常数因子 (0.05 * Tinner ?)
			;------------  -384000(FA2400h) <= 80hI(j,i) <= +384000(05DC00h)  --------- // 积分项限幅
			;------------  -3000 <= I(j,i) <= +3000  ---------
			CALL	CLRMath
			MOV	A, a_EH					;~~~ 80hE(j,i)~~~ // 获取误差
			MOV	a_data2, A
			MOV	A, a_EM
			MOV	a_data1, A
			MOV	A, a_EL
			MOV	a_data0, A
			MOV	A, 000H					;~~~ Tinner = 2ms~~~ // 加载积分时间 Tinner (这里是 3ms)
			MOV	a_data6, A				;~~~ Tinner = 3ms~~~
			MOV	A, 000H
			MOV	a_data5, A
			;MOV	A, 002H
			MOV	A, 003H
			MOV	a_data4, A
			CALL	SignedMul_24Bit				;~~~ [80hE(j,i)*Tinner] ~~~(78us) // 计算误差乘以积分时间
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			CALL	CLRMath
			MOV	A, a_temp2				; ~~~[80hE(j,i)*Tinner] ~~~ // 获取误差乘以积分时间的结果
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H					; ~~~ /14h~~~ // 加载除数 0x14 (20)
			MOV	a_data6, A
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, 014h
			MOV	a_data4, A
			CALL	SignedDiv_24Bit				; ~~~~[80hE(j,i)*Tinner]/14h~~~(20us) // 计算积分增量
			MOV	A, a_to2 ; // 保存积分增量到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			CALL	CLRMath
			SZ	fg_IterationStart ; // 检查是否是第一次迭代
			JMP	PT_PIDIter1I ; // 不是第一次，跳转

			;JMP	PT_PIDIter0I
	PT_PIDIter0I: ; // 第一次迭代
			MOV	A, 000H					;;80hI(j,0)=0 // 积分项初值为 0
			MOV	a_data2, A
			MOV	A, 000H
			MOV	a_data1, A
			MOV	A, 000H
			MOV	a_data0, A
			JMP	PT_PIDIterEndI
	PT_PIDIter1I: ; // 非第一次迭代	
			MOV	A, a_IM1 				;;80hI(j,i-1) // 获取上一次的积分项 80hI(j,i-1)
			MOV	a_data2, A
			MOV	A, a_IM0
			MOV	a_data1, A
			MOV	A, a_IL
			MOV	a_data0, A
			;JMP	PT_PIDIterEndI
	PT_PIDIterEndI:
			MOV	A, a_temp2 ; // 获取积分增量
			MOV	a_data6, A
			MOV	A, a_temp1
			MOV	a_data5, A
			MOV	A, a_temp0
			MOV	a_data4, A
			CALL	SignedAdd_24Bit				;;80hI(j,i) = 80hI(j,i-1) + [80hE(j,i)*Tinner]/14h~~~ // 计算当前积分项 80hI(j,i)
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			; 80hI(j,i) <= +384000 = 05DC00h; x - 05DC00h >= 0, 80hI(j,i)=Max=05DC00h; x - 05DC00h < 0 to Check // 积分上限判断
			; I <= +3000 = BB8h; x - BB8h >= 0, I=Max=BB8h; x - BB8h < 0 to Check
			CALL	CLRMath
			MOV	A, a_temp2 ; // 获取当前积分项
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 005H ; // 加载积分上限值 0x05DC00
			MOV	a_data6, A
			MOV	A, 0DCH
			MOV	a_data5, A
			MOV	A, 000H
			MOV	a_data4, A
			CALL	SignedSub_24Bit ; // 当前积分项 - 上限值
			SNZ	a_to3.7 ; // 检查结果符号位 (最高位)
			JMP	PT_PIDC_IiniPlusMax ; // 结果 >= 0 (符号位为 0)，跳转去设置积分项为最大值

			; FA2400h = -384000 <= 80hI(j,i); x - FA2400h >= 0, 80hI(j,i)=I_ini ; x - FA2400h < 0, 80hI(j,i)=Min=FA2400h // 积分下限判断
			; F448h = -3000 <= I; x - F448h >= 0, I=I_ini ; x - F448h < 0, I=Min=F448h 
			CALL	CLRMath
			MOV	A, a_temp2 ; // 获取当前积分项
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 0FAH ; // 加载积分下限值 0xFA2400 (负数)
			MOV	a_data6, A
			MOV	A, 024H
			MOV	a_data5, A
			MOV	A, 000H
			MOV	a_data4, A
			CALL	SignedSub_24Bit ; // 当前积分项 - 下限值
			SNZ	a_to3.7 ; // 检查结果符号位
			JMP	PT_PIDC_I_Cal ; // 结果 >= 0 (符号位为 0)，跳转去保存当前积分值 (未超下限)
			JMP	PT_PIDC_IiniMinusMin ; // 结果 < 0 (符号位为 1)，跳转去设置积分项为最小值

	; x - 05DC00h >= 0, 80hI(j,i)=Max=05DC00h
	; x - BB8h >= 0, I=Max=BB8h
	PT_PIDC_IiniPlusMax:					
			MOV	A, 005H ; // 设置积分项为最大值 0x05DC00
			MOV	a_IM1, A
			MOV	A, 0DCH
			MOV	a_IM0, A
			MOV	A, 000H
			MOV	a_IL, A
			JMP	PT_PIDC_Iend

	; x - FA2400h < 0, 80hI(j,i)=Min=FA2400h 
	; x - F448h < 0, I=Min=F448h
	PT_PIDC_IiniMinusMin:					
			MOV	A, 0FAH ; // 设置积分项为最小值 0xFA2400
			MOV	a_IM1, A
			MOV	A, 024H
			MOV	a_IM0, A
			MOV	A, 000H
			MOV	a_IL, A
			JMP	PT_PIDC_Iend
	PT_PIDC_I_Cal: ; // 保存未超限的积分项
			MOV	A, a_temp2
			MOV	a_IM1, A
			MOV	A, a_temp1
			MOV	a_IM0, A
			MOV	A, a_temp0
			MOV	a_IL, A
			;JMP	PT_PIDC_Iend

	;-----------------------------
	;--80hP(j,i)=Kp*80hE(j,i)---- // 计算比例项 P(j,i)，乘以 0x80
	;-----------------------------
	PT_PIDC_Iend:
			CALL	CLRMath
			MOV	A, a_EH ; // 获取误差 80hE(j,i)
			MOV	a_data2, A
			MOV	A, a_EM
			MOV	a_data1, A
			MOV	A, a_EL
			MOV	a_data0, A
			MOV	A, 000H
			MOV	a_data6, A
			MOV	A, 000H
			MOV	a_data5, A
	PT_PIDC_IendKp4: ; // 根据 a_StatusCntInt1 的位来选择不同的 Kp 值 (比例系数)
			SNZ	a_StatusCntInt1.0
			JMP	PT_PIDC_IendKp6
			MOV	A, 003H ; // Kp = 3
			JMP	PT_PIDC_IendKp
	PT_PIDC_IendKp6:
			SNZ	a_StatusCntInt1.1
			JMP	PT_PIDC_IendKp8
			MOV	A, 006H ; // Kp = 6
			JMP	PT_PIDC_IendKp
	PT_PIDC_IendKp8:
			SNZ	a_StatusCntInt1.2
			JMP	PT_PIDC_IendKp10
			MOV	A, 008H ; // Kp = 8
			JMP	PT_PIDC_IendKp		
	PT_PIDC_IendKp10:
			MOV	A, 00AH ; // Kp = 10
	PT_PIDC_IendKp:
			MOV	a_data4, A ; // 将选择的 Kp 值存入 a_data4
			CALL	SignedMul_24Bit				;~~~ Kp*80hE(j,i) ~~~(78us) // 计算 24 位乘法得到比例项 80hP(j,i)
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A
	                	
			
			;--80hPID(j,i)=80hP(j,i)+80hI(j,i)------ // 计算 PID 总输出 = P + I
			;--PID(j,i)= [80hP(j,i)+80hI(j,i)] / 80h------ // 将结果除以 0x80 得到实际 PID 输出值
			;----------   -20000(FFB1E0h) <= PID <= +20000(004E20h) // PID 输出限幅
			;~~~ [80hP(j,i)+80hI(j,i)] ~~~(17us)
			CALL	CLRMath
			MOV	A, a_temp2				;~~~ 80hP(j,i) ~~~ // 获取比例项
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, a_IM1				;~~~ 80hI(j,i) ~~~ // 获取积分项
			MOV	a_data6, A
			MOV	A, a_IM0
			MOV	a_data5, A
			MOV	A, a_IL
			MOV	a_data4, A
			CALL	SignedAdd_24Bit ; // 计算 24 位加法得到 80hPID(j,i)
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			; ~~~~PID(j,i)= [80hP(j,i)+80hI(j,i)] / 80h~~~ // 除以 0x80
			CALL	CLRMath
			MOV	A, a_temp2				; ~~~ [80hP(j,i)+80hI(j,i)] ~~~ // 获取 P+I 的结果
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H					; ~~~ /80h~~~ // 加载除数 0x80
			MOV	a_data6, A
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, 080h
			MOV	a_data4, A
			CALL	SignedDiv_24Bit					; // 执行 24 位除法得到 PID(j,i)
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			; PID <= +20000 = 4E20h; x - 004E20h >= 0, PID=Max=4E20h ; x - 4E20h < 0 to Check // PID 输出上限判断
			CALL	CLRMath
			MOV	A, a_temp2 ; // 获取 PID 输出值
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H ; // 加载上限值 0x004E20 (+20000)
			MOV	a_data6, A
			MOV	A, 04EH
			MOV	a_data5, A
			MOV	A, 020H
			MOV	a_data4, A
			CALL	SignedSub_24Bit ; // PID - 上限值
			SNZ	a_to3.7 ; // 检查结果符号位
			JMP	PT_PIDC_PIDiniPlusMax ; // 结果 >= 0 (超上限)，跳转去设置 PID 为最大值

			; FFB1E0h = -20000 <= PID; x - FFB1E0h >= 0, PID=x ; x - FFB1E0h < 0, PID=Min=FFB1E0h // PID 输出下限判断
			CALL	CLRMath
			MOV	A, a_temp2 ; // 获取 PID 输出值
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 0FFH ; // 加载下限值 0xFFB1E0 (-20000)
			MOV	a_data6, A
			MOV	A, 0B1H
			MOV	a_data5, A
			MOV	A, 0E0H
			MOV	a_data4, A
			CALL	SignedSub_24Bit			; // PID - 下限值
			SNZ	a_to3.7 ; // 检查结果符号位
			JMP	PT_PIDC_PIDend ; // 结果 >= 0 (未超下限)，跳转去保存当前 PID 值
			JMP	PT_PIDC_PIDiniMinusMin ; // 结果 < 0 (超下限)，跳转去设置 PID 为最小值
		
	PT_PIDC_PIDiniPlusMax:
			MOV	A, 000H					; x - 004E20h >= 0, PID=Max=4E20h // 设置 PID 为最大值 0x004E20
			MOV	a_temp2, A
			MOV	A, 04EH
			MOV	a_temp1, A
			MOV	A, 020H
			MOV	a_temp0, A
			JMP	PT_PIDC_PIDend
	               	
	PT_PIDC_PIDiniMinusMin:
			MOV	A, 0FFH					; x - FFB1E0h < 0, PID=Min=FFB1E0h // 设置 PID 为最小值 0xFFB1E0
			MOV	a_temp2, A
			MOV	A, 0B1H
			MOV	a_temp1, A
			MOV	A, 0E0H
			MOV	a_temp0, A
			;JMP	PT_PIDC_PIDend

			;--V(j,i)=[V(j,i-1)-[Sv*PID(j,i)]]------- // 计算新的控制输出值 V(j,i) = V(j,i-1) - Sv * PID(j,i)
	PT_PIDC_PIDend: ; // 保存 (可能经过限幅的) PID 值到 a_temp2, a_temp1, a_temp0
			CALL	CLRMath
			MOV	A, a_temp2				; ~~~PID(j,i) ~~~ // 获取 PID 值
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H					; ~~~ [Sv]~~~ // 获取 Sv 参数
			MOV	a_data6, A
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, a_Sv
			MOV	a_data4, A
			CALL	SignedMul_24Bit				; ~~~~[Sv*PID(j,i)]~~~(78us) // 计算 Sv * PID(j,i)
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			; // --- 以下部分除以 Ah (10) 的作用未知，可能是为了调整尺度 ---
			CALL	CLRMath
			MOV	A, a_temp2				; ~~~[AhSv*PID(j,i)] ~~~
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H					; ~~~ /Ah~~~
			MOV	a_data6, A
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, 00Ah ; // 除数 Ah = 10
			MOV	a_data4, A
			CALL	SignedDiv_24Bit				; ~~~~[AhSv*PID(j,i)]/Ah~~~(20us) // 计算 [Sv*PID(j,i)] / 10
			MOV	A, a_to2 ; // 保存结果到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A

			CALL	CLRMath
			SZ	fg_start ; // 检查是否首次启动
			JMP	PT_PIDIter1V

			SZ	fg_IterationStart ; // 检查是否首次迭代
			JMP	PT_PIDIter1V
			;JMP	PT_PIDIter0V

	PT_PIDIter0V: ; // 首次启动或首次迭代
			SZ	fg_RXCoilD ; // 检查线圈类型
			JMP	  PT_PIDIter0V1 ; // D 型线圈

			;JMP  PT_PIDIter0V0
	PT_PIDIter0V0: ; // 非 D 型线圈
			;MOV	A, 002H					;~~~ V(0,0) PLL=2EEh, 175kHz=2AB98h
			;... (注释掉的代码，可能对应不同的初始频率)
			MOV	A, 002H					;~~~ V(0,0) PLL=2D0h, 172kHz=29FE0h // 设置初始控制值 V(0,0) 对应 172kHz
			MOV	a_data2, A
			MOV	A, 09FH
			MOV	a_data1, A
			MOV	A, 0E0H
			MOV	a_data0, A
		
			;SET	fg_restart
			JMP	PT_PIDIter0Vend
	PT_PIDIter0V1: ; // D 型线圈
			;MOV	A, 002H					;~~~ V(0,0) PLL=2CBh, 171.5kHz=29DECh
			;... (注释掉的代码)
			MOV	A, 002H					;~~~ V(0,0) PLL=2D0h, 172kHz=29FE0h // 设置初始控制值 V(0,0) 对应 172kHz
			MOV	a_data2, A
			MOV	A, 09FH
			MOV	a_data1, A
			MOV	A, 0E0H
			MOV	a_data0, A
			;JMP	PT_PIDIter0Vend
	PT_PIDIter0Vend:
			JMP	PT_PIDIterEndV
	PT_PIDIter1V: ; // 非首次启动/迭代
			;SET	fg_RestartCE00	
			MOV	A, a_VM1				;~~~V(j,i-1) // 获取上一次的控制值 V(j,i-1)
			MOV	a_data2, A
			MOV	A, a_VM0
			MOV	a_data1, A
			MOV	A, a_VL
			MOV	a_data0, A
			;JMP	PT_PIDIterEndV
	PT_PIDIterEndV:
			MOV	A, a_temp2				; ~~~~[Sv*PID(j,i)]~~~(20us) // 获取 [Sv*PID(j,i)] / 10 的结果
			MOV	a_data6, A
			MOV	A, a_temp1
			MOV	a_data5, A
			MOV	A, a_temp0
			MOV	a_data4, A
			CALL	SignedSub_24Bit				;~~~ V(j,i)=V(j,i-1)-[Sv*PID(j,i)] ~~~(22us) // 计算新的控制值 V(j,i)
			MOV	A, a_to2 ; // 保存新的控制值 V(j,i) 到 a_VM1, a_VM0, a_VL
			MOV	a_VM1, A
			MOV	A, a_to1
			MOV	a_VM0, A
			MOV	A, a_to0
			MOV	a_VL, A

	PT_PIDVconverPWM: ; // 将控制值 V(j,i) 转换为 PLL 频率设置值
			;CLR WDT
			CALL	CLRMath
			MOV	A, a_VM1 ; // 获取控制值 V(j,i)
			MOV	a_data2, A
			MOV	A, a_VM0
			MOV	a_data1, A
			MOV	A, a_VL
			MOV	a_data0, A
			MOV	A, 001H ; // 加载基准频率值 0x0186A0 (对应某个频率，可能是 100kHz?)
			MOV	a_data6, A
			MOV	A, 086H
			MOV	a_data5, A
			MOV	A, 0A0H
			MOV	a_data4, A
			CALL	SignedSub_24Bit ; // V(j,i) - 基准频率值
			MOV	A, a_to2 ; // 保存差值到临时变量
			MOV	a_temp2, A
			MOV	A, a_to1
			MOV	a_temp1, A
			MOV	A, a_to0
			MOV	a_temp0, A
			                        
			;CLR WDT
			CALL	CLRMath
			MOV	A, a_temp2 ; // 获取差值
			MOV	a_data2, A
			MOV	A, a_temp1
			MOV	a_data1, A
			MOV	A, a_temp0
			MOV	a_data0, A
			MOV	A, 000H ; // 加载除数 0x64 (100)
			MOV	a_data6, A
			MOV	A, 000H
			MOV	a_data5, A
			MOV	A, 064H
			MOV	a_data4, A
			CALL	SignedDiv_24Bit ; // (V(j,i) - 基准频率值) / 100
			MOV	A, a_to1 ; // 获取结果的高 8 位作为 PLLFH
			MOV	a_ParPLLFH, A
			MOV	A, a_to0 ; // 获取结果的低 8 位作为 PLLFL
			MOV	a_ParPLLFL, A

	PT_PLLProtect: ; // PLL 频率保护，防止频率超出范围
			MOV	A, c_IniPLLFmaxH110 ; // 加载 PLL 频率上限高位 (对应 110kHz?)
			MOV	a_to7, A
			MOV	A, c_IniPLLFmaxL110 ; // 加载 PLL 频率上限低位
			MOV	a_to6, A
			CALL	PLLCompare ; // 比较当前计算出的 PLL 值与上限值
			SZ	a_Carry ; // 检查比较结果 (a_Carry=1 表示 当前值 < 上限值)
			JMP	PT_PLLProtectPLLHset			; < // 小于上限，跳转去设置 PLL 为上限值

			JMP	PT_PLLProtectCheckL			; >= // 大于等于上限，继续检查下限
	PT_PLLProtectPLLHset:	
			MOV	A, c_IniPLLFmaxH110 ; // 设置 PLL 为上限值
			MOV	a_ParPLLFH, A
			MOV	A, c_IniPLLFmaxL110
			MOV	a_ParPLLFL, A
			MOV	A, 001H					;;110kHz // 同时将控制值 V 也设置为对应上限频率的值
			MOV	a_VM1, A
			MOV	A, 0ADH
			MOV	a_VM0, A
			MOV	A, 0B0H
			MOV	a_VL, A
			JMP	PPT_PLLSetting ; // 跳转去应用 PLL 设置

	PT_PLLProtectCheckL:	
			MOV	A, c_IniPLLFminH205 ; // 加载 PLL 频率下限高位 (对应 205kHz?)
			;MOV	A, c_IniPLLFminH220
			MOV	a_to7, A
			MOV	A, c_IniPLLFminL205 ; // 加载 PLL 频率下限低位
			;MOV	A, c_IniPLLFminL220
			MOV	a_to6, A
  			CALL	PLLCompare ; // 比较当前计算出的 PLL 值与下限值
			SZ	a_Carry ; // 检查比较结果 (a_Carry=1 表示 当前值 < 下限值)
			JMP	PPT_PLLSettingOFF			; < // 小于下限，跳转去设置 PLL 为下限值

			;JMP	PT_PLLProtectPLLLset			; >= // 大于等于下限，保持计算出的 PLL 值
	PT_PLLProtectPLLLset: ; // 设置 PLL 为下限值
			;; Normal 205kHz
			SZ	fg_PLL205 ; // 检查是否已经是 205kHz
			CALL	DTincPWdec ; // 如果不是，增加死区时间 (降低功率?)
		
			CALL	ReSetPLL205 ; // 调用函数将 PLL 设置为 205kHz 对应的值
			SET	fg_PLL205 ; // 设置 205kHz 标志
			JMP	PPT_PLLSetting ; // 跳转去应用 PLL 设置
			
	PPT_PLLSettingOFF: ; // 当前计算出的 PLL 值小于下限，但之前不是 205kHz
			SNZ	fg_PLL205
			JMP	PPT_PLLSetting	; // 如果之前已经是 205kHz，则保持不变 (防止频率过低?)

			; // --- 以下部分检查频率是否低于另一个阈值 (162kHz?) ---
			MOV	A, c_IniPLLFH162
			MOV	a_to7, A
			MOV	A, c_IniPLLFL162
			MOV	a_to6, A
			CALL	PLLCompare
			SZ	a_Carry
			JMP	PPT_PLLSettingOFF1			; < 162kHz
			
			JMP	PPT_PLLSetting				; >= 162kHz
	PPT_PLLSettingOFF1: ; // 频率低于 162kHz
			CALL	DTdecPWinc ; // 减少死区时间 (增加功率?)
	PPT_PLLSetting:	; // 应用计算出的 (或经过限幅的) PLL 频率设置
			MOV	A, a_ParPLLFL
			MOV	PLLFL, A ; // 写入 PLLFL 寄存器
			MOV	A, a_ParPLLFH
			MOV	PLLFH, A ; // 写入 PLLFH 寄存器
	PIDandPWMLoopIterCheck:
			SET	fg_IterationStart ; // 设置迭代开始标志 (为下一次迭代准备)
			CALL	DetectVin ; // 检测输入电压
			SZ	fg_VinLow ; // 检查电压是否过低
			JMP	PT_PIDandPWMEnd ; // 如果过低，则结束本次 PID 计算

			SDZ	a_LoopIteration				; Loop time =1.76ms including AD10次 // PID 内部迭代计数减 1
			JMP	PT_PIDInteration ; // 如果计数未到 0，继续下一次迭代
	PT_PIDandPWMEnd: ; // PID 迭代完成或电压过低，结束 PID 计算
			MOV	A, a_ParPLLFL				;New PLL_L	; Low Byte // 获取最终确定的 PLL 低位
			XOR	A, a_ParPLLFLpre ; // 与上一次的 PLL 值比较
			SNZ	STATUS.2
			JMP	PPT_PLLSetting0 ; // 如果不同，跳转去更新 PLL 寄存器和记录值

			MOV	A, a_ParPLLFH				;New PLL_H	; High Byte // 获取最终确定的 PLL 高位
			XOR	A, a_ParPLLFHpre ; // 与上一次的 PLL 值比较
			SNZ	STATUS.2
			JMP	PPT_PLLSetting0 ; // 如果不同，跳转

			; // --- 如果 PLL 值与上次相同，根据 CE 符号微调 PLL 和 V 值 ---
			MOV	A, 000H
			MOV	a_to7, A
			;MOV	A, 001H
			MOV	A, 008H ; // 设置微调步长高低位
			MOV	a_to6, A
			
			SZ	a_0x03ContlErr.7 ; // 检查 CE 符号
			JMP	PLLINC ; // CE < 0，增加 PLL 频率 (降低电压 V)

			;JMP	PLLDEC
	PLLDEC: ; // CE >= 0，减少 PLL 频率 (增加电压 V)
			MOV	A, a_ParPLLFL
			SUB	A, a_to6 ; // PLL - 步长
			MOV	a_ParPLLFL, A
			MOV	A, a_ParPLLFH
			SBC	A, a_to7
			MOV	a_ParPLLFH, A
			MOV	A, 000H ; // 设置 V 的微调步长
			MOV	a_to7, A
			MOV	A, 003H
			MOV	a_to6, A
			MOV	A, 020H
			MOV	a_to5, A
			MOV	A, a_VL ; // 获取当前 V 值
			SUB	A, a_to5 ; // V - 步长 (这里似乎是增加 V，因为后面是减法 V-step)
			MOV	a_VL, A
			MOV	A, a_VM0
			SBC	A, a_to6
			MOV	a_VM0, A
			MOV	A, a_VM1
			SBC	A, a_to7
			MOV	a_VM1, A
			JMP	PPT_PLLSetting0
	PLLINC: ; // CE < 0，增加 PLL 频率 (降低电压 V)
			MOV	A, a_ParPLLFL
			ADD	A, a_to6 ; // PLL + 步长
			MOV	a_ParPLLFL, A
			MOV	A, a_ParPLLFH
			ADC	A, a_to7
			MOV	a_ParPLLFH, A
			MOV	A, 000H ; // 设置 V 的微调步长
			MOV	a_to7, A
			MOV	A, 003H
			MOV	a_to6, A
			MOV	A, 020H
			MOV	a_to5, A
			MOV	A, a_VL ; // 获取当前 V 值
			ADD	A, a_to5 ; // V + 步长 (这里似乎是降低 V，因为后面是减法 V-step，而 PLL 增加了)
			MOV	a_VL, A
			MOV	A, a_VM0
			ADC	A, a_to6
			MOV	a_VM0, A
			MOV	A, a_VM1
			ADC	A, a_to7
			MOV	a_VM1, A
	PPT_PLLSetting0: ; // 更新 PLL 寄存器和记录值
			MOV	A, a_ParPLLFL
			MOV	PLLFL, A ; // 写入 PLL 低位寄存器
			MOV	a_ParPLLFLpre, A ; // 记录当前 PLL 低位
			MOV	A, a_ParPLLFH
			MOV	PLLFH, A ; // 写入 PLL 高位寄存器
			MOV	a_ParPLLFHpre, A ; // 记录当前 PLL 高位
			SET	fg_start ; // 设置启动标志 (可能表示 PID 至少运行过一次)
			CLR	fg_IterationStart ; // 清除迭代开始标志
 			;MOV	A, 00AH
 			MOV	A, 009H ; // 重置迭代计数器
			MOV	a_LoopIteration, A
			MOV	A, 005H ; // 重置 PCHO 包数据?
			MOV	a_PCHO0x06_B0, A
			SET	a_StatusEndPower ; // 设置结束充电状态? (此处作用不明)
			CLR	a_OptConfiCNT ; // 清除可选配置计数?
			RET ; // PID 子程序返回


;========================================================
;Function : ReSetPLL205 // 函数：重置 PLL 到 205kHz
;Note     : Call Function Type for 205kHz // 注释：调用 205kHz 函数类型
;input = // 输入：无
;(1)
;		output = // 输出：无 (修改 PLL 和 V 值)
;(1)
;========================================================
	ReSetPLL205:
			MOV	A, c_IniPLLFminH205 ; // 加载 205kHz 对应的 PLL 高位
			MOV	a_ParPLLFH, A
			MOV	A, c_IniPLLFminL205 ; // 加载 205kHz 对应的 PLL 低位
			MOV	a_ParPLLFL, A
			MOV	A, 003H					;;205kHz // 加载 205kHz 对应的控制值 V
			MOV	a_VM1, A
			MOV	A, 020H
			MOV	a_VM0, A
			MOV	A, 0C8H
			MOV	a_VL, A
			RET


;========================================================
;Function : DTincPWdec // 函数：增加死区时间，减少 PWM 占空比 (可能也调整频率)
;Note     : Call Function Type for 205kHz // 注释：调用 205kHz 函数类型
;input 	  : // 输入：无 (读取 CPR 寄存器)
;output	  : // 输出：无 (修改 CPR 和 PWMC 寄存器)
;========================================================
	DTincPWdec:
			SZ	CPR ; // 检查 CPR 寄存器是否为 0
			JMP	DTi2 ; // 不为 0 跳转
			;JMP	DTi1
	DTi1: ; // CPR 为 0 的情况	
			MOV	A, 050H ; // 关闭 PWM? (具体含义需查手册 PWMC=0x50 的作用)
			MOV	PWMC, A
	DTi2:	
			MOV	A, CPR ; // 读取 CPR 寄存器值
			XOR	A, 007H					;;SC=00, DT=111 // 检查是否为 SC=00, DT=111
			SZ	STATUS.2
			JMP	DTiSet1 ; // 是，跳转

			MOV	A, CPR
			XOR	A, 00FH					;;SC=01, DT=111 // 检查是否为 SC=01, DT=111
			SZ	STATUS.2
			JMP	DTiSet2 ; // 是，跳转

			MOV	A, CPR
			XOR	A, 017H					;;SC=10, DT=111 // 检查是否为 SC=10, DT=111
			SZ	STATUS.2
			JMP	DTiSetEnd1				;;True => Zreo-bit=1 // 是，跳转到结束 1 (已达最大死区?)

			JMP	DTiSetEnd ; // 都不是，跳转到增加 CPR
	DTiSet1:
			MOV	A, 00BH					;;SC=01, DT=011 // 设置 CPR 为 SC=01, DT=011
			MOV 	CPR, A
			JMP	DTiSetEnd
	DTiSet2:		
			MOV	A, 013H					;;SC=10, DT=011 // 设置 CPR 为 SC=10, DT=011
			MOV 	CPR, A
			;JMP	DTiSetEnd
	DTiSetEnd:		
			INC		CPR ; // 增加 CPR 寄存器值 (增加死区时间或调整 PWM)
	DTiSetEnd1:		
			MOV	A, 0A3H ; // 设置 PWMC 寄存器 (具体含义需查手册)
			MOV	PWMC, A
			RET
			
			
;;;=============================================================
;						MOV	A, 050H
;						MOV	PWMC, A
;
;						SZ	fg_DTCPRmin
;						RET
;						
;						SZ	fg_DTCPR
;						JMP	DTincPWdecDTmin
;						;JMP		DTincPWdecDTde
;			DTincPWdecDTde:			
;						MOV	A, 001H			;;SC=00, DT=001
;						MOV CPR, A
;						SET	fg_DTCPR
;						JMP	DTincPWdecEND
;
;			DTincPWdecDTmin:			
;						MOV	A, 017H			;;SC=10, DT=111
;						MOV CPR, A
;						SET	fg_DTCPRmin
;						;JMP	DTincPWdecEND
;			DTincPWdecEND:
;						MOV	A, 0A3H
;						MOV	PWMC, A
;
;			RET


;;========================================================
;;Function : DTincPWdec1 // 函数：(似乎是直接设置到最大死区?)
;;Note     : Call Function Type for 205kHz
;;		input = 
;;(1)
;;		output = 
;;(1)
;;========================================================
	DTincPWdec1:
			MOV	A, 050H
			MOV	PWMC, A ; // 关闭 PWM?
			MOV	A, 017H					;;SC=10, DT=111 // 设置 CPR 为最大死区?
			MOV 	CPR, A
			MOV	A, 0A3H
			MOV	PWMC, A ; // 重新设置 PWMC
			RET

;========================================================
;Function : DTdecPWinc // 函数：减少死区时间，增加 PWM 占空比 (可能也调整频率)
;Note     : Call Function Type for 205kHz
;input 	  :
;output	  : 
;========================================================
	DTdecPWinc:
			MOV	A, CPR ; // 读取 CPR
			XOR	A, 014H					;;SC=10, DT=100 // 检查是否为 SC=10, DT=100
			SZ	STATUS.2
			JMP	DTdSet1 ; // 是，跳转

			MOV	A, CPR
			XOR	A, 00CH					;;SC=01, DT=100 // 检查是否为 SC=01, DT=100
			SZ	STATUS.2
			JMP	DTdSet2 ; // 是，跳转
	       
			SZ CPR						;;SC=00, DT=000 // 检查是否为 SC=00, DT=000 (最小死区?)
			JMP	DTdSetEnd ; // 不是，跳转到减少 CPR

			; // --- 如果已经是最小死区 ---
			CLR	fg_PLL205 ; // 清除 205kHz 标志
			MOV	A, 0A0H
			MOV	PWMC, A ; // 设置 PWMC (具体含义需查手册)
			CLR	fg_DTCPR
			CLR	fg_DTCPRmin
			MOV	A, 053H
			MOV	PWMC, A ; // 重新设置 PWMC
			;JMP	DTdSetEnd1
			RET
	 			
	DTdSet1:
			MOV	A, 010H					;;SC=10, DT=000 // 设置 CPR 为 SC=10, DT=000
			MOV 	CPR, A
			JMP	DTdSetEnd
	DTdSet2:		
			MOV	A, 008H					;;SC=01, DT=000 // 设置 CPR 为 SC=01, DT=000
			MOV 	CPR, A
			;JMP	DTdSetEnd
	DTdSetEnd:		
			DEC	CPR ; // 减少 CPR 寄存器值 (减少死区时间或调整 PWM)
	               
;			CLR	CPR
;			CLR	fg_PLL205
;			MOV	A, 0A0H
;			MOV	PWMC, A
			
;			MOV	A, 053H
;			MOV	PWMC, A
			
;			CALL	ReSetPLL205
			
			RET
					


;========================================================
;Function 	: PLLCompare  (  us) // 函数：比较 PLL 频率
;Note     	: Call Function Type for FOD Isen // 注释：调用 FOD 电流检测函数类型
;input 		: a_ParPLLFH/L (当前 PLL 值), a_to7/6 (目标 PLL 值)
;output 	: a_Carry (1 if a_ParPLL < a_to, 0 otherwise) // 输出：a_Carry (如果当前 < 目标则为 1，否则为 0)
;parameter	:
;PreSetting	:
;========================================================
	PLLCompare:
			CALL	PreCarry ; // 清除 a_Carry
			MOV		A, a_ParPLLFL			;New PLL_L	; Low Byte // 获取当前 PLL 低位
			SUB		A, a_to6 ; // 当前低位 - 目标低位
			MOV		A, a_ParPLLFH			;New PLL_H	; High Byte // 获取当前 PLL 高位
			SBC		A, a_to7 ; // 当前高位 - 目标高位 - 借位
			CALL	PostCarry ; // 根据最终借位结果设置 a_Carry
			RET


END ; // 文件结束