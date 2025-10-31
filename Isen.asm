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
PUBLIC		PID_SenPriCoilCurrWay65Double	; // 声明公共函数：两次采样主线圈电流
PUBLIC		PID_Isen65_SUBISen				; // 声明公共函数：16位减法 (Isen - 阈值)
PUBLIC		PID_SenPriCoilCurrWay65			; // 声明公共函数：采样主线圈电流并检查阈值
PUBLIC		PID_Isen65AvgTwo				; // 声明公共函数：获取两次ADC采样的平均值并转换为电流(mA)

EXTERN		Sensoring10_8					:	near	; // 外部函数：ADC采样（可能是10次采样求平均）
EXTERN		CLRMath						:	near	; // 外部函数：清除数学运算寄存器
EXTERN		PreCarry					:	near	; // 外部函数：多字节运算前准备进位标志
EXTERN		PostCarry					:	near	; // 外部函数：多字节运算后处理进位标志
EXTERN		SignedMul_16Bit					:	near	; // 外部函数：16位有符号乘法

EXTERN		a_ADRHbuffer					:	byte	; // 外部变量：ADC 结果高位缓冲区
EXTERN		a_ADRLbuffer			        	:	byte	; // 外部变量：ADC 结果低位缓冲区
EXTERN		a_data0						:	byte	; // 外部变量：通用数据缓冲 0
EXTERN		a_data1				        	:	byte	; // 外部变量：通用数据缓冲 1
EXTERN		a_data4						:	byte	; // 外部变量：通用数据缓冲 4
EXTERN		a_data5				        	:	byte	; // 外部变量：通用数据缓冲 5
EXTERN		a_to0						:	byte	; // 外部变量：通用临时存储 0
EXTERN		a_to1				        	:	byte	; // 外部变量：通用临时存储 1
EXTERN		a_to2                                   	:	byte	; // 外部变量：通用临时存储 2
EXTERN		a_to3                                   	:	byte	; // 外部变量：通用临时存储 3
EXTERN		a_to6                           		:	byte	; // 外部变量：通用临时存储 6 (用于比较阈值)
EXTERN		a_to7                                   	:	byte	; // 外部变量：通用临时存储 7 (用于比较阈值 / ADC结果低位)
EXTERN		a_temp1                                 	:	byte	; // 外部变量：通用临时变量 temp1 (用于 ADC结果高位)
EXTERN		fg_IsenSmall					:	bit		; // 外部标志位：电流过小
EXTERN		fg_IsenBig					:	bit		; // 外部标志位：电流过大
EXTERN		fg_IsenFirst					:	bit		; // 外部标志位：是否为首次电流采样
EXTERN		a_ExIP0x81_B1					:	byte	; // 外部变量：(复用) 存储上一次ADC采样低位
EXTERN		a_ExIP0x81_B2                   		:	byte	; // 外部变量：(复用) 存储上一次ADC采样高位
EXTERN		a_Carry						:	byte	; // 外部变量：用于数学运算的进位/借位标志


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
Isen		.Section 	'code'		; // 定义代码段名称为 Isen
;========================================================
;Function 	: PID_SenPriCoilCurrWay65Double  ( 370 us)
;Note     	: Call Function Type for Sensor Primary Coil Current
; // 功能：执行两次主线圈电流采样和处理。
; // 这通常用于获取一个更稳定或更新的读数，例如在PID计算之前。
;========================================================
PID_SenPriCoilCurrWay65Double:
			CALL	PID_SenPriCoilCurrWay65		; // 调用一次采样和阈值检查
			CALL	PID_SenPriCoilCurrWay65		; // 再次调用采样和阈值检查
			RET								; // 返回


;========================================================
;Function 	: PID_Isen65_SUBISen  (  us)
;Note     	: Call Function Type for FOD Isen 
;input  	: a_ADRHbuffer/a_ADRLbuffer (当前电流值), a_to7/a_to6 (要比较的阈值)
;output 	: a_Carry (1 表示 a_ADR < a_to, 0 表示 a_ADR >= a_to)
;parameter	: 	
;Setting	:
; // 功能：执行一个16位的减法 (a_ADRHbuffer:a_ADRLbuffer) - (a_to7:a_to6)
; // 结果的借位(符号)存储在 a_Carry 中。
;========================================================
	PID_Isen65_SUBISen:
			CALL	PreCarry					; // 初始化 a_Carry 为 0
			MOV	A, a_ADRLbuffer				;New Isen_L	; Low Byte 	; // A = Isen 低位
			SUB	A, a_to6				;IsenSmallTh_L 		; // A = Isen 低位 - 阈值 低位
			MOV	A, a_ADRHbuffer				;New Isen_H	; High Byte ; // A = Isen 高位
			SBC	A, a_to7				;IsenSmallTh_H 		; // A = Isen 高位 - 阈值 高位 - 借位
			CALL	PostCarry					; // 保存最终的借位标志到 a_Carry (如果结果为负，a_Carry=1)
			RET

