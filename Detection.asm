;*******************************************************************************************
;*****	                               History	                                       *****
;*******************************************************************************************
;V1.0 - WPC Qi Certification Source Code by Edward in HOLTEK Semiconductor Inc. on 2014/12/25
; // 版本 V1.0 - HOLTEK Semiconductor Inc. 的 Edward 于 2014 年 12 月 25 日编写的 WPC Qi 认证源代码



;*******************************************************************************************
;*****	                           Including File	                               *****
;*******************************************************************************************
#INCLUDE 	HT66FW2230.inc ; // 包含 HT66FW2230 单片机的头文件
#INCLUDE	TxUserDEF2230v302.inc ; // 包含用户自定义的常量和宏定义



;*******************************************************************************************
;*****	                        Function / Parameter Claim	                       *****
;*******************************************************************************************
PUBLIC		DetectVin ; // 声明 DetectVin 子程序为公共，用于检测输入电压
PUBLIC		ObjectDetection ; // 声明 ObjectDetection 子程序为公共，用于检测是否有物体放在充电板上
PUBLIC		ObjectDetectLeave ; // 声明 ObjectDetectLeave 子程序为公共，用于检测物体是否离开
PUBLIC		ObjDetLeaveIni ; // 声明 ObjDetLeaveIni 子程序为公共，物体离开检测的初始化部分
PUBLIC		ObjDetLeavePowe ; // 声明 ObjDetLeavePowe 子程序为公共，物体离开检测的功率脉冲部分
PUBLIC		ObjDetLeaveDetect ; // 声明 ObjDetLeaveDetect 子程序为公共，物体离开检测的检测延时部分
PUBLIC		ObjDetLeaveCheck ; // 声明 ObjDetLeaveCheck 子程序为公共，物体离开检测的比较部分

; // 声明外部函数（在其他文件中定义）
EXTERN		Sensoring10_8					:	near ; // ADC 采样函数 (采样10次取平均?)
EXTERN		PreCarry					:	near ; // 多字节运算前准备进位标志
EXTERN		PostCarry					:	near ; // 多字节运算后处理进位标志
EXTERN		ADCData						:	near ; // 执行一次 ADC 转换
EXTERN		DelayTimer					:	near ; // 基于 CTM (TM1) 的精确延时函数
EXTERN		Delay3						:	near ; // 一个固定的延时函数

