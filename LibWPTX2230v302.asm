;*******************************************************************************************
;*****	                               History	                                       *****
;*******************************************************************************************
;V1.0 - WPC Qi Certification Source Code by Edward in HOLTEK Semiconductor Inc. on 2014/12/25



;*******************************************************************************************
;*****	                          IC Application Information                           *****
;*******************************************************************************************
;;   	Work Voltage 			: 5.0V
;;      Osc. Type 			: HXT 20MHz	
;;      MCU Type			: HT66FW2230
;;                      		: 4KB (4096 *16) Program ROM
;;                      		: 128 ( 128 * 8) Bytes Data RAM
;;			 		:  64 (  64 * 8) Bytes EEPROM
;; 	Package 			: 28-Pin SSOP
;;
;;	HT66FW2230 Pin Application	:
;;
;;				                   +---------+      
;;				               AX  |1      28| AN  
;;				               CP  |2      27| COMM0  
;;				               CN  |3      26| AN7  
;;				               CX  |4      25| PA5  
;;				           OCDSDA  |5      24| PA4  
;;				           OCDSCK  |6      23| AN3  
;;				              VSS  |7      22| OCP 
;;				              VDD  |8      21| PLLCOM
;;				            PWM03  |9      20| AVSS 
;;				            PWM02  |10     19| AVDD  
;;				            PWM01  |11     18| OSC1  
;;				            PWM00  |12     17| OSC2  
;;				       (LED_G)PB2  |13     16| INT1  
;;				       (LED_R)PB3  |14     15| DEMO  
;;				                   +---------+      
;;


;*******************************************************************************************
;*****	                           Including File	                               *****
;*******************************************************************************************
#INCLUDE 	HT66FW2230.inc
#INCLUDE	TxUserDEF2230v302.inc	


;*******************************************************************************************
;*****	                        Function / Parameter Claim	                       *****
;*******************************************************************************************
; // 外部函数和变量声明，这些函数/变量在其他文件中定义
EXTERN		ReciPackageDataUnitPreee1		:	near
EXTERN		ReciPackageDataUnit			:	near
EXTERN		Delay1					:	near
EXTERN		Delay3					:	near
EXTERN		DelayTimer                              :	near
EXTERN		TimeOutTimer				:	near
EXTERN		SetTimer1				:	near
EXTERN		SetTimer2                               :	near
EXTERN		PT_PIDandPWM				:	near
EXTERN		DemoVI1I2Select                         :	near
EXTERN		DemoVI1I2swEN                           :	near
EXTERN		DemoVI1I2swDisEN			:	near
EXTERN		CLRMath					:	near
EXTERN		SignedSub_8Bit                          :	near
EXTERN		SignedAdd_16Bit                         :	near
EXTERN		SignedMul_16Bit                         :	near
EXTERN		SignedSub_24Bit			        :	near
EXTERN		SignedAdd_24Bit			        :	near
EXTERN		SignedMul_24Bit			        :	near
EXTERN		SignedDiv_24Bit			        :	near
EXTERN		sum_ADC_value				:	near
EXTERN		avg_ADC_value				:	near
EXTERN		DetectVin				:	near
EXTERN		ObjectDetection                         :	near
EXTERN		ObjectDetectLeave                       :	near
EXTERN		ObjDetLeaveIni                          :	near
EXTERN		ObjDetLeavePowe                         :	near
EXTERN		ObjDetLeaveDetect                       :	near
EXTERN		ObjDetLeaveCheck                        :	near
EXTERN		PT_DecodeCommand                        :	near
EXTERN		EndPowCMD0x02Decode                     :	near
EXTERN		PowContlHoldCMD0x06Decode               :	near
EXTERN		ConfigCMD0x51Decode			:	near
EXTERN		PID_SenPriCoilCurrWay65Double           :	near
EXTERN		PID_Isen65_SUBIsen                      :	near
EXTERN		PID_Isen65AvgTwo			:	near
EXTERN		ExtractPacData				:	near
EXTERN		PT_PIDCE4				:	near
EXTERN		INTCheck				:	near
EXTERN		INTTimer				:	near
EXTERN		PT_ReceiPowerCNT			:	near
EXTERN		PLLCompare				:	near
EXTERN		Sensoring10_8                           :	near
EXTERN		PreCarry                                :	near
EXTERN		PostCarry                               :	near
EXTERN		DemoCLR                                 :	near
EXTERN		ADCData 				:	near

