;*******************************************************************************************
;*****	                          Parameters Claim                                     *****
;*******************************************************************************************
User_Data_Ram	.Section	at 080H		'data'		;HT66FW2230 // 用户数据RAM区，起始地址为0x80
;===========================================================================================
;Function :   PLL claim // 函数: 锁相环(PLL)相关变量声明
;Note     : 	0 bit, 2 byte
;===========================================================================================
			a_ParPLLFH				DB	? ; // 存储PLL频率设置的高位字节
			a_ParPLLFL				DB	? ; // 存储PLL频率设置的低位字节
	

;===========================================================================================
;Function :   CTM claim // 函数: 紧凑型定时器(CTM)相关变量声明
;Note     : 	2 bit, 2 byte
;===========================================================================================
			fg_BaseTimeCTM				DBIT ; // CTM基础定时时间到达标志
			fg_MutipleTimeHflagCTM			DBIT ; // CTM长延时(高位)标志
			a_MutipleTimeLCTM			DB	? ; // CTM长延时计数器低位
			a_MutipleTimeHCTM			DB	? ; // CTM长延时计数器高位

;===========================================================================================
;Function :   STM claim // 函数: 标准定时器(STM)相关变量声明
;Note     : 	3 bit, 2 byte
;===========================================================================================
			fg_BaseTimeSTM				DBIT ; // STM基础定时时间到达标志
			fg_MutipleTimeHflagSTM			DBIT ; // STM长延时(高位)标志
			fg_TimeOut				DBIT ; // 通用超时标志，通常由STM设置
			a_MutipleTimeLSTM			DB	? ; // STM长延时计数器低位
			a_MutipleTimeHSTM			DB	? ; // STM长延时计数器高位

;===========================================================================================
;Function :   Demodulation claim // 函数: 解调相关变量声明
;Note     : 	1 bit, 0 byte
;===========================================================================================
			fg_FlagDemo				DBIT ; // 解调中断标志
			a_DemoV_I1_I2				DB	? ; // 解调电路选择变量
			
;===========================================================================================
;Function :   INT1_Demodulation claim // 函数: 中断与数据包解码相关变量声明
;Note     : 	16 bit, 34 byte
;===========================================================================================
			fg_INT1					DBIT ; // 外部中断1标志
			fg_INT0					DBIT ; // 外部中断0标志
			fg_DUDataStart				DBIT ; // 数据单元开始标志
			fg_DU					DBIT ; // 数据单元标志
			fg_StartBit				DBIT ; // 处于起始位解码状态标志
			fg_ParityBit				DBIT ; // 处于奇偶校验位解码状态标志
			fg_ParityErr				DBIT ; // 奇偶校验错误标志
			fg_StopBit				DBIT ; // 处于停止位解码状态标志
			fg_WaitDataOut				DBIT ; // 等待数据输出标志
			fg_StopBitPre				DBIT ; // 上一个停止位标志
			fg_DataFirst				DBIT ; // 收到第一个数据包标志
			fg_Preamble				DBIT ; // 处于前导码解码状态标志
			fg_ChecksumBit				DBIT ; // 处于校验和解码状态标志

			fg_PacDataOK				DBIT ; // 数据包接收校验OK标志
			fg_StartReci				DBIT ; // 开始接收标志

			fg_DataByteCNTFull			DBIT ; // 数据包字节计数满标志
			                                	
			a_StatusCntInt1				DB	? ; // 中断状态计数器

			a_DataOUTtemp				DB	? ; // 临时存储接收到的数据字节
			a_DataParityCNT				DB	? ; // 用于计算奇偶校验的计数器
			a_TimeOutCNT				DB	? ; // 位接收超时计数器
			a_DataOUT				DB	10	dup (?) ; // 接收数据包的缓冲区(10字节)

			a_DataCNT				DB	? ; // 字节内数据位计数器
			                                	
			a_Preamble4BitCNT			DB	? ; // 前导码计数器 (4-bit)
			a_Preamble25BitCNT			DB	? ; // 前导码计数器 (25-bit)
			                                	
			a_NoToggleCNT				DB	? ; // 通信线路无翻转超时计数器
			a_DataByteCNT				DB	? ; // 数据包字节计数器
			a_DataByteCNTtemp			DB	? ; // 数据包字节计数器临时变量
			a_AddrDataOUT				DB	? ; // 指向a_DataOUT缓冲区的地址指针
			a_HeadMessageCNT			DB	? ; // 包头/消息计数器
			a_ContlDataMessag			DB	? ; // 控制数据消息变量



			a_DataHeader				DB	?       ;;Sensor Primary Coil Current Data // 存储解析后的包头
			a_DataMessageB0				DB	?       ;;Sensor Primary Coil Current Data // 存储解析后的消息字节0
			a_DataMessageB1             		DB	?       ;;Sensor Primary Coil Current Data // ...
			a_DataMessageB2             		DB	?       ;;Sensor Primary Coil Current Data
			a_DataMessageB3             		DB	?	;;Sensor Primary Coil Current Data
			a_DataMessageB4             		DB	?	;;Sensor Primary Coil Current Data 
			a_DataMessageB5             		DB	?	;;Sensor Primary Coil Current Data 
			a_DataMessageB6             		DB	?	;;Sensor Primary Coil Current Data 
			a_DataMessageB7             		DB	?	;;Sensor Primary Coil Current Data 
			a_DataChecksum				DB	?	;;Sensor Primary Coil Current Data // 存储解析后的校验和
			                                	
			a_XORchecksum				DB	? ; // 存储本地计算出的校验和


