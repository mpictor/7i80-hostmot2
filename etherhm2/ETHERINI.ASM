
init
	jsr	zeromem
	lwi	05A00h
	sta	lbpcookie0
	lwi	05A01h
	sta	lbpcookie1
	lwi	05A02h
	sta	lbpcookie2
	lwi	05A03h
	sta	lbpcookie3
	lwi	05A04h
	sta	lbpcookie4
	lwi	05A06h
	sta	lbpcookie6
	lwi	05A07h
	sta	lbpcookie7
	  
	lwi	 'H'+('o' * 256)
	sta	lbpspace0name0
	lwi	 's'+('t' * 256)
	sta	lbpspace0name1
	lwi	 'M'+('o' * 256)
	sta	lbpspace0name2
	lwi	 't'+('2' * 256)
	sta	lbpspace0name3

	lwi	'K'+('S' * 256)
	sta	lbpspace1name0
	lwi	'Z'+('8' * 256)
	sta	lbpspace1name1
        lwi     '8'+('5' * 256)
	sta	lbpspace1name2
        lwi     '1'+(0   * 256)
	sta	lbpspace1name3

	lwi	'E'+('t' * 256)
	sta	lbpspace2name0
	lwi	'h'+('e' * 256)
	sta	lbpspace2name1
	lwi	'r'+('E' * 256)
	sta	lbpspace2name2
	lwi	'E'+('P' * 256)
	sta	lbpspace2name3

	lwi	'F'+('P' * 256)
	sta	lbpspace3name0
	lwi	'G'+('A' * 256)
	sta	lbpspace3name1
	lwi	'F'+('l' * 256)
	sta	lbpspace3name2
	lwi	's'+('h' * 256)
	sta	lbpspace3name3

	lwi	'T'+('i' * 256)
	sta	lbpspace4name0
	lwi	'm'+('e' * 256)
	sta	lbpspace4name1
	lwi	'r'+('s' * 256)
	sta	lbpspace4name2
	lwi	 0 +( 0  * 256)
	sta	lbpspace4name3

	lwi	'L'+('B' * 256)
	sta	lbpspace6name0
	lwi	'P'+('1' * 256)
	sta	lbpspace6name1
	lwi	'6'+('R' * 256)
	sta	lbpspace6name2
	lwi	'W'+(0   * 256)
	sta	lbpspace6name3

	lwi	'L'+('B' * 256)
	sta	lbpspace7name0
	lwi	'P'+('1' * 256)
	sta	lbpspace7name1
	lwi	'6'+('R' * 256)
	sta	lbpspace7name2
	lwi	'O'+(0   * 256)
	sta	lbpspace7name3
	lwi	recvpktcount	; default debug leds are recvpktcount
	sta	t		; note t is not used by anyone else
	lwi	08h		; default recvpktcount
	sta	leddebugptr

	lwi	003h	
	sta	lbpversion

	lwi	00Eh	
	sta	firmwarever

	lwi	1
	sta	oneloc
	lwi	2
	sta	twoloc
	lwi	3
	sta	threeloc
	lwi	4  
	sta	fourloc
	lwi	5  
	sta	fiveloc
	lwi	6  
	sta	sixloc
	lwi	7
	sta	sevenloc
	lwi	8	
	sta	eightloc
	lwi	16
	sta	sixteenloc
	lwi	0000Fh
	sta	mask0f
	lwi	LBPMemSpace0	;normal process space
	sta	lbptype_sizes0	
	lwi	LBPMemRanges0
	sta	lbpadd_ranges0 
	lwi	LBPMemSpace1	; KSZ8816 chip access
	sta	lbptype_sizes1	
	lwi	LBPMemRanges1
	sta	lbpadd_ranges1 
	lwi	LBPMemSpace2	; KSZ8816 chip EEPROM access
	sta	lbptype_sizes2	
	lwi	LBPMemRanges2
	sta	lbpadd_ranges2 
	lwi	LBPMemSpace3	; FPGA serial config flash
	sta	lbptype_sizes3	
	lwi	LBPMemRanges3
	sta	lbpadd_ranges3 
	lwi	LBPMemSpace4	; Timers and utility
	sta	lbptype_sizes4	
	lwi	LBPMemRanges4
	sta	lbpadd_ranges4 
	lwi	LBPMemSpace6	; lbp rw space
	sta	lbptype_sizes6	
	lwi	LBPMemRanges6
	sta	lbpadd_ranges6 
	lwi	LBPMemSpace7	; lbp ro space
	sta	lbptype_sizes7	
	lwi	LBPMemRanges7
	sta	lbpadd_ranges7 

	lwi	000FFh
	sta	lowbytemask
	lwi	0FF00h
	sta	highbytemask	
	lwi	0FFFCh
	sta	qamask
	lwi	00100h
	sta	icmpprotonbo
	lwi	01100h
	sta	udpprotonbo
	lwi	LBPMemSpace1Sel
	sta	mem1space
	lwi	LBPMemSpace2Sel
	sta	mem2space
	lwi	LBPMemSpace3Sel
	sta	mem3space
	lwi	LBPMemSpace4Sel
	sta	mem4space
	lwi	LBPMemSpace6Sel
	sta	mem6space
	lwi	LBPMemSpace7Sel
	sta	mem7space
	lwi	0100h
	sta	lbpsize2
	lwi	0200h
	sta	lbpsize4
	
	loaddnbo	00060h,mymac+0		;		
	loaddnbo	01B10h,mymac+1
	loaddnbo	00000h,mymac+2

	loaddnbo	0FF00h,destmac+0	;	
	loaddnbo	00000h,destmac+1
	loaddnbo	00000h,destmac+2

	loaddnbo	27181,lbpport		; 
	loaddnbo	BPClientPort,bpclport
	lwi	1536
	sta	maxrxpktsize
	lwi	1536
	sta	maxtxpktsize
	lwi	recvbufend-4	; maximum transfer size is 4 words
	sta	recvbuflimit	; for index register bound checking
	lwi	sendbufend-4
	sta	sendbuflimit
	lwi	0FFFFh
	sta	FPGASPICS	; always clear CS
	ret	