EXTERN		a_ParPLLFH			        :	byte
EXTERN		a_ParPLLFL			        :	byte
EXTERN		fg_BaseTimeCTM			        :	bit
EXTERN		fg_MutipleTimeHflagCTM		        :	bit
EXTERN		a_MutipleTimeLCTM		        :	byte
EXTERN		a_MutipleTimeHCTM		        :	byte
EXTERN		fg_BaseTimeSTM			        :	bit
EXTERN		fg_MutipleTimeHflagSTM		        :	bit
EXTERN		fg_TimeOut			        :	bit
EXTERN		a_MutipleTimeLSTM		        :	byte
EXTERN		a_MutipleTimeHSTM		        :	byte
EXTERN		fg_FlagDemo			        :	bit
EXTERN		a_DemoV_I1_I2			        :	byte
EXTERN		fg_INT1				        :	bit
EXTERN		fg_INT0				        :	bit
EXTERN		fg_DUDataStart			        :	bit
EXTERN		fg_DU				        :	bit
EXTERN		fg_StartBit			        :	bit
EXTERN		fg_ParityBit			        :	bit
EXTERN		fg_ParityErr			        :	bit
EXTERN		fg_StopBit			        :	bit
EXTERN		fg_WaitDataOut			        :	bit
EXTERN		fg_StopBitPre			        :	bit
EXTERN		fg_DataFirst			        :	bit
EXTERN		fg_Preamble			        :	bit
EXTERN		fg_ChecksumBit			        :	bit
EXTERN		fg_PacDataOK			        :	bit
EXTERN		fg_StartReci			        :	bit
EXTERN		fg_DataByteCNTFull		        :	bit
EXTERN		a_StatusCntInt1			        :	byte
EXTERN		a_DataOUTtemp			        :	byte
EXTERN		a_DataParityCNT			        :	byte
EXTERN		a_TimeOutCNT			        :	byte
EXTERN		a_DataOUT			        :	byte
EXTERN		a_DataCNT			        :	byte
EXTERN		a_Preamble4BitCNT		        :	byte
EXTERN		a_Preamble25BitCNT		        :	byte
EXTERN		a_NoToggleCNT			        :	byte
EXTERN		a_DataByteCNT			        :	byte
EXTERN		a_DataByteCNTtemp		        :	byte
EXTERN		a_AddrDataOUT			        :	byte
EXTERN		a_HeadMessageCNT		        :	byte
EXTERN		a_ContlDataMessag		        :	byte
EXTERN		a_DataHeader			        :	byte
EXTERN		a_DataMessageB0			        :	byte
EXTERN		a_DataMessageB1             	        :	byte
EXTERN		a_DataMessageB2             	        :	byte
EXTERN		a_DataMessageB3             	        :	byte
EXTERN		a_DataMessageB4             	        :	byte
EXTERN		a_DataMessageB5             	        :	byte
EXTERN		a_DataMessageB6             	        :	byte
EXTERN		a_DataMessageB7             	        :	byte
EXTERN		a_DataChecksum			        :	byte
EXTERN		a_XORchecksum			        :	byte
EXTERN		fg_INT_AD			        :	bit
EXTERN		a_ADRHbuffer			        :	byte
EXTERN		a_ADRLbuffer			        :	byte
EXTERN		a_com1				        :	byte
EXTERN		a_com2				        :	byte
EXTERN		a_com3				        :	byte
EXTERN		a_com4				        :	byte
EXTERN		a_data0				        :	byte
EXTERN		a_data1				        :	byte
EXTERN		a_data2				        :	byte
EXTERN		a_data3				        :	byte
EXTERN		a_data4				        :	byte
EXTERN		a_data5				        :	byte
EXTERN		a_data6				        :	byte
EXTERN		a_data7				        :	byte
EXTERN		a_to0				        :	byte
EXTERN		a_to1				        :	byte
EXTERN		a_to2                                   :	byte
EXTERN		a_to3                                   :	byte
EXTERN		a_to4                                   :	byte
EXTERN		a_to5                                   :	byte
EXTERN		a_to6                                   :	byte
EXTERN		a_to7                                   :	byte
EXTERN		a_count0			        :	byte
EXTERN		a_temp2                                 :	byte
EXTERN		a_temp1                                 :	byte
EXTERN		a_temp0                                 :	byte
EXTERN		fg_PIDIni			        :	bit
EXTERN		fg_start			        :	bit
EXTERN		fg_IterationStart		        :	bit
EXTERN		fg_FODTemp60                            :	bit
EXTERN		a_IL              	   	        :	byte
EXTERN		a_IM0                 		        :	byte
EXTERN		a_IM1                 		        :	byte
EXTERN		a_VL				        :	byte
EXTERN		a_VM0				        :	byte
EXTERN		a_VM1				        :	byte
EXTERN		a_EL				        :	byte
EXTERN		a_EM				        :	byte
EXTERN		a_EH				        :	byte
EXTERN		a_Sv				        :	byte
EXTERN		a_LoopIteration			        :	byte
EXTERN		fg_0x02PowDownChargeComplete            :	bit
EXTERN		fg_0x02PowDownReconfigure               :	bit
EXTERN		fg_0x02PowDownNoResponse                :	bit
EXTERN		fg_ExIdet0x81			        :	bit
EXTERN		fg_Idet				        :	bit
EXTERN		fg_Tdelay			        :	bit
EXTERN		fg_0x04OutReceiPowTime		        :	bit
EXTERN		fg_0x51PowClass			        :	bit
EXTERN		fg_0x51NonPID			        :	bit
EXTERN		fg_EndPowDown			        :	bit
EXTERN		fg_CEinput			        :	bit
EXTERN		fg_0x04ReceiPowCNTHflag		        :	bit
EXTERN		fg_PSVin			        :	bit
EXTERN		fg_PCH0x06Abnor			        :	bit
EXTERN		fg_RecodeRPpre			        :	bit
EXTERN		fg_RPNoStable			        :	bit
EXTERN		fg_adc_avg_cnt			        :	bit
EXTERN		fg_RXCoilD			        :	bit
EXTERN		fg_NoChange			        :	bit
EXTERN		fg_IsenSmall			        :	bit
EXTERN		fg_IsenBig			        :	bit
EXTERN		fg_WaitNextCE			        :	bit
EXTERN		fg_CEThr			        :	bit
EXTERN		fg_CEThrPana			        :	bit
EXTERN		fg_IsenFirst			        :	bit
EXTERN		fg_PLLDown			        :	bit
EXTERN		fg_PLLPana			        :	bit
EXTERN		fg_DetectVin			        :	bit
EXTERN		fg_VinLow			        :	bit
EXTERN		fg_PLL205			        :	bit
EXTERN		fg_DTCPR			        :	bit
EXTERN		fg_DTCPRmin			        :	bit
EXTERN		fg_PLLThr			        :	bit
EXTERN		fg_Ping				        :	bit
EXTERN		fg_FODEfficLow			        :	bit
EXTERN		fg_ReCordTemp			        :	bit
EXTERN		fg_CalTempTimeHigh		        :	bit
EXTERN		fg_PowOver5wLEDsw		        :	bit
EXTERN		fg_DemoDetect			        :	bit
EXTERN		fg_DemoDetectTimeOut			:	bit		
EXTERN          fg_RxTI					:	bit
EXTERN          fg_RxPana			        :	bit
EXTERN		a_SSP0x01_B0			        :	byte
EXTERN		a_CSP0x05_B0			        :	byte
EXTERN		a_PCHO0x06_B0			        :	byte
EXTERN		a_Config0x51_B0			        :	byte
EXTERN		a_Config0x51_B2                         :	byte
EXTERN		a_Config0x51_B3                         :	byte
EXTERN		a_IP0x71_B0			        :	byte
EXTERN		a_IP0x71_B1			        :	byte
EXTERN		a_IP0x71_B2			        :	byte
EXTERN		a_IP0x71_B3			        :	byte
EXTERN		a_IP0x71_B4			        :	byte
EXTERN		a_IP0x71_B5			        :	byte
EXTERN		a_IP0x71_B6			        :	byte
EXTERN		a_ExIP0x81_B0			        :	byte
EXTERN		a_ExIP0x81_B1			        :	byte
EXTERN		a_ExIP0x81_B2                           :	byte
EXTERN		a_ExIP0x81_B3                           :	byte
EXTERN		a_ExIP0x81_B4                           :	byte
EXTERN		a_ExIP0x81_B5                           :	byte
EXTERN		a_ExIP0x81_B6                           :	byte
EXTERN		a_ExIP0x81_B7                           :	byte
EXTERN		a_0x03ContlErr			        :	byte
EXTERN		a_0x04ReceivedPow		        :	byte
EXTERN		a_0x04ReceivedPowPre		        :	byte
EXTERN		a_0x06TdelayML			        :	byte
EXTERN		a_0x06TdelayMH			        :	byte
EXTERN		a_StatusEndPower		        :	byte
EXTERN		a_OptConfiCNT			        :	byte
EXTERN		a_0x51PowMax			        :	byte
EXTERN		a_0x04ReceiPowCNTH		        :	byte
EXTERN		a_0x04ReceiPowCNTL		        :	byte
EXTERN		a_ParPLLFHpre			        :	byte
EXTERN		a_ParPLLFLpre			        :	byte
EXTERN		a_Carry				        :	byte
EXTERN		a_r_DetectCNT			        :	byte
EXTERN		a_r_RPowCNT			        :	byte
EXTERN		a_TempH				        :	byte
EXTERN		a_TempL	                                :	byte


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
MainCode	.Section 	at 0000H 	'code'
;========================================================
;Function : Program Memory Define // 函数: 程序存储器定义
;Note     : 
;========================================================
			ORG	0000H					; Reset in Program Memory 0000H // 程序复位向量地址
           		JMP	Initialization				; Jump into Initial // 跳转到初始化程序
                                                                	
			ORG	0004H					; Over Currrent Protection Interrupt // 过流保护中断向量地址
			JMP	ISR_OCP                         	
			                                        	
			ORG	0008H					; Demodulation Interrupt // 解调中断向量地址
			JMP	ISR_DeMod                       	
			                                        	
			ORG	000CH					; External Interrupt 0 // 外部中断0向量地址
			JMP	ISR_ExInt0                      	
			                                        	
			ORG	0010H					; MultiFunction0 Interrupt for TM0 // 多功能中断0 (用于定时器TM0) 向量地址
			JMP	ISR_MultiFun_TM0                	
                                                                	
			ORG	0014H					; MultiFunction1 Interrupt for TM1 // 多功能中断1 (用于定时器TM1) 向量地址
			JMP	ISR_MultiFun_TM1                	
                                                                	
			ORG	0018H					; MultiFunction2 Interrupt for LVD / EEPROM // 多功能中断2 (用于低压侦测/EEPROM) 向量地址
			JMP	ISR_MultiFun_LVD_EEP            	
			                                        	
			ORG	001CH					; ADC Interrupt // ADC中断向量地址
			JMP	ISR_ADC                         	
                                                                	
			ORG	0020H					; IIC Interrupt // IIC中断向量地址
			JMP	ISR_IIC                         	
			                                        	
			ORG	0024H					; Time Base 0 Interrupt // 时基0中断向量地址
			JMP	ISR_TimeBase0                   	
			                                        	
			ORG	0028H					; Time Base 1 Interrupt // 时基1中断向量地址
			JMP	ISR_TimeBase1                   	
			                                        	
			ORG	002CH					; External Interrupt 1 // 外部中断1向量地址
			JMP	ISR_ExInt1


;========================================================
;Function : Initial // 函数: 初始化
;Note     : IO and parameter initial setting // IO和参数的初始化设置
;========================================================
		Initialization:	
			SNZ	STATUS.4				; PDF flag // 检查STATUS寄存器的位4(PDF)，如果不为0则跳过下一条指令。PDF是掉电标志位，用于判断是否从掉电模式唤醒。
			JMP	InitiIO
			SNZ	STATUS.5				;;TO flag // 检查STATUS寄存器的位5(TO)，如果不为0则跳过。TO是看门狗超时标志位。
			JMP	InitiIO
			;JMP	Phase_Selection

			SET	fg_NoChange ; // 设置一个标志位，可能用于跳过某些初始化步骤
	PS_PWMsw:
			SDZ	a_r_DetectCNT ; // 检查变量a_r_DetectCNT是否为0，如果是则跳过下一条指令
			JMP	PS_175KHz

			JMP	PS_171KHz
	PS_175KHz:							;Normal // 正常模式
			MOV	A, 0D0H                         	
			MOV	PLLFL, A				; PLLFL @SPDM 61H (POR=0000_0000, WDT Out=0000_0000) // 设置PLL频率低位字节
			MOV	a_ParPLLFL, A                   	; // 备份PLLFL的值
			MOV	A, 002H                         	
			MOV	PLLFH, A				; PLLFH @SPDM 62H (POR=----_-000, WDT Out=----_-000) // 设置PLL频率高位字节，与PLLFL共同决定线圈工作频率
			MOV	a_ParPLLFH, A                   	; // 备份PLLFH的值
			CLR	fg_RXCoilD                      	; // 清除接收线圈类型D的标志位
			JMP	InitiIO1                        	; // 跳转到IO口初始化
	PS_171KHz:							;for type D Rx Coil // 针对D型接收线圈的配置
			MOV	A, 0D0H					; 172kHz
			MOV	PLLFL, A				; PLLFL @SPDM 61H (POR=0000_0000, WDT Out=0000_0000) // 设置PLL频率低位字节
			MOV	a_ParPLLFL, A
			MOV	A, 002H	
			MOV	PLLFH, A
			MOV	a_ParPLLFH, A
			MOV	A, 008H
			MOV	a_r_DetectCNT, A ; // 设置一个检测计数值
			SET	fg_RXCoilD ; // 设置接收线圈为D型的标志位
			JMP	InitiIO1