;===========================================================================================
;Function :   AD claim // 函数: ADC(模数转换)相关变量声明
;Note     : 	1 bit, 2 byte
;===========================================================================================
			fg_INT_AD				DBIT ; // ADC转换完成中断标志
			                                	
			a_ADRHbuffer				DB	? ; // 存储ADC结果的高位字节
			a_ADRLbuffer				DB	? ; // 存储ADC结果的低位字节

;===========================================================================================
;Function :   Math claim // 函数: 数学运算相关变量声明
;Note     : 	0 bit, 24 byte
;===========================================================================================
			a_com1					DB	? ; // 通用临时变量1
			a_com2					DB	? ; // 通用临时变量2
			a_com3					DB	? ; // 通用临时变量3
			a_com4					DB	? ; // 通用临时变量4
			;a_com5					DB	?
			
			a_data0					DB	? ; // 通用数据缓冲0
			a_data1					DB	? ; // 通用数据缓冲1
			a_data2					DB	? ; // ...
			a_data3					DB	?
			a_data4					DB	?
			a_data5					DB	?
			a_data6					DB	?
			a_data7					DB	?

			a_to0					DB	? ; // 通用临时存储0
			a_to1					DB	? ; // ...
			a_to2                                   DB	?
			a_to3                                   DB	?
			a_to4                                   DB	?
			a_to5                                   DB	?
			a_to6                                   DB	?
			a_to7                                   DB	?
			a_count0				DB	? ; // 通用计数器0
			;a_temp3				DB	?
			a_temp2                                 DB	? ; // 通用临时变量 temp2
			a_temp1                                 DB	? ; // ... temp1
			a_temp0                                 DB	? ; // ... temp0
			
			
