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
PUBLIC		DemoVI1I2Select ; // 声明 DemoVI1I2Select 子程序为公共，用于选择解调/中断方式
PUBLIC		DemoVI1I2swEN ; // 声明 DemoVI1I2swEN 子程序为公共，用于使能选定的解调/中断
PUBLIC		DemoVI1I2swDisEN ; // 声明 DemoVI1I2swDisEN 子程序为公共，用于禁用选定的解调/中断
PUBLIC		INTCheck ; // 声明 INTCheck 子程序为公共，用于设置中断检测的定时器
PUBLIC		INTTimer ; // 声明 INTTimer 子程序为公共，用于基于定时器的中断检测循环

; // 声明外部变量（在其他文件中定义）
EXTERN		fg_BaseTimeCTM				:	bit ; // CTM (TM1) 基础定时中断标志
EXTERN		fg_MutipleTimeHflagCTM			:	bit ; // CTM (TM1) 长延时高字节计数标志
EXTERN		a_MutipleTimeLCTM			:	byte ; // CTM (TM1) 长延时计数器低字节
EXTERN		a_MutipleTimeHCTM			:	byte ; // CTM (TM1) 长延时计数器高字节
EXTERN		fg_TimeOut				:	bit ; // 通用超时标志 (由 INTTimer 控制)
EXTERN		fg_FlagDemo				:	bit ; // 解调中断标志 (由中断服务程序清除)
EXTERN		a_DemoV_I1_I2				:	byte ; // 用于选择解调/中断方式的变量
EXTERN		fg_INT1					:	bit ; // 外部中断 1 标志 (由中断服务程序清除)


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
DemoFun		.Section 	'code' ; // 定义代码段名称为 DemoFun
;========================================================
;Function : DemoVI1I2Select // 函数：选择解调/中断方式
;Note     : Call Function Type for Demo Selection // 注释：调用解调选择函数类型
;input    : // 输入：无 (读取 a_DemoV_I1_I2)
;output   : a_DemoV_I1_I2 // 输出：更新 a_DemoV_I1_I2 的值 (循环切换选择)
;========================================================
	DemoVI1I2Select:
			CLR 	WDT ; // 清除看门狗
	DemoVI1I2Select11:
			;SNZ	a_DemoV_I1_I2.2				; enable when having PPT_DemoVI1I2Select13 ; // (注释掉的代码，可能用于支持第三种方式)
			SNZ	a_DemoV_I1_I2.1				; disenable when having PPT_DemoVI1I2Select13 ; // 检查当前选择位 1 是否为 0
			JMP	DemoVI1I2Select12 ; // 如果位 1 为 0，跳转到选择方式 2

			; // 如果位 1 为 1 (当前选择方式 2 或 3?)
			MOV	A, 001H ; // 将选择方式设置为 1 (使用解调中断 DEM)
			MOV	a_DemoV_I1_I2, A ; // 更新选择变量
			RET ; // 返回
	
	DemoVI1I2Select12:
			;SNZ	a_DemoV_I1_I2.0				; enable when having PPT_DemoVI1I2Select13 ; // (注释掉的代码)
			;JMP	DemoVI1I2Select13			; enable when having PPT_DemoVI1I2Select13 ; // (注释掉的代码)
			RL	a_DemoV_I1_I2 ; // 将选择变量左循环移位 (例如 001 -> 010 -> 100 -> 001 ...)
			RET ; // 返回
		
	;DemoVI1I2Select13: ; // (注释掉的代码，可能对应第三种中断方式 INT0)
	;		RL	a_DemoV_I1_I2
	;		RET


;========================================================
;Function : DemoVI1I2swEN // 函数：使能选定的解调/中断方式
;Note     : Call Function Type for Demo Enable // 注释：调用解调使能函数类型
;input    : a_DemoV_I1_I2 // 输入：当前选择的方式
;output   : // 输出：无 (配置中断相关寄存器)
;========================================================
	DemoVI1I2swEN:
			CLR	WDT ; // 清除看门狗
	DemoVI1I2sw11:				
			SNZ	a_DemoV_I1_I2.0 ; // 检查选择位 0 是否为 0
			JMP	DemoVI1I2sw12 ; // 为 0，跳转到处理方式 2 或 3

			; // 位 0 为 1，选择方式 1 (解调中断)
			SET	INTC0.2					; DEME-bit = 1 as Demodulation INT ON // 使能解调中断 (DEME)
			;CLR	INTC2.3					; INT1E=1 as INT1 OFF // (注释掉，意为禁用 INT1)
			RET ; // 返回
	DemoVI1I2sw12:
			;SNZ	a_DemoV_I1_I2.1				; enable when having PPT_DemoVI1I2sw13 ; // (注释掉的代码)
			;JMP	DemoVI1I2sw13				; enable when having PPT_DemoVI1I2sw13 ; // (注释掉的代码)
			
			; // 位 0 为 0，可能是方式 2 (外部中断 INT1)
			CLR	INTC2.7 ; // 清除外部中断 1 标志位 (INT1F)
			MOV	A, 00CH					; set INTEG = 0000_1100 = 0Ch // 配置 INTEG 寄存器，设置 INT1 为边沿触发 (具体是上升沿还是下降沿，或两者都是，需查手册)
			MOV	INTEG, A				; INTEG @SPDM 30H (POR=----_0000, WDT Out=----_0000)
			SET	INTC2.3					; INT1E=1 as INT1 ON // 使能外部中断 1 (INT1E)
			;CLR	INTC0.2					; DEME-bit = 1 as Demodulation INT OFF // (注释掉，意为禁用解调中断)
			RET ; // 返回
	;DemoVI1I2sw13:	;;Need to check pin setting ; // (注释掉的代码，可能对应方式 3 INT0)
	;		CLR	INTC0.6
	;		MOV	A, 003H					; set INTEG = 0000_0011 = 03h
	;		MOV	INTEG, A				; INTEG @SPDM 30H (POR=----_0000, WDT Out=----_0000)
	;		SET	INTC0.3					; INT0E=1 as INT0 ON
	;		RET