;-----------------------I/O Setting------------------------ // IO口设置
	InitiIO:
			CLR	fg_NoChange ; // 清除标志位
			MOV	A, 001H
			MOV	a_DemoV_I1_I2, A   ; // 初始化一个用于解调的变量
	InitiIO1:
			MOV	A, 005H					; set PCS0 = 0000_0101 = 05h
			MOV	PCS0, A					; PCS0 @SPDM 3DH // 配置引脚功能选择寄存器0
                                                                	
			MOV	A, 0FAH					; set PCS1 = 1111_1010 = FAh
			MOV	PCS1, A					; PCS1 @SPDM 3FH // 配置引脚功能选择寄存器1
                                                                	
			MOV	A, 0D0H					; set PCC = 1101_0000 = D0h 
			MOV	PCC, A					; PCC @SPDM 38H // 配置PC口方向，设为输入或输出
                                                                	
			;MOV	A, 000H					; set PCPU = 0000_0000 = 00h
			;MOV	PCPU, A					; PCPU @SPDM 39H // 配置PC口上拉电阻
                                                                	
			MOV	A, 04FH					; set PA = 0101_1111 = 5Fh ;;test PA.7/PA.5
			MOV	PA, A						; PA @SPDM 12H // 设置PA口的初始电平
			                                        	
			MOV	A, 0C8H					; set PAS0 = 0000_1000 = C8h;;AN3
			MOV	PAS0, A					; PAS0 @SPDM 3AH // 配置PA口引脚功能，如配置为模拟输入AN3
                                                                	
			MOV	A, 0E0H					; set PAS1 = 1110_0000 = E0h	;; AN7
			;MOV	A, 020H					; set PAS1 = 0010_0000 = 20h;;test PA.7
			MOV	PAS1, A					; PAS1 @SPDM 3BH // 配置PA口引脚功能，如配置为模拟输入AN7
			                                        	
			MOV	A, 0CFH					; set PAC = 1100_1111 = CFh ;;Temperture Sensor/PA.5
			;MOV	A, 04FH					; set PAC = 0100_1111 = 4Fh ;test PA.7/PA.5
			MOV	PAC, A					; PAC @SPDM 13H // 配置PA口方向，设为输入或输出
                                                                	
			;MOV	A, 000H					; set PAPU = 0000_0000 = 00h as no pull high
			;MOV	PAPU, A					; PAPU @SPDM 14H (POR=0000_0000, WDT Out=0000_0000) // 配置PA口上拉电阻
			                                        	
			;MOV	A, 000H					; set PAPU = 0000_0000 = 00h as no wake up HALT
			;MOV	PAWU, A					; PAPU @SPDM 15H (POR=0000_0000, WDT Out=0000_0000) // 配置PA口唤醒功能
                                                                	
			MOV	A, 0F7H					; set PB = 1111_0111 = F7h 
			MOV	PB, A					; PB @SPDM 1AH // 设置PB口的初始电平
                                                                	
			MOV	A, 082H					; set PBS0 = 1000_0010 = 82h
			MOV	PBS0, A					; PBS0 @SPDM 3CH // 配置PB口引脚功能
	                                                        	
			MOV	A, 011H					; set PBC = ---1_0001 = 11h 
			MOV	PBC, A					; PBC @SPDM 1BH (POR=---1_1111, WDT Out=---1_1111) // 配置PB口方向
                                                                	
			;MOV	A, 000H					; set PBPU = 0000_0000 = 00h as no pull high
			;MOV	PBPU, A					; PBPU @SPDM 1CH (POR=---0_0000, WDT Out=---0_0000) // 配置PB口上拉电阻
                                                                	
			;MOV	A, 0FFH					; set PC = 1111_1111 = FFh 
			;MOV	PC, A					; PC @SPDM 37H // 设置PC口的初始电平
                                                                	
			MOV	A, 007H					; set IFS0 = 0000_0111 = 07h
			MOV	IFS0, A					; IFS0 @SPDM 3EH // 输入功能选择寄存器，配置引脚的输入功能
                                                                	
;-----------------------System Setting--------------------- // 系统设置
			;MOV	A, 001H					; set HXTC = 0000_0001 = 01h
			;MOV	HXTC, A					; HXTC @SPDM 2DH
			SET	HXTC.0 ; // 使能高速外部晶振(HXT)

	Ini_CheckHXTF:
			CLR	WDT ; // 清除看门狗定时器
			SNZ	HXTC.1 ; // 检查高速外部晶振是否稳定，如果不稳定则循环等待
			JMP	Ini_CheckHXTF

			MOV	A, 008H
			MOV	SCC, A ; // 系统时钟控制寄存器，选择HXT作为系统时钟
			CLR	HIRCC.0 ; // 关闭内部高速RC振荡器
	
			;MOV	A, 000H					; set STATUS = --00_0000 = 00h
			;MOV	STATUS, A				; STATUS @SPDM 0AH (POR=xx00_xxxx, WDT Out=xx1u_uuuu) // 状态寄存器
			                                        	
			;MOV	A, 000H					; set RSTFC = --00_0000 = 00h
			;MOV	RSTFC, A				; RSTFC @SPDM 17H (POR=xx00_xxxx, WDT Out=xx1u_uuuu) // 复位标志寄存器
		                                                	
			;MOV	A, 053H					; set WDTC = 0101_0000 = 50h
			;MOV	WDTC, A					; WDTC @SPDM 23H (POR=0101_0011, WDT Out=0101_0011) // 看门狗定时器控制寄存器
                                                                	
			;MOV	A, 055H					; set WDTC = 0101_0101 = 55h
			;MOV	LVRC, A					; WDTC @SPDM 23H (POR=0101_0101, WDT Out=0101_0101) // 低电压复位控制寄存器
                                                                	
;-------------------VCO PLL / PWM setting------------------ // 压控振荡器/锁相环/PWM设置
			;MOV	A, 080H					; set CKGEN = 1000_0000 = 80h
			;MOV	CKGEN, A				; CKGEN @SPDM 60H (POR=0000_----, WDT Out=0000_----) // 时钟产生寄存器
                                                                	
			MOV	A, 0D0H					;316h= 179kHz, 2EEh=175kHz, 2D0h=172kHz
			MOV	PLLFL, A				; PLLFL @SPDM 61H (POR=0000_0000, WDT Out=0000_0000) // 设置PLL频率低位字节
			MOV	a_ParPLLFL, A                   	; // 备份值
                                                                	
			MOV	A, 002H					;316h= 179kHz
			MOV	PLLFH, A				; PLLFH @SPDM 62H (POR=----_-000, WDT Out=----_-000) // 设置PLL频率高位字节
			MOV	a_ParPLLFH, A                   	; // 备份值
                                                                	
;			MOV	A, 001H					; set CPR = 0--0_0001 = 01h
;			MOV	CPR, A					; CPR @SPDM 72H
                                                                	
			;MOV	A, 050H					; set PWMC = 0101_0000 = 00h, as Mode 0
			;MOV	PWMC, A					; PWMC @SPDM 63H // PWM控制寄存器
			;CLR	PWMC                            	
                                                                	
;----------------Timer Module 0 (STM) setting-------------- // 定时器模块0 (标准定时器) 设置
			;MOV	A, 000H					; set TM0C0 = 0000_0000 = 00h
			;MOV	TM0C0, A				; TM0C0 @SPDM 43H (POR=0000_0000, WDT Out=0000_0000) // 定时器0控制寄存器0
                                                                	
			MOV	A, 0C1H					; set TM0C1 = 1100_0001 = C1h
			MOV	TM0C1, A				; TM0C1 @SPDM 44H (POR=0000_0000, WDT Out=0000_0000) // 定时器0控制寄存器1，选择时钟源和模式
                                                                	
			MOV	A, c_IniSTMTimeBaseL			; set TM0AL = 0000_0000 = 00h
			MOV	TM0AL, A				; TM0AL @SPDM 47H (POR=0000_0000, WDT Out=0000_0000) // 定时器0周期寄存器低位
                                                                	
			MOV	A, c_IniSTMTimeBaseH			; set TM0AH = 0000_0000 = 00h
			MOV	TM0AH, A				; TM0AH @SPDM 48H (POR=----_--00, WDT Out=----_--00) // 定时器0周期寄存器高位
                                                                	
;----------------Timer Module 1 (CTM) setting-------------- // 定时器模块1 (紧凑型定时器) 设置
			;MOV	A, 000H					; set TM1C0 = 0000_0000 = 00h
			;MOV	TM1C0, A				; TM1C0 @SPDM 49H (POR=0000_0000, WDT Out=0000_0000) // 定时器1控制寄存器0
                                                                	
			MOV	A, 0C1H					; set TM1C1 = 0000_0000 = 00h
			MOV	TM1C1, A				; TM1C1 @SPDM 4AH (POR=0000_0000, WDT Out=0000_0000) // 定时器1控制寄存器1
                                                                	
			MOV	A, c_IniCTMTimeBaseL			; set TM1AL = 1111_1010 = FAh for 50us
			MOV	TM1AL, A				; TM1AL @SPDM 4DH (POR=0000_0000, WDT Out=0000_0000) // 定时器1周期寄存器低位，根据注释，设置为50微秒中断
                                                                	
			MOV	A, c_IniCTMTimeBaseH			; set TM1AH = 0000_0000 = 00h
			MOV	TM1AH, A				; TM1AH @SPDM 4EH (POR=----_--00, WDT Out=----_--00) // 定时器1周期寄存器高位
                                                                	
;-------------------Internal VREF setting------------------ // 内部参考电压设置
			MOV	A, 080H					; set VREFC = 1000_0000 = 80h
			MOV	VREFC, A				; VREFC @SPDM 6FH (POR=0---_---x, WDT Out=0---_---x) // 使能内部参考电压
                                                                	
			;MOV	A, 020H					; set VREACAL = 0010_0000 = 20h for Non-Calibration
			;MOV	VREACAL, A				; VREACAL @SPDM 70H (POR=0010_0000, WDT Out=0010_0000) // 参考电压校准寄存器
                                                                	
;----------------Demodulation & OCP setting----------------- // 解调 和 过流保护 设置
			;MOV	A, 000H					; set DCMISC = 0000_0000 = 00h @ AVDD=5v			
			;MOV	DCMISC, A				; DCMISC @SPDM 6EH (POR=000-_--00, WDT Out=000-_--00) // 解调杂项控制寄存器
                                                                	
			;MOV	A, 020H					; set DMACAL = 0010_0000 = 20h for Non-Calibration
			;MOV	DEMACAL, A				; DMACAL @SPDM 67H (POR=0010_0000, WDT Out=0010_0000) // 解调放大器校准
                                                                	
			;MOV	A, 010H					; set DMCCAL = 0001_0000 = 10h for Non-Calibration
			;MOV	DEMCCAL, A				; DMCCAL @SPDM 68H (POR=0001_0000, WDT Out=0001_0000) // 解调比较器校准
                                                                	
			MOV	A, 040H					; set DEMC0 = 0100_0000 = 40h			
			MOV	DEMC0, A				; DEMC0 @SPDM 64H (POR=00--_----, WDT Out=00--_----) // 解调控制寄存器0，使能解调器
			                                        	
			;MOV	A, 007H					; set DEMC1 = 0000_0110 = 06h for OPA gain= 1, 63~64 tFLT
			;MOV	DEMC1, A				; DEMC1 @SPDM 65H (POR=x-00_0000, WDT Out=x-00_0000) // 解调控制寄存器1
                                                                	
			MOV	A, 042H					; set DEMREF = 0100_0010 = 42h for 5v / 256 x 66(42h) = 1.3v Reference voltage
			MOV	DEMREF, A				; DEMREF @SPDM 66H (POR=0000_0000, WDT Out=0000_0000) // 设置解调器的参考电压，用于ASK解调
                                                                	
			;MOV	A, 020H					; set OCPACAL = 0010_0000 = 20h for Non-Calibration
			;MOV	OCPACAL, A				; OCPACAL @SPDM 6CH (POR=0010_0000, WDT Out=0010_0000) // OCP放大器校准
			;MOV	OCACAL, A                       	
                                                                	
			;MOV	A, 010H					; set OCPCCAL = 0001_0000 = 10h for Non-Calibration
			;MOV	OCPCCAL, A				; OCPCCAL @SPDM 6DH (POR=0001_0000, WDT Out=0001_0000) // OCP比较器校准
			;MOV	OCCCAL, A                       	
                                                                	
			MOV	A, 040H					; set OCPC0 = 0100_0000 = 40h
			MOV	OCPC0, A				; OCPC0 @SPDM 69H (POR=00--_----, WDT Out=00--_----) // OCP控制寄存器0，使能OCP功能
			                                        	
			MOV	A, 007H					; set OCPC1 = 0000_0111 = 07h
			MOV	OCPC1, A				; OCPC1 @SPDM 6AH (POR=x-00_0000, WDT Out=x-00_0000) // OCP控制寄存器1
                                                                	
			MOV	A, 0B2H					; set OCPREF = 0B2h =3.5v@VREF=5V (2014/06/24), CCh=4V
			MOV	OCPREF, A				; OCPREF @SPDM 6BH (POR=0000_0000, WDT Out=0000_0000) // 设置OCP参考电压，即过流阈值
                                                                	