;===========================================================================================
;Function :   PID claim // 函数: PID(比例-积分-微分)控制器相关变量声明
;Note     : 	4 bit, 11 byte
;===========================================================================================
			fg_PIDIni				DBIT ; // PID初始化标志
			fg_start				DBIT ; // PID启动标志
			fg_IterationStart			DBIT ; // PID迭代开始标志
			fg_FODTemp60				DBIT ; // FOD(异物检测)温度达到60度标志
			a_IL              	   		DB	? ; // PID积分项(I)低位
			a_IM0                 			DB	? ; // PID积分项(I)中位0
			a_IM1                 			DB	? ; // PID积分项(I)中位1
			;a_IH					DB	?
			a_VL					DB	? ; // PID当前值(V)低位
			a_VM0					DB	? ; // PID当前值(V)中位0
			a_VM1					DB	? ; // PID当前值(V)中位1
			;a_VH					DB	?
			a_EL					DB	? ; // PID误差项(E)低位
			a_EM					DB	? ; // PID误差项(E)中位
			a_EH					DB	? ; // PID误差项(E)高位
			a_Sv					DB	? ; // PID控制输出设定值(Sv)
			a_LoopIteration				DB	? ; // PID循环迭代计数器
					
;===========================================================================================
;Function :   Phase claim // 函数: Qi协议状态机相关变量声明
;Note     : 	42 bit, 38 byte
;===========================================================================================
			;fg_0x02PowDownUnknown			DBIT
			fg_0x02PowDownChargeComplete        	DBIT ; // 结束充电原因：充电完成
			;fg_0x02PowDownInternalFault         	DBIT
			;fg_0x02PowDownOverTemp              	DBIT
			;fg_0x02PowDownOverVoltage           	DBIT
			;fg_0x02PowDownOverCurrent           	DBIT
			;fg_0x02PowDownBatteryFail           	DBIT
			fg_0x02PowDownReconfigure           	DBIT ; // 结束充电原因：需要重新配置
			fg_0x02PowDownNoResponse            	DBIT ; // 结束充电原因：接收端无响应
			;fg_0x02PowDownReserved              	DBIT
			fg_ExIdet0x81				DBIT ; // 等待扩展身份包(0x81)标志
			fg_Idet					DBIT ; // 身份识别完成标志
			fg_Tdelay				DBIT ; // 延时进行中标志
			fg_0x04OutReceiPowTime			DBIT ; // 接收功率包(0x04)超时标志
			fg_0x51PowClass				DBIT ; // 功率等级(0x51)已设置标志
			fg_0x51NonPID				DBIT ; // 配置包(0x51)指定为非PID模式标志
			fg_EndPowDown				DBIT ; // 接收到结束充电指令标志
			fg_CEinput				DBIT ; // 接收到控制错误(CE)包标志
			fg_0x04ReceiPowCNTHflag			DBIT ; // 接收功率计数器高位标志
			fg_PSVin				DBIT ; // 在选择(Selection)阶段电压正常标志
			fg_PCH0x06Abnor				DBIT ; // 功率控制保持包(0x06)异常标志
			fg_RecodeRPpre				DBIT ; // 记录上一个接收功率(RP)包标志
			fg_RPNoStable				DBIT ; // 接收功率(RP)不稳定标志
			fg_adc_avg_cnt				DBIT ; // ADC平均计数标志
		    	fg_RXCoilD				DBIT ; // 接收端为D型线圈标志
		    	fg_NoChange				DBIT ; // (可能用于初始化)无变化标志
		    	fg_IsenSmall				DBIT ; // 电流过小标志
		    	fg_IsenBig				DBIT ; // 电流过大标志
		    	fg_WaitNextCE				DBIT ; // 等待下一个CE包标志
		    	fg_CEThr				DBIT ; // CE阈值相关标志
		    	fg_CEThrPana				DBIT ; // 针对松下设备的CE阈值标志
			fg_IsenFirst				DBIT ; // 首次电流采样标志
			fg_PLLDown				DBIT ; // PLL频率降低标志
			fg_PLLPana				DBIT ; // 针对松下设备的PLL标志
			fg_DetectVin				DBIT ; // 检测到有效输入电压标志
			fg_VinLow				DBIT ; // 输入电压过低标志
			fg_PLL205				DBIT ; // PLL频率达到205kHz标志
			fg_DTCPR				DBIT ; // 占空比相关标志
			fg_DTCPRmin				DBIT ; // 最小占空比标志
			fg_PLLThr				DBIT ; // PLL频率阈值相关标志
			fg_Ping					DBIT ; // 处于Ping阶段标志
			fg_FODEfficLow				DBIT ; // FOD效率过低标志
			fg_ReCordTemp				DBIT ; // 记录温度标志
			fg_CalTempTimeHigh			DBIT ; // 计算温度时间过长标志
			fg_PowOver5wLEDsw			DBIT ; // 功率超过5W，LED切换标志
			fg_DemoDetect				DBIT ; // 解调检测标志
			fg_DemoDetectTimeOut			DBIT ; // 解调检测超时标志
   			fg_RxTI					DBIT ; // 接收端为TI设备标志
    			fg_RxPana				DBIT ; // 接收端为松下设备标志
			a_SSP0x01_B0				DB	? ; // 存储信号强度包(0x01)数据
			a_CSP0x05_B0				DB	? ; // 存储能力包(0x05)数据
			a_PCHO0x06_B0				DB	? ; // 存储功率控制保持包(0x06)数据
			a_Config0x51_B0				DB	? ; // 存储配置包(0x51)数据字节0
			a_Config0x51_B2                 	DB	? ; // ...字节2
			a_Config0x51_B3                 	DB	? ; // ...字节3
			a_IP0x71_B0				DB	? ; // 存储身份包(0x71)数据字节0
			a_IP0x71_B1				DB	? ; // ...字节1
			a_IP0x71_B2				DB	? ; // ...字节2
			a_IP0x71_B3				DB	? ; // ...字节3
			a_IP0x71_B4				DB	? ; // ...字节4
			a_IP0x71_B5				DB	? ; // ...字节5
			a_IP0x71_B6				DB	? ; // ...字节6
			a_ExIP0x81_B0				DB	? ; // 存储扩展身份包(0x81)数据字节0
			a_ExIP0x81_B1				DB	? ; // ...
			a_ExIP0x81_B2                   	DB	?
			a_ExIP0x81_B3                   	DB	?
			a_ExIP0x81_B4                   	DB	?
			a_ExIP0x81_B5                   	DB	?
			a_ExIP0x81_B6                   	DB	?
			a_ExIP0x81_B7                   	DB	?
			a_0x03ContlErr				DB	? ; // 存储控制错误包(0x03)数据
			a_0x04ReceivedPow			DB	? ; // 存储当前接收功率包(0x04)数据
			a_0x04ReceivedPowPre			DB	? ; // 存储上一次接收功率包(0x04)数据
			a_0x06TdelayML				DB	? ; // 存储延时值低位
			a_0x06TdelayMH				DB	? ; // 存储延时值高位
			a_StatusEndPower			DB	? ; // 存储结束充电状态
			a_OptConfiCNT				DB	? ; // 可选配置包计数器
			a_0x51PowMax				DB	? ; // 存储最大功率值
			a_0x04ReceiPowCNTH			DB	? ; // 接收功率计数器高位
			a_0x04ReceiPowCNTL			DB	? ; // 接收功率计数器低位
			a_ParPLLFHpre				DB	?		;;(Record for Isen) // 存储上一次的PLL频率高位(用于电流采样)
			a_ParPLLFLpre				DB	?		;;(Record for Isen) // 存储上一次的PLL频率低位(用于电流采样)
		    	a_Carry					DB	? ; // 进位标志/变量
		    	a_r_DetectCNT				DB	? ; // 物体检测计数器
		    	a_r_RPowCNT				DB	? ; // 接收功率计数器
		    	a_TempH					DB	? ; // 温度值高位
		    	a_TempL					DB	? ; // 温度值低位


