;*******************************************************************************************
;*****	                               History	                                       *****
;*******************************************************************************************
;V1.0 - WPC Qi Certification Source Code by Edward in HOLTEK Semiconductor Inc. on 2014/12/25
; // 版本 V1.0 - HOLTEK Semiconductor Inc. 的 Edward 于 2014 年 12 月 25 日编写的 WPC Qi 认证源代码


;*******************************************************************************************
;*****	                           Including File	                               *****
;*******************************************************************************************
#INCLUDE 	HT66FW2230.inc			; // 包含 HT66FW2230 微控制器的寄存器定义文件
#INCLUDE	TxUserDEF2230v302.inc	; // 包含用户自定义的常量和宏定义


;*******************************************************************************************
;*****	                        Function / Parameter Claim	                       *****
;*******************************************************************************************
PUBLIC			Sensoring10_8				; // 声明公共函数：执行10次ADC采样并计算平均值（去掉最大最小）
PUBLIC			PreCarry					; // 声明公共函数：(多字节运算) 准备进位/借位
PUBLIC			PostCarry					; // 声明公共函数：(多字节运算) 保存进位/借位
PUBLIC			DemoCLR 					; // 声明公共函数：清除解调/通信相关变量
PUBLIC			ADCData 					; // 声明公共函数：执行一次ADC转换并等待完成

; // 声明外部函数（在其他文件中定义）
EXTERN			sum_ADC_value				:	near	; // 外部函数：累加ADC值 (来自 Math.asm)
EXTERN			avg_ADC_value				:	near	; // 外部函数：计算平均ADC值 (来自 Math.asm)

