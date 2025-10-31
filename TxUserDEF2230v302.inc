;*******************************************************************************************
;*****	                    Customized Parameters Define                               *****
;*******************************************************************************************
; // 这是一个自定义参数定义文件，用于配置无线充电发射器的各种阈值和参数。

;;==========================================================================================
;;Function :  Detect Vin for Min Threshold Claim
;;Note     : 
;;==========================================================================================
;;-----------To detect Vin of USB Power in Initialization
; // --- 初始化阶段 (上电后，开始Ping之前) 的输入电压 (Vin) 检测阈值 ---
#DEFINE	c_IniVinMinL				00FH	; // 初始化时, Vin 最小阈值低位
#DEFINE	c_IniVinMinH				00BH	; // 初始化时, Vin 最小阈值高位 (0B0Fh)
; @5v,VREF=2.08v, DetectVin=B0Fh = 4.5v*(47k/(100k+47K))=1.438v, ADC=FFFh*1.438/2.08v=B0Fh
; // 注释解释：上面的 0B0Fh 对应 4.5V 的输入电压。计算基于一个分压电路 (R1=100k, R2=47k) 和 2.08V 的 ADC 参考电压。
; // (4.5V * 47k / (100k + 47k)) / 2.08V * 4095 = 2831 (十进制) = 0B0Fh (十六进制)
                                        	
#DEFINE	c_IniVinMaxL				075H	; // 初始化时, Vin 最大阈值低位
#DEFINE	c_IniVinMaxH				00DH	; // 初始化时, Vin 最大阈值高位 (0D75h)
; @5v,VREF=2.08v, DetectVin=D75h = 5.5v*(47k/(100k+47K))=1.75v, ADC=FFFh*1.75/2.08v=D75h
; // 注释解释：0D75h 对应 5.5V 的输入电压。
																				
;;-----------To Detect Vin of USB Power in Power Transfer Phase
; // --- 功率传输阶段的输入电压检测阈值 ---
#DEFINE	c_IniPTVinMinL				013H	; // 功率传输时, Vin 最小阈值低位 (用于判断是否出错)
#DEFINE	c_IniPTVinMinH				00AH	; // 功率传输时, Vin 最小阈值高位 (0A13h)
; @5v,VREF=2.08v, DetectVin=A13h = 4.1v*(47k/(100k+47K))=1.31v, ADC=FFFh*1.31/2.08v=A13h
; // 注释解释：0A13h 对应 4.1V 的输入电压。
                                        	
#DEFINE	c_IniPTVinLowL				0B0H	; // 功率传输时, Vin "过低" (Warning) 阈值低位
#DEFINE	c_IniPTVinLowH				00BH	; // 功率传输时, Vin "过低" 阈值高位 (0BB0h)
; @5v,VREF=2.08v, DetectVin=BB0h = 4.75v*(47k/(100k+47K))=1.52v, ADC=FFFh*1.52/2.08v=BB0h
; // 注释解释：0BB0h 对应 4.75V 的输入电压。用于设置 fg_VinLow 标志。


;;==========================================================================================
;;Function :  Temperture Deviation Claim
;;Note     : 
;; [Note] Temperture Sensor 10k@25, 3k@60, 1.6k@80, 188k@-40
;;	      HW Temperture = Temperture 10k@25 + 1k(+-1%) in 5V
;;	      ADC IVref=2.08v
;; [Note] Vtemp = 1.92v = 1k / ( 1k +   1.6k) x 5v @+80
;; [Note] Vtemp = 1.25v = 1k / ( 1k +   3.0k) x 5v @+60
;; [Note] Vtemp = 0.45v = 1k / ( 1k +  10.0k) x 5v @+25
;; [Note] Vtemp = 0.03v = 1k / ( 1k + 188.0k) x 5v @-40
;;            
;; [Note] Vtemp = 1.84v = 1k / ( 1k +   1.6k) x 4.8v @+80
;; [Note] Vtemp = 1.20v = 1k / ( 1k +   3.0k) x 4.8v @+60
;; [Note] Vtemp = 0.43v = 1k / ( 1k +  10.0k) x 4.8v @+25
;; [Note] Vtemp = 0.03v = 1k / ( 1k + 188.0k) x 4.8v @-40
;;  	      
;; [Note] Vtemp = 1.73v = 1k / ( 1k +   1.6k) x 4.5v @+80
;; [Note] Vtemp = 1.13v = 1k / ( 1k +   3.0k) x 4.5v @+60
;; [Note] Vtemp = 0.41v = 1k / ( 1k +  10.0k) x 4.5v @+25
;; [Note] Vtemp = 0.02v = 1k / ( 1k + 188.0k) x 4.5v @-40
; // --- FOD（异物检测）相关的温度阈值 ---
; // 这些注释在计算不同温度下，NTC热敏电阻（10k @ 25°C）和1k电阻分压后的ADC读数
; // Vtemp = (1k / (1k + R_ntc)) * VCC
; // ADC_Value = (Vtemp / 2.08V) * 4095
;;==========================================================================================
;;OK for 1mm Space
;;-------small load status
#DEFINE	c_IniT60LDL0				05AH	; // FOD: 60度检测阈值，低负载情况 0 (Low)
#DEFINE	c_IniT60LDH0				005H	; // FOD: 60度检测阈值，低负载情况 0 (High) -> (0x055A)
;;-------Big load status
#DEFINE	c_IniT60LDL1				04AH	; // FOD: 60度检测阈值，高负载情况 1 (Low)
#DEFINE	c_IniT60LDH1				005H	; // FOD: 60度检测阈值，高负载情况 1 (High) -> (0x054A)
;;-------Temperature Rise status
#DEFINE	c_IniT60LDL2				04EH	; // FOD: 温升状态阈值 (Low)
#DEFINE	c_IniT60LDH2				00CH	; // FOD: 温升状态阈值 (High) -> (0x0C4E)
; 880H=1.1v, C4EH=1.5v
;;-------Temperature Rise Threshold
#DEFINE	c_IniTempDeL				046H	; // FOD: 温度 *变化* 阈值 低位 (0x0046)
#DEFINE	c_IniTempDeH				000H	; // FOD: 温度 *变化* 阈值 高位
								; 150mV=0.150*4096/2.08=295=127h
								; 100mV=0.100*4096/2.08=196= C4h
								;  50mV=0.050*4096/2.08= 98= 62h
								;  47mV=0.047*4096/2.08= 93= 5Dh
								;  36mV=0.036*4096/2.08= 70= 46h
								;  25mV=0.025*4096/2.08= 49= 31h
								; 23mV=0.023*4096/2.08= 45= 2Dh