; // 声明外部变量（在其他文件中定义）
EXTERN		fg_MutipleTimeHflagCTM				:	bit ; // CTM 长延时高位标志
EXTERN		a_MutipleTimeLCTM				:	byte ; // CTM 长延时计数器低位
EXTERN		a_MutipleTimeHCTM				:	byte ; // CTM 长延时计数器高位
EXTERN		a_data0						:	byte ; // 通用数据缓冲 0
EXTERN		a_data1				        	:	byte ; // 通用数据缓冲 1
EXTERN		a_data2						:	byte ; // 通用数据缓冲 2
EXTERN		a_data3						:	byte ; // 通用数据缓冲 3
EXTERN		a_to1				        	:	byte ; // 通用临时存储 1
EXTERN		a_to2                                   	:	byte ; // 通用临时存储 2
EXTERN		a_to3                                   	:	byte ; // 通用临时存储 3 (可能用于 Vin 比较)
EXTERN		a_to4                           		:	byte ; // 通用临时存储 4
EXTERN		a_to5                           		:	byte ; // 通用临时存储 5
EXTERN		a_to7                                   	:	byte ; // 通用临时存储 7 (可能存储 ADC 结果低位)
EXTERN		a_temp1                                 	:	byte ; // 通用临时变量 temp1 (可能存储 ADC 结果高位)
EXTERN		fg_PSVin					:	bit ; // 选择阶段 Vin 正常标志
EXTERN		fg_RXCoilD					:	bit ; // D 型接收线圈标志
EXTERN		fg_DetectVin					:	bit ; // 检测到有效输入电压标志
EXTERN		fg_VinLow					:	bit ; // 输入电压过低标志
EXTERN		a_Carry						:	byte ; // 进位/借位标志变量


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
Detection		.Section 	'code' ; // 定义代码段名称为 Detection
;========================================================
;Function : DetectVin // 函数：检测输入电压
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : // 输入：无 (读取 ADC)
;output   : fg_DetectVin (1 if Vin is OK, 0 if Vin is out of range) // 输出：fg_DetectVin 标志 (1 表示电压正常，0 表示超出范围)
;         : fg_VinLow (1 if Vin is lower than threshold during power transfer) // 输出：fg_VinLow 标志 (1 表示功率传输阶段电压低于阈值)
;setting  : (1) Setting WDTC reg. for Period Timing
;	  : (2) Setting c_IniDetectMutipleTimeH/L
;	  : (3) Setting OCP INT ON/OFF
;========================================================
	DetectVin:
			MOV	A, 003H					; set ADCR0 = 0000_0011 = 003h, AN3 // 设置 ADC 通道为 AN3 (连接到 Vin 检测分压电路)
			MOV	ADCR0, A				; ADCR0 @SPDM 2AH (POR=0110_0000, WDT Out=0110_0000)
			CALL	Sensoring10_8 ; // 调用 ADC 采样函数，结果存入 a_temp1 (高) 和 a_to7 (低)
			SZ	fg_PSVin ; // 检查是否处于选择 (PS) 阶段 (fg_PSVin=1)
			JMP	DetectVinSet1 ; // 是选择阶段，跳转到 DetectVinSet1 (使用功率传输阶段的阈值)

			;JMP	DetectVinSet0 ; // 否 (初始化阶段?)，执行 DetectVinSet0 (使用初始化阶段的阈值)
	DetectVinSet0: ; // 初始化阶段的电压阈值设置
			MOV	A, c_IniVinMaxH ; // 加载初始化阶段 Vin 最大值高位
			MOV	a_to2, A
			MOV	A, c_IniVinMaxL ; // 加载初始化阶段 Vin 最大值低位
			MOV	a_to1, A

			MOV	A, c_IniVinMinH ; // 加载初始化阶段 Vin 最小值高位
			MOV	a_to5, A
			MOV	A, c_IniVinMinL ; // 加载初始化阶段 Vin 最小值低位
			MOV	a_to4, A
			CLR	a_to3.7 ; // 清除临时比较标志位
			JMP	PS_VinCheckmax ; // 跳转到电压比较
	DetectVinSet1: ; // 功率传输阶段的电压阈值设置		
			MOV	A, c_IniPTVinLowH ; // 加载功率传输阶段 Vin 下限高位 (低于此值为 VinLow)
			MOV	a_to2, A
			MOV	A, c_IniPTVinLowL ; // 加载功率传输阶段 Vin 下限低位
			MOV	a_to1, A

			MOV	A, c_IniPTVinMinH ; // 加载功率传输阶段 Vin 最小值高位 (低于此值可能认为是异常)
			MOV	a_to5, A
			MOV	A, c_IniPTVinMinL ; // 加载功率传输阶段 Vin 最小值低位
			MOV	a_to4, A
			CLR	a_to3.7 ; // 清除临时比较标志位
			;JMP	PS_VinCheckmax
	PS_VinCheckmax:							; DetectVin max = 3D8h // 检查是否超过上限 (或功率传输阶段的下限)
			CALL	PreCarry ; // 准备减法
			MOV	A, a_to7				; Low Byte // 获取 ADC 结果低位
			SUB	A, a_to1 ; // ADC 低位 - 阈值低位
			MOV	A, a_temp1				; High Byte // 获取 ADC 结果高位
			SBC	A, a_to2 ; // ADC 高位 - 阈值高位 - 借位
			CALL	PostCarry ; // 处理最终借位，结果存入 a_Carry (1 表示 ADC < 阈值)
			SZ	a_Carry ; // 检查 a_Carry 是否为 0 (ADC >= 阈值)
			JMP	PS_VinCheckmin				; < // 为 1 (ADC < 阈值)，跳转到检查下限

			JMP	PS_LightDark				; >= // 为 0 (ADC >= 阈值)，跳转到 PS_LightDark 处理 (可能表示电压过高或在功率传输阶段电压正常)
	PS_VinCheckmin:							; DetectVin min = 325h // 检查是否低于下限
			CALL	PreCarry ; // 准备减法
			SET	a_to3.7 ; // 设置临时比较标志位 (表示已进行过上限/下限比较)
			MOV	A, a_to7                   		; Low Byte // 获取 ADC 结果低位
			SUB	A, a_to4 ; // ADC 低位 - 阈值低位 (最小值)
			MOV	A, a_temp1                   		; High Byte // 获取 ADC 结果高位
			SBC	A, a_to5 ; // ADC 高位 - 阈值高位 - 借位
			CALL	PostCarry ; // 处理最终借位 (1 表示 ADC < 最小值)
			SZ	a_Carry ; // 检查 a_Carry 是否为 0 (ADC >= 最小值)
			JMP	PS_LightDark				; < // 为 1 (ADC < 最小值)，跳转到 PS_LightDark 处理 (电压过低)

			JMP	DetectVinEnd				; >= // 为 0 (ADC >= 最小值)，跳转到 DetectVinEnd 处理 (电压在正常范围内)
	PS_LightDark:	; // 根据阶段和比较结果设置标志
			SZ	fg_PSVin ; // 检查是否处于选择阶段
			JMP	PS_LightDark1 ; // 是，跳转

			;JMP	PS_LightDark0
	PS_LightDark0: ; // 初始化阶段
			SET	fg_DetectVin ; // 设置检测到 Vin 标志 (可能表示电压过高或过低，需要闪灯)
			RET
	PS_LightDark1: ; // 功率传输阶段
			CLR	fg_VinLow ; // 先清除 VinLow 标志
			SNZ	a_to3.7 ; // 检查临时比较标志位是否为 1 (之前是否进行了下限比较?)
			RET ; // 为 0 (表示之前是 >= 上限/下限，即电压正常)，直接返回

			; // 为 1 (表示之前进行了下限比较，并且 ADC < 最小值)
			SET	fg_VinLow ; // 设置 VinLow 标志
			RET
	DetectVinEnd: ; // 电压在正常范围内
			SZ	fg_PSVin ; // 检查是否是选择阶段
			JMP	DetectVinEnd1 ; // 是，跳转

			; // 初始化阶段
			CLR	fg_DetectVin ; // 清除检测标志 (表示电压正常)
			RET
	DetectVinEnd1: ; // 功率传输阶段
			SET	fg_VinLow ; // (此处逻辑似乎有误，应该清除 fg_VinLow?) 设置 VinLow 标志
			RET