; // 声明外部变量（在其他文件中定义）
EXTERN			a_StatusCntInt1				:	byte	; // 中断状态计数器
EXTERN			a_DataOUT				:	byte	; // 接收数据包缓冲区
EXTERN			a_DataHeader				:	byte	; // (复用) 存储ADC采样值 1 (高位)
EXTERN			a_DataMessageB0				:	byte	; // (复用) 存储ADC采样值 1 (低位)
EXTERN			a_DataMessageB1             :	byte	; // (复用) 存储ADC采样值 2 (高位)
EXTERN			a_DataMessageB2             :	byte	; // (复用) 存储ADC采样值 2 (低位)
EXTERN			a_DataMessageB3             :	byte	; // (复用) 存储ADC采样值 3 (高位)
EXTERN			a_DataMessageB4             :	byte	; // (复用) 存储ADC采样值 3 (低位)
EXTERN			a_DataMessageB5             :	byte	; // (复用) 存储ADC采样值 4 (高位)
EXTERN			a_DataMessageB6             :	byte	; // (复用) 存储ADC采样值 4 (低位)
EXTERN			a_DataMessageB7             :	byte	; // (复用) 存储ADC采样值 5 (高位)
EXTERN			a_DataChecksum				:	byte	; // (复用) 存储ADC采样值 5 (低位)
EXTERN			fg_INT_AD				:	bit		; // ADC转换完成中断标志
EXTERN			a_com1					:	byte	; // (复用) 存储ADC采样值 6 (高位)
EXTERN			a_com2				    :	byte	; // (复用) 存储ADC采样值 6 (低位)
EXTERN			a_com3				    :	byte	; // (复用) 存储ADC采样值 7 (高位)
EXTERN			a_com4					:	byte	; // (复用) 存储ADC采样值 7 (低位)
EXTERN			a_data0					:	byte	; // (复用) 存储ADC采样值 8 (高位)
EXTERN			a_data1				    :	byte	; // (复用) 存储ADC采样值 8 (低位)
EXTERN			a_data2					:	byte	; // (复用) 存储ADC采样值 9 (高位)
EXTERN			a_data3					:	byte	; // (复用) 存储ADC采样值 9 (低位)			
EXTERN			a_data4					:	byte	; // (复用) 存储ADC采样值 10 (高位)
EXTERN			a_data5				    :	byte	; // (复用) 存储ADC采样值 10 (低位)
EXTERN			a_to0					:	byte	; // (复用) 累加和低位
EXTERN			a_to1				    :	byte	; // (复用) 累加和中位
EXTERN			a_to2                       :	byte	; // (复用) 累加和高位
EXTERN			a_to3                       :	byte	; // (复用) 存储最大值低位
EXTERN			a_to4                       :	byte	; // (复用) 存储最大值高位
EXTERN			a_to5                       :	byte	; // (复用) 存储最小值低位
EXTERN			a_to6                       :	byte	; // (复用) 存储最小值高位
EXTERN			a_to7                       :	byte	; // (复用) 平均值低位 / ADC结果低位
EXTERN			fg_adc_avg_cnt				:	bit		; // ADC平均计算标志
EXTERN		    	a_Carry					:	byte	; // 进位/借位标志


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
Other		.Section 	'code'	
;========================================================
;Function 	: Sensoring10_8
;Note     	: Call Function Type for AD Sensor
; // 功能：执行10次ADC采样，存储结果，然后调用 sum_ADC_value 和 avg_ADC_value
; //        来计算去掉最大值和最小值后的平均值。
; // 输出：平均值结果存储在 a_temp1 (高位) 和 a_to7 (低位) (由 avg_ADC_value 完成)
;========================================================
	Sensoring10_8:
			CLR	a_DataHeader				;M1H ; // 清除用于存储第1次ADC高位的变量
			CLR	a_DataMessageB0				;M1L ; // 清除用于存储第1次ADC低位的变量
			CLR	a_DataMessageB1				;M2H ; // 清除用于存储第2次ADC高位的变量
			CLR	a_DataMessageB2				;M2L ; // 清除用于存储第2次ADC低位的变量
			CLR	a_DataMessageB3				;M3H ; // ...
			CLR	a_DataMessageB4				;M3L
			CLR	a_DataMessageB5				;M4H
			CLR	a_DataMessageB6				;M4L
			CLR	a_DataMessageB7				;M5H
			CLR	a_DataChecksum				;M5L
			CLR	a_com1					;M6H
			CLR	a_com2                  ;M6L		
			CLR	a_com3					;M7H
			CLR	a_com4                  ;M7L		
			CLR	a_data0					;M8H
			CLR	a_data1                 ;M8L		
			CLR	a_data2					;M9H
			CLR	a_data3                 ;M9L		
			CLR	a_data4					;M10H
			CLR	a_data5                 ;M10L		
			CLR	a_to0					;M11 ; // 清除累加和低位 (a_to0, a_to1, a_to2)
			CLR	a_to1                   ;M11 		
			CLR	a_to2					;M12 ; // (M11, M12 在这里似乎是错误的注释，这些是累加和)
			CLR	a_to3                   ;M12
			CLR	a_to4					;M13
			CLR	a_to5                   ;M13		
			CLR	a_to6					;M14
			CLR	a_to7					; // 清除用于存储ADC结果和累加和的变量
	PID_Isen65sensoring:
			CALL	ADCData					; // 调用ADC转换
			MOV	A, ADRH					; // 获取ADC结果高位
			MOV	a_DataHeader, A			;M1 	; // 存储第1次ADC高位
			MOV	A, ADRL                 ; // 获取ADC结果低位
			MOV	a_DataMessageB0, A      ; // 存储第1次ADC低位
                                                        		
			CALL	ADCData                 ; // 第2次ADC转换
			MOV	A, ADRH                 		
			MOV	a_DataMessageB1, A		;M2
			MOV	A, ADRL                 		
			MOV	a_DataMessageB2, A      		
                                                        		
			CALL	ADCData                 ; // 第3次ADC转换
			MOV	A, ADRH                 		
			MOV	a_DataMessageB3, A		;M3
			MOV	A, ADRL                 		
			MOV	a_DataMessageB4, A      		
                                                        		
			CALL	ADCData                 ; // 第4次ADC转换
			MOV	A, ADRH                 		
			MOV	a_DataMessageB5, A		;M4
			MOV	A, ADRL                 		
			MOV	a_DataMessageB6, A      		
                                                        		
			CALL	ADCData                 ; // 第5次ADC转换
			MOV	A, ADRH                 		
			MOV	a_DataMessageB7, A		;M5
			MOV	A, ADRL                 		
			MOV	a_DataChecksum, A       		
                                                        		
			CALL	ADCData                 ; // 第6次ADC转换
			MOV	A, ADRH                 		
			MOV	a_com1, A				;M6
			MOV	A, ADRL                 		
			MOV	a_com2, A               		
                                                        		
			CALL	ADCData                 ; // 第7次ADC转换
			MOV	A, ADRH                 		
			MOV	a_com3, A				;M7
			MOV	A, ADRL                 		
			MOV	a_com4, A               		
                                                        		
			CALL	ADCData                 ; // 第8次ADC转换
			MOV	A, ADRH                 		
			MOV	a_data0, A				;;M8
			MOV	A, ADRL                 		
			MOV	a_data1, A              		
                                                        		
			CALL	ADCData                 ; // 第9次ADC转换
			MOV	A, ADRH                 		
			MOV	a_data2, A				;;M9
			MOV	A, ADRL                 		
			MOV	a_data3, A              		
                                                        		
			CALL	ADCData                 ; // 第10次ADC转换
			MOV	A, ADRH                 		
			MOV	a_data4, A				;;M10
			MOV	A, ADRL
			MOV	a_data5, A

	;;;~~~Sum_ADC_value~~~
	PID_Isen65_Sum_ADC:
			CLR	fg_adc_avg_cnt			; // 清除平均值计算标志 (用于 sum_ADC_value 内部逻辑，重置最大/最小值)
			; 1st data					
			mov	A, offset a_DataHeader			; point high byte of M1
			mov	mp1l, A                         ; // MP1L 指向 a_DataHeader (高位)
			mov	A, offset a_DataMessageB0		; point low byte of M1
			mov	mp0, A                          ; // MP0 指向 a_DataMessageB0 (低位)
			; [注意]：这里的代码假定 sum_ADC_value 会从 MP1L 和 MP0 指向的地址读取 R1 和 R0。
			;         然而，根据 Math.asm，sum_ADC_value 是直接使用 R1 和 R0 的值。
			;         此处缺少 `MOV A, [MP1L]`, `MOV R1, A`, `MOV A, [MP0]`, `MOV R0, A` 指令。
			;         假设这里调用的是一个不同版本或未提供的 sum_ADC_value，或者 R0/R1 已被正确加载。
			call	sum_ADC_value           ; // 累加第1个值 (a_to0, a_to1, a_to2) 并更新 Min/Max        	
			; 2nd data						
			mov	A, offset a_DataMessageB1		; point high byte of M2
			mov	mp1l, A                         	
			mov	a, offset a_DataMessageB2		; point low byte of M2
			mov	mp0, A                          	
			call	sum_ADC_value                   ; // 累加第2个值，并更新 Min/Max
			; 3th data						
			mov	A, offset a_DataMessageB3		; point high byte of M3
			mov	mp1l, A                         	
			mov	a, offset a_DataMessageB4		; point low byte of M3
			mov	mp0, a                          	
			call	sum_ADC_value                   ; // 累加第3个值 ...
			; 4th data						
			mov	a, offset a_DataMessageB5		; point high byte of M4
			mov	mp1l, a                         	
			mov	a, offset a_DataMessageB6		; point low byte of M4
			mov	mp0, a                          	
			call	sum_ADC_value                   ; // 累加第4个值 ...
			; 5th data						
			mov	a, offset a_DataMessageB7		; point high byte of M5
			mov	mp1l, a                         	
			mov	a, offset a_DataChecksum		; point low byte of M5
			mov	mp0, a                          	
			call	sum_ADC_value                   ; // 累加第5个值 ...
			; 6th data						
			mov	a, offset a_com1			; point high byte of M6
			mov	mp1l, a                         	
			mov	a, offset a_com2			; point low byte of M6
			mov	mp0, a                          	
			call	sum_ADC_value                   ; // 累加第6个值 ...
			; 7th data						
			mov	a, offset a_com3			; point high byte of M7
			mov	mp1l, a                         	
			mov	a, offset a_com4			; point low byte of M7
			mov	mp0, a
			call	sum_ADC_value                   ; // E_A(E_A0_L, E_A0_H)
			; 8th data					
			mov	a, offset a_data0			; point high byte of M8
			mov	mp1l, a                 		
			mov	a, offset a_data1			; point low byte of M8
			mov	mp0, a                  		
			call	sum_ADC_value           		
			; 9th data							
			mov	a, offset a_data2			; point high byte of M9
			mov	mp1l, a                 		
			mov	a, offset a_data3			; point low byte of M9
			mov	mp0, a                  		
			call	sum_ADC_value           		
			; 10th data							
			mov	a, offset a_data4			; point high byte of M10
			mov	mp1l, a                 		
			mov	a, offset a_data5			; point low byte of M10
			mov	mp0, a
			call	sum_ADC_value
		
	;;;~~~Avg_ADC_value=Sum_ADC_value /8~~~
	PID_Isen65_Avg_ADC:
			CLR 	WDT
			call	avg_ADC_value			; // 调用 avg_ADC_value (在 Math.asm 中)
											; // 它会使用 a_to0-a_to2 (总和) 和 a_to3-a_to6 (Min/Max)
											; // 计算 (总和 - Max - Min) / 8
											; // 结果存放在 a_temp1 (高位) 和 a_to7 (低位)
			RET


