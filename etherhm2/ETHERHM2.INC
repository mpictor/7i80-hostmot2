


;TYPES (contents of ram address)
;	<blank>	number of bits is hardware dependent	
;	ptr	10 bit address pointer
;	flag	16 bit value 0 is false, nonzero is true
;	uint	16 bit unsigned value 0..65535
;	int	16 bit signed value -32768..32767
;	ulong	32 bit unsigned value 0..4294967295
;	long	32 bit signed value -2147483648..2147483647
;	double	64 bit signed value -1.8E19..1.8E19

;PARAMETER	VALUE	TYPE	FUNCTION
; local hardware
MinusOne	0FFFFh
MinusFour	0FFFCh
MinusSix	0FFFAh
MinusEight	0FFF8h
MinusFourteen	0FFF2h
MinusTwentyTwo	0FFEAh

; KSZ8816 EEPROM access bits
EECS		00001h
EEClk		00002h	
EEDataOutBit	00004h
EEDataInMask	00008h
EEAccessEnable	00010h
EETSEn		00020h
EEIdle		00000h

;micro wire EEPROM commands
EEReadCom	00006h
EEWriteCom	00005h
EEEraseCom	00007h
EEWrEnCom	00004h		

ExtData			060h
ExtAdd			068h
ExtStat			06Ah
StartExtRead		06Ch
StartExtWrite		06Dh
ExtAddrInc		06Eh
HTimerBits		070h
ErrorLED		079h
LocalLEDs		07Ah
LEDMode			07Bh
FPGASPICS		07Dh
FPGASPIData		07Eh

; FPGA serial flash commands
FlashReadCom		003h
FlashReadIDCom		0ABh
FlashWritePageCom	002h
FlashEraseSecCom	00D8h
FlashWriteEnaCom	006h
FlashWriteDisCom	004h
FlashReadStatusCom	005h

FlashIdle		0AA01h
FlashRead		0AA02h
FlashWrite		0AA03h
FlashErase		0AA04h
FlashID			0AA05h

; WACMMMSSINNNNNNN = lbp16 command bits

LBPCountMask		0007Fh
LBPIncAddrMask		00080h
LBPSizeMask		00300h
LBPMemSpaceMask		01C00h
LBPControlMask		02000h
LBPContAndMemMask	03C00h
LBPAddrThereMask	04000h
LBPWriteMask		08000h
LBPMemSpace6Sel		01800h
LBPMemSpace7Sel		01C00h
LBPMemSpace1Sel		00400h
LBPMemSpace2Sel		00800h
LBPMemSpace3Sel		00C00h
LBPMemSpace4Sel		01000h

; MEM Space  WTTT TTTT AAAA AAAA 
; 01 register 02 control 8E eeprom 8F flash 	
; W is writeable, T is type A is access types (bit 0 = byte bit 1 = 16 bit)
; so for example 0x06 means 16 bit and 32 bit operations allowed 
; MEM Ranges EEEE EPPP PPSS SSSS (E AND P only apply to flash)
; E is erase block size P is Page size S is address range (2^E, 2^P, 2^S)

LBPMemSpace0		08104h	; type 0x01 32 bit RW access
LBPMemRanges0		00010h	; 2^16 address range

LBPMemSpace1		08102h	; type 0x01 16 RW bit access
LBPMemRanges1		00008h	; 2^8 address range

LBPMemSpace6		08202h	; type 0x02 16 bit RW access
LBPMemRanges6		00004h	; 2^4 address range

LBPMemSpace7		00202h	; type 0x02 16 bit RO access
LBPMemRanges7		00004h	; 2^4 address range

LBPMemSpace2		08E02h	; type 0x0E 16 bit RW access
LBPMemRanges2		00007h	; 2^7 address range

LBPMemSpace3		08F04h	; type 0x0F 32 bit RW access
LBPMemRanges3		08200h	; address range discovered, 256 byte page 
				; 64k byte erase

LBPMemSpace4		08202h	; type 0x02 16 bit RW access
LBPMemRanges4		00003h	; 2^3 address range

RecvBufSize		(sendbuf-recvbuf)*2	; in bytes


EBCSRChipSel	041H
EBCSRCom	042h
EBCSRRead	044h
EBCSRWrite	048h
EBCSRDrive	050h

EtherBusIdle	040h
EtherBusCS_In_Data 	041h
EtherBusCS_Out_Data 	051h
EtherBusCS_Out_Add 	053h
EtherBusWrData	059h	 
EtherBusRdData	045h 
EtherBusWrAdd	05Bh
EtherBusRdAdd	047h 