;-------------------------I2C setting----------------------     	
			; IICC0                                 	
			; IICC1                                 	
			; IICD                                  	
			; IICA                                  	
			; I2CTOC                                	
                                                                	
;-------------------------ADC setting----------------------     	
			MOV	A, 001H					; set ADCR0 = 0000_0001 = 001h
			MOV	ADCR0, A				; ADCR0 @SPDM 2AH (POR=0110_0000, WDT Out=0110_0000) // ADC控制寄存器0，选择ADC时钟
                                                                	
			MOV	A, 07CH					; set ADCR1 = 0111_1100 = 07Ch
			MOV	ADCR1, A				; ADCR1 @SPDM 2BH (POR=-000_0000, WDT Out=-000_0000) // ADC控制寄存器1，选择参考电压和模拟通道
                                                                	
;-----------------------EEPROM setting---------------------     	
			; EEA                                   	
			; EED                                   	
			; EEC                                   	
                                                                	
;-----------------------LVDC setting---------------------       	
			; LVDC                                  	
                                                                	
;----------------------Time Base setting------------------- // 时基设置
			MOV	A, 001					;; PSCR = 0000_0001=01h
			MOV	PSCR,	A				;; 00h=> Fsys, 01h=>Fsys/4, 11h=>Fsub // 预分频器控制寄存器，设置时基时钟源
			                                        	
			MOV	A, 006					;; TBC0 = 0000_0110=06h
			MOV	TBC0, A					;; 110=>16384/Ftb // 时基控制寄存器0，设置中断周期
			                                        	
			MOV	A, 007					;; TBC1 = 0000_0111=07h
			MOV	TBC1, A					;; 111=>32768/Ftb // 时基控制寄存器1
                                                                	
;-----------------------Parameter Setting------------------- // 软件参数初始化
			SET	fg_BaseTimeCTM                  	; // 设置CTM定时器基准时间标志
			CLR	fg_MutipleTimeHflagCTM          	; // 清除CTM长延时标志
			CLR	a_MutipleTimeHCTM               	; // 清除CTM长延时计数器高位
			CLR	a_MutipleTimeLCTM               	; // 清除CTM长延时计数器低位
			SET	fg_BaseTimeSTM                  	; // 设置STM定时器基准时间标志
			CLR	fg_MutipleTimeHflagSTM          	; // 清除STM长延时标志
			CLR	a_MutipleTimeHSTM               	; // 清除STM长延时计数器高位
			CLR	a_MutipleTimeLSTM               	; // 清除STM长延时计数器低位
			SET	fg_FlagDemo				; Demodulation IP with bug // 设置解调标志（注释提到IP有bug）
			SET	fg_INT1                         	; // 初始化外部中断1标志
			SET	fg_INT0                         	; // 初始化外部中断0标志
			CLR	a_DataOUTtemp                   	; // 清除数据输出临时变量
			SET	fg_DUDataStart                  	; // 设置数据单元开始标志
			SET	fg_DU                           	; // 设置数据单元标志
			SET	fg_StartBit                     	; // 初始化为等待起始位状态
			CLR	fg_ParityBit                    	; // 清除奇偶校验位标志
			CLR	fg_ParityErr                    	; // 清除奇偶校验错误标志
			MOV	A, 00AH					;00AH(Start-bit, b0~b7, Parity-bit)
			MOV	a_DataCNT, A                    	; // 设置数据位计数器为10（1起始+8数据+1奇偶）
			CLR	a_DataParityCNT                 	; // 清除用于计算奇偶性的计数器
			SET	fg_StopBit                      	; // 初始化为等待停止位状态
			MOV	A, 00BH                         	
			MOV	a_TimeOutCNT, A				; 09H for the front of Stop-bit // 设置超时计数器
			CALL	DemoCLR	                        	; // 调用一个函数来清除解调相关的变量
			SET	fg_WaitDataOut                  	; // 设置等待数据输出标志
			SET	fg_StopBitPre                   	; // 设置前一个停止位标志
			SET	fg_DataFirst                    	; // 设置首次数据标志
			SET	fg_Preamble                     	; // 初始化为等待前导码状态
			MOV	A, 007H                         	
			MOV	a_Preamble4BitCNT, A            	; // 设置前导码计数器
			MOV	A, 002H                         	
			MOV	a_NoToggleCNT, A                	; // 设置无翻转超时计数器
			CLR	fg_ChecksumBit                  	; // 清除校验和位标志
			CLR	a_DataByteCNT                   	; // 清除数据字节计数器
			CLR	a_DataByteCNTtemp               	; // 清除数据字节计数器临时变量
			CLR	a_AddrDataOUT                   	; // 清除数据输出地址指针
			CLR	fg_DataByteCNTFull              	; // 清除数据字节接收满标志
			CLR	a_HeadMessageCNT                	; // 清除包头/消息计数器
			MOV	A, 080H                         	
			MOV	a_ContlDataMessag, A            	; // 初始化控制数据消息变量
			CLR	a_DataHeader                    	; // 清除数据包头缓冲区
			CLR	a_DataMessageB0                 	; // 清除消息数据字节0缓冲区
			CLR	a_DataMessageB1                 	; // ...
			CLR	a_DataMessageB2                 	
			CLR	a_DataMessageB3                 	
			CLR	a_DataMessageB4                 	
			CLR	a_DataMessageB5                 	
			CLR	a_DataMessageB6                 	
			CLR	a_DataMessageB7                 	; // 清除消息数据字节7缓冲区
			CLR	a_DataChecksum                  	; // 清除接收到的校验和
			CLR	a_XORchecksum                   	; // 清除计算出的校验和
			SET	fg_PacDataOK                    	; // 设置数据包OK标志（初始为OK）
			SET	fg_StartReci                    	; // 设置开始接收标志
			MOV	A, 01DH                         	
			MOV	a_Preamble25BitCNT, A			; preamble maximmn 25-bit[(25*2)-(4*2-1)=43=2BH]; 43-14=29=1Dh // 设置前导码最大位数的超时计数器
			SET	fg_TimeOut ; // 设置超时标志
			CLR	a_SSP0x01_B0 ; // 清除信号强度包(0x01)缓冲区
			CLR	a_CSP0x05_B0 ; // 清除能力包(0x05)缓冲区
			CLR	a_IP0x71_B0 ; // 清除身份包(0x71)缓冲区
			CLR	a_IP0x71_B1
			CLR	a_IP0x71_B2
			CLR	a_IP0x71_B3
			CLR	a_IP0x71_B4
			CLR	a_IP0x71_B5
			CLR	a_IP0x71_B6
			CLR	a_ExIP0x81_B0 ; // 清除扩展身份包(0x81)缓冲区
			CLR	a_ExIP0x81_B1
			CLR	a_ExIP0x81_B2
			CLR	a_ExIP0x81_B3
			CLR	a_ExIP0x81_B4
			CLR	a_ExIP0x81_B5
			CLR	a_ExIP0x81_B6
			CLR	a_ExIP0x81_B7
			CLR	a_Config0x51_B0 ; // 清除配置包(0x51)缓冲区
			CLR	a_Config0x51_B2
			CLR	a_Config0x51_B3
			CLR	fg_Idet ; // 清除身份认证完成标志
			CLR	fg_ExIdet0x81 ; // 清除扩展身份认证完成标志
			CLR	fg_0x51PowClass ; // 清除功率等级标志
			CLR	fg_PCH0x06Abnor ; // 清除功率控制保持异常标志
			CLR	fg_0x02PowDownChargeComplete ; // 清除结束充电（完成）标志
			CLR	fg_0x02PowDownReconfigure ; // 清除结束充电（重新配置）标志
			CLR	fg_0x02PowDownNoResponse ; // 清除结束充电（无响应）标志
			SET	a_StatusEndPower ; // 初始化结束充电状态
			CLR	a_OptConfiCNT ; // 清除可选配置计数
			SET	fg_Tdelay ; // 设置延时标志
			MOV	A, 005H
			MOV	a_PCHO0x06_B0, A ; // 初始化功率控制保持包(0x06)的值
			CLR	a_0x03ContlErr ; // 清除控制错误(0x03)的值
			CLR	a_0x04ReceivedPow ; // 清除接收功率(0x04)的值
			CLR	a_0x04ReceivedPowPre ; // 清除上一次接收功率的值
			CLR	a_0x06TdelayML ; // 清除延时值低位
			CLR	a_0x06TdelayMH ; // 清除延时值高位
			CLR	a_0x51PowMax ; // 清除最大功率值
			CLR	fg_0x51NonPID ; // 清除非PID模式标志
			CLR	fg_0x04OutReceiPowTime ; // 清除接收功率超时标志
			CLR	fg_EndPowDown ; // 清除结束充电标志
			CLR	fg_CEinput ; // 清除控制错误(CE)输入标志
			CLR	fg_ReCordTemp ; // 清除记录温度标志
			CLR	fg_CalTempTimeHigh ; // 清除计算温度时间过长标志
			CLR	fg_PowOver5wLEDsw ; // 清除功率超过5W的LED切换标志
			CLR	fg_RecodeRPpre ; // 清除记录上一次RP包的标志
			CLR	fg_RPNoStable ; // 清除接收功率不稳定标志
			SET	fg_INT_AD ; // 设置ADC中断标志
			CLR	a_ADRHbuffer ; // 清除ADC结果高位缓冲区
			CLR	a_ADRLbuffer ; // 清除ADC结果低位缓冲区
		SkipStart:
			SZ	fg_NoChange ; // 检查fg_NoChange标志是否为0，为0则跳过
			JMP	SkipEnd
			MOV	A, 008H
			MOV	a_r_DetectCNT, A ; // 重置检测计数
			CLR	fg_RXCoilD ; // 清除D型线圈标志
		SkipEnd:
			CALL	CLRMath ; // 调用函数清除数学运算相关变量
			CLR	a_temp2
			CLR	a_temp1
			CLR	a_temp0
			SET	fg_PIDIni ; // 设置PID初始化标志
			CLR	a_IL ; // 清除PID积分项相关变量
			CLR	a_IM0
			CLR	a_IM1
			CLR	a_VL ; // 清除PID比例项相关变量
			CLR	a_VM0
			CLR	a_VM1
			CLR	a_EL ; // 清除PID误差项相关变量
			CLR	a_EM
			CLR	a_EH
			MOV	A, c_IniSv161_180N0
			MOV	a_Sv, A ; // 初始化PID控制变量Sv
			CLR	fg_start ; // 清除启动标志
			CLR	fg_IterationStart ; // 清除迭代开始标志
			MOV	A, 009H
			MOV	a_LoopIteration, A ; // 设置循环迭代次数
			MOV	A, c_IniReceiPowCNTL
			MOV	a_0x04ReceiPowCNTL, A ; // 初始化接收功率计数器低位
			MOV	A, c_IniReceiPowCNTH
			MOV	a_0x04ReceiPowCNTH, A ; // 初始化接收功率计数器高位
			SZ	a_0x04ReceiPowCNTH ; // 检查高位是否为0
			SET	fg_0x04ReceiPowCNTHflag
			
			CLR	fg_0x04ReceiPowCNTHflag ; // 清除接收功率计数器高位标志
			CLR	fg_adc_avg_cnt ; // 清除ADC平均计数标志
			CLR	a_ParPLLFHpre ; // 清除上一次的PLL频率高位
			CLR	a_ParPLLFLpre ; // 清除上一次的PLL频率低位
			CLR	fg_FODTemp60 ; // 清除异物检测(FOD)温度60度标志
			CLR	fg_IsenSmall ; // 清除电流过小标志
			CLR	fg_IsenBig ; // 清除电流过大标志
			CLR	fg_WaitNextCE ; // 清除等待下一个控制错误(CE)包的标志
			CLR	fg_CEThr ; // 清除CE阈值标志
			CLR	fg_CEThrPana ; // ...
			CLR	fg_PLLThr ; // 清除PLL阈值标志
			CLR	fg_IsenFirst ; // 清除首次电流检测标志
			CLR	fg_PLLDown ; // 清除PLL频率降低标志
			CLR	fg_PLLPana
			CLR	fg_DetectVin ; // 清除检测到Vin标志
			CLR	fg_VinLow ; // 清除Vin过低标志
			CLR	fg_PSVin ; // 清除选择阶段Vin正常标志
			CLR	fg_PLL205 ; // 清除PLL频率205k标志
			CLR	fg_DTCPR ; // 清除占空比相关标志
			CLR	fg_DTCPRmin
			SET	fg_Ping ; // 设置当前处于Ping阶段的标志
			CLR	fg_FODEfficLow ; // 清除FOD效率过低标志
			MOV	A, 00AH
			MOV	a_r_RPowCNT, A ; // 初始化接收功率计数
			CLR	fg_DemoDetect ; // 清除解调检测标志
			CLR	fg_DemoDetectTimeOut ; // 清除解调检测超时标志
			CLR	fg_RxTI ; // 清除接收到TI设备的标志
			CLR	fg_RxPana ; // 清除接收到松下设备的标志
