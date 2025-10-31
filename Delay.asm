;*******************************************************************************************
;*****	                               History	                                       *****
;*******************************************************************************************
;V1.0 - WPC Qi Certification Source Code by Edward in HOLTEK Semiconductor Inc. on 2014/12/25
; // 版本 V1.0 - HOLTEK Semiconductor Inc. 的 Edward 于 2014 年 12 月 25 日编写的 WPC Qi 认证源代码



;*******************************************************************************************
;*****	                           Including File	                               *****
;*******************************************************************************************
#INCLUDE 	HT66FW2230.inc ; // 包含 HT66FW2230 单片机的头文件，定义寄存器地址和位名称
#INCLUDE	TxUserDEF2230v302.inc	; // 包含用户自定义的常量和宏定义



;*******************************************************************************************
;*****	                        Function / Parameter Claim	                       *****
;*******************************************************************************************
PUBLIC		Delay1 ; // 声明 Delay1 子程序为公共，可被其他模块调用
PUBLIC		Delay3 ; // 声明 Delay3 子程序为公共
PUBLIC		DelayTimer ; // 声明 DelayTimer 子程序为公共
PUBLIC		TimeOutTimer ; // 声明 TimeOutTimer 子程序为公共
PUBLIC		PT_ReceiPowerCNT ; // 声明 PT_ReceiPowerCNT 子程序为公共

; // 声明外部变量（在其他文件中定义）
EXTERN		a_MutipleTimeLCTM		        :	byte ; // CTM (TM1) 长延时计数器低字节
EXTERN		a_MutipleTimeHCTM		        :	byte ; // CTM (TM1) 长延时计数器高字节
EXTERN		fg_MutipleTimeHflagCTM		        :	bit ; // CTM (TM1) 长延时高字节计数标志
EXTERN		fg_BaseTimeCTM				:	bit ; // CTM (TM1) 基础定时中断标志
EXTERN		fg_MutipleTimeHflagSTM		        :	bit ; // STM (TM0) 长延时高字节计数标志
EXTERN		fg_TimeOut			        :	bit ; // 通用超时标志，通常由 STM (TM0) 控制
EXTERN		a_MutipleTimeLSTM		        :	byte ; // STM (TM0) 长延时计数器低字节
EXTERN		a_MutipleTimeHSTM		        :	byte ; // STM (TM0) 长延时计数器高字节
EXTERN		fg_BaseTimeSTM			        :	bit ; // STM (TM0) 基础定时中断标志
EXTERN		a_0x04ReceiPowCNTL			:	byte ; // (Qi) 接收功率包 (0x04) 计数器低字节
EXTERN		a_0x04ReceiPowCNTH                      :	byte ; // (Qi) 接收功率包 (0x04) 计数器高字节
EXTERN		fg_0x04ReceiPowCNTHflag                 :	bit ; // (Qi) 接收功率包 (0x04) 计数器高字节标志
EXTERN		fg_RxTI					:	bit ; // 接收设备是 TI (德州仪器) 设备的标志
EXTERN		fg_0x04OutReceiPowTime			:	bit ; // (Qi) 接收功率包 (0x04) 超时标志


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
Delay		.Section 	'code' ; // 定义代码段名称为 Delay
;========================================================
;Function : Delay1 // 函数：Delay1
;Note     : Call Function Type for delay timer // 注释：调用延时定时器函数类型
;input    : c_IniTtermiMutipleTimeH // 输入：终止定时的高位计数值 (来自 .inc 文件)
;	  : c_IniTtermiMutipleTimeL // 输入：终止定时的低位计数值 (来自 .inc 文件)
;output   : // 输出：无
;========================================================
	Delay1:
			MOV	A, c_IniTtermiMutipleTimeL ; // 将终止定时低位计数值加载到累加器 A
			MOV	a_MutipleTimeLCTM, A ; // 将 A 的值存入 CTM 的低位计数器变量
			MOV	A, c_IniTtermiMutipleTimeH ; // 将终止定时高位计数值加载到累加器 A
			MOV	a_MutipleTimeHCTM, A ; // 将 A 的值存入 CTM 的高位计数器变量
			SZ	a_MutipleTimeHCTM ; // 检查高位计数器是否为 0？
			SET	fg_MutipleTimeHflagCTM ; // 如果高位计数器不为 0，则设置长延时高位标志

			CALL	DelayTimer ; // 调用 DelayTimer 子程序执行延时
			RET ; // 子程序返回