; // 注释解释：0x0046 (70d) 对应约 36mV 的ADC电压变化，这是FOD判断温度是否异常上升的阈值


;;==========================================================================================
;;Function :  Isen Threshhold Claim
;;Note     :  Isen(mA) = ADC_Thr
; // --- 电流检测 (Isen) 阈值定义 ---
; // 这些值用于 `Isen.asm` 中的 `PID_SenPriCoilCurrWay65` 函数，判断电流是否过大或过小
;;==========================================================================================
;;-------Small Isen Threshold
#DEFINE	c_IniIsenSmallTh_L			09EH			; 158mA(09Eh)	; // 电流过小阈值 低位 (0x009E -> 约 158mA)
#DEFINE	c_IniIsenSmallTh_H			000H			;				; // 电流过小阈值 高位
; 142mA(08Eh)

;;-------Big Isen Threshold
#DEFINE	c_IniIsenBigTh_L			020H			; 900mA(384h) 	; // 电流过大阈值 低位 (0x0320 -> 约 800mA)
#DEFINE	c_IniIsenBigTh_H			003H			; 700mA(2BCh)	; // 电流过大阈值 高位
									; 500mA(1F4h)
									; 800mA(320h)


;;==========================================================================================
;;Function :  FOD Isen Threshhold Claim
;;Note     :  Isen(mA) = ADC_Thr
; // --- FOD（异物检测）使用的电流阈值表 ---
; // 这些值定义了FOD算法中用于比较的多个电流等级
;;==========================================================================================
#DEFINE	c_IniIsenFODTh1_L			033H			; 307mA(133h)	; // FOD 电流阈值 1 - 低位 (0x0133 -> 约 307mA)
#DEFINE	c_IniIsenFODTh1_H			001H			; 				; // FOD 电流阈值 1 - 高位

#DEFINE	c_IniIsenFODTh2_L			091H			; 414mA(191h)	; // FOD 电流阈值 2 - 低位 (0x0191 -> 约 414mA)
#DEFINE	c_IniIsenFODTh2_H			001H			; 				; // ... (以此类推)

#DEFINE	c_IniIsenFODTh3_L			030H			; 560mA(230h)
#DEFINE	c_IniIsenFODTh3_H			002H

#DEFINE	c_IniIsenFODTh4_L			08DH			; 653mA(28Dh)
#DEFINE	c_IniIsenFODTh4_H			002H

#DEFINE	c_IniIsenFODTh5_L			0F2H			; 754mA(1CDh)
#DEFINE	c_IniIsenFODTh5_H			002H

#DEFINE	c_IniIsenFODTh6_L			04CH			; 844mA(34Ch)
#DEFINE	c_IniIsenFODTh6_H			003H

#DEFINE	c_IniIsenFODTh7_L			0A4H			; 932mA(3A4h)
#DEFINE	c_IniIsenFODTh7_H			003H

#DEFINE	c_IniIsenFODTh8_L			005H			; 1029mA(405h)
#DEFINE	c_IniIsenFODTh8_H			004H

#DEFINE	c_IniIsenFODTh9_L			06BH			; 1131mA(46Bh)
#DEFINE	c_IniIsenFODTh9_H			004H

#DEFINE	c_IniIsenFODThA_L			0CDH			; 1229mA(4CDh)
#DEFINE	c_IniIsenFODThA_H			004H

