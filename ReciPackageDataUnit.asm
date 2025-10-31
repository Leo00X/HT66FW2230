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
PUBLIC		ReciPackageDataUnitPreee1 ; // 声明 ReciPackageDataUnitPreee1 子程序为公共，用于接收数据包的前导码部分
PUBLIC		ReciPackageDataUnit ; // 声明 ReciPackageDataUnit 子程序为公共，用于接收完整的数据包

; // 声明外部函数（在其他文件中定义）
EXTERN		DelayTimer				:	near ; // 精确延时函数 (使用 CTM)
EXTERN		INTTimer				:	near ; // 基于定时器的中断检测循环
EXTERN		INTCheck				:	near ; // 设置中断检测的定时器

; // 声明外部变量（在其他文件中定义）
EXTERN		a_r_DetectCNT			        :	byte ; // 物体检测计数器
EXTERN		a_MutipleTimeLCTM		        :	byte ; // CTM 长延时计数器低位
EXTERN		a_MutipleTimeHCTM		        :	byte ; // CTM 长延时计数器高位
EXTERN		a_DemoV_I1_I2			        :	byte ; // 解调/中断方式选择变量
EXTERN		a_MutipleTimeLSTM		        :	byte ; // STM 长延时计数器低位
EXTERN		a_MutipleTimeHSTM		        :	byte ; // STM 长延时计数器高位
EXTERN		fg_FlagDemo			        :	bit ; // 解调中断标志
EXTERN		fg_INT1				        :	bit ; // 外部中断 1 标志
EXTERN		fg_DemoDetect			        :	bit ; // 解调检测标志
EXTERN		fg_DemoDetectTimeOut			:	bit ; // 解调检测超时标志
EXTERN		fg_TimeOut			        :	bit ; // 通用超时标志
EXTERN		fg_MutipleTimeHflagCTM		        :	bit ; // CTM 长延时高位标志