;========================================================
;Function 	: PreCarry  (  us)
;Note     	: Call Function Type for FOD Isen 
;input  	: 	
;output 	: 	
;parameter	: 	
;Setting	:
; // 功能：在执行多字节减法之前，清除自定义的进位/借位标志变量 a_Carry。
;========================================================
	PreCarry:
			CLR 	WDT						; // 清狗
			CLR	a_Carry					; // 清除 a_Carry 变量 (通常用于存储借位)
			RET

;========================================================
;Function 	: PostCarry  (  us)
;Note     	: Call Function Type for FOD Isen 
;input  	: 	(隐式输入：CPU 的状态标志 C - 进位/借位标志)
;output 	: a_Carry (0x00 或 0xFF)
;parameter	: 	
;Setting	:
; // 功能：在执行多字节减法 (SBC) 之后，将 CPU 的硬件进位/借位标志 (C) 保存到 a_Carry 变量中。
; // Holtek 架构中，SBC 借位时 C=1，不借位 C=0。
;========================================================
	PostCarry:
			MOV	A, 000H					; // A = 0
			SBCM	A, a_Carry			; // A = A - a_Carry - C (此时 a_Carry 为 0)
											; // A = 0 - 0 - C
											; // 如果 C=0 (无借位)，A = 0。a_Carry = 0。
											; // 如果 C=1 (有借位)，A = 0 - 0 - 1 = -1 (即 0xFF)。a_Carry = 0xFF。
			RET