;========================================================
;Function : Delay3 // 函数：Delay3
;Note     : Call Function Type for delay timer // 注释：调用延时定时器函数类型
;input    : Constant // 输入：固定的常量值 (0x4A 和 0xAA)
;output   : // 输出：无
;========================================================
	Delay3:
			MOV	A, 0AAh ; // 将常量 0xAA 加载到累加器 A
			MOV	a_MutipleTimeLCTM, A ; // 设置 CTM 低位计数器
			MOV	A, 04Ah ; // 将常量 0x4A 加载到累加器 A
			MOV	a_MutipleTimeHCTM, A ; // 设置 CTM 高位计数器
			SZ	a_MutipleTimeHCTM ; // 检查高位计数器是否为 0？
			SET	fg_MutipleTimeHflagCTM ; // 如果不为 0，设置长延时高位标志

			CALL	DelayTimer ; // 调用 DelayTimer 子程序执行延时
			RET ; // 子程序返回


;========================================================
;Function : DelayTimer // 函数：DelayTimer (使用 CTM - 定时器1 实现精确延时)
;Note     : Call Function Type for Timer of 10-bit TM1(CTM) // 注释：调用 10 位 TM1(CTM) 定时器的函数类型
;input    : a_MutipleTimeLCTM // 输入：低位计数值
;	  : a_MutipleTimeHCTM // 输入：高位计数值
;	  : fg_MutipleTimeHflagCTM // 输入：高位计数标志
;========================================================
	DelayTimer:
			SET	fg_BaseTimeCTM				; TM1(CTM) basetime flag reset // 设置基础定时标志 (可能是为了进入循环时清除旧状态或表示定时器活动)
	DelayT_Start:
			SET	EMI ; // 使能全局中断 (确保定时器中断能被响应，但也可能影响精确延时)
			SET	TM1C0.3					; TM1C0[3] (T1ON-bit) = 1 as TM1 ON // 启动定时器 TM1
			CLR WDT ; // 清除看门狗定时器，防止复位
			SZ	fg_BaseTimeCTM				; TM1(CTM) basetime stop // 检查基础定时标志是否为 0 (等待定时器中断发生并清零此标志)
			JMP	DelayT_Start ; // 如果标志不为 0 (中断未发生)，继续循环等待
	DelayT_RunTimeL0: ; // 定时器基础中断发生后执行
			SZ	a_MutipleTimeLCTM ; // 检查低位计数值是否为 0
			JMP	DelayT_RunTimeL1 ; // 不为 0，跳转去减低位计数
			JMP	DelayT_RunTimeL2 ; // 为 0，跳转去处理高位计数
	DelayT_RunTimeL1:
			SDZ	a_MutipleTimeLCTM ; // 低位计数值减 1，如果结果为 0 则跳过下一条指令
			JMP	DelayTimer ; // 如果低位减 1 后不为 0，则重新调用 DelayTimer 等待下一次基础中断
	
	DelayT_RunTimeL2:		
			SZ	fg_MutipleTimeHflagCTM ; // 检查高位计数标志是否为 0 (是否需要处理高位计数)
			JMP	DelayT_RunTimeH0 ; // 不为 0，跳转去减高位计数
			
			JMP	DelayT_End ; // 为 0，表示高位计数已完成或无需高位计数，跳转到结束
	DelayT_RunTimeH0:
			SDZ	a_MutipleTimeHCTM ; // 高位计数值减 1，如果结果为 0 则跳过
			JMP	DelayT_RunTimeH1 ; // 如果高位减 1 后不为 0，跳转到 DelayT_RunTimeH1

			CLR	fg_MutipleTimeHflagCTM ; // 如果高位减到 0，清除高位计数标志
	DelayT_RunTimeH1:
			SET	a_MutipleTimeLCTM ; // 高位计数未完成，重置低位计数器为最大值 (0xFF)
			JMP	DelayTimer ; // 重新调用 DelayTimer 继续等待

	DelayT_End:
			CLR WDT ; // 清除看门狗
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 1 as TM1 ON // 停止定时器 TM1
			RET ; // 子程序返回