;========================================================
;Function : DemoVI1I2swDisEN // 函数：禁用选定的解调/中断方式
;Note     : Call Function Type for Demo Disenable // 注释：调用解调禁用函数类型
;input    : a_DemoV_I1_I2 // 输入：当前选择的方式
;output   : // 输出：无 (配置中断相关寄存器)
;========================================================
	DemoVI1I2swDisEN:
			CLR	WDT ; // 清除看门狗
	DemoVI1I2sw21:				
			SNZ	a_DemoV_I1_I2.0 ; // 检查选择位 0 是否为 0
			JMP	DemoVI1I2sw22 ; // 为 0，跳转到处理方式 2 或 3

			; // 位 0 为 1，选择方式 1 (解调中断)
			CLR	INTC0.2					; DEME-bit = 1 as Demodulation INT ON // 禁用解调中断 (DEME)
			RET ; // 返回
	DemoVI1I2sw22:
			;SNZ	a_DemoV_I1_I2.1				; enable when having PPT_DemoVI1I2sw13 ; // (注释掉的代码)
			;JMP	PPT_DemoVI1I2sw23			; enable when having PPT_DemoVI1I2sw13 ; // (注释掉的代码)
			; // 位 0 为 0，可能是方式 2 (外部中断 INT1)
			CLR	INTC2.3					; INT1E=1 as INT1 ON // 禁用外部中断 1 (INT1E)
			MOV	A, 000H					; set INTEG = 0000_0000 = 00h // 清除 INTEG 设置
			MOV	INTEG, A				; INTEG @SPDM 30H (POR=----_0000, WDT Out=----_0000)
			CLR	INTC2.7 ; // 清除外部中断 1 标志位 (INT1F)
			RET ; // 返回
	;DemoVI1I2sw23:							;;Need to check pin setting ; // (注释掉的代码)
	;		CLR	INTC0.6
	;		MOV	A, 000H					; set INTEG = 0000_0000 = 00h
	;		MOV	INTEG, A				; INTEG @SPDM 30H (POR=----_0000, WDT Out=----_0000)
	;		CLR	INTC0.3					; INT0E=1 as INT0 ON
	;		RET
	;		RET


;========================================================
;Function : INTCheck // 函数：设置中断检测的定时器周期
;Note     : Call Function Type for INT Capture // 注释：调用中断捕获函数类型
;input    : c_IniComByMutipleTimeL // 输入：通信相关定时低位值 (来自 .inc)
;	  : c_IniComByMutipleTimeH // 输入：通信相关定时高位值 (来自 .inc)
;output   : // 输出：无 (配置 CTM 定时器)
;========================================================
	INTCheck:
			MOV	A, c_IniComByMutipleTimeL		; 300us   (100us + 300us = 400us) // 加载 CTM 低位计数值
			MOV	a_MutipleTimeLCTM, A ; // 设置 CTM 低位计数器
			MOV	A, c_IniComByMutipleTimeH ; // 加载 CTM 高位计数值
			MOV	a_MutipleTimeHCTM, A ; // 设置 CTM 高位计数器
			SZ	a_MutipleTimeHCTM ; // 检查高位是否为 0
			SET	fg_MutipleTimeHflagCTM ; // 不为 0 则设置高位标志
			CALL	INTTimer ; // 调用 INTTimer 函数启动定时器并等待中断
			RET ; // 返回
			