;-----------------------INT setting------------------------ // 中断设置
	TestRepeat:
			;MOV	A, 00CH				; set INTEG = 0000_1100 = 0Ch
			;MOV	A, 000H
			;MOV	INTEG, A			; INTEG @SPDM 30H (POR=----_0000, WDT Out=----_0000) // 中断边沿控制寄存器
			MOV	A, 002H				; set INTC0 = 0000_0010 = 02h, as OCPE
			MOV	INTC0, A			; INTC0 @SPDM 10H (POR=-000_0000, WDT Out=-000_0000) // 中断控制寄存器0，使能过流保护中断(OCPE)

			MOV	A, 00BH				; set INTC1 = 0000_1011 = 02h, as ADE, MF1E, MF0E ON(TM0/STM and TM1/CTM enable INT)
			MOV	INTC1, A			; INTC1 @SPDM 31H (POR=0000_0000, WDT Out=0000_0000) // 中断控制寄存器1，使能ADC、多功能中断0和1

			;MOV	A, 008H				; set INTC2 = 0000_1000 = 08h, as INT1E ON
			;MOV	INTC2, A			; INTC2 @SPDM 32H (POR=0000_0000, WDT Out=0000_0000) // 中断控制寄存器2，使能外部中断1

			MOV	A, 002H				; set MFI0 = 0000_0010 = 02h, as T0AE ON
			MOV	MFI0, A				; MFI0 @SPDM 33H (POR=--00_--00, WDT Out=--00_--00) // 多功能中断源寄存器0，使能TM0周期匹配中断

			MOV	A, 002H				; set MFI1 = 0000_0010 = 02h, as T1AE ON
			MOV	MFI1, A				; MFI1 @SPDM 34H (POR=--00_--00, WDT Out=--00_--00) // 多功能中断源寄存器1，使能TM1周期匹配中断

;========================================================
;Function : Main Function Program // 函数: 主程序
;Note     : 
;========================================================
;--------------------Qi Selection Phase---------------------- // Qi 选择阶段
	Phase_Selection:
			CLR 	WDT ; // 清看门狗
	PS_VCOstart:
			SET	CKGEN.7					; 1 as VCO ON // 打开VCO(压控振荡器)，开始驱动线圈
	PS_EMIstart:
			CLR	INTC0.5 ; // 清除解调中断使能
			CLR	INTC2.7 ; // 清除外部中断1使能
			SET	INTC0.1					; 1 as OCPE ON // 使能过流保护中断
			;SET	INTC0.2					; DEME-bit = 1 as Demodulation ON
			SET	INTC0.0					; 1 as EMI ON // 打开总中断使能(EMI)
	PS_WaitVCO_DTin:
			MOV	A, c_IniWVCOMutipleTimeL ; // 加载VCO稳定延时的低位字节
			MOV	a_MutipleTimeLCTM, A
			MOV	A, c_IniWVCOMutipleTimeH ; // 加载VCO稳定延时的高位字节
			MOV	a_MutipleTimeHCTM, A
			SZ	a_MutipleTimeHCTM
			SET	fg_MutipleTimeHflagCTM ; // 如果需要长延时，设置标志

	PS_WaitVCO_DTFunc:
			;Waiting for VCO Stable Time
			CALL	DelayTimer ; // 调用延时函数，等待VCO稳定
	PS_DetectVin:
			CALL	DetectVin ; // 调用函数检测输入电压
			SNZ	fg_DetectVin ; // 检查电压检测标志，如果不为0(表示电压OK)则跳过
			JMP	PS_Remind ; // 电压OK，跳转到提醒步骤

			CALL	LightDark ; // 电压异常，调用LED闪烁函数
			JMP	PS_DetectVin ; // 继续检测电压
	PS_Remind:
		        SET	fg_PSVin ; // 设置选择阶段电压正常的标志
	PS_Detection:
			CALL	ObjectDetection ; // 调用异物检测函数
	Phase_SelectionEnd:		
			MOV	A, c_IniCTMTimeBaseL1			; set TM1AL = 1111_1010 = FAh for 50us
			MOV	TM1AL, A				; TM1AL @SPDM 4DH (POR=0000_0000, WDT Out=0000_0000) // 重新设置定时器1的周期
 			MOV	A, c_IniCTMTimeBaseH1			; set TM1AH = 0000_0000 = 00h
			MOV	TM1AH, A				; TM1AH @SPDM 4EH (POR=----_--00, WDT Out=----_--00)
			MOV	A, 053H
			MOV	PWMC, A ; // 配置PWM控制寄存器，为下一阶段做准备