;===========================================================================================
;Function :   PUBLIC // 函数: 公共变量声明
;Note     :   // 将此文件中定义的所有变量声明为公共的，以便其他汇编文件可以引用它们
;===========================================================================================
PUBLIC			a_ParPLLFH			
PUBLIC			a_ParPLLFL			
PUBLIC			fg_BaseTimeCTM			
PUBLIC			fg_MutipleTimeHflagCTM		
PUBLIC			a_MutipleTimeLCTM		
PUBLIC			a_MutipleTimeHCTM		
PUBLIC			fg_BaseTimeSTM			
PUBLIC			fg_MutipleTimeHflagSTM		
PUBLIC			fg_TimeOut			
PUBLIC			a_MutipleTimeLSTM		
PUBLIC			a_MutipleTimeHSTM		
PUBLIC			fg_FlagDemo			
PUBLIC			a_DemoV_I1_I2			
PUBLIC			fg_INT1				
PUBLIC			fg_INT0				
PUBLIC			fg_DUDataStart			
PUBLIC			fg_DU				
PUBLIC			fg_StartBit			
PUBLIC			fg_ParityBit			
PUBLIC			fg_ParityErr			
PUBLIC			fg_StopBit			
PUBLIC			fg_WaitDataOut			
PUBLIC			fg_StopBitPre			
PUBLIC			fg_DataFirst			
PUBLIC			fg_Preamble			
PUBLIC			fg_ChecksumBit			
PUBLIC			fg_PacDataOK			
PUBLIC			fg_StartReci			
PUBLIC			fg_DataByteCNTFull		
PUBLIC			a_StatusCntInt1			
PUBLIC			a_DataOUTtemp			
PUBLIC			a_DataParityCNT			
PUBLIC			a_TimeOutCNT			
PUBLIC			a_DataOUT			
PUBLIC			a_DataCNT			
PUBLIC			a_Preamble4BitCNT		
PUBLIC			a_Preamble25BitCNT		
PUBLIC			a_NoToggleCNT			
PUBLIC			a_DataByteCNT			
PUBLIC			a_DataByteCNTtemp		
PUBLIC			a_AddrDataOUT			
PUBLIC			a_HeadMessageCNT		
PUBLIC			a_ContlDataMessag		
PUBLIC			a_DataHeader			
PUBLIC			a_DataMessageB0			
PUBLIC			a_DataMessageB1             	
PUBLIC			a_DataMessageB2             	
PUBLIC			a_DataMessageB3             	
PUBLIC			a_DataMessageB4             	
PUBLIC			a_DataMessageB5             	
PUBLIC			a_DataMessageB6             	
PUBLIC			a_DataMessageB7             	
PUBLIC			a_DataChecksum			
PUBLIC			a_XORchecksum			
PUBLIC			fg_INT_AD			
PUBLIC			a_ADRHbuffer			
PUBLIC			a_ADRLbuffer			
PUBLIC			a_com1				
PUBLIC			a_com2				
PUBLIC			a_com3				
PUBLIC			a_com4				
PUBLIC			a_data0				
PUBLIC			a_data1				
PUBLIC			a_data2				
PUBLIC			a_data3				
PUBLIC			a_data4				
PUBLIC			a_data5				
PUBLIC			a_data6				
PUBLIC			a_data7				
PUBLIC			a_to0				
PUBLIC			a_to1				
PUBLIC			a_to2                           
PUBLIC			a_to3                           
PUBLIC			a_to4                           
PUBLIC			a_to5                           
PUBLIC			a_to6                           
PUBLIC			a_to7                           
PUBLIC			a_count0			
PUBLIC			a_temp2                         
PUBLIC			a_temp1                         
PUBLIC			a_temp0                         
PUBLIC			fg_PIDIni			
PUBLIC			fg_start			
PUBLIC			fg_IterationStart		
PUBLIC			fg_FODTemp60
PUBLIC			a_IL              	   	
PUBLIC			a_IM0                 		
PUBLIC			a_IM1                 		
PUBLIC			a_VL				
PUBLIC			a_VM0				
PUBLIC			a_VM1				
PUBLIC			a_EL				
PUBLIC			a_EM				
PUBLIC			a_EH				
PUBLIC			a_Sv				
PUBLIC			a_LoopIteration			
PUBLIC			fg_0x02PowDownChargeComplete    
PUBLIC			fg_0x02PowDownReconfigure       
PUBLIC			fg_0x02PowDownNoResponse        
PUBLIC			fg_ExIdet0x81			
PUBLIC			fg_Idet				
PUBLIC			fg_Tdelay			
PUBLIC			fg_0x04OutReceiPowTime		
PUBLIC			fg_0x51PowClass			
PUBLIC			fg_0x51NonPID			
PUBLIC			fg_EndPowDown			
PUBLIC			fg_CEinput			
PUBLIC			fg_0x04ReceiPowCNTHflag		
PUBLIC			fg_PSVin			
PUBLIC			fg_PCH0x06Abnor			
PUBLIC			fg_RecodeRPpre			
PUBLIC			fg_RPNoStable			
PUBLIC			fg_adc_avg_cnt			
PUBLIC		    	fg_RXCoilD			
PUBLIC		    	fg_NoChange			
PUBLIC		    	fg_IsenSmall			
PUBLIC		    	fg_IsenBig			
PUBLIC		    	fg_WaitNextCE			
PUBLIC		    	fg_CEThr			
PUBLIC		    	fg_CEThrPana			
PUBLIC			fg_IsenFirst			
PUBLIC			fg_PLLDown			
PUBLIC			fg_PLLPana			
PUBLIC			fg_DetectVin			
PUBLIC			fg_VinLow			
PUBLIC			fg_PLL205			
PUBLIC			fg_DTCPR			
PUBLIC			fg_DTCPRmin			
PUBLIC			fg_PLLThr			
PUBLIC			fg_Ping				
PUBLIC			fg_FODEfficLow			
PUBLIC			fg_ReCordTemp			
PUBLIC			fg_CalTempTimeHigh		
PUBLIC			fg_PowOver5wLEDsw		
PUBLIC			fg_DemoDetect			
PUBLIC			fg_DemoDetectTimeOut		
PUBLIC           	fg_RxTI				
PUBLIC           	fg_RxPana			
PUBLIC			a_SSP0x01_B0			
PUBLIC			a_CSP0x05_B0			
PUBLIC			a_PCHO0x06_B0			
PUBLIC			a_Config0x51_B0			
PUBLIC			a_Config0x51_B2                 
PUBLIC			a_Config0x51_B3                 
PUBLIC			a_IP0x71_B0			
PUBLIC			a_IP0x71_B1			
PUBLIC			a_IP0x71_B2			
PUBLIC			a_IP0x71_B3			
PUBLIC			a_IP0x71_B4			
PUBLIC			a_IP0x71_B5			
PUBLIC			a_IP0x71_B6			
PUBLIC			a_ExIP0x81_B0			
PUBLIC			a_ExIP0x81_B1			
PUBLIC			a_ExIP0x81_B2                   
PUBLIC			a_ExIP0x81_B3                   
PUBLIC			a_ExIP0x81_B4                   
PUBLIC			a_ExIP0x81_B5                   
PUBLIC			a_ExIP0x81_B6                   
PUBLIC			a_ExIP0x81_B7                   
PUBLIC			a_0x03ContlErr			
PUBLIC			a_0x04ReceivedPow		
PUBLIC			a_0x04ReceivedPowPre		
PUBLIC			a_0x06TdelayML			
PUBLIC			a_0x06TdelayMH			
PUBLIC			a_StatusEndPower		
PUBLIC			a_OptConfiCNT			
PUBLIC			a_0x51PowMax			
PUBLIC			a_0x04ReceiPowCNTH		
PUBLIC			a_0x04ReceiPowCNTL		
PUBLIC			a_ParPLLFHpre			
PUBLIC			a_ParPLLFLpre			
PUBLIC		    	a_Carry				
PUBLIC		    	a_r_DetectCNT			
PUBLIC		    	a_r_RPowCNT			
PUBLIC		    	a_TempH				
PUBLIC		    	a_TempL				
   

END