;========================================================
;Function : ObjectDetection // 函数：物体检测 (在上电或 Ping 阶段使用)
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : // 输入：无
;output   : // 输出：无 (如果检测到物体则继续，否则可能进入休眠)
;setting  : (1) Setting WDTC reg. for Period Timing
;	    (2) Setting c_IniDetectMutipleTimeH/L
;	    (3) Setting OCP INT ON/OFF
;========================================================
	ObjectDetection:
			CLR WDT ; // 清狗

			MOV	A, 009H					; set ADCR0 = 0000_1001 = 009 ;;AN9 when OCP // 设置 ADC 通道为 AN9 (连接到 OCP/电流检测?)
			MOV	ADCR0, A				; ADCR0 @SPDM 2AH (POR=0110_0000, WDT Out=0110_0000)
			SZ	fg_RXCoilD				;default=0 // 检查是否是 D 型线圈
			JMP	OD_ParaSetupRXD ; // 是，跳转

			;JMP	OD_ParaSetup
	OD_ParaSetup: ; // 非 D 型线圈参数设置
			CALL	ObjDetLeaveIni ; // 加载通用检测定时参数
			MOV	A, c_IniDetObjMinL ; // 加载非 D 型线圈物体检测阈值低位
			MOV	a_data2, A
			MOV	A, c_IniDetObjMinH ; // 加载非 D 型线圈物体检测阈值高位
			MOV	a_data3, A
			JMP	OD_Power
	OD_ParaSetupRXD: ; // D 型线圈参数设置
			MOV	A, c_IniDetectRXDMutipleTimeL ; // 加载 D 型线圈检测定时低位
			MOV	a_data0, A
			MOV	A, c_IniDetectRXDMutipleTimeH ; // 加载 D 型线圈检测定时高位
			MOV	a_data1, A
			MOV	A, c_IniDetObjRXDMinL ; // 加载 D 型线圈物体检测阈值低位
			MOV	a_data2, A
			MOV	A, c_IniDetObjRXDMinH ; // 加载 D 型线圈物体检测阈值高位
			MOV	a_data3, A
	OD_Power: ; // 发送功率脉冲
			CALL	ObjDetLeavePowe ; // 设置定时器并打开 PWM 输出一段时间
			SZ	fg_RXCoilD				;default=0 // 检查是否是 D 型线圈
			JMP	OD_ADdetect ; // 是，跳转到 ADC 采样

			;JMP	OD_Detection				
	OD_Detection: ; // 非 D 型线圈的检测延时 (可能通过硬件 OCP?)
			CALL	ObjDetLeaveDetect ; // 设置 PWM 模式并延时
			SDZ 	ACC ; // 延时等待 (循环减 A 寄存器?)
			JMP 	$-1
	OD_ADdetect: ; // D 型线圈的 ADC 采样
			CALL	ADCData ; // 执行 ADC 转换
			MOV	A, 050H ; // 关闭 PWM?
			MOV	PWMC, A
	OD_DetectCheck:							;DetectObject min = 027h // 比较检测结果与阈值
			CALL	ObjDetLeaveCheck                	; // 调用比较子程序 (ADC 值 - 阈值)，结果在 a_Carry
			SZ	a_Carry                         	; // 检查 a_Carry 是否为 0 (ADC >= 阈值)
			JMP	OD_Repeat				; < // 为 1 (ADC < 阈值)，跳转到重复检测/休眠

			JMP	ObjectDetectionEnd			; >= // 为 0 (ADC >= 阈值，检测到物体)，跳转到结束
	OD_Repeat:                                              	
			SET	INTC0.5                         	; // 使能解调中断? (可能是为了唤醒?)
			CLR	CKGEN.7					; 1 as VCO OFF // 关闭 VCO
			CLR	INTC0.0					; 0 as EMI OFF // 关闭总中断
			HALT                                    	; // 进入休眠，等待中断唤醒并重新检测
	ObjectDetectionEnd:						; // 检测到物体
			MOV	A, 0C8H					; // 设置一个延时值
			MOV	a_MutipleTimeLCTM, A			
			MOV	A, 032H
			MOV	a_MutipleTimeHCTM, A
			SZ	a_MutipleTimeHCTM
			SET	fg_MutipleTimeHflagCTM
                       	
			CALL	DelayTimer ; // 执行延时
			RET ; // 返回，继续后续流程