;----------------------Qi Ping Phase------------------------- // Qi Ping(探测)阶段
	Phase_Ping:		
	PP_Tping:			
			SET	fg_TimeOut
			MOV	A, c_IniDiPingMutipleTimeL		; Tping <= 70ms // 设置Tping超时时间(<= 70ms)，用于等待接收端响应
			MOV	a_MutipleTimeLSTM, A
			MOV	A, c_IniDiPingMutipleTimeH
			MOV	a_MutipleTimeHSTM, A
			SZ	a_MutipleTimeHSTM
			SET	fg_MutipleTimeHflagSTM

			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset // 重置并启动标准定时器TM0
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON
			CALL	DemoVI1I2swEN        ; // 使能解调器，准备接收数据
			CALL	ReciPackageDataUnitPreee1 ; // 尝试接收数据包（前导码部分）
			SNZ	fg_TimeOut ; // 检查是否超时
			JMP	Status_DetectNoise ; // 如果超时（未收到响应），则进入噪音检测状态并休眠

			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF // 关闭定时器
	PP_Tfirst:
			SET	fg_TimeOut
			MOV	A, c_IniPingTfirstMutipleTimeL		; Tfirst <= 20ms // 设置Tfirst超时时间(<= 20ms)，用于接收完整数据包
			MOV	a_MutipleTimeLSTM, A
			MOV	A, c_IniPingTfirstMutipleTimeH
			MOV	a_MutipleTimeHSTM, A
			SZ	a_MutipleTimeHSTM
			SET	fg_MutipleTimeHflagSTM
			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset // 再次启动定时器
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON
	PP_Tfirst1:
			CALL	ReciPackageDataUnit ; // 接收完整的数据包
			CALL	DemoVI1I2swDisEN ; // 关闭解调器
			SNZ	fg_TimeOut				; for PP timing // 检查是否超时
			JMP	Status_DetectNoise ; // 如果超时，则进入噪音检测状态
			
			SNZ	fg_ChecksumBit ; // 检查校验和是否出错
			JMP	Status_PowerDown ; // 如果出错，进入关机状态

			CALL	ExtractPacData ; // 提取接收到的数据包内容
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF // 关闭定时器
			SET	fg_TimeOut
	PP_ErrData:
			SZ	fg_PacDataOK ; // 检查数据包是否有效
			JMP	Status_PowerDown ; // 如果无效，进入关机状态

			SET	fg_PacDataOK
	PP_SignalStregth:		
			MOV	A, a_DataHeader ; // 获取包头
			XOR	A, 001H ; // 检查包头是否为0x01 (信号强度包)
			SNZ	STATUS.2 ; // 检查零标志位
			JMP	PP_EndPackage ; // 如果不是0x01，跳转到结束包处理

			MOV	A, a_DataMessageB0 ; // 是信号强度包，保存数据
			MOV	a_SSP0x01_B0, A
			JMP	Phase_IdentConfi ; // 跳转到身份识别与配置阶段
	PP_EndPackage:		
			MOV	A, a_DataHeader ; // 获取包头
			XOR	A, 002H ; // 检查包头是否为0x02 (结束充电包)
			SNZ	STATUS.2
			JMP	Status_PowerDown ; // 如果不是，关机
			
			CALL	EndPowCMD0x02Decode ; // 解码结束充电指令
			SZ	fg_EndPowDown				; for PP timing // 检查结束充电标志
			JMP	Status_PowerDown ; // 确认关机
		
;----------Qi Identification & Configuration Phase----------- // Qi 身份识别与配置阶段
	Phase_IdentConfi:
			CLR	fg_0x02PowDownReconfigure ; // 清除“因重新配置而关机”的标志
			CLR	fg_CEinput ; // 清除控制错误输入标志
	PIC_Tnext:
			CLR WDT
			SET	fg_TimeOut
			MOV	A, c_IniIdeConTnextMutipleTimeL		; Tnext <= 21ms // 设置Tnext超时(<= 21ms)，等待下一个数据包
			MOV	a_MutipleTimeLSTM, A
			MOV	A, c_IniIdeConTnextMutipleTimeH
			MOV	a_MutipleTimeHSTM, A
			SZ	a_MutipleTimeHSTM
			SET	fg_MutipleTimeHflagSTM

			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON
			CALL	DemoVI1I2swEN
			CALL	ReciPackageDataUnitPreee1 ; // 准备接收
			SNZ	fg_TimeOut
			JMP	Status_PowerDown ; // 超时则关机

			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
	PIC_Tmax:
			SET	fg_TimeOut
			MOV	A, c_IniIdeConTmaxMutipleTimeL		; Tmax <= 170ms // 设置Tmax超时(<= 170ms)，用于整个阶段的数据包接收
			MOV	a_MutipleTimeLSTM, A
			MOV	A, c_IniIdeConTmaxMutipleTimeH
			MOV	a_MutipleTimeHSTM, A
			SZ	a_MutipleTimeHSTM
			SET	fg_MutipleTimeHflagSTM

			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON
	PIC_Tmax1:
			CALL	ReciPackageDataUnit ; // 接收数据
			CALL	DemoVI1I2swDisEN
			SNZ	fg_TimeOut
			JMP	Status_PowerDown ; // 超时则关机

			SZ	fg_DataByteCNTFull ; // 检查数据字节是否接收完整
			JMP	PIC_Tmax2
			
			SNZ	fg_ChecksumBit
			JMP	Status_PowerDown ;;LAB test // 校验和错误则关机
	PIC_Tmax2:		
			CALL	ExtractPacData ; // 提取数据
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
			SET	fg_TimeOut
	PIC_ErrData:
			SZ	fg_DataByteCNTFull ; // 检查数据是否完整
			JMP	PIC_IdentPac0x71 ; // 如果不完整，也尝试解码（可能部分包有效）
			
			SZ	fg_PacDataOK ; // 检查数据包是否有效
			JMP	Status_PowerDown ; // 无效则关机
			;JMP	PIC_TmaxReCheck
			SET	fg_PacDataOK
			
	PIC_IdentPac0x71:                  ;// // 解码识别阶段的数据包
			CLR WDT
			CLR	fg_DataByteCNTFull
			SZ	fg_Idet ; // 检查是否已完成身份识别
			JMP	PIC_PowContlHoldOffPac0x06 ; // 如果已完成，则检查是否为其他包（如0x06）
			
			SZ	fg_ExIdet0x81 ; // 检查是否在等待扩展身份包
			JMP	PIC_ExIdentPac0x81 ; // 如果是，则跳转到扩展身份包处理

			MOV	A, a_DataHeader
			XOR	A, 071H ; // 检查是否为身份包(0x71)
			SNZ	STATUS.2
			JMP	Status_PowerDown ; // 不是则关机
		
			MOV	A, a_DataMessageB0 ; // 保存身份包数据
			MOV	a_IP0x71_B0, A
			MOV	A, a_DataMessageB1
			MOV	a_IP0x71_B1, A
			MOV	A, a_DataMessageB2
			MOV	a_IP0x71_B2, A
			SZ	a_IP0x71_B1 ; // 检查是否为TI或松下等特殊设备
			JMP	PIC_IdentPac0x71_TI

			XOR	A, 010H
			SZ	STATUS.2
			SET	fg_RxTI ; // 设置TI设备标志
		PIC_IdentPac0x71_TI:
			MOV	A, a_IP0x71_B1
			XOR	A, 034H
			SNZ	STATUS.2
			JMP	PIC_IdentPac0x71_Conti

			MOV	A, a_IP0x71_B2
			XOR	A, 033H
			SZ	STATUS.2
			SET	fg_RxPana ; // 设置松下设备标志
		PIC_IdentPac0x71_Conti:
			MOV	A, a_DataMessageB3
			MOV	a_IP0x71_B3, A
			MOV	A, a_DataMessageB4
			MOV	a_IP0x71_B4, A
			MOV	A, a_DataMessageB5
			MOV	a_IP0x71_B5, A
			MOV	A, a_DataMessageB6
			MOV	a_IP0x71_B6, A
			SNZ	a_IP0x71_B3.7 ; // 检查是否需要扩展身份包
			JMP	PIC_IdentPac0x71_1

			SET	fg_ExIdet0x81 ; // 如果需要，设置标志并等待下一个包
			JMP	PIC_Tnext
	PIC_IdentPac0x71_1:
			SET	fg_Idet ; // 身份识别完成
			JMP	PIC_Tnext ; // 等待下一个包（如配置包）
	PIC_ExIdentPac0x81:
			MOV	A, a_DataHeader
			XOR	A, 081H ; // 检查是否为扩展身份包(0x81)
			SNZ	STATUS.2
			JMP	Status_PowerDown
		
			MOV	A, a_DataMessageB0 ; // 保存扩展身份包数据
			MOV	a_ExIP0x81_B0, A
			MOV	A, a_DataMessageB1
			MOV	a_ExIP0x81_B1, A
			MOV	A, a_DataMessageB2
			MOV	a_ExIP0x81_B2, A
			MOV	A, a_DataMessageB3
			MOV	a_ExIP0x81_B3, A
			MOV	A, a_DataMessageB4
			MOV	a_ExIP0x81_B4, A
			MOV	A, a_DataMessageB5
			MOV	a_ExIP0x81_B5, A
			MOV	A, a_DataMessageB6
			MOV	a_ExIP0x81_B6, A
			MOV	A, a_DataMessageB7
			MOV	a_ExIP0x81_B7, A
			SET	fg_Idet ; // 身份识别完成
			CLR	fg_ExIdet0x81 ; // 清除等待扩展包的标志
			JMP	PIC_Tnext
	PIC_PowContlHoldOffPac0x06:
			MOV	A, a_DataHeader
			XOR	A, 071H ; // 检查是否为身份包，这里可能是个错误检查
			SZ	STATUS.2
			JMP	Status_PowerDown

			MOV	A, a_DataHeader
			XOR	A, 006H ; // 检查是否为功率控制保持包(0x06)
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac ; // 不是则检查是否为私有包
			
			INC	a_OptConfiCNT ; // 是0x06包，增加可选配置包计数
			MOV	A, a_DataMessageB0
			MOV	a_PCHO0x06_B0, A
			CLR	fg_Tdelay
			JMP	PIC_Tnext
	PIC_ProprietaryPac:                ;// // 处理一系列私有协议包
			MOV	A, a_DataHeader
			XOR	A, 018H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac1
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac1:
			MOV	A, a_DataHeader
			XOR	A, 019H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac2
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac2:
			MOV	A, a_DataHeader
			XOR	A, 028H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac3
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac3:
			MOV	A, a_DataHeader
			XOR	A, 029H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac4
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac4:
			MOV	A, a_DataHeader
			XOR	A, 038H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac5
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac5:
			MOV	A, a_DataHeader
			XOR	A, 048H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac6
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac6:
			CLR WDT
			MOV	A, a_DataHeader
			XOR	A, 058H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac7
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac7:
			MOV	A, a_DataHeader
			XOR	A, 068H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac8
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac8:
			MOV	A, a_DataHeader
			XOR	A, 078H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac9
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac9:
			MOV	A, a_DataHeader
			XOR	A, 084H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac10
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac10:
			MOV	A, a_DataHeader
			XOR	A, 0A4H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac11
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac11:
			MOV	A, a_DataHeader
			XOR	A, 0C4H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac12
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac12:
			MOV	A, a_DataHeader
			XOR	A, 0E2H
			SNZ	STATUS.2
			JMP	PIC_ProprietaryPac13
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ProprietaryPac13:
			MOV	A, a_DataHeader
			XOR	A, 0F2H
			SNZ	STATUS.2
			JMP	PIC_ReservPac
			
			INC	a_OptConfiCNT
			JMP	PIC_Tnext
	PIC_ReservPac:
			MOV	A, a_DataHeader
			XOR	A, 051H ; // 检查是否为配置包(0x51)
			SNZ	STATUS.2
			JMP	PIC_ReservPac0

			JMP	PIC_Config0x51 ; // 是，则跳转到配置包处理
	PIC_ReservPac0:
			INC	a_OptConfiCNT
			JMP	Status_PowerDown ; // 不是，关机
	PIC_Config0x51:
			CLR WDT
			MOV	A, a_DataMessageB0 ; // 保存配置包数据
			MOV	a_Config0x51_B0, A
			MOV	A, a_DataMessageB2
			MOV	a_Config0x51_B2, A
			MOV	A, a_DataMessageB3
			MOV	a_Config0x51_B3, A
			MOV	A, a_Config0x51_B2
			AND	A, 007H ; // 检查已接收的可选配置包数量是否正确
			XOR	A, a_OptConfiCNT
			SNZ	STATUS.2
			JMP	Status_PowerDown ; // 不正确则关机
		
			CLR	a_OptConfiCNT ; // 清除计数
			CALL	ConfigCMD0x51Decode ; // 解码配置指令
			SNZ	fg_Tdelay
			JMP	PIC_Config0x51_1
			
			MOV	A, 005H
			MOV	a_PCHO0x06_B0, A
	PIC_Config0x51_1:
			;CLR WDT
			SET	fg_Tdelay
			CALL	PowContlHoldCMD0x06Decode ; // 解码功率控制保持指令
			
			SZ	fg_PCH0x06Abnor ; // 检查是否有异常
			JMP	Status_PowerDown ; // 异常则关机
			
				