EtherBusData	030h
EtherBusIRQ	031h
EtherReset	032h
SetTP0		03Ch
ClrTP0		03Dh
SetTP1		03Eh
ClrTP1		03Fh
OptJprs		03Fh

; KSZ8851-16 registers (note all 16 bit little endian MSBs are BEs)
E_CCR		03008h
E_MARL		03010h
E_MARM		0C012h
E_MARH		03014h
E_OBCR		03020h
E_EEPCR		0C022h
E_MBIR		03024h
E_GRR		0C026h
E_TXCR		03070h
E_TXSR		0C072h
E_RXCR1		03074h
E_RXCR2		0C076h
E_TXMIR		03078h
E_RXFHSR	0307Ch
E_RXFHBCR	0C07Eh
E_TXQCR		03080h
E_RXQCR		0C082h
E_TXFDPR	03084h
E_RXFDPR	0C086h
E_RXDTTR	0308Ch
E_RXDBCTR	0C08Eh
E_IER		03090h
E_ISR		0C092h
E_RXFCTR	0309Ch
E_TXNTFSR	0C09Eh
E_CIDER		030C0h
E_CGCR		0C0C6h
E_IACR		030C8h
E_IADLR		030D0h
E_IADHR		0C0D2h
E_PMECR		030D4h
E_GSWUTR	0C0D6h
E_PHYRR		030D8h
E_P1MBCR	030E4h
E_P1MBSR	0C0E6h
E_PHY1ILR	030E8h
E_PHY1IHR	0C0EAh
E_P1ANAR	030ECh
E_P1ANLPR	0C0EEh
E_P1SCLMD	030F4H
E_P1CR		0C0F6h
E_P1SR		030F8h
USTimer		07Ch
SPICS		07Dh
SPIData		07Eh

icmpproto_ttl	04001h	; ttl always 64
udpproto_ttl	04011h
BPServerPort	67
BPClientPort	68

; mac header offsets (in 16 bit words)
EtherDAOff		0
EtherSAOff		3
EtherTypeOff		6
; arp packet offsets
ArpHTOff		7	; ethernet hardware type
ArpPTOff		8	; protocol type
ArpSizesOff		9	; sizes
ArpOperOff		10	; 2 for repuest
ArpSendMacOff		11	; sender mac addres
ArpSendIPoff		14	; sender ip address
ArpTargetMacOff		16	; target mac address
ArpTargetIPOff		19	; target ip address

; ip header offsets
IPPLHLOff		7
IPPackLenOff		8
IPIdentOff		9
IPFlagsOff		10
IPTTL_ProtoOff		11
IPSendIPOff		13
IPDestIPOff		15

;udp header offsets
UDPSrcPortOff		17
UDPDestPortOff		18
UDPLengthOff		19
UDPCkSumOff		20
UDPDataOff		21

;bootp header offsets
BootPTIDOff		23
BootPYourIPOff		29

RAMBegin	128          
RAMEnd		2047

zeroloc		128	%ptr	
oneloc		129	%ptr	
twoloc		130	%ptr
threeloc	131	%ptr
fourloc		132	%ptr
fiveloc		133	%ptr
sixloc		134	%ptr
sevenloc	135	%ptr		
eightloc	136	%ptr
sixteenloc	137	%ptr

lowbytemask	138
highbytemask	139
qamask		140
icmpprotonbo	141
udpprotonbo	142
mask0f		143

; WACMMMSSINNNNNNN = lbp16 command bits
mem1space	144
mem2space	145
mem3space	146
mem4space	147
mem5space	148
mem6space	149
mem7space	150

lbpsize2	151	%ptr
lbpsize4	152	%ptr

loopiloc	153	%ptr
loopjloc	154	%ptr
loopkloc	155	%ptr

etherout	156
etherin		157

temp0		158	
temp1		159	

mymac		160
destmac		163
myip		166
destip		168

recvfcount	170
recvpktsize	171
recvpktloop	172

sendpktsize	180
sendpktloop	181
sendpkttype	182

maxtxpktsize	184
maxrxpktsize	185
sendbuflimit	186
recvbuflimit	187
tid		188	; 32 bits 	

delay0		190
delay1		191
test0		192
htimermask	193
htimerstate	194
oldhtimerstate	195
hustimerstart	196
hustimerdelta	197
usstarttime	198

randx		204
randy		206
rand		208

; Ethernet EEPROM access variables