;========================================================
;Function : ObjectDetectLeave // 函数：检测物体是否离开 (充电结束后调用)
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : // 输入：无
;output   : // 输出：无 (循环检测直到物体离开)
;setting  :
;========================================================
	ObjectDetectLeave:
			CLR 	WDT ; // 清狗
			MOV	A, 009H					; set ADCR0 = 0000_1001 = 009 ;;AN9 when OCP // 选择 ADC 通道 AN9
			MOV	ADCR0, A				; ADCR0 @SPDM 2AH (POR=0110_0000, WDT Out=0110_0000)
			CALL	ObjDetLeaveIni ; // 加载通用检测定时参数
			MOV	A, c_IniDetObjLeaMaxL ; // 加载物体离开检测阈值低位 (通常比物体检测阈值低)
			MOV	a_data2, A
			MOV	A, c_IniDetObjLeaMaxH ; // 加载物体离开检测阈值高位
			MOV	a_data3, A
			CALL	ObjDetLeavePowe ; // 发送功率脉冲
			CALL	ObjDetLeaveDetect ; // 延时
			SDZ 	ACC ; // 延时等待
			JMP 	$-1
			
			CALL	ADCData ; // ADC 采样
			CALL	ObjDetLeaveCheck ; // 比较 ADC 值和离开阈值
			SZ	a_Carry ; // 检查 a_Carry 是否为 0 (ADC >= 阈值)
			RET						; < // 为 1 (ADC < 阈值，物体已离开)，返回

			; // 为 0 (ADC >= 阈值，物体仍在)
			CALL	Delay3					; >= // 延时一段时间
			CALL	Delay3
			JMP	ObjectDetectLeave ; // 继续循环检测