;------------------Qi Power Transfer Phase-------------------Power Transfer // Qi 功率传输阶段
	Phase_PowerTrans:
			CLR	fg_Ping ; // 清除Ping阶段标志
	PPT_Ttimeout0:
			SET	fg_TimeOut
			CALL	SetTimer1				; Ttimeout <= 1800ms // 设置长超时(1.8s)，如果在功率传输阶段长时间没收到包，则关机
			SET	TM0C0.3																; TM0C0[3] (T0ON-bit) = 1 as TM0 ON;????????check
			CALL	DemoVI1I2swEN
			CALL	ReciPackageDataUnitPreee1        
			SNZ	fg_TimeOut
			JMP	Status_PowerDown

			CLR	TM0C0.3																; 1 as TM0 ON;(2014/05/15)
			SET	fg_TimeOut
			CALL	SetTimer1				; Ttimeout <= 1800ms
			SET	TM0C0.3																; TM0C0[3] (T0ON-bit) = 1 as TM0 ON;????????check
			CALL	ReciPackageDataUnit
			CALL	DemoVI1I2swDisEN
			SNZ	fg_ChecksumBit ; // 检查校验和
			JMP	PPT_Recheck ; // 出错则重试
			
			CALL	ExtractPacData
	PPT_ErrDataCheck0:
			SZ	fg_PacDataOK ; // 检查数据有效性
			JMP	PPT_Recheck ; // 无效则重试

			SET	fg_PacDataOK
			CLR	TM0C0.3															; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
			SET	fg_TimeOut
	PPT_Command:				
			CALL	PT_DecodeCommand ; // 解码收到的指令(如控制错误、接收功率、结束充电等)
			SZ	fg_0x02PowDownReconfigure ; // 检查是否是重新配置请求
			JMP	Phase_IdentConfi ; // 是则返回配置阶段

			SZ	fg_EndPowDown ; // 检查是否是结束充电指令
			JMP	Status_PowerDown ; // 是则关机
	PPT_Recheck:
			SZ	fg_CEinput ; // 检查是否收到控制错误包
			CALL	PT_ReceiPowerCNT ; // 如果不是，则可能是接收功率包，进行计数

			MOV	A, 00AH
			MOV	a_ExIP0x81_B0, A
			CLR	PB.2					;Green LED // 熄灭绿灯
			SET	PB.3					;Red LED // 点亮红灯（表示充电中）
	PPT_Nor:																			;----------?????????check // 功率传输主循环
			CLR WDT
			SNZ	fg_CEinput				; To check first data for CE or RP // 检查是否有CE包输入
			JMP	PPT_NextPac ; // 没有则等待下一个包
			SET	fg_TimeOut

			MOV	A, a_0x06TdelayML			; 5ms <= Tdelay <= 205ms // 根据接收端请求设置延时
			MOV	a_MutipleTimeLCTM, A
			MOV	A, a_0x06TdelayMH
			MOV	a_MutipleTimeHCTM, A
			SZ	a_MutipleTimeHCTM
			SET	fg_MutipleTimeHflagCTM
	PPT_Tdelay:
			CALL	DelayTimer ; // 执行延时
	PPT_CellCurrJ:		
			CALL	PID_SenPriCoilCurrWay65Double ; // 采样主线圈电流
	PPT_Tactive:
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
			SET	fg_TimeOut
			MOV	A, c_IniPowTrTactMutipleTimeL		; Tactive <= 21ms // 设置一个短暂的活动时间
			MOV	a_MutipleTimeLSTM, A
			MOV	A, c_IniPowTrTactMutipleTimeH
			MOV	a_MutipleTimeHSTM, A
			SZ	a_MutipleTimeHSTM
			SET	fg_MutipleTimeHflagSTM

			SET	fg_BaseTimeSTM				; TM0(STM) basetime flag reset
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON
			
			;---PID Algorithm & Fpwm Output--- // PID算法与PWM输出
			SZ	fg_0x51NonPID ; // 检查是否为非PID模式
			JMP	PPT_TactiveNoPID

			;JMP	PPT_TactivePID
		PPT_TactivePID:
			CALL	PT_PIDCE4 ; // 执行PID计算
		PPT_TactivePID1:
;			;;~~~FOD Temperture Check~~~ // FOD温度检查
			SZ	fg_PLLDown
			JMP	PPT_TactiveCheck

			SZ	fg_PLLPana
			JMP	PPT_TactiveCheck
			
			SZ	a_0x03ContlErr ; // 检查控制错误值
			JMP	PPT_TactivePID_Cal ; // 如果有错误，进行PID计算
			
			;; CNT=2, 5
			SDZ	a_ExIP0x81_B0
			JMP	PPT_TactiveCheck

			SET	fg_PLLDown
			SZ	fg_CEThrPana
			SET	fg_PLLPana

			MOV	A, 00AH
			MOV	a_ExIP0x81_B0, A
			JMP	PPT_TactiveCheck
		PPT_TactivePID_Cal:	
			SZ	fg_VinLow ; // 检查输入电压是否过低
			JMP	PPT_TactiveCheck

			;JMP	PPT_TactivePID_Cal0
		PPT_TactivePID_Cal0:
			CALL	PT_PIDandPWM ; // 根据PID结果调整PWM输出
			JMP	PPT_TactiveCheck
		PPT_TactiveNoPID:
			JMP	Status_PowerDown
		PPT_TactiveCheck:	
			CLR WDT
			SNZ	fg_TimeOut ; // 检查活动时间是否结束
			JMP	Status_PowerDown ; // 结束则关机（逻辑可能异常）
	PPT_Tsettle:
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF (STM)
			MOV	A, c_IniPowTrTsettleMutipleTimeL	; Tsettle min = 3ms // 设置一个稳定时间
			MOV	a_MutipleTimeLCTM, A
			MOV	A, c_IniPowTrTsettleMutipleTimeH
			MOV	a_MutipleTimeHCTM, A
			SZ	a_MutipleTimeHCTM
			SET	fg_MutipleTimeHflagCTM

			CALL	DelayTimer ; // 执行延时
	PPT_NextPac:
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF (STM)
			SET	fg_TimeOut
			CALL	SetTimer2 ; // 设置接收下一个数据包的超时
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON (STM)
			SET	fg_DemoDetect
	PPT_NextPac1:
			CLR	WDT
			SZ	fg_CEinput
			CALL	PT_ReceiPowerCNT
	PPT_DetectVin:
			CALL	DetectVin ; // 循环中持续检测输入电压
	;;~~~Enable INT for Demodulation SW ~~~			
	PPT_DemoVI1I2sw3:
			CLR 	WDT			
			CALL	DemoVI1I2swEN ; // 使能解调
			CALL	ReciPackageDataUnitPreee1 ; // 准备接收
			SZ	fg_DemoDetectTimeOut
			JMP	PPT_DemoVI1I2sw4

			SNZ	fg_TimeOut ; // 检查是否超时
			JMP	Status_PowerDown

			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
			SET	fg_TimeOut
			CALL	SetTimer2
			SET	TM0C0.3					; TM0C0[3] (T0ON-bit) = 1 as TM0 ON;
			CALL	ReciPackageDataUnit ; // 接收数据
	;;~~~disenable INT for Demodulation SW ~~~			
	PPT_DemoVI1I2sw4:
			CALL	DemoVI1I2swDisEN ; // 关闭解调
			SZ	fg_DemoDetectTimeOut
			JMP	PPT_DemoVI1I2Select2

			SNZ	fg_TimeOut
			JMP	Status_PowerDown

			CALL	ExtractPacData
	PPT_ErrDataCheck2:
			SZ	fg_DataByteCNTFull
			JMP	PPT_ErrDataCheck3
			
			SZ	fg_PacDataOK
			JMP	PPT_DemoVI1I2Select2_1
			
			SET	fg_PacDataOK
	PPT_ErrDataCheck3:
			CLR	fg_DataByteCNTFull
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
			SET	fg_TimeOut
			JMP	PPT_Command2
				
	;;~~~Demodulation SW~~~ // 解调软件逻辑
	PPT_DemoVI1I2Select2:
			CLR	fg_DemoDetectTimeOut
			CALL	DemoVI1I2Select ; // 切换解调方式
			JMP	PPT_DemoVI1I2sw3 ; // 重新尝试接收
	
	PPT_DemoVI1I2Select2_1:
			CALL	DemoVI1I2Select
			JMP	PPT_NextPac
				
	PPT_Command2:
			CALL	PT_DecodeCommand ; // 解码收到的指令
			CLR	fg_DemoDetectTimeOut
			SNZ	fg_0x02PowDownReconfigure
			JMP	PPT_Command21

			SNZ	fg_VinLow ; // 检查电压是否过低
			JMP	Phase_IdentConfi ; // 如果是重新配置请求，则返回配置阶段

			JMP	Status_PowerDown
	PPT_Command21:
			SZ	fg_FODTemp60					; Temp 60 Check // 检查FOD温度是否超标
			JMP	Status_PowerDown

			SZ	fg_EndPowDown
			JMP	Status_PowerDown
			
			SZ	fg_FODEfficLow			
			JMP	Status_PowerDown
	Phase_PowerTransEnd:		
			JMP	PPT_Nor ; // 结束一轮循环，返回功率传输循环的开始