#DEFINE	c_IniIsenFODThB_L			0AFH			; 1455mA(5AFh)
#DEFINE	c_IniIsenFODThB_H			005H

#DEFINE	c_IniIsenFODThC_L			010H			; 1552mA(610h)
#DEFINE	c_IniIsenFODThC_H			006H

#DEFINE	c_IniIsenFODThD_L			07FH			; 1663mA(67Fh)
#DEFINE	c_IniIsenFODThD_H			006H

#DEFINE	c_IniIsenFODThE_L			0F7H			; 1783mA(6F7h)
#DEFINE	c_IniIsenFODThE_H			006H

#DEFINE	c_IniIsenFODThF_L			08FH			; 1935mA(78Fh)
#DEFINE	c_IniIsenFODThF_H			007H


;;==========================================================================================
;;Function :  FOD Efficiency Threshhold Claim
;;Note     :  
; // --- FOD 效率阈值定义 ---
; // 用于WPC标准的FOD功率损耗计算。定义了基础效率和两条效率曲线的阈值。
;;==========================================================================================
#DEFINE	c_IniFODEffiBasic			029H			; 50=32H, 41=29H	; // FOD 基础效率阈值 (十进制 41，可能代表 41%)
#DEFINE	c_IniFODEffi_26_1Ah_Per 		01AH			; // 26%
#DEFINE	c_IniFODEffi_22_16h_Per 		016H			; // 22%
#DEFINE	c_IniFODEffi_20_14h_Per			014H			; // 20%
#DEFINE	c_IniFODEffi_17_11h_Per  		011H			; // 17%
#DEFINE	c_IniFODEffi_16_10h_Per  		010H			; // 16%
#DEFINE	c_IniFODEffi_15_Fh_Per			00FH			; // 15%
#DEFINE	c_IniFODEffi_14_Eh_Per			00EH			; 12=CH		; // 14%
#DEFINE	c_IniFODEffi_13_Dh_Per			00DH			; // 13%
#DEFINE	c_IniFODEffi_12_Ch_Per			00CH			; 12=CH		; // 12%
#DEFINE	c_IniFODEffi_10_Ah_Per			00AH			; 10=AH		; // 10%
#DEFINE	c_IniFODEffi_4_4h_Per			004H			; 4=4H		; // 4%
#DEFINE	c_IniFODEffi_5_5h_Per			005H			; 5=5H		; // 5%
#DEFINE	c_IniFODEffi_6_6h_Per			006H			; 6=6H		; // 6%
#DEFINE	c_IniFODEffi_7_7h_Per			007H			; 7=7H		; // 7%
#DEFINE	c_IniFODEffi_8_8h_Per			008H			; 8=8H		; // 8%
#DEFINE	c_IniFODEffi_9_9h_Per			009H			; 9=9H		; // 9%
                                        	
                                        	
;;Highest Efficiency (Curve 1)
; // --- FOD 最高效率曲线 (Curve 1) 阈值 ---
#DEFINE	c_IniFODEffThr11			027H			; 37=25H		; // (0x27 = 39)
#DEFINE	c_IniFODEffThr12			03BH			; 57=39H		; // (0x3B = 59)
#DEFINE	c_IniFODEffThr13			043H			; 65=41H		; // ...
#DEFINE	c_IniFODEffThr14			049H			; 71=47H
#DEFINE	c_IniFODEffThr15			04AH			; 72=48H
#DEFINE	c_IniFODEffThr16			04DH			; 75=4BH
#DEFINE	c_IniFODEffThr17			04DH			; 76=4CH
#DEFINE	c_IniFODEffThr18			04DH			; 77=4DH
C_IniFODEffThr19 的值在 .INC 文件中缺失，根据上下文和注释（78=4EH）推断：
#DEFINE	c_IniFODEffThr19			04EH			; 78=4EH
#DEFINE	c_IniFODEffThr1A			04DH			; 79=4FH
#DEFINE	c_IniFODEffThr1B			04EH			; 80=50H
#DEFINE	c_IniFODEffThr1C			04EH			; 80=50H
#DEFINE	c_IniFODEffThr1D			04FH			; 81=51H
#DEFINE	c_IniFODEffThr1E			04FH			; 81=51H
#DEFINE	c_IniFODEffThr1F			050H			; 82=52H
#DEFINE	c_IniFODEffThr1G			04FH			; 80=50H
                                        	
                                        	
;;Lowest Efficiency (Curve 2)
; // --- FOD 最低效率曲线 (Curve 2) 阈值 ---
#DEFINE	c_IniFODEffThr21			013H			; 21=15H		; // (0x13 = 19)
#DEFINE	c_IniFODEffThr22			015H			; 34=22H		; // (0x15 = 21)
#DEFINE	c_IniFODEffThr23			017H			; 44=2CH		; // ...
#DEFINE	c_IniFODEffThr24			018H			; 52=34H
#DEFINE	c_IniFODEffThr25			020H			; 52=34H
#DEFINE	c_IniFODEffThr26			020H			; 53=35H
#DEFINE	c_IniFODEffThr27			020H			; 54=36H
#DEFINE	c_IniFODEffThr28			020H			; 54=36H
#DEFINE	c_IniFODEffThr29			037H			; 55=37H
#DEFINE	c_IniFODEffThr2A			036H			; 54=36H
#DEFINE	c_IniFODEffThr2B			036H			; 54=36H
#DEFINE	c_IniFODEffThr2C			036H			; 54=36H
#DEFINE	c_IniFODEffThr2D			036H			; 54=36H
#DEFINE	c_IniFODEffThr2E			036H			; 54=36H
#DEFINE	c_IniFODEffThr2F			036H			; 54=36H
#DEFINE	c_IniFODEffThr2G			031H			; 49=31H