EXTERN		fg_DUDataStart				:	bit ; // 数据单元开始标志
EXTERN		fg_DU					:	bit ; // 数据单元标志 (表示当前电平是高还是低)
EXTERN		fg_StartBit				:	bit ; // 起始位解码状态标志
EXTERN		fg_ParityBit				:	bit ; // 奇偶校验位解码状态标志
EXTERN		fg_ParityErr				:	bit ; // 奇偶校验错误标志
EXTERN		fg_StopBit				:	bit ; // 停止位解码状态标志
EXTERN		fg_WaitDataOut				:	bit ; // 等待数据输出标志
EXTERN		fg_StopBitPre				:	bit ; // 上一个停止位标志
EXTERN		fg_DataFirst				:	bit ; // 第一个数据包标志
EXTERN		fg_Preamble				:	bit ; // 前导码解码状态标志
EXTERN		fg_ChecksumBit				:	bit ; // 校验和解码状态标志
EXTERN		fg_StartReci				:	bit ; // 开始接收标志
EXTERN		fg_DataByteCNTFull			:	bit ; // 数据字节计数满标志
EXTERN		a_StatusCntInt1				:	byte ; // 中断状态计数器 (可能用于区分边沿)
EXTERN		a_DataOUTtemp				:	byte ; // 临时存储正在接收的数据字节
EXTERN		a_DataParityCNT				:	byte ; // 奇偶校验计数器
EXTERN		a_TimeOutCNT				:	byte ; // 位接收超时计数器
EXTERN		a_DataOUT				:	byte ; // 接收数据包缓冲区 (10 字节)
EXTERN		a_DataCNT				:	byte ; // 字节内数据位计数器
EXTERN		a_Preamble4BitCNT			:	byte ; // 前导码计数器 (4-bit)
EXTERN		a_Preamble25BitCNT			:	byte ; // 前导码计数器 (25-bit, 用于超时)
EXTERN		a_NoToggleCNT				:	byte ; // 线路无翻转超时计数器
EXTERN		a_DataByteCNT				:	byte ; // 数据包字节计数器
EXTERN		a_DataByteCNTtemp			:	byte ; // 数据包字节计数器临时变量
EXTERN		a_AddrDataOUT				:	byte ; // 指向 a_DataOUT 缓冲区的地址指针


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
ReciPackageDataUnit		.Section 	'code' ; // 定义代码段名称为 ReciPackageDataUnit
;========================================================
;Function : ReciPackageDataUnitPreee1 // 函数：接收数据包前导码
;Note     : Call Function Type for Detection // 注释：调用检测函数类型
;input    : // 输入：无
;output   : // 输出：无 (修改状态标志和计数器)
;========================================================
	ReciPackageDataUnitPreee1:
			MOV	A, 00EH					;; without ReciPackageDataUnitPre // 设置检测计数器初始值 (0xE)
			MOV	a_r_DetectCNT, A
	RPDUP_INTcheck: ; // 循环检测中断的入口
			CLR WDT ; // 清除看门狗
			MOV	A, c_IniComBy0MutipleTimeL		; 100us // 加载短延时 (100us) 低位
			MOV	a_MutipleTimeLCTM, A ; // 设置 CTM 低位
			MOV	A, c_IniComBy0MutipleTimeH ; // 加载短延时高位
			MOV	a_MutipleTimeHCTM, A ; // 设置 CTM 高位
			SZ	a_MutipleTimeHCTM ; // 检查高位是否为 0
			SET	fg_MutipleTimeHflagCTM ; // 不为 0 则设置高位标志

			CALL	DelayTimer ; // 执行 100us 延时
			SET	fg_INT1 ; // 重置 INT1 中断标志 (准备接收)
			;SET	fg_INT0 ; // (注释掉)
			SET	fg_FlagDemo	;3 // 重置解调中断标志 (准备接收)
			MOV	A, c_IniComByMutipleTimeL0		; 250us // 加载检测窗口时间 (250us) 低位
			MOV	a_MutipleTimeLCTM, A ; // 设置 CTM 低位
			MOV	A, c_IniComByMutipleTimeH0 ; // 加载检测窗口时间高位
			MOV	a_MutipleTimeHCTM, A ; // 设置 CTM 高位
			SZ	a_MutipleTimeHCTM ; // 检查高位是否为 0
			SET	fg_MutipleTimeHflagCTM ; // 不为 0 则设置高位标志

			CALL	INTTimer ; // 启动定时器并等待中断或超时
			SNZ	fg_TimeOut ; // 检查是否超时 (INTTimer 返回后 fg_TimeOut=1 表示未超时/收到中断)
			RET ; // 如果超时 (fg_TimeOut=0)，则直接返回

	RPDUP_INT_DEMO1:;;; // 收到中断信号
			SNZ	a_DemoV_I1_I2.0 ; // 检查当前选择的是否是方式 1 (DEM)
			JMP	RPDUP_INT_DEMO2;;; // 不是，跳转

			SZ	fg_FlagDemo	;4	; // 是方式 1，检查解调中断标志是否为 0 (0 表示收到了 DEM 中断)
			JMP	RPDUP_Recheck;;; // 为 1 (未收到 DEM 中断，可能是误触发或定时器中断)，跳转到重试逻辑
			JMP	RPDUP_INT;;; // 为 0 (收到了 DEM 中断)，跳转到处理中断逻辑
	RPDUP_INT_DEMO2:;;;
			SZ	fg_INT1	;4 ; // 不是方式 1，检查外部中断 1 标志是否为 0 (0 表示收到了 INT1 中断)
			JMP	RPDUP_Recheck;;; // 为 1 (未收到 INT1 中断)，跳转到重试逻辑

			;JMP	RPDUP_INT;;; // 为 0 (收到了 INT1 中断)，跳转到处理中断逻辑 (代码中被注释掉了，会直接执行下面的 RPDUP_INT)
	RPDUP_INT:		
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF // 停止定时器 TM1
			SET	fg_INT1 ; // 重置 INT1 标志 (为下一次检测准备)
			;SET	fg_INT0
			SET	fg_FlagDemo	;5 ; // 重置解调标志 (为下一次检测准备)
			SDZ	a_r_DetectCNT ; // 检测计数器减 1，如果结果为 0 则跳过
			JMP	RPDUP_INTcheck ; // 计数未到 0，继续循环检测中断

			; // 计数到 0 (连续检测到指定次数的中断信号，认为前导码有效)
			RET ; // 返回，表示前导码接收成功
	RPDUP_Recheck: ; // 未在指定时间内检测到有效中断
			MOV	A, 00EH ; // 重置检测计数器
			MOV	a_r_DetectCNT, A
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF // 停止定时器 TM1
			SET	fg_INT1 ; // 重置中断标志
			;SET	fg_INT0
			SET	fg_FlagDemo ; // 重置解调标志
			SNZ	fg_DemoDetect ; // 检查 Demo 检测标志 (可能是功率传输阶段使用的)
			JMP	RPDUP_INTcheck ; // 如果 fg_DemoDetect=0 (非功率传输阶段?)，则重新开始检测

			; // 如果 fg_DemoDetect=1 (功率传输阶段?)
			MOV	A, a_MutipleTimeHSTM ; // 获取 STM 定时器的高位值
			SUB	A, 053H					;;53F7h   807Fh-2C88h(570ms)=53F7h // 减去一个常量 (似乎是检查剩余时间是否足够?)
			SZ	STATUS.0 ; // 检查借位标志
			JMP	RPDUP_INTcheck ; // 如果没有借位 (剩余时间足够?)，重新开始检测
			;JMP	TO_Repeat_L1
	TO_Repeat_L1: ; // (似乎是高位相减发生借位后的补充检查)
			MOV	A, a_MutipleTimeLSTM ; // 获取 STM 定时器的低位值
			SUB	A, 0F7H					;;53F7h   807Fh-2C88h(570ms)=53F7h // 减去常量
			SZ	STATUS.0 ; // 检查借位标志
			JMP	RPDUP_INTcheck ; // 如果没有借位，重新开始检测
	TO_Repeat_H: ; // (如果两次相减都发生借位，表示时间不足?)
			SET	fg_DemoDetectTimeOut ; // 设置 Demo 检测超时标志
			CLR	fg_DemoDetect ; // 清除 Demo 检测标志
			RET ; // 返回