;========================================================
;Function : ObjDetLeaveIni // 函数：物体离开检测 - 初始化定时参数
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : c_IniDetectMutipleTimeL // 输入：通用检测定时低位
;         : c_IniDetectMutipleTimeH // 输入：通用检测定时高位
;output   : a_data0 // 输出：保存定时低位
;    	  : a_data1 // 输出：保存定时高位
;Presetting:
;========================================================
	ObjDetLeaveIni:
			MOV	A, c_IniDetectMutipleTimeL ; // 加载定时低位
			MOV	a_data0, A ; // 存入 a_data0
			MOV	A, c_IniDetectMutipleTimeH ; // 加载定时高位
			MOV	a_data1, A ; // 存入 a_data1
			RET ; // 返回

;========================================================
;Function : ObjDetLeavePowe // 函数：物体离开检测 - 发送功率脉冲
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : a_data0 (定时低位)
;	  : a_data1 (定时高位)
;output   : // 输出：无
;setting  :
;========================================================
	ObjDetLeavePowe :
			MOV	A, a_data0 ; // 获取定时低位
			MOV	a_MutipleTimeLCTM, A ; // 设置 CTM 低位
			MOV	A, a_data1 ; // 获取定时高位
			MOV	a_MutipleTimeHCTM, A ; // 设置 CTM 高位
			SZ	a_MutipleTimeHCTM ; // 检查高位
			SET	fg_MutipleTimeHflagCTM ; // 设置高位标志
        	
			MOV	A, 053H					;  PWM output for PWM0 and PWM0B,  需要修正判讀位置????????????? // 设置 PWM 模式 (具体含义需查手册)
			MOV	PWMC, A
			CALL	DelayTimer ; // 调用延时函数，驱动线圈发送功率脉冲
			RET ; // 返回
		
		
;========================================================
;Function : ObjDetLeaveDetect // 函数：物体离开检测 - 检测延时
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : // 输入：无
;output   : // 输出：无
;setting  :
;========================================================
	ObjDetLeaveDetect:
			CLR WDT ; // 清狗
			MOV	A, 050H ; // 设置 PWM 模式 (可能是关闭 PWM?)
			MOV	PWMC, A
			MOV	A, 00AH					;;delay to detect coil // 加载一个延时值到累加器 A (用于后续 SDZ 延时)
			RET ; // 返回
		
;========================================================
;Function : ObjDetLeaveCheck // 函数：物体离开检测 - 比较 ADC 值
;Note     : Call Function Type for Obfject Detection // 注释：调用物体检测函数类型
;input    : ADRL, ADRH (当前 ADC 结果)
;         : a_data2, a_data3 (阈值)
;output   : a_Carry (1 if ADC < threshold, 0 otherwise) // 输出：a_Carry (如果 ADC < 阈值则为 1，否则为 0)
;setting  :
;========================================================
	ObjDetLeaveCheck:
			CALL	PreCarry ; // 准备减法
			MOV	A, ADRL   				; Low Byte // 获取 ADC 低位
			SUB	A, a_data2 ; // ADC 低位 - 阈值低位
			MOV	A, ADRH					; High Byte // 获取 ADC 高位
			SBC	A, a_data3 ; // ADC 高位 - 阈值高位 - 借位
			CALL	PostCarry ; // 处理最终借位，结果存入 a_Carry
			RET ; // 返回
		


END ; // 文件结束