;;==========================================================================================
;;Function :  FOD Pd Threshhold Claim
;;Note     :  
; // --- FOD 功率损耗 (Pd) 阈值表 ---
; // 这些值用于与计算出的功率损耗进行比较，以确定是否存在异物。
;;==========================================================================================
#DEFINE	c_IniFOD128Pin0_L			0B3H			; 179=0B3h		; // FOD 功率损耗阈值 0 - 低位 (179)
#DEFINE	c_IniFOD128Pin0_H			000H			;				; // ... 高位 (0x00B3)

#DEFINE	c_IniFOD128Pin1_L			0DAH			; 218=0DAh
#DEFINE	c_IniFOD128Pin1_H			000H

#DEFINE	c_IniFOD128Pin2_L			00DH			; 269=10Dh
#DEFINE	c_IniFOD128Pin2_H			001H

#DEFINE	c_IniFOD128Pin3_L			05AH			; 346=15Ah
#DEFINE	c_IniFOD128Pin3_H			001H

#DEFINE	c_IniFOD128Pin4_L			08DH			; 397=18Dh
#DEFINE	c_IniFOD128Pin4_H			001H

#DEFINE	c_IniFOD128Pin5_L			0CDH			; 461=1CDh
#DEFINE	c_IniFOD128Pin5_H			001H

#DEFINE	c_IniFOD128Pin6_L			0F3H			; 499=1F3h
#DEFINE	c_IniFOD128Pin6_H			001H

#DEFINE	c_IniFOD128Pin7_L			01AH			; 538=21Ah
#DEFINE	c_IniFOD128Pin7_H			002H

#DEFINE	c_IniFOD128Pin8_L			04DH			; 589=24Dh
#DEFINE	c_IniFOD128Pin8_H			002H

#DEFINE	c_IniFOD128Pin9_L			080H			; 640=280h
#DEFINE	c_IniFOD128Pin9_H			002H
				
#DEFINE	c_IniFOD128PinA_L			0B3H			; 691=2B3h
#DEFINE	c_IniFOD128PinA_H			002H

#DEFINE	c_IniFOD128PinB_L			000H			; 768=300h
#DEFINE	c_IniFOD128PinB_H			003H

#DEFINE	c_IniFOD128PinC_L			033H			; 819=333h
#DEFINE	c_IniFOD128PinC_H			003H

#DEFINE	c_IniFOD128PinD_L			073H			; 883=373h
#DEFINE	c_IniFOD128PinD_H			003H

#DEFINE	c_IniFOD128PinE_L			09AH			; 992=39Ah
#DEFINE	c_IniFOD128PinE_H			003H

#DEFINE	c_IniFOD128PinF_L			0CDH			; 973=3CDh
#DEFINE	c_IniFOD128PinF_H			003H
													

;;==========================================================================================
;;Function :  Detect Object for Min Threshold Claim
;;Note     : 
; // --- 物体检测阈值 (用于 Ping 阶段和检测物体离开) ---
; // 这些值在 `Detection.asm` 中使用
;;==========================================================================================
;-------Detect Object Min Threshold
#DEFINE	c_IniDetObjMinL				010H		; 0145h @ V=5v, VREF=2.08v	; // 物体检测阈值 低位 (0x0110)
#DEFINE	c_IniDetObjMinH				001H		; 							; // 物体检测阈值 高位 (用于 ObjectDetection)

;-------Detect Object Min Threshold for D type Rx
#DEFINE	c_IniDetObjRXDMinL			050H		; 0145h @ V=5v, VREF=2.08v	; // D型线圈 物体检测阈值 低位 (0x0050)
#DEFINE	c_IniDetObjRXDMinH			000H		; 							; // D型线圈 物体检测阈值 高位

;-------Detect Object Max Threshold for Leaving
#DEFINE	c_IniDetObjLeaMaxL			0A0H		; 0145h @ V=5v, VREF=2.08v	; // 物体离开检测阈值 低位 (0x00A0)
#DEFINE	c_IniDetObjLeaMaxH			000H		; 							; // 物体离开检测阈值 高位 (用于 ObjectDetectLeave)