;========================================================
;Function : TimeOutTimer // 函数：TimeOutTimer (使用 STM - 定时器0 实现超时判断)
;Note     : Call Function Type for Timer of 10-bit TM0(STM) // 注释：调用 10 位 TM0(STM) 定时器的函数类型
;input    : a_MutipleTimeLSTM // 输入：STM 低位计数值
;	  : a_MutipleTimeHSTM // 输入：STM 高位计数值
;	  : fg_MutipleTimeHflagSTM // 输入：STM 高位计数标志
;output   : fg_TimeOut // 输出：超时标志 (fg_TimeOut=0 表示超时，fg_TimeOut=1 表示未超时)
;========================================================
	TimeOutTimer:
			CLR WDT ; // 清除看门狗
	TO_RunTimeL0:
			SZ	a_MutipleTimeLSTM ; // 检查低位计数值是否为 0
			JMP	TO_RunTimeL1 ; // 不为 0，处理低位
			JMP	TO_RunTimeL2 ; // 为 0，处理高位
	TO_RunTimeL1:
			SDZ	a_MutipleTimeLSTM ; // 低位减 1，结果为 0 则跳过
			JMP	TO_Repeat ; // 不为 0，跳转去重启定时器，继续等待
	TO_RunTimeL2:
			SZ	fg_MutipleTimeHflagSTM ; // 检查高位标志
			JMP	TO_RunTimeH0 ; // 不为 0，处理高位
			
			JMP	TO_Check ; // 为 0，表示定时时间到，跳转去检查并设置超时标志
	TO_RunTimeH0:
			SDZ	a_MutipleTimeHSTM ; // 高位减 1，结果为 0 则跳过
			JMP	TO_RunTimeH1 ; // 不为 0，继续处理高位

			CLR	fg_MutipleTimeHflagSTM ; // 为 0，清除高位标志
	TO_RunTimeH1:
			SET	a_MutipleTimeLSTM ; // 重置低位为最大值
	TO_Repeat:
			CLR WDT ; // 清除看门狗
			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset // 设置基础定时标志 (为下一次中断做准备)
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON // 重新启动定时器 TM0
			JMP	TO_End ; // 跳转到结束 (本次调用未超时)
	TO_Check:
			CLR	fg_TimeOut	; // 清除超时标志 (表示定时时间已到，发生超时)
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF // 停止定时器 TM0
	TO_End:
			RET ; // 子程序返回


;========================================================
;Function : PT_ReceiPowerCNT // 函数：处理接收功率计数 (Qi 协议相关)
;Note     : Call Function Type for CNT // 注释：调用计数函数类型
;input    : a_0x04ReceiPowCNTL // 输入：接收功率计数器低位
;	  : a_0x04ReceiPowCNTH // 输入：接收功率计数器高位
;	  : fg_0x04ReceiPowCNTHflag // 输入：高位计数标志
;output   : fg_0x04OutReceiPowTime // 输出：接收功率超时标志
;========================================================
	PT_ReceiPowerCNT:
			CLR WDT ; // 清除看门狗
	PT_RunCNTL:
			SZ	a_0x04ReceiPowCNTL ; // 检查低位计数是否为 0
			JMP	PT_RunCNTL0 ; // 不为 0，跳转去减计数
			JMP	PT_RunCNTL1 ; // 为 0，跳转去处理高位
	PT_RunCNTL0:
			SDZ	a_0x04ReceiPowCNTL ; // 低位减 1，结果为 0 则跳过
			JMP	PT_ReceiPowerCNTEnd ; // 不为 0，跳转结束 (继续计数)

	PT_RunCNTL1:		
			SZ	fg_0x04ReceiPowCNTHflag ; // 检查高位标志
			JMP	PT_RunCNTH0 ; // 不为 0，跳转去减高位计数
			
			JMP	PT_ReceiPowerCNTFlag ; // 为 0 (计数完成)，跳转去设置超时标志
	PT_RunCNTH0:
			SDZ	a_0x04ReceiPowCNTH ; // 高位减 1，结果为 0 则跳过
			JMP	PT_RunCNTH1 ; // 不为 0，跳转到 PT_RunCNTH1

			CLR	fg_0x04ReceiPowCNTHflag ; // 为 0，清除高位标志
	PT_RunCNTH1:
			SET	a_0x04ReceiPowCNTL ; // 重置低位为最大值
			JMP	PT_ReceiPowerCNTEnd ; // 跳转结束
	
	PT_ReceiPowerCNTFlag:
			SNZ	fg_RxTI ; // 检查是否是 TI 设备 (TI 设备可能有不同的超时逻辑)
			SET	fg_0x04OutReceiPowTime ; // 如果不是 TI 设备，设置接收功率包超时标志
			
	PT_ReceiPowerCNTEnd:
			CLR 	WDT ; // 清除看门狗
			RET ; // 子程序返回



END ; // 文件结束