initipaddr
	lwi	3
	and	OptJprs
	sta	optionjprs			; for space 7 reporting
	sub	oneloc				; 1 is use eeprom IP
	jmpz	eepromip
	sub	oneloc
	jmpz	bootpip
	nop
	nop
	jmp 	defaultip
eepromip					; read from Ethernet EEPROM
	lwi	0011h
	sta	eeaddr
	jsr	e_eepread
	movdnbo	eedout,myip+0
	lwi	0010h
	sta	eeaddr
	jsr	e_eepread
	movdnbo	eedout,myip+1
	jmp	ipchosen
bootpip
	jsr	random32
	lda	rand+0
	sta	tid+0
	lda	rand+1
	sta	tid+1
	lwi	sendbuf
	sta	x
	lwi	328		; bootp packet size with mac and IP headers
	sta	sendpktsize
	jsr	clearsendpkt		
	loaddnbo	0800h,sendpkttype		
	lwi	0FFFFh
	sta	destip+0	; both IP and MAC address are broadcast address
	sta	destip+1
	sta	destmac+0
	sta	destmac+1
	sta	destmac+2
	lwi	0		; dont know so 0 for now
	sta	myip+0
	sta	myip+1
	lwinbo	udpproto_ttl
	sta	@x,IPTTL_ProtoOff
	jsr	makeethermachdr		; cobble up a broadcast header	
	jsr	makeiphdr
	movdnbox	sendpktsize,IPPackLenOff;
	lwi	14		; add mac header size
	addto	sendpktsize
	jsr	makeudpbootpreq
	jsr	makebootpreq
	jsr	EtherSendFromMem
	lwi	1000			; ~1000 ms so ~1 Hz repeat rate
	sta	loopkloc
bpreplywait
	lwi	1
	jsr	delayms
	lwi	MinusOne
	addto	loopkloc
	jmpz	bootpip			; retry send
	lda	recvfcount
	jmpnz	bpstartrecv
	lda	EtherBusIRQ  
	jmpnz	bpreplywait		; no receive interrupt idle
bpstartrecv
	nop
	nop
	loaddY	recvbufd		; 2 chars ahead to dump sync bytes
	jsr	EtherRecv2Mem
	jmpz	bpreplywait		; bad or no packet
	loaddY	recvbuf
	nop
	nop
	lwinbo	0800h	
	sub	@y,EtherTypeOff		; check ethertype
	jmpnz	bpreplywait		; 0800 = ip ethertype
	lda	@y,IPTTL_ProtoOff
	sub	udpprotonbo		; udp ? 
	and	highbytemask		
	jmpnz	bpreplywait		; 0800 = ip ethertype
	lda	@y,UDPDestPortOff	; check if its bootpsocket	
	sub	bpclport		; 
	jmpnz	bpreplywait
	lda	@y,BootPTIDOff+0	; check TID	
	sub	tid+0
	jmpnz	bpreplywait
	lda	@y,BootPTIDOff+1	; 	
	sub	tid+1
	jmpnz	bpreplywait
	lda	@y,BootPYourIPOff+0	; a live one!	
	sta	myip+0
	lda	@y,BootPYourIPOff+1		
	sta	myip+1
	jmp	ipchosen
defaultip
	loaddnbo	0C0A8h,myip+0		; NBO
	loaddnbo	00179h,myip+1		;192:168.1.121
ipchosen	
	ret


initether
	nop
	lwi	0			; hard reset
	sta	EtherReset		; assert
	lwi	10
	jsr	delayms	
	lwi	1
	sta	EtherReset		; release
	lwi	10
	jsr	delayms			; wait before we access enet chip	
	loadd	1,etherout		; soft reset
	lwi	E_GRR
	jsr	EtherWW
	lwi	10
	jsr	delayms
	loadd	0,etherout
	lwi	E_GRR
	jsr	EtherWW
	lwi	10
	jsr	delayms	