;;==========================================================================================
;;Function :  TM1(CTM) Timer Function Claim
;;Note     : 
; // --- 定时器1 (CTM) 相关的时间常量 ---
; // 基于 Fsys=20MHz, Fsys/4 = 5MHz, 时钟周期 = 0.2us
;;==========================================================================================
;-------CTM Time Base 0
#DEFINE	c_IniCTMTimeBaseL			032H	;@ Fsys/4 = 20MHz/4 = 5MHz = 0.2us, Time Base = 0.2us x 250 = 0.2us x FAh = 50us
; // CTM 基础定时器周期 低位 (50d = 10us @ 5MHz)
#DEFINE	c_IniCTMTimeBaseH			000H    ;@ Fsys/4 = 20MHz/4 = 5MHz = 0.2us, Time Base = 0.2us x  50 = 0.2us x 32h = 10us
; // CTM 基础定时器周期 高位

;-------CTM Mutiple Time for VCO
#DEFINE	c_IniWVCOMutipleTimeL			0C8H	;Time Base = 50us, 50us x 3E8h = 50us x 1000 = 50ms
; // VCO 启动稳定时间的倍率 低位 (0x00C8 = 200)
#DEFINE	c_IniWVCOMutipleTimeH			000H	;Time Base = 10us, 10us x 1388h = 10us x 5000 = 50ms
; // VCO 启动稳定时间的倍率 高位 (总延时 = 200 * 10us = 2ms。注释中的50ms似乎是旧值或针对不同基础时钟的)

;-------CTM Mutiple Time for Detection
#DEFINE	c_IniDetectMutipleTimeL			007H	;Time Base = 10us, 10us x 0007h = 10us x 7 = 70us
; // 物体检测(Ping)脉冲宽度 低位 (7 * 10us = 70us)
#DEFINE	c_IniDetectMutipleTimeH			000H	; // ... 高位

;-------CTM Mutiple Time for Detect Rx D-Type
#DEFINE	c_IniDetectRXDMutipleTimeL		050H	;Time Base = 10us, 10us x 023h = 10us x 35 = 350us Lab
; // D型线圈 物体检测脉冲宽度 低位 (0x0050 = 80 -> 80 * 10us = 800us) (注释中的350us可能是旧值)
#DEFINE	c_IniDetectRXDMutipleTimeH		000H	;LAB 

;-------CTM Time Base 1
#DEFINE	c_IniCTMTimeBaseL1			0FAH	;@ Fsys/4 = 20MHz/4 = 5MHz = 0.2us, Time Base = 0.2us x 250 = 0.2us x FAh = 50us
; // CTM 基础定时器周期 (用于通信) 低位 (250d = 50us @ 5MHz)
#DEFINE	c_IniCTMTimeBaseH1			000H    ;@ Fsys/4 = 20MHz/4 = 5MHz = 0.2us, Time Base = 0.2us x  50 = 0.2us x 32h = 10us
; // CTM 基础定时器周期 (用于通信) 高位

;-------CTM Mutiple Time for Preamble of Communication
#DEFINE	c_IniComBy0MutipleTimeL			002H	;Time Base = 50us, 50us x 2h = 50us x 2 = 100us
; // 通信前导码检测的短延时 低位 (2 * 50us = 100us)
#DEFINE	c_IniComBy0MutipleTimeH			000H	;Time Base = 10us, 10us x Ah = 10us x 10 = 100us
; // ... 高位

;-------CTM Mutiple Time for Preamble of Communication
#DEFINE	c_IniComByMutipleTimeL0			005H	;Time Base = 50us, 50us x 7h = 50us x 7 = 350us
; // 通信前导码检测窗口时间 低位 (5 * 50us = 250us)
#DEFINE	c_IniComByMutipleTimeH0			000H    ;Time Base = 50us, 50us x 8h = 50us x 8 = 400us
; // ... 高位

;-------CTM Mutiple Time for Data of Communication
#DEFINE	c_IniComByMutipleTimeL			007H	;Time Base = 50us, 50us x 7h = 50us x 7 = 350us
; // 通信数据位检测窗口时间 低位 (7 * 50us = 350us)
#DEFINE	c_IniComByMutipleTimeH			000H    ;Time Base = 50us, 50us x 8h = 50us x 8 = 400us
; // ... 高位

;-------CTM Mutiple Time for settle timing
#DEFINE	c_IniPowTrTsettleMutipleTimeL 		078H	;Time Base = 50us, 50us x 0064h = 50us x 100 = 5ms (3ms <= Tsettle <= 7ms)
; // 功率传输稳定时间(Tsettle) 低位 (0x0078 = 120 -> 120 * 50us = 6ms)
#DEFINE	c_IniPowTrTsettleMutipleTimeH		000H	;Time Base = 50us, 50us x 003Ch = 50us x 60 = 3ms (3ms <= Tsettle <= 7ms)
							;Time Base = 50us, 50us x 0078h = 50us x 120 = 6ms (3ms <= Tsettle <= 7ms)
;-------CTM Mutiple Time for termination timing
#DEFINE	c_IniTtermiMutipleTimeL 		0F4H	;Time Base = 50us, 50us x 21Ch = 50us x 540 = 27ms (Tterminate <= 28ms)
; // 终止延时 低位 (0x01F4 = 500 -> 500 * 50us = 25ms。 注释中的 27ms 可能是 0x021C)
#DEFINE	c_IniTtermiMutipleTimeH			001H	; // ... 高位