;========================================================
;Function : INTTimer // 函数：基于 CTM 定时器的中断/解调信号检测循环
;Note     : Call Function Type for Timer of 10-bit TM1(CTM) // 注释：调用 10 位 TM1(CTM) 定时器的函数类型
;input 	  : a_MutipleTimeLCTM // 输入：CTM 低位计数值 (由 INTCheck 设置)
;	  : a_MutipleTimeHCTM // 输入：CTM 高位计数值 (由 INTCheck 设置)
;	  : fg_MutipleTimeHflagCTM // 输入：CTM 高位计数标志 (由 INTCheck 设置)
;	  : fg_INT1 // 输入：外部中断 1 标志 (中断发生时由 ISR 清零)
;	  : fg_FlagDemo // 输入：解调中断标志 (中断发生时由 ISR 清零)
;output   : fg_TimeOut (0 if timed out, 1 otherwise) // 输出：超时标志 (如果定时结束仍未收到中断，fg_TimeOut 会被清零)
;========================================================
	INTTimer:
			SET	fg_BaseTimeCTM				; TM1(CTM) basetime flag reset // 设置基础定时标志
			SET	TM1C0.3					; TM1C0[3] (T1ON-bit) = 1 as TM1 ON // 启动定时器 TM1

	CT_Start:
			CLR WDT ; // 清除看门狗
			SNZ	fg_TimeOut ; // 检查通用超时标志是否为 1 (如果被其他地方清零，则直接结束)
			JMP	CT_End ; // 超时标志为 0，跳转结束
	CT_Start_DEMO1:		
			SNZ	a_DemoV_I1_I2.0 ; // 检查当前选择的是否是方式 1 (DEM)
			JMP	CT_Start_DEMO2 ; // 不是方式 1，跳转

			; // 是方式 1 (DEM)
			SNZ	fg_FlagDemo ; // 检查解调中断标志是否为 1 (1 表示未发生中断)
			JMP	CT_End ; // 为 0 (发生解调中断)，跳转结束

			JMP	CT_Start_DEMOEnd ; // 为 1 (未发生解调中断)，继续等待或检查定时器
	CT_Start_DEMO2:
			;SNZ	a_DemoV_I1_I2.1				;enable when having CT_Start_DEMO3 ; // (注释掉的代码)
			;JMP	CT_Start_DEMO2				;enable when having CT_Start_DEMO3 ; // (注释掉的代码)
			
			; // 不是方式 1，检查是否是方式 2 (INT1)
			SNZ	fg_INT1 ; // 检查外部中断 1 标志是否为 1 (1 表示未发生中断)
			JMP	CT_End ; // 为 0 (发生 INT1 中断)，跳转结束
			;JMP	CT_Start_DEMOEnd			;enable when having CT_Start_DEMO3 ; // (注释掉的代码)
				
	;CT_Start_DEMO3: ; // (注释掉的代码，可能对应方式 3 INT0)
	;		SNZ	a_DemoV_I1_I2.2
	;		JMP	CT_Start_DEMO2
  	;
	;		SNZ	fg_INT0
	;		JMP	CT_End
	;		;JMP	CT_Start_DEMOEnd
			
			
	CT_Start_DEMOEnd: ; // 未收到中断信号
			SZ	fg_BaseTimeCTM				; TM1(CTM) basetime stop // 检查 CTM 基础定时标志是否为 0 (判断定时器一个周期是否结束)
			JMP	CT_Start ; // 未结束，继续循环等待中断或定时器中断

	; // CTM 基础定时中断已发生
	CT_RunTimeL0:
			SZ	a_MutipleTimeLCTM ; // 检查低位计数值是否为 0
			JMP	CT_RunTimeL1 ; // 不为 0，跳转
			JMP	CT_RunTimeL2 ; // 为 0，跳转
	CT_RunTimeL1:
			SDZ	a_MutipleTimeLCTM ; // 低位计数值减 1
			JMP	INTTimer ; // 重新启动定时器，继续等待
	CT_RunTimeL2:		
			SZ	fg_MutipleTimeHflagCTM ; // 检查高位标志
			JMP	CT_RunTimeH0 ; // 需要处理高位

			JMP	CT_End ; // 高位计数完成或无需高位计数，跳转结束 (超时)
	CT_RunTimeH0:
			SDZ	a_MutipleTimeHCTM ; // 高位计数值减 1
			JMP	CT_RunTimeH1 ; // 未减到 0

			CLR	fg_MutipleTimeHflagCTM ; // 减到 0，清除高位标志
	CT_RunTimeH1:
			SET	a_MutipleTimeLCTM ; // 重置低位计数器为最大值
			JMP	INTTimer ; // 重新启动定时器，继续等待
	CT_End:
			CLR WDT ; // 清除看门狗
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 1 as TM1 OFF // 停止定时器 TM1
			RET		; // 子程序返回 (如果是因为超时结束，fg_TimeOut 会保持原值，通常是 1；如果是收到中断，fg_TimeOut 也会保持原值)
			; // 注意：此函数本身不清除 fg_TimeOut，超时判断通常是在调用此函数后检查 fg_TimeOut 是否仍为 1


END ; // 文件结束