;	movdnbo	mymac,etherout		; setup mac address in MAC chip
;	lwi	E_MARH
;	jsr	EtherWW

;	movdnbo	mymac+1,etherout
;	lwi	E_MARM
;	jsr	EtherWW

;	movdnbo	mymac+2,etherout	; we use EEPROM for LSBs
;	lwi	E_MARL
;	jsr	EtherWW

	;use EEPROM for all MAC address (V14)

	lwi	E_MARH	
	jsr	EtherRW
	movdnbo	etherin,mymac

	lwi	E_MARM	
	jsr	EtherRW
	movdnbo	etherin,mymac+1

	lwi	E_MARL	
	jsr	EtherRW
	movdnbo	etherin,mymac+2

	loadd	04000h,etherout	; enable txfptr,rxfdptr auto increment			
	lwi	E_TXFDPR
	jsr	EtherWW

	loadd	001EEh,etherout;  (ip receive)
	lwi	E_TXCR
	jsr	EtherWW	

	loadd	04000h,etherout	; enable txfptr,rxfdptr auto increment			
	lwi	E_RXFDPR
	jsr	EtherWW

	loadd	00001h,etherout; set frame count for interrupt to 1
	lwi	E_RXFCTR
	jsr	EtherWW	

	loadd	07CE0h,etherout;  (IP modes)
	lwi	E_RXCR1
	jsr	EtherWW	

	loadd	00016h,etherout;  (ip csums)
	lwi	E_RXCR2
	jsr	EtherWW	

	loadd	00230h,etherout;  (2 byte offset, dequeue DMA off)
	lwi	E_RXQCR
	jsr	EtherWW	

	loadd	020FFh,etherout; Force phy re-negotiate
	lwi	E_P1CR
	jsr	EtherWW	

	loadd	0FFFFh,etherout; clear any pending receive interupts
	lwi	E_ISR
	jsr	EtherWW	

	loadd	02800h,etherout; enable recv interrupts
	lwi	E_IER
	jsr	EtherWW	

	loadd	001EFh,etherout;  (IP+ENA)
	lwi	E_TXCR
	jsr	EtherWW	

	loadd	07CE1h,etherout;  (IP+ENA)
	lwi	E_RXCR1
	jsr	EtherWW	

	lda	mymac+2
	sta	randx+0		; seed random number generator with EEPROM MAC address
	sta	randx+1
	lda	mymac+1
	sta	randy+0
	sta	randy+1
	nop
	nop
	nop
	ret	

initeeprom			; Ethernet EEPROM access can only be done  					; after the Ethernet chip is up and running
	lwi	008h		; after chip enabled so this is last init
	sta	eeaddr		; card name is stored in Ethernet EEPROM
	lwi	0		; R/O area
	sta	z
cardnameloop			; install card name from Ethernet EEPROM
	jsr	e_eepread
	lda	eedout
	sta	@z,lbpcardname0
	lwi	1
	addto	eeaddr
	lda	z
	sub	sevenloc
	jmpnc	cardnamedone	
	addiz	1
	nop
	jmp	cardnameloop
cardnamedone		
	lwi	014h		; default LEDMode is there as well
	sta	eeaddr
	jsr	e_eepread
	lda	eedout
	sta	ledmodeset
	sta	LEDMode
	jsr	readflid	; get flash ID
	lwi	4		; adding 4 to flash ID 
	add	fldata+0	; makes it flash size in bytes
	orto	lbpadd_ranges3 
	ret

clearsendpkt
	ashr	; change from bytes to words
	sta	loopjloc
	lwi	sendbuf
	sta	z
clearsploop
	lwi	0
	sta	@z
	nop
	nop
	nop
	lwi	MinusOne
	addiz	1
	addto	loopjloc
	jmpnz	clearsploop		
	nop
	nop
	ret

zeromem
	lwi	RAMBegin	; somewhat tricky since we have no memory variables
	sta	z
zeromemloop
	lwi	0
	sta	@z
	nop
	nop
	nop
	addiz	1
	lda	z	
	rcl			; shl 5 to get bit 11 (2048) into carry
	rcl
	rcl
	rcl
	rcl
	jmpnc	zeromemloop
	nop
	nop
	ret

random32
	lwi	36969		; Marsaglia with some mistakes :-(
	mulss	randx+0
	add	randx+1
	sta	randx+0
	ldph
	addc	zeroloc
	sta	randx+1
	lwi	18000
	mulss	randy+0
	add	randy+1
	sta	randy+0
	ldph
	addc	zeroloc
	sta	randy+1
	lda	randy+0
	sta	rand+0
	nop
	lda	randy+1
	add	randx+1		
	sta	rand+1
	ret