;-------CTM Mutiple Time for Light
#DEFINE	c_IniPowDownLight1MutilpleTimeL		0E8H	;Time Base = 50us, 50us x 03E8h = 50us x 1000 = 50ms 
; // 关机LED闪烁定时 低位 (0x03E8 = 1000 -> 1000 * 50us = 50ms)
#DEFINE	c_IniPowDownLight1MutilpleTimeH		003H	; // ... 高位

;-------CTM Mutiple Time for Power Down
#DEFINE	c_IniPIDMutilpleTimeL			00AH	;Time Base = 50us, 50us x 000Ah = 50us x 10 = 500us = 0.5ms
; // PID 循环内部延时 低位 (0x000A = 10 -> 10 * 50us = 0.5ms)
#DEFINE	c_IniPIDMutilpleTimeH			000H	;Time Base = 50us, 50us x 0004h = 50us x 4 = 0.2ms 
							;Time Base = 50us, 50us x 000Ch = 50us x 12 = 0.6ms 

;;==========================================================================================
;;Function :  TM0(STM) Timer Function Claim
;;Note     : 
; // --- 定时器0 (STM) 相关的时间常量 ---
; // 同样基于 Fsys=20MHz, Fsys/4 = 5MHz, 时钟周期 = 0.2us
;;==========================================================================================
;-------CTM Time Base 0
#DEFINE	c_IniSTMTimeBaseL			0FAH	;@ Fsys/4 = 20MHz/4 = 5MHz = 0.2us, Time Base = 0.2us x 250 = 0.2us x FAh = 50us
; // STM 基础定时器周期 低位 (250d = 50us @ 5MHz)
#DEFINE	c_IniSTMTimeBaseH			000H	; // ... 高位

;-------CTM Mutiple Time for Ping Timing
#DEFINE	c_IniDiPingMutipleTimeL			025H	;Time Base = 50us, 50us x 578h = 50us x 1400 = 70ms (Tping <= 70ms)
; // Ping 阶段超时 (Tping) 低位 (0x0525 = 1317 -> 1317 * 50us = 65.85ms)
#DEFINE	c_IniDiPingMutipleTimeH			005H	;Time Base = 50us, 50us x 550h = 50us x 1360 = 68ms (Tping <= 70ms)
; // ... 高位

;-------CTM Mutiple Time for First Packet Timing
#DEFINE	c_IniPingTfirstMutipleTimeL		008H	;Time Base = 50us, 50us x 190h = 50us x 400 = 20.0ms (Tfirst <= 20ms)
; // 接收第一个包的超时 (Tfirst) 低位 (0x0208 = 520 -> 520 * 50us = 26ms)
#DEFINE	c_IniPingTfirstMutipleTimeH		002H	;Time Base = 50us, 50us x 1B8h = 50us x 440 = 23.2ms (Tfirst <= 20ms)
							;Time Base = 50us, 50us x 1D0h = 50us x 464 = 23.2ms (Tfirst <= 20ms)
							;Time Base = 50us, 50us x 208h = 50us x 520 = 26.0ms (Tfirst <= 20ms)
							
;-------CTM Mutiple Time for Next Packet Timing
#DEFINE	c_IniIdeConTnextMutipleTimeL 		01AH	;Time Base = 50us, 50us x 1A4h = 50us x 420 = 21ms (Tnext <= 21ms)
; // 身份识别阶段，接收下一个包的超时 (Tnext) 低位 (0x011A = 282 -> 282 * 50us = 14.1ms)
#DEFINE	c_IniIdeConTnextMutipleTimeH		001H	;Time Base = 50us, 50us x 190h = 50us x 400 = 20ms (Tnext <= 21ms)
; // ... 高位 (注释中的 20ms 和 21ms 与代码 0x011A 不符)

;-------CTM Mutiple Time for Maximun Packet Timing
#DEFINE	c_IniIdeConTmaxMutipleTimeL 		034H	;Time Base = 50us, 50us x D48h = 50us x 3400 = 170ms (Tmax <= 170ms)
; // 身份识别阶段总超时 (Tmax) 低位 (0x0D34 = 3380 -> 3380 * 50us = 169ms)
#DEFINE	c_IniIdeConTmaxMutipleTimeH		00DH	;Time Base = 50us, 50us x D34h = 50us x 3380 = 169ms (Tmax <= 170ms)
; // ... 高位

;-------CTM Mutiple Time for CE Packet Timing 0
#DEFINE	c_IniPowTrTtimeoutMutipleTimeL 		030H	;Time Base = 50us, 50us x 84D0h = 50us x 34000 = 1700ms (Ttimeout <= 1800ms)
; // 功率传输阶段总超时 (Ttimeout) 低位 (0x8030 = 32816 -> 32816 * 50us = 1640.8ms)
#DEFINE	c_IniPowTrTtimeoutMutipleTimeH		080H