;========================================================
;Function 	: PID_SenPriCoilCurrWay65  ( 370 us)
;Note     	: Call Function Type for Sensor Primary Coil Current
;Description    : sensor 10 to access 8, then avg_ADC = sum_ADC /8 with
;		  checking PLL and precious avg_ADC 
;input  	: 	
;output 	: fg_IsenSmall, fg_IsenBig (标志位)
;parameter	: 
;Setting	:
; // 功能：获取电流采样值 (通过 PID_Isen65AvgTwo)，并与高低阈值比较，设置 fg_IsenSmall 或 fg_IsenBig 标志。
; // 第一次调用时 (fg_IsenFirst=1)，只采样不比较。
;========================================================
	PID_SenPriCoilCurrWay65:
			CLR 	WDT							; // 清看门狗
			CALL	PID_Isen65AvgTwo			; // 调用函数获取两次采样的平均值，结果存入 a_ADRHbuffer/a_ADRLbuffer
			SZ	fg_IsenFirst					; // 检查是否是第一次采样 (Skip if Zero)
			RET								; // 如果是第一次 (fg_IsenFirst=1)，跳过比较，直接返回
			
			CLR	fg_IsenSmall					; // 清除 "电流过小" 标志
			CLR	fg_IsenBig						; // 清除 "电流过大" 标志
   
   	;;IsenSmall and IsenBig
  	PID_Isen65_IsenCheckSmall:
			MOV	A, c_IniIsenSmallTh_H			;IsenSmallTh_H 	; // 加载 "电流过小" 阈值高位 (0x00)
			MOV	a_to7, A                        	
			MOV	A, c_IniIsenSmallTh_L			;IsenSmallTh_L 	; // 加载 "电流过小" 阈值低位 (0x9E, 158mA)
			MOV	a_to6, A                        	
			CALL	PID_Isen65_SUBISen              ; // 计算 Isen - IsenSmallTh
			SZ	a_Carry                         ; // 检查结果 (a_Carry=1 表示 Isen < IsenSmallTh)
			JMP	PID_Isen65_IsenSmallfg			; < 				; // 如果 Isen < 阈值，跳转
                                                                	
			JMP	PID_Isen65_IsenCheckBig			; >= 				; // 如果 Isen >= 阈值，跳转到大电流检查
	PID_Isen65_IsenSmallfg:                                 	
			SET	fg_IsenSmall                    ; // 设置 "电流过小" 标志
			JMP	PID_Isen65END                   ; // 结束
	PID_Isen65_IsenCheckBig:                                	
			MOV	A, c_IniIsenBigTh_H			;IsenBigTh_H 	; // 加载 "电流过大" 阈值高位 (0x03)
			MOV	a_to7, A                        	
			MOV	A, c_IniIsenBigTh_L			;IsenBigTh_L 	; // 加载 "电流过大" 阈值低位 (0x20, 800mA)
			MOV	a_to6, A                        	
			CALL	PID_Isen65_SUBISen              ; // 计算 Isen - IsenBigTh
			SZ	a_Carry                         ; // 检查结果 (a_Carry=1 表示 Isen <= IsenBigTh)
			JMP	PID_Isen65END				; < 				; // 如果 Isen <= 阈值，跳转到结束 (电流正常)
	PID_Isen65_IsenBigfg:
			SET	fg_IsenBig						; // 如果 Isen > 阈值 (a_Carry=0)，设置 "电流过大" 标志
	PID_Isen65END:
			CLR 	WDT							; // 清狗
			RET									; // 返回


