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
PUBLIC		SetTimer1 ; // 声明 SetTimer1 子程序为公共，可被其他模块调用
PUBLIC		SetTimer2 ; // 声明 SetTimer2 子程序为公共

; // 声明外部变量（在其他文件中定义）
EXTERN		a_MutipleTimeLSTM		        :	byte ; // STM (TM0) 长延时计数器低字节
EXTERN		a_MutipleTimeHSTM		        :	byte ; // STM (TM0) 长延时计数器高字节
EXTERN		fg_MutipleTimeHflagSTM		        :	bit ; // STM (TM0) 长延时高字节计数标志
EXTERN		fg_BaseTimeSTM				:	bit ; // STM (TM0) 基础定时中断标志

;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
STMtimer		.Section 	'code' ; // 定义代码段名称为 STMtimer
;========================================================
;Function : SetTimer1 // 函数：SetTimer1
;Note     : Call Function Type for timer // 注释：调用定时器函数类型
;========================================================
	SetTimer1:
			MOV	A, c_IniPowTrTtimeoutMutipleTimeL	; Ttimeout <= 1800ms // 将常量 c_IniPowTrTtimeoutMutipleTimeL (Ttimeout 定时低位值) 加载到累加器 A
			MOV	a_MutipleTimeLSTM, A ; // 将 A 的值存入 STM 定时器低位计数器变量
			MOV	A, c_IniPowTrTtimeoutMutipleTimeH ; // 将常量 c_IniPowTrTtimeoutMutipleTimeH (Ttimeout 定时高位值) 加载到累加器 A
			MOV	a_MutipleTimeHSTM, A ; // 将 A 的值存入 STM 定时器高位计数器变量
			SZ	a_MutipleTimeHSTM ; // 检查高位计数器是否为 0？
			SET	fg_MutipleTimeHflagSTM ; // 如果高位计数器不为 0，设置 STM 长延时高位标志

			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset // 设置 STM 基础定时标志 (通常在中断发生后被清除，这里设置可能是为了表示定时器已配置)
			RET ; // 子程序返回

;========================================================
;Function : SetTimer2 // 函数：SetTimer2
;Note     : Call Function Type for timer // 注释：调用定时器函数类型
;========================================================
	SetTimer2:
			MOV	A, c_IniPowTrTtioutMutipleTimeL		; Ttiout = Ttimeout - T(unknown) // 将常量 c_IniPowTrTtioutMutipleTimeL (Ttiout 定时低位值) 加载到累加器 A
			MOV	a_MutipleTimeLSTM, A ; // 将 A 的值存入 STM 定时器低位计数器变量
			MOV	A, c_IniPowTrTtioutMutipleTimeH ; // 将常量 c_IniPowTrTtioutMutipleTimeH (Ttiout 定时高位值) 加载到累加器 A
			MOV	a_MutipleTimeHSTM, A ; // 将 A 的值存入 STM 定时器高位计数器变量
			SZ	a_MutipleTimeHSTM ; // 检查高位计数器是否为 0？
			SET	fg_MutipleTimeHflagSTM ; // 如果高位计数器不为 0，设置 STM 长延时高位标志

			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset // 设置 STM 基础定时标志
			RET ; // 子程序返回

END ; // 文件结束