;-------CTM Mutiple Time for CE Packet Timing 1
#DEFINE	c_IniPowTrTtioutMutipleTimeL 		07FH	;Time Base = 50us, 50us x 84D0h = 50us x 34000 = 1700ms (Ttimeout <= 1800ms, Ttiout=Ttimeout-T(unknown))
; // 功率传输阶段超时 (Ttiout) 低位 (0x807F = 32895 -> 32895 * 50us = 1644.75ms)
#DEFINE	c_IniPowTrTtioutMutipleTimeH		080H

;-------CTM Mutiple Time for Power Control Active Timing
#DEFINE	c_IniPowTrTactMutipleTimeL 		0A4H	;Time Base = 50us, 50us x 01A4h = 50us x 420 = 21ms (Tactive <= 21ms)
; // PID 运行时间 (Tactive) 低位 (0x01A4 = 420 -> 420 * 50us = 21ms)
#DEFINE	c_IniPowTrTactMutipleTimeH		001H	;Time Base = 50us, 50us x 0190h = 50us x 400 = 20ms (Tactive <= 21ms)
; // ... 高位


;;==========================================================================================
;;Function :  INT1 Function Claim
;;Note     : 
;;==========================================================================================
;------- No Preamble Counter
#DEFINE	c_IniNoPreambleCNT			010H	; // 在 ReciPackageDataUnit.asm 中用于线路无翻转超时计数 (0x10 = 16)


;;==========================================================================================
;;Function :  Sv Paramenter of PID Claim
;;Note     : 
; // --- PID 控制器增益 (Sv) 参数 ---
; // 这些值用于 `PID.asm` 中的 `PT_SvParaSelect` 函数，根据不同的频率范围和工作条件选择不同的增益。
; // 注释中的 Sv*10=5.0*10=50=32H 表示 5.0 这个值在程序中用整数 50 (0x32) 来代表。
;;==========================================================================================
;;for New MOS 4226, Gate Resistance 10ohm
#DEFINE	c_IniSv181_205S           		032H	; Sv*10=5.0*10=50=32H	; // PID 增益 (181-205kHz, S) -> 5.0
#DEFINE	c_IniSv181_205N		  		032H	; Sv*10=5.0*10=50=32H	; // PID 增益 (181-205kHz, N) -> 5.0

#DEFINE	c_IniSv161_180S0			01EH	; Sv*10=3.0*10=30=1EH	; // PID 增益 (161-180kHz, S0) -> 3.0
#DEFINE	c_IniSv161_180S1			01DH	; Sv*10=2.9*10=29=1DH	; // PID 增益 (161-180kHz, S1) -> 2.9
#DEFINE	c_IniSv161_180N0			01EH	; Sv*10=3.0*10=30=1EH	; // PID 增益 (161-180kHz, N0) -> 3.0
#DEFINE	c_IniSv161_180N1			01DH	; Sv*10=2.9*10=29=1DH	; // PID 增益 (161-180kHz, N1) -> 2.9
#DEFINE	c_IniSv161_180B0			012H	; Sv*10=1.8*10=18=12H	; // PID 增益 (161-180kHz, B0) -> 1.8
#DEFINE	c_IniSv161_180B1			00DH	; Sv*10=1.3*10=13= DH	; // PID 增益 (161-180kHz, B1) -> 1.3
#DEFINE	c_IniSv161_180B11			011H	; Sv*10=1.7*10=17=11H	; // PID 增益 (161-180kHz, B11) -> 1.7
#DEFINE	c_IniSv161_180B111			00EH	; Sv*10=1.4*10=14= EH	; // PID 增益 (161-180kHz, B111) -> 1.4

#DEFINE	c_IniSv141_160N00			014H	; Sv*10=2.0*10=20=14H	; // PID 增益 (141-160kHz, N00) -> 2.0
#DEFINE	c_IniSv141_160N1			009H	; Sv*10=0.9*10= 9= 9H	; // PID 增益 (141-160kHz, N1) -> 0.9
#DEFINE	c_IniSv141_160S0			012H	; Sv*10=1.8*10=18=12H	; // PID 增益 (141-160kHz, S0) -> 1.8
#DEFINE	c_IniSv141_160S1			010H	; Sv*10=1.6*10=16=10H	; // PID 增益 (141-160kHz, S1) -> 1.6
#DEFINE	c_IniSv141_160B0			010H	; Sv*10=1.6*10=16=10H	; // PID 增益 (141-160kHz, B0) -> 1.6
#DEFINE	c_IniSv141_160B1			007H	; Sv*10=0.7*10= 7= 7H	; // PID 增益 (141-160kHz, B1) -> 0.7
#DEFINE	c_IniSv141_160B11			006H	; Sv*10=0.7*10= 7= 6H	; // PID 增益 (141-160kHz, B11) -> 0.6
#DEFINE	c_IniSv141_160B111			004H    ; Sv*10=0.4*10= 4= 4H	; // PID 增益 (141-160kHz, B111) -> 0.4
#DEFINE	c_IniSv131_140N00			013H	; Sv*10=0.9*10= 9= 9H	; // PID 增益 (131-140kHz, N00) -> 1.9 (注释似乎有误)