eeshadow	210
eedin		211
eedout		212
eeaddr		213
eebitmask	214

lbpport		216	; lbp port number
bpclport	218	; bootp client port (67)

; lbp parser variables

lbprecvsize	220
lasty		221
startx		222
lbpcommand	223
lbpethaddr	224
lbpcaddr	226

fladdr		228	;double
fldata		230	;double
flcommflag	232
flspibyte	233

; LBP Flash EEPROM = memspace 3
mem3c		256
lbpcookie3	256
lbptype_sizes3  257	
lbpadd_ranges3	258	 
lbpaddr3	259
lbpspace3name0	260
lbpspace3name1	261
lbpspace3name2	262
lbpspace3name3	263

; LBP ethernet EEPROM = memspace 2
mem2c		284
lbpcookie2	284
lbptype_sizes2  285	
lbpadd_ranges2	286	 
lbpaddr2	287
lbpspace2name0	288
lbpspace2name1	289
lbpspace2name2	290
lbpspace2name3	291



; LBP read/write region = memspace 6 control = X
mem6c		292
lbpcookie6	292
lbptype_sizes6  293	
lbpadd_ranges6	294	 
lbpaddr6	295
lbpspace6name0	296
lbpspace6name1	297
lbpspace6name2	298
lbpspace6name3	299

mem6		300
errorreg	300		;		
lbpparseerrors	301		
lbpmemerrors	302
lbpwriteerrors	303
recvpktcount	304	; 0x130	
recvudpcount	305	; 0x131
recvbadcount	306	; 0x132
sendpktcount	307 	; 0x133
sendudpcount	308	; 0x134
sendbadcount	309	; 0x135
ledmodeset	310
leddebugptr	311
udppkttime	312
eepromwena	313
lbpreset	314
scratch		315	

mem6end		315

; LBP read only region = memspace 7 control = X

mem7c		316
lbpcookie7	316
lbptype_sizes7  317	;
lbpadd_ranges7	318	; 
lbpaddr7	319
lbpspace7name0	320
lbpspace7name1	321
lbpspace7name2	322
lbpspace7name3	323

mem7		324
lbpcardname0    324	; Cardname character0,1 Read only 
lbpcardname1    325	; Cardname character2,3 Read only 
lbpcardname2    326	; Cardname character4,5 Read only 
lbpcardname3    327	; Cardname character6,7 Read only 
lbpcardname4    328	; Cardname character8,9 Read only 
lbpcardname5    329	; Cardname character10,11 Read only 
lbpcardname6    330	; Cardname character12,12 Read only 
lbpcardname7    331	; Cardname character14,13 Read only 
lbpversion      332     ; LBP Software Version, Read only 
firmwarever	333	; firmware version
optionjprs	334	; boot option jumpers
s7spare		335
recvstart_ts	336
recvend_ts	337
sendstart_ts	338
sendend_ts	339
	
; user info - memspace 0 control = 1
mem0c		340
lbpcookie0	340
lbptype_sizes0  341	;
lbpadd_ranges0	342	; 
lbpaddr0	343	;	
lbpspace0name0	344
lbpspace0name1	345
lbpspace0name2	346
lbpspace0name3	347
mem0cend	347

mem1c		348
lbpcookie1	348
lbptype_sizes1  349	;
lbpadd_ranges1	350	; 
lbpaddr1	351	;	
lbpspace1name0	352
lbpspace1name1	353
lbpspace1name2	354
lbpspace1name3	355
mem1cend	355

; Timer/utility = memspace 4 control = X
mem4c		357
lbpcookie4	357
lbptype_sizes4  358	
lbpadd_ranges4	359	 
lbpaddr4	360
lbpspace4name0	361
lbpspace4name1	362
lbpspace4name2	363
lbpspace4name3	364

mem4		366
timestamp	366	; reads return timeout, writes are no-op
uwait		367	; reads return last wait writes wait n usec
htimeout	368	; sets host timer timeout value in usec
rwait		369	; reads or writes wait till rising end of REF
hwait1		370	; reads or writes wait till rising edge of Timer1
hwait2		371	; "" timer2 
hwait3		372	; "" timer3
hwait4		373	; "" timer4
			; reads of rwait or hwaits return usec waited

recvbufd	383	; this is to accomodate the KSZs 2 alignment bytes
			; on DMA reads while still fetching data in quads
recvbuf		384	; 822 words = 1664 bytes
recvbufend	1205
sendbuf		1206	; 822 words = 1664 bytes
sendbufend	2047
endmem		2047