;;========================================================
;;Function : DemoCLR
;;Note     : Call Function Type for  
;;input    : 
;;output   :
; // 功能：清除用于接收数据包的缓冲区 (a_DataOUT) 和相关状态。
;========================================================
	DemoCLR:
			MOV	A, 009H					; // 设置循环次数 (a_DataOUT 缓冲区大小为 10，但索引从 0-9)
			MOV	a_StatusCntInt1, A		; // 使用 a_StatusCntInt1 作为循环计数器
			MOV	A, offset a_DataOUT		; // A = a_DataOUT 缓冲区的起始地址
			MOV	MP0, A					; // 将该地址加载到内存指针 0 (MP0)
	LOOP_CLR1:
			CLR WDT						; // 清狗
			CLR	IAR0					; // 清除 MP0 (IAR0) 指向的内存位置
			INC	MP0						; // MP0 指向下一个字节
			SDZ	a_StatusCntInt1			; // 计数器减 1，如果为 0 则跳过
			JMP	LOOP_CLR1				; // 继续循环
			
			RET							; // 循环结束，返回


;========================================================
;Function : ADCData  
;Note     : Call Function Type for Isence
;		input = No need
;		output = ADRH(H) + ADRL(L)
; // 功能：启动一次 ADC 转换并等待其完成。
; // 使用 fg_INT_AD 标志进行同步。
;========================================================
	ADCData:
			CLR	START					; // 清除 ADC 启动位 (ADCR0.7)
			SET	START					; // 设置 ADC 启动位，开始转换
			CLR	START					; // 启动位必须在置位后由软件清零
	AD_Wait:
			CLR WDT						; // 清狗
			SZ	fg_INT_AD				; // 检查 ADC 中断标志 (Skip if Zero)
										; // 假设：ISR 会在转换完成时将 fg_INT_AD 清零
										; // 因此，这里等待 fg_INT_AD 变为 0
			JMP	AD_Wait					; // 循环等待

			SET	fg_INT_AD				; // 转换完成 (fg_INT_AD 为 0)，将其重新置 1 (准备下一次转换)
	ADCDataEnd:
			RET							; // 返回 (ADC 结果在 ADRH 和 ADRL 寄存器中)