;========================================================
;Function : ReciPackageDataUnit // 函数：接收完整的数据包 (包括包头、消息、校验和)
;Note     : Call Function Type for Package Data // 注释：调用包数据函数类型
;input    : (1) INT signal Rising/Falling // 输入：中断信号的上升沿/下降沿
;output   : (1) a_DataOUT by IAR0 for Header, Message, checksum // 输出：数据存入 a_DataOUT 缓冲区
;	    (2) a_DataByteCNTtemp for CNT Header, Message, checksum data byte times // 输出：接收到的字节数存入 a_DataByteCNTtemp
;	    (3) a_AddrDataOUT for MP0 // 输出：MP0 指向 a_DataOUT 缓冲区的下一个位置
;	    (4) fg_ChecksumBit(to detect checksum stop)(Default=0, True(OK)=1) // 输出：fg_ChecksumBit 标志 (如果接收到校验和则置位)
;========================================================
	ReciPackageDataUnit:
			MOV	A, 001H ; // 初始化状态计数器为 1
			MOV	a_StatusCntInt1, A
	;--------------------Data Latch------------------------- ; // 数据锁存部分
	DU_DataLatch: ; // 每次检测到边沿中断后进入
			CLR WDT ; // 清狗
			SET	fg_INT1 ; // 重置 INT1 标志
			;SET	fg_INT0
			SET	fg_FlagDemo ; // 重置解调标志
			SNZ	fg_StopBitPre				;;default=1 // 检查上一个停止位标志是否为 1 (正常帧结束后应为 1)
			CLR	fg_StopBit ; // 如果上一个停止位为 0 (异常?)，则清除当前停止位标志 (准备重新同步?)

			SZ	fg_DUDataStart				;;default=1 // 检查数据单元开始标志是否为 0
			JMP	DU_DataLatchCheck ; // 为 0，跳转

			; // 为 1 (表示这是一个数据单元的中间边沿)
			MOV	A, a_StatusCntInt1 ; // 获取状态计数器
			XOR	A, 001H ; // 翻转最低位 (用于区分上升沿/下降沿或高低电平?)
			MOV	a_StatusCntInt1, A ; // 保存翻转后的值
	DU_DataLatchCheck:
			CLR WDT ; // 清狗
			SZ	a_StatusCntInt1				;;default=1 // 检查状态计数器是否为 0 (可能是判断电平?)
			JMP	DU_DataLatchCheck1 ; // 为 0，跳转

			; // 不为 0
			SNZ	fg_StopBit				;;default=1 // 检查停止位标志是否为 1 (正常应为 1)
			JMP	DU_DataLatchCheck1 ; // 为 0 (异常?)，跳转

			; // 状态计数器不为 0 且停止位标志为 1
			SZ	fg_StartBit				;;default=1 // 检查起始位标志是否为 1 (等待起始位?)
			JMP	DU_DataStart ; // 为 0 (已收到起始位)，跳转到数据处理

			; // 为 1 (正在等待起始位)
			JMP	DU_DataOUTcnt ; // 跳转到数据位计数处理 (此时应跳过数据处理逻辑)
	DU_DataStart: ; // 检测到起始位 (通常是一个下降沿?)
			CLR WDT ; // 清狗
			CLR	fg_StartBit ; // 清除起始位标志 (表示已收到)
			CLR	fg_WaitDataOut ; // 清除等待数据输出标志
			JMP	DU_DataLatchCheck ; // 跳回检查逻辑 (等待下一个边沿)
	DU_DataOUTcnt: ; // 处理数据位/奇偶校验位/停止位
			SZ	fg_WaitDataOut ; // 检查等待数据输出标志是否为 0 (0 表示起始位刚过，不处理数据)
			JMP	DU_DataLatchCheck1 ; // 为 0，跳转到等待下一个中断

			; // 为 1 (表示可以处理数据/校验/停止位)
			SET	fg_WaitDataOut ; // (这个 SET 似乎多余，前面已经判断了它为 1)
			SDZ	a_DataCNT ; // 数据位计数器减 1，结果为 0 则跳过 (0 表示当前是停止位)
			JMP	DU_DataOUT ; // 不为 0，跳转到处理数据位/奇偶校验位

			; // 为 0 (当前是停止位)
			;JMP	DU_DataOUTParCheck ; // (代码被注释掉，跳转到下一行)
	DU_DataOUTParCheck: ; // 处理奇偶校验位 (实际上是在 a_DataCNT=1 时执行，即停止位之前)
			SZ	fg_DU ; // 检查数据单元标志 (记录了奇偶校验位的电平)
			SET	fg_ParityBit ; // 如果 fg_DU=0 (低电平)，设置 fg_ParityBit=1

			SZ	a_DataParityCNT.0 ; // 检查已接收数据位中 '1' 的个数是奇数还是偶数 (最低位为 0 是偶数，1 是奇数)
			JMP	DU_DataOUTParCheckOd			;fg_ParityBit=0 // 偶数个 '1'，跳转
		
			JMP	DU_DataOUTParCheckEv			;fg_ParityBit=1 // 奇数个 '1'，跳转
	DU_DataOUTParCheckOd: ; // 偶校验
			SNZ	fg_ParityBit ; // 检查接收到的奇偶校验位是否为 1
			JMP	DU_DataOUTParCheck0 ; // 为 0 (校验正确)，跳转

			SET	fg_ParityErr ; // 为 1 (校验错误)，设置错误标志
			JMP	DU_DataOUTParCheck0
	DU_DataOUTParCheckEv: ; // 奇校验
			SZ	fg_ParityBit ; // 检查接收到的奇偶校验位是否为 0
			JMP	DU_DataOUTParCheck0 ; // 为 1 (校验正确)，跳转

			SET	fg_ParityErr ; // 为 0 (校验错误)，设置错误标志
			JMP	DU_DataOUTParCheck0
	DU_DataOUTParCheck0: ; // 奇偶校验处理完成
			CLR WDT ; // 清狗
			SET	fg_DU ; // 重置数据单元标志
			CLR	a_DataParityCNT ; // 清除奇偶校验计数器
			CLR	fg_StopBitPre ; // 清除上一个停止位标志 (准备接收停止位)
			JMP	DU_DataLatchCheck1 ; // 跳转等待下一个中断 (停止位)
	DU_DataOUT: ; // 处理数据位
			CLR WDT ; // 清狗
			SZ	fg_DU ; // 检查数据单元标志 (记录了数据位的电平)
			JMP	DU_DataOUThigh ; // 为 0 (低电平)，跳转
	
			JMP	DU_DataOUTlow ; // 为 1 (高电平)，跳转
	DU_DataOUThigh: ; // 数据位为高电平 ('1')
			SET	a_DataOUTtemp.7 ; // 将 '1' 移入临时字节的最高位
			INC	a_DataParityCNT ; // 奇偶校验计数器加 1
			MOV	A, 00BH ; // 重置位超时计数器
			MOV	a_TimeOutCNT, A
			JMP	DU_DataOUTRR ; // 跳转到右移处理			
	DU_DataOUTlow: ; // 数据位为低电平 ('0')
			CLR	a_DataOUTtemp.7 ; // 将 '0' 移入临时字节的最高位

			SDZ	a_TimeOutCNT ; // 位超时计数器减 1，结果为 0 则跳过 (如果连续低电平超时，会跳到 DU_End)
			JMP	DU_DataOUTRR ; // 未超时，跳转到右移处理

			JMP	DU_End ; // 超时，跳转到结束处理
	DU_DataOUTRR:				
			MOV	A, a_DataCNT ; // 获取当前位计数
			XOR	A, 001H ; // 检查是否是最后一个数据位 (a_DataCNT=1 时异或结果为 0)
			SNZ	STATUS.2 				;;1=True // 如果不是最后一个数据位 (结果不为 0)
			RR	a_DataOUTtemp ; // 将临时字节右循环移位一位 (准备接收下一位)

			SET	fg_DU ; // 重置数据单元标志
			;JMP	DU_DataLatchCheck1 ; // 跳转等待下一个中断
	DU_DataLatchCheck1:					
			CLR WDT ; // 清狗
	
	;--------------------INT Capture & Time------------------------- ; // 中断捕获与计时
	DU_TimerINT:
			SET	fg_INT1 ; // 重置中断标志
			;SET	fg_INT0
			SET	fg_FlagDemo ; // 重置解调标志
			CALL	INTCheck ; // 设置 CTM 定时器并等待中断或超时
			SNZ	fg_TimeOut ; // 检查是否超时
			JMP	DU_End ; // 超时，跳转结束

			; // 未超时，收到了中断
			;SZ	fg_INT1
	DU_INT_DEMO1: ; // 判断中断来源
			SNZ	a_DemoV_I1_I2.0 ; // 是否是方式 1 (DEM)
			JMP	DU_INT_DEMO2 ; // 不是，跳转

			SZ	fg_FlagDemo ; // 是方式 1，检查 DEM 标志是否为 0
			JMP	DU_Out ; // 为 1 (不是 DEM 中断)，跳转到异常处理

			JMP	DU_INT ; // 为 0 (是 DEM 中断)，跳转到中断处理
	DU_INT_DEMO2:
			SZ	fg_INT1	;4 ; // 不是方式 1，检查 INT1 标志是否为 0
			JMP	DU_Out ; // 为 1 (不是 INT1 中断)，跳转到异常处理
			;JMP	DU_INT					;enable when having DU_INT_DEMO3 ; // 为 0 (是 INT1 中断)，跳转到中断处理 (代码注释掉了)
	
	;DU_INT_DEMO3: ... (注释掉的代码)

	DU_INT:		; // 有效中断处理入口
			CLR	TM1C0.3					; TM1C0[3] (T1ON-bit) = 0 as TM1 OFF // 停止 CTM 定时器

	DU_INT_1:
			SET	fg_INT1 ; // 重置中断标志
			;SET	fg_INT0
			SET	fg_FlagDemo ; // 重置解调标志
			;------------------Preamble CNT 4bit---------------- ; // 前导码 4 位计数器处理
			CLR WDT ; // 清狗
			SNZ	fg_Preamble				;;default=1 // 检查是否处于前导码接收阶段
			JMP	DU_INTcheck0 ; // 不是，跳转

			; // 是前导码阶段
			SDZ	a_Preamble4BitCNT			;;default=7 // 前导码计数减 1
			JMP	DU_DataLatch ; // 未减到 0，跳转回数据锁存 (继续接收前导码位)

			; // 减到 0 (收到足够的前导码位)
			CLR	fg_Preamble ; // 清除前导码标志
	DU_INTcheck0:				
			MOV	A, 002H ; // 重置无翻转超时计数器
			MOV	a_NoToggleCNT, A
			SZ	fg_StartReci				;;default=1 // 检查是否是第一次接收数据包
			JMP	DU_INTcheck01 ; // 不是，跳转

			; // 是第一次接收
			JMP	DU_INTcheck02 ; // 跳转 (跳过了前导码超时检查?)
	DU_INTcheck01:
			SDZ	a_Preamble25BitCNT ; // 前导码超时计数器减 1
			JMP	DU_INTcheck02 ; // 未减到 0，跳转

			; // 减到 0 (前导码接收超时)
			JMP	DU_End ; // 跳转结束
	DU_INTcheck02:
			SZ	fg_StartBit				;;default=1 // 检查是否在等待起始位
			JMP	DU_INTcheck1 ; // 不是，跳转

			; // 是 (说明刚刚收到的是起始位)
			CLR	fg_WaitDataOut ; // 清除等待数据输出标志
			CLR	fg_StartReci ; // 清除首次接收标志
	DU_INTcheck1:		
			SZ	fg_StopBit				; default=1 // 检查是否在等待停止位
			JMP	DU_DataLatch ; // 不是，跳转回数据锁存 (处理数据位/校验位)

			; // 是 (说明刚刚收到的是停止位)
			;--------------------Data OUT------------------------- ; // 处理接收到的完整字节
			SNZ	fg_DataFirst				; default=1 // 检查是否是第一个字节
			JMP	DU_INTcheck2 ; // 不是，跳转

			; // 是第一个字节
			MOV	A, offset a_DataOUT ; // 获取数据缓冲区地址
			MOV	a_AddrDataOUT, A ; // 保存地址
			MOV	MP0, A ; // 设置间接寻址指针 MP0
			CLR	fg_DataFirst ; // 清除第一个字节标志
	DU_INTcheck2:		
			CLR WDT ; // 清狗
			SZ	fg_DataByteCNTFull ; // 检查数据包是否已接收满 (11 字节?)
			JMP	DU_INTcheck3 ; // 未满，跳转

			; // 已满
			MOV	A, a_DataOUTtemp ; // 获取刚接收的最后一个字节 (校验和)
			MOV	IAR0, A ; // 存入缓冲区
			INC	a_DataByteCNT ; // 字节计数加 1
			MOV	A, a_DataByteCNT
			MOV	a_DataByteCNTtemp, A ; // 更新字节计数临时变量
			INC	MP0 ; // 指针加 1
			MOV	A, a_DataByteCNT
			XOR	A, 00BH ; // 检查是否达到 11 字节
			SZ	STATUS.2
			SET	fg_DataByteCNTFull ; // 如果达到则设置满标志
	DU_INTcheck3:	
			SET	fg_DUDataStart ; // 重置数据单元开始标志
			SET	fg_StartBit ; // 重置起始位标志 (准备接收下一字节)
			SET	fg_StopBit ; // 重置停止位标志
			SET	fg_StopBitPre ; // 重置上一个停止位标志
			CLR	fg_ParityBit ; // 清除奇偶校验位标志
			CLR	fg_ParityErr ; // 清除奇偶校验错误标志
			CLR	a_DataParityCNT ; // 清除奇偶校验计数器
			CLR	a_DataOUTtemp ; // 清除临时字节缓冲
			MOV	A, 00BH ; // 重置位超时计数器
			MOV	a_TimeOutCNT, A
			MOV	A, 00AH ; // 重置字节内位计数器 (1 起始 + 8 数据 + 1 奇偶)
			MOV	a_DataCNT, A
			JMP	DU_DataLatch ; // 跳转回数据锁存，开始接收下一字节
	DU_Out:		; // 异常处理 (中断标志与当前模式不符，或定时器中断?)
			CLR WDT ; // 清狗
	DU_Out_1:		
			SZ	fg_Preamble ; // 检查是否在前导码阶段
			JMP	DU_OutPre0 ; // 是，跳转

			JMP	DU_OutPre1 ; // 不是，跳转
	DU_OutPre0:		
			JMP	DU_DataLatch ; // 跳转回数据锁存 (可能是前导码接收错误?)
	DU_OutPre1:		
			SDZ	a_NoToggleCNT ; // 无翻转超时计数减 1
			JMP	DU_Out0 ; // 未减到 0，跳转

			; // 减到 0 (线路长时间无翻转)
			SZ	a_DataByteCNTtemp ; // 检查是否已接收到部分字节
			SET	fg_ChecksumBit				;Mark checksum stop-bit // 如果接收到字节，则设置校验和标志 (强制结束?)

			JMP	DU_End ; // 跳转结束
	DU_Out0:
			CLR	fg_DU ; // 清除数据单元标志
			SZ	fg_StartBit				;;defualt=1 // 检查是否在等待起始位
			JMP	DU_Out1 ; // 不是，跳转

			CLR	fg_WaitDataOut ; // 是，清除等待数据标志
	DU_Out1:
			CLR	fg_DUDataStart ; // 清除数据单元开始标志
			SZ	fg_StopBit				;;default=1 // 检查是否在等待停止位
			JMP	DU_DataLatch ; // 不是，跳转回数据锁存 (可能是数据位接收错误?)
	DU_End: ; // 结束处理 (超时、错误或接收完成校验和)
			CLR WDT ; // 清狗
			; // --- 重置所有状态标志和计数器，为下一次接收做准备 ---
			SET	fg_DUDataStart
			SET	fg_StartBit
			CLR	fg_ParityBit
			CLR	fg_ParityErr
			CLR	a_DataParityCNT
			SET	fg_StopBit
			SET	fg_StopBitPre
			CLR	a_DataOUTtemp
			CLR	a_DataOUTtemp.7
			SET	fg_WaitDataOut
			SET	fg_DU
			MOV	A, 002H
			MOV	a_NoToggleCNT, A
			MOV	A, 00BH
			MOV	a_TimeOutCNT, A
			MOV	A, 00AH
			MOV	a_DataCNT, A
			SET	fg_DataFirst
			SET	fg_Preamble
			MOV	A, 007H
			MOV	a_Preamble4BitCNT, A
			CLR	a_DataByteCNT
			MOV	A, 01DH
			MOV	a_Preamble25BitCNT, A
			SET	fg_StartReci
			RET ; // 返回


END ; // 文件结束