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
PUBLIC			ExtractPacData				; // 声明公共函数：提取数据包内容

EXTERN			DemoCLR					:	near	; // 外部函数：清除解调/通信相关的变量和标志

EXTERN			fg_ChecksumBit				:	bit		; // 外部标志：指示校验和字节是否已接收
EXTERN			fg_PacDataOK				:	bit		; // 外部标志：数据包是否有效（校验和是否匹配）
EXTERN			a_DataByteCNTtemp			:	byte	; // 外部变量：接收到的总字节数（包括包头、消息和校验和）
EXTERN			a_AddrDataOUT				:	byte	; // 外部变量：a_DataOUT 缓冲区的起始地址
EXTERN			a_HeadMessageCNT			:	byte	; // 外部变量：用于遍历数据包字节的计数器
EXTERN			a_ContlDataMessag			:	byte	; // 外部变量：用于控制消息字节提取的位掩码/指针
EXTERN			a_DataHeader				:	byte	; // 外部变量：存储提取出的包头
EXTERN			a_DataMessageB0				:	byte	; // 外部变量：存储提取出的消息字节 0
EXTERN			a_DataMessageB1             :	byte	; // ... 消息字节 1
EXTERN			a_DataMessageB2             :	byte	; // ... 消息字节 2
EXTERN			a_DataMessageB3             :	byte	; // ... 消息字节 3
EXTERN			a_DataMessageB4             :	byte	; // ... 消息字节 4
EXTERN			a_DataMessageB5             :	byte	; // ... 消息字节 5
EXTERN			a_DataMessageB6             :	byte	; // ... 消息字节 6
EXTERN			a_DataMessageB7             :	byte	; // ... 消息字节 7
EXTERN			a_DataChecksum				:	byte	; // 外部变量：存储提取出的校验和字节
EXTERN			a_XORchecksum				:	byte	; // 外部变量：用于本地计算校验和