#DEFINE	c_IniSv131_140N1			009H	; Sv*10=0.9*10= 9= 9H	; // PID 增益 (131-140kHz, N1) -> 0.9
#DEFINE	c_IniSv131_140S0			008H	; Sv*10=0.8*10= 8= 8H	; // PID 增益 (131-140kHz, S0) -> 0.8
#DEFINE	c_IniSv131_140S1			007H	; Sv*10=0.7*10= 7= 7H	; // PID 增益 (131-140kHz, S1) -> 0.7
#DEFINE	c_IniSv131_140B0			008H	; Sv*10=0.8*10= 8= 8H	; // PID 增益 (131-140kHz, B0) -> 0.8
#DEFINE	c_IniSv131_140B1			004H	; Sv*10=0.4*10= 4= 4H	; // PID 增益 (131-140kHz, B1) -> 0.4
#DEFINE	c_IniSv131_140B11			003H	; Sv*10=0.3*10= 3= 3H	; // PID 增益 (131-140kHz, B11) -> 0.3
#DEFINE	c_IniSv131_140B111			002H	; Sv*10=0.2*10= 2= 2H	; // PID 增益 (131-140kHz, B111) -> 0.2

#DEFINE	c_IniSv121_130N00			011H	; Sv*10=1.7*10=17=11H	; // PID 增益 (121-130kHz, N00) -> 1.7
#DEFINE	c_IniSv121_130N1			006H	; Sv*10=0.6*10= 6= 6H	; // PID 增益 (121-130kHz, N1) -> 0.6
#DEFINE	c_IniSv121_130S0			008H	; Sv*10=0.8*10= 8= 8H	; // PID 增益 (121-130kHz, S0) -> 0.8
#DEFINE	c_IniSv121_130S1			007H	; Sv*10=0.7*10= 7= 7H	; // PID 增益 (121-130kHz, S1) -> 0.7
#DEFINE	c_IniSv121_130B0			005H	; Sv*10=0.5*10= 5= 5H	; // PID 增益 (121-130kHz, B0) -> 0.5
#DEFINE	c_IniSv121_130B1			003H	; Sv*10=0.3*10= 3= 3H	; // PID 增益 (121-130kHz, B1) -> 0.3
#DEFINE	c_IniSv121_130B11			002H	; Sv*10=0.2*10= 2= 2H	; // PID 增益 (121-130kHz, B11) -> 0.2
#DEFINE	c_IniSv121_130B111			001H	; Sv*10=0.1*10= 1= 1H	; // PID 增益 (121-130kHz, B111) -> 0.1

#DEFINE	c_IniSv110_120N0			002H	; Sv*10=0.2*10= 2= 2H	; // PID 增益 (110-120kHz, N0) -> 0.2
#DEFINE	c_IniSv110_120N1			001H	; Sv*10=0.1*10= 1= 1H	; // PID 增益 (110-120kHz, N1) -> 0.1
#DEFINE	c_IniSv110_120B0			002H	; Sv*10=0.2*10= 2= 2H	; // PID 增益 (110-120kHz, B0) -> 0.2
#DEFINE	c_IniSv110_120B1			001H	; Sv*10=0.1*10= 1= 1H	; // PID 增益 (110-120kHz, B1) -> 0.1
#DEFINE	c_IniSv110_120B11			001H	; Sv*10=0.1*10= 1= 1H	; // PID 增益 (110-120kHz, B11) -> 0.1
                                                        	
#DEFINE	c_IniReceiPowCNTL			060H	; 24000ms/250ms=96=60h	; // 接收功率超时计数器 低位 (96)
#DEFINE	c_IniReceiPowCNTH			000H	; 						; // ... 高位

;;========================================================
;;Function :  Protection for Resonant Frequency_max/min
;;Note     : 
; // --- PLL (即工作频率) 的硬件保护限制 ---
; // 这些值用于 `PID.asm` 中的 `PT_PLLProtect` 函数
;;========================================================
;-------PLL max Threshold
#DEFINE	c_IniPLLFmaxL110			064H	; 110kHz=064H		; // PLL 频率上限 低位 (对应 110kHz)
#DEFINE	c_IniPLLFmaxH110			000H	; 					; // ... 高位 (0x0064)

;-------PLL min Threshold
#DEFINE	c_IniPLLFminL205			01AH	; 205kHz=41AH		; // PLL 频率下限 低位 (对应 205kHz)
#DEFINE	c_IniPLLFminH205			004H	; 					; // ... 高位 (0x041A)

;-------PLL max Threshold in dead time control
#DEFINE	c_IniPLLFL162				06CH	; 162kHz=26CH		; // PLL 频率下限 (用于死区时间控制) 低位 (对应 162kHz)
#DEFINE	c_IniPLLFH162				002H	; 					; // ... 高位 (0x026C)