;========================================================
;Function 	: PID_Isen65AvgTwo  (  us)
;Note     	: Call Function Type for Isen twice
;input  	: 	
;output 	: a_ADRHbuffer, a_ADRLbuffer (存放最终计算出的电流值mA)
;parameter	: a_ExIP0x81_B1, a_ExIP0x81_B2 (用于存储上一次的ADC采样值)
;Setting	:
; // 功能：执行一次ADC采样(Sensoring10_8)，并与上一次的采样值(存储在a_ExIP0x81_B1/B2)进行2点移动平均。
; //         然后将12位的平均ADC值转换为16位的电流值(mA)，结果存入 a_ADRHbuffer/a_ADRLbuffer。
;========================================================
	PID_Isen65AvgTwo:
			MOV	A, 009H					; set ADCR0 = 0000_0001 = 001h ; // 设置 ADC 通道为 AN9 (OCP/电流检测)
			MOV	ADCR0, A				; ADCR0 @SPDM 2AH (POR=0110_0000, WDT Out=0110_0000)
			;; Output a_temp1(High Byte)+ a_to7(Low Byte)
			CALL	Sensoring10_8			; // 调用ADC采样(10次平均)，结果在 a_temp1(H) 和 a_to7(L)
			;;;~~~Save Pre ADC_H/L and Avg_ADC_H/L Convert to Now ADC_H/L~~~
			;;;~~~	Isen(A)=Isen(v)=(VsenADC/4096)*2.08v ~~~
			;;;~~~ => Isen(mA)=(VsenADC/4096)*2.08v*1000 (mA) ~~~
			;;;~~~ => Isen(mA)=VsenADC*130/256=VsenADC*82h/(2^8)~~~
			SZ	fg_IsenFirst			; // 检查是否是第一次运行此函数
			JMP	PID_Isen65Isne2			; // 不是第一次，跳转到 PID_Isen65Isne2
			;JMP	PID_Isen65Isne1
	PID_Isen65Isne1:	
			SET	fg_IsenFirst			; // 是第一次，设置标志
			;; Save Now Avg_ADC_H/L first
			MOV	A, a_temp1				;;Now Avg_ADC_H 	; // 保存第一次的ADC结果高位
			MOV	a_ExIP0x81_B2, A		; // (复用a_ExIP0x81_B2来存储)
			MOV	A, a_to7				;;Now Avg_ADC_L 	; // 保存第一次的ADC结果低位
			MOV	a_ExIP0x81_B1, A		; // (复用a_ExIP0x81_B1来存储)
			RET							; // 第一次运行结束
	PID_Isen65Isne2:
			CLR	fg_IsenFirst			; // 不是第一次运行，清除标志 (以便 PID_SenPriCoilCurrWay65 进行比较)
			MOV	A, a_ExIP0x81_B1			;Low Byte 		; // 加载上一次的ADC结果低位
			ADD	A, a_to7				; // 加上这一次的ADC结果低位 (a_to7)
			MOV	a_to7	, A  			;;Saving 			; // 保存 (ADC1_L + ADC2_L)
			MOV	A, a_ExIP0x81_B2			;High Byte 		; // 加载上一次的ADC结果高位
			ADC	A, a_temp1				; // 加上这一次的ADC结果高位 (a_temp1) 和进位
			MOV	a_temp1	, A  			;;Saving 			; // 保存 (ADC1_H + ADC2_H)

			;; /256=/2^1 					; // 注释有误，这里是 /2 (求平均)
			CLR	c							; // 清除进位位
			RRC	a_temp1						; // 右移一位（除以2），高位
			RRC	a_to7						; // 右移一位（除以2），低位
	
			;; Save Now Avg_ADC_H/L
			MOV	A, a_temp1				;;Now Avg_ADC_H
			MOV	a_ADRHbuffer, A			; // 将平均值高位存入 a_ADRHbuffer
			MOV	A, a_to7				;;Now Avg_ADC_L
			MOV	a_ADRLbuffer, A			; // 将平均值低位存入 a_ADRLbuffer
			
	;; Now Avg_ADC_H/L Isen(A) convert to Now ADC_H/L Isen(mA)
	PID_Isen65Conversion:
			;; ADC*82h 						; // 将12位ADC值转换为mA (Isen(mA) ~= ADC * 130 / 256)
			CALL	CLRMath					; // 清理数学运算寄存器 (a_data0-7, a_to0-7等)
			MOV	A, a_ADRHbuffer				;;Now Avg_ADC_H
			MOV	a_data1, A              ; // data1 = ADC高位
			MOV	A, a_ADRLbuffer				;;Now Avg_ADC_L
			MOV	a_data0, A              ; // data0 = ADC低位
			CLR	a_data5                 ; // data5 = 0 (乘数高位)
			MOV	A, 082h					;; 82h 				; // A = 0x82 (130)
			MOV	a_data4, A				; // data4 = 0x82 (乘数低位)
			CALL	SignedMul_16Bit			; // 执行 16位乘法 (a_data1:a_data0) * (a_data5:a_data4)
											; // 结果在 a_to3:a_to2:a_to1:a_to0
			
			;; /256=/2^8 
			; // 执行8次右移 (除以256)
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
				
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			CLR		c
			RRC		a_to3
			RRC		a_to2
			RRC		a_to1
			RRC		a_to0
        	
			MOV		A, a_to0					; // 结果的[15:8]位 (原[23:16])
			MOV		a_ADRLbuffer, A			;Now Isen_L 	; // 存为电流值低位
			MOV		A, a_to1					; // 结果的[23:16]位 (原[31:24])
			MOV		a_ADRHbuffer, A			;Now Isen_H 	; // 存为电流值高位
			RET



END