;*******************************************************************************************
;*****	                            Program Body	                               *****
;*******************************************************************************************
PackageData		.Section 	'code'		; // 定义代码段名称为 PackageData
;========================================================
;Function : ExtractPacData
;Note     : Call Function Type for Packege format 
;		input =  (1) a_AddrDataOUT for a_DataOUT by IAR0 for Header, Message, checksum (a_DataOUT缓冲区基地址)
;			 (2) a_DataByteCNTtemp (接收到的总字节数)
;			 (3) fg_ChecksumBit (Default=0, True(OK)=1) (是否已接收到校验和)
;		output = (1)  a_DataHeader (提取的包头)
;			 (2)  a_DataMessageB0 (提取的消息字节0)
;			 (3)  a_DataMessageB1 (...)
;			 (4)  a_DataMessageB2
;			 (5)  a_DataMessageB3
;			 (6)  a_DataMessageB4
;			 (7)  a_DataMessageB5
;			 (8)  a_DataMessageB6
;			 (9)  a_DataMessageB7
;			 (10) a_DataChecksum (提取的校验和)
;			 (11) fg_PacDataOK (Default=1, True(OK)=0) (校验和是否匹配，0=OK, 1=Error)
;========================================================
	ExtractPacData:
			CLR WDT						; // 清看门狗
			CLR	a_XORchecksum			; // 初始化本地校验和计算器为0
			SNZ	fg_ChecksumBit			; // 检查是否已接收到校验和位 (如果没收到，说明包不完整)
			JMP	EPD_DataMessageEnd		; // 如果 fg_ChecksumBit=0 (包不完整)，直接跳转到结束处理

			DEC	a_DataByteCNTtemp		; // 接收到的总字节数减1 (因为校验和字节不参与计算)
	EPD_DataMessageH:
			MOV	A, a_AddrDataOUT		; // 获取 a_DataOUT 缓冲区的基地址
			ADD	A, a_HeadMessageCNT		; // 加上当前字节偏移量 (a_HeadMessageCNT 初始为0)
			MOV	MP0, A					; // 设置内存指针 MP0 指向该地址
			MOV	A, IAR0					; // 通过 MP0 (IAR0) 间接寻址，读取数据
			MOV	a_DataHeader, A			; // 将第一个字节存为包头
			XORM	A, a_XORchecksum       	; // 将该字节 异或(XOR) 到本地校验和
			JMP	EPD_DataMessageAJ       ; // 跳转到调整指针和计数的公共代码    	
	EPD_DataMessageB:                                       	
			MOV	A, a_AddrDataOUT        ; // 获取 a_DataOUT 缓冲区的基地址    	
			ADD	A, a_HeadMessageCNT     ; // 加上当前字节偏移量
			MOV	MP0, A                  ; // 设置内存指针 MP0 指向该地址
			MOV	A, IAR0                 ; // 通过 MP0 (IAR0) 间接寻址，读取数据
	EPD_DataMessageB0:                                      	
			SNZ	a_ContlDataMessag.0		; // 检查控制位0 (a_ContlDataMessag 初始为 0x80)
										; // 第一次 (Header后)，位7为1，位0为0，跳转
			JMP	EPD_DataMessageB1       ; // 跳转到下一字节检查       	
			MOV	a_DataMessageB0, A      ; // (此行及以下两行不会在第一次循环执行) 
			XORM	A, a_XORchecksum        ; // 将消息字节 异或 到本地校验和
			JMP	EPD_DataMessageAJ       ; // 跳转到调整指针和计数的公共代码   	
	EPD_DataMessageB1:                                      	
			SNZ	a_ContlDataMessag.1		; // 检查控制位1 (初始为0)
			JMP	EPD_DataMessageB2       ; // 跳转到下一字节检查
			MOV	a_DataMessageB1, A      ; // (不会执行)
			XORM	A, a_XORchecksum                	
			JMP	EPD_DataMessageAJ               	
	EPD_DataMessageB2:                                      	
			SNZ	a_ContlDataMessag.2		; // 检查控制位2 (初始为0)
			JMP	EPD_DataMessageB3               	
			MOV	a_DataMessageB2, A              	
			XORM	A, a_XORchecksum                	
			JMP	EPD_DataMessageAJ               	
	EPD_DataMessageB3:                                      	
			SNZ	a_ContlDataMessag.3		; // 检查控制位3 (初始为0)
			JMP	EPD_DataMessageB4               	
			MOV	a_DataMessageB3, A              	
			XORM	A, a_XORchecksum                	
			JMP	EPD_DataMessageAJ               	
	EPD_DataMessageB4:                                      	
			SNZ	a_ContlDataMessag.4		; // 检查控制位4 (初始为0)
			JMP	EPD_DataMessageB5               	
			MOV	a_DataMessageB4, A              	
			XORM	A, a_XORchecksum                	
			JMP	EPD_DataMessageAJ               	
	EPD_DataMessageB5:                                      	
			SNZ	a_ContlDataMessag.5		; // 检查控制位5 (初始为0)
			JMP	EPD_DataMessageB6               	
			MOV	a_DataMessageB5, A              	
			XORM	A, a_XORchecksum                	
			JMP	EPD_DataMessageAJ               	
	EPD_DataMessageB6:                                      	
			SNZ	a_ContlDataMessag.6		; // 检查控制位6 (初始为0)
			JMP	EPD_DataMessageB7               	
			MOV	a_DataMessageB6, A              	
			XORM	A, a_XORchecksum                	
			JMP	EPD_DataMessageAJ               	
	EPD_DataMessageB7:                                      	
			SNZ	a_ContlDataMessag.7		; // 检查控制位7 (初始为1)
			JMP	EPD_DataChecksum		; // 不为0，跳转到校验和处理 (这个跳转永远不会发生，因为我们是从 EPD_DataMessageH 进来的)
			MOV	a_DataMessageB7, A		; // (此行及下一行不会执行)
			XORM	A, a_XORchecksum
	EPD_DataMessageAJ:		
			CLR WDT						; // 清狗
			INC	a_HeadMessageCNT		; // 字节偏移量+1
			RL	a_ContlDataMessag		; // 控制变量左移 (0x80 -> 0x01, 0x02, 0x04 ...)
			MOV	A, a_HeadMessageCNT		; // 获取当前偏移量
			XOR	A, a_DataByteCNTtemp	; // 与总字节数(已减1)比较
			SNZ	STATUS.2 				;;1=True ; // 检查是否相等 (Z=1表示相等)
			JMP	EPD_DataMessageB		; // 如果不相等 (Z=0)，说明还有消息字节未处理，跳回 EPD_DataMessageB

			; // 如果相等 (Z=1)，说明所有消息字节都已处理完毕
			;JMP	EPD_DataChecksum		; // (隐式跳转到下一条指令)
	EPD_DataChecksum:
			MOV	A, a_AddrDataOUT		; // 获取缓冲区基地址
			ADD	A, a_HeadMessageCNT		; // 加上当前偏移量 (现在指向校验和字节)
			MOV	MP0, A					; // 设置 MP0
			MOV	A, IAR0					; // 读取校验和字节
			MOV	a_DataChecksum, A		; // 存储接收到的校验和
	EPD_DataCheck:		
			MOV	A, a_XORchecksum		; // 获取本地计算的校验和
			XOR	A, a_DataChecksum		; // 与接收到的校验和进行异或
			SNZ	STATUS.2				; // 检查结果是否为 0 (Z=1 表示相等，校验通过)
			JMP	EPD_DataMessageEnd		; // 不为 0 (校验失败)，跳转到结束

			CLR	fg_PacDataOK			; // 为 0 (校验成功)，清除 fg_PacDataOK (注意：这里 0 表示 OK，1 表示 Error)
	EPD_DataMessageEnd:
			CLR	a_HeadMessageCNT		; // 清除字节偏移量计数器
			CLR	a_DataByteCNTtemp		; // 清除接收字节数临时变量
			MOV	A, 080H					; // 重置消息字节控制变量
			MOV	a_ContlDataMessag, A
			CLR	a_XORchecksum			; // 清除本地校验和
			CLR	fg_ChecksumBit			; // 清除校验和接收标志
			CALL	DemoCLR					; // 调用 DemoCLR 清理通信状态机 (如 fg_StartBit, a_DataCNT 等)
			CLR	a_AddrDataOUT			; // 清除缓冲区地址指针 (虽然在下次接收时会重新设置，但保持清洁)
			RET							; // 返回

END