;---------------------Qi Power Down Status-------------------Go Back to Selection and Power OFF // Qi 关机状态
	Status_DetectNoise:
			CLR WDT
			CALL	Delay1
			MOV	A, 050H
			MOV	PWMC, A ; // 关闭PWM
			CLR	INTC0.2					; DEME-bit = 0 as Demodulation OFF // 关闭解调
			CLR	DEMC0					; Demodulation OFF
			CLR	INTC0.5
			MOV	A, 008H
			MOV	a_r_DetectCNT, A
			CLR	CKGEN.7					; 1 as VCO OFF // 关闭VCO
			CLR	INTC0.0					; 0 as EMI OFF // 关闭总中断
			HALT ; // 进入休眠模式
	Status_PowerDown:
			SET	PA.5
			MOV	A, 03EH
			MOV	PLLFL, A
			MOV	A, 003H
			MOV	PLLFH, A
			MOV	A, c_IniPIDMutilpleTimeL
			MOV	a_MutipleTimeLCTM, A
			MOV	A, c_IniPIDMutilpleTimeH
			MOV	a_MutipleTimeHCTM, A
			SZ	a_MutipleTimeHCTM
			SET	fg_MutipleTimeHflagCTM

			CALL	DelayTimer
			CLR WDT
			MOV	A, 050H					;  PWM output OFF // 关闭PWM输出
			MOV	PWMC, A
			CLR	INTC0.2					; DEME-bit = 0 as Demodulation OFF // 关闭解调
			CLR	DEMC0					; Demodulation OFF
			CLR	INTC0.5
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF // 关闭定时器
			SET	fg_TimeOut
			CALL	Delay1
			SZ	fg_0x02PowDownChargeComplete ; // 检查关机原因：是否是充电完成
			JMP	PD_AbnormalLight
			
			SZ	fg_0x02PowDownNoResponse ; // 是否是无响应
			JMP	PD_AbnormalLight
			
			SZ	fg_0x02PowDownReconfigure ; // 是否是重新配置
			JMP	PD_AbnormalLight
			
			SZ	fg_FODTemp60 ; // 是否是FOD温度过高
			JMP   	PD_AbnormalLight
			
			SZ	fg_FODEfficLow ; // 是否是FOD效率过低
			JMP	PD_AbnormalLight	

			JMP	PD_PWMDown ; // 正常关机
	PD_AbnormalLight:
			SZ	fg_0x02PowDownReconfigure
			JMP	PD_PowerDownEnd
						
			SZ	fg_0x02PowDownNoResponse
			JMP	PD_PowerDownEnd
			
			CALL	LightDark			; // 调用LED闪烁函数以提示异常
			JMP	PD_PowerDownEnd
	PD_PWMDown:
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF
			SET	fg_TimeOut
	PD_LightWarningEnd:
			CLR WDT
			CLR	PB.3					;; Red LED // 熄灭红灯
			SET	PB.2					;; Green LED // 点亮绿灯（表示待机）
			CALL	Delay3
			CALL	Delay3
			SZ	fg_Ping
			JMP	PP_Repeat	
	PD_PowerDownEnd:
			CLR WDT
			CLR	PB.3					;; Red LED
			SET	PB.2					;; Green LED

			;;Detect Object to leave // 检测物体是否已移开
			SZ	fg_0x02PowDownChargeComplete
			CALL	ObjectDetectLeave
			
			SZ	fg_0x02PowDownReconfigure
			CALL	ObjectDetectLeave
			
			SZ	fg_0x02PowDownNoResponse
			CALL	ObjectDetectLeave

			CLR	CKGEN					; 0 as VCO OFF // 关闭VCO
			CLR	INTC0.0					; 0 as EMI OFF // 关闭总中断
			MOV	A, 007H
			MOV	WDTC, A ; // 配置看门狗
	PP_Repeat:
			MOV	A, 008H
			MOV	a_r_DetectCNT, A
			CALL	DemoVI1I2Select
			SET	INTC0.5
			CLR	CKGEN.7					; 1 as VCO OFF
			CLR	INTC0.0					; 0 as EMI OFF
			HALT ; // 进入休眠，等待下一次唤醒

;========================================================
;Function : LightDark // 函数: LED闪烁
;Note     : Call Function Type for Light dark
;		input = No Need

;		output = No Need
;Presetting:
;		(1) Setting WDTC reg. for Period Timing
;		(2) Setting c_IniDetectMutipleTimeH/L
;		(3) Setting OCP INT ON/OFF
;========================================================
	LightDark:
			MOV	A, 005H;;003h ; // 设置闪烁次数
			MOV	a_com1, A
	PS_LightDarkRepeat:		
			CLR	WDT    
			SZ	fg_0x02PowDownChargeComplete ; // 检查是否是充电完成
			JMP	LightDarkGreen0 ; // 是则只闪绿灯
	LightDarkBoth0:
			CLR	PB.3					;;Red LED // 熄灭红灯
			CLR	PB.2					;;Green LED // 熄灭绿灯
			JMP	LightDarkend0
	LightDarkGreen0:
			CLR	PB.2					;;Green LED
		;	CLR	PB.3					;;Red LED
	LightDarkend0:
			CALL	Delay3 ; // 延时
			SZ	fg_0x02PowDownChargeComplete
			JMP	LightDarkGreen1
	LightDarkBoth1:
			SET	PB.3					;;Red LED // 点亮红灯
			SET	PB.2					;;Green LED // 点亮绿灯
			JMP	LightDarkend1
	LightDarkGreen1:
			SET	PB.2					;;Green LED
	LightDarkend1:
			CALL	Delay3
			
			SDZ	a_com1 ; // 闪烁次数减1
			JMP	PS_LightDarkRepeat ; // 循环
			
			CLR	a_com1
			RET


;========================================================
;Function : ISR // 函数: 中断服务程序
;Note     : 
;========================================================
	;---------------------OCP---------------------
	ISR_OCP:
			MOV	A, 050H
			MOV	PWMC, A ; // 发生过流，立即关闭PWM
			NOP
			RETI
			
	;-----------Demodulation Interrupt------------
	ISR_DeMod:
			CLR WDT
			CLR	fg_FlagDemo
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF // 收到解调信号，关闭定时器
			RETI
			
	;------------External Interrupt 0-------------
	ISR_ExInt0:
			CLR	fg_INT0
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF
			CLR 	WDT
			RETI
				
	;--------MultiFunction0 Interrupt for TM0(STM)------
	ISR_MultiFun_TM0:
			CLR	MFI0.5					; MFI0[5] (T0AF-bit) = 0 as clear A match interrupt request flag // 清除中断标志
			CLR	fg_BaseTimeSTM				; TM0(STM) basetime flag reset
			CLR	TM0C0.3					; TM0C0[3] (T0ON-bit) = 0 as TM0 OFF // 关闭定时器
			CALL	TimeOutTimer ; // 调用超时处理函数
			SNZ	fg_0x04OutReceiPowTime
			RETI
		
			CLR	fg_TimeOut ; // 清除超时标志
			RETI

	
	;--------MultiFunction1 Interrupt for TM1(CTM)------
	ISR_MultiFun_TM1:
			CLR	MFI1.5					; MFI1[5] (T1AF-bit) = 0 as clear A match interrupt request flag
			CLR	fg_BaseTimeCTM				; TM1(CTM) basetime flag reset
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF
			CLR 	WDT
			RETI
	
	;---MultiFunction2 Interrupt for LVD / EEPROM---
	ISR_MultiFun_LVD_EEP:
			RETI
	
	;------------------ADC Interrupt----------------
	ISR_ADC:
			CLR	fg_INT_AD ; // 清除ADC中断标志
			CLR 	WDT
			RETI
				
	;------------------IIC Interrupt----------------
	ISR_IIC:
			RETI
				
	;--------------Time Base 0 Interrupt------------
	ISR_TimeBase0:
			CLR	TBC0.7					;; Time Base0 OFF
			RETI
				
	;--------------Time Base 1 Interrupt------------
	ISR_TimeBase1:
			RETI
				
	;--------------External Interrupt 1-------------
	ISR_ExInt1:
			CLR	fg_INT1
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF
			CLR 	WDT
			RETI


end
