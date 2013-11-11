
.MSFIRST
.include "static16.mac" 
.include "global.equ"

.include "etherhm2.equ"
;			
;program		Simple UDP packet Ethernet interface

begin
	nop	
	nop			; majik pipeline foo
	nop
	lwi	0
	stsp			; clear stack
	lwi	0FFFFh		; blink LEDs	
	sta	LEDMode		; mode is debug for now
	sta	LocalLEDs
	lwi	100
	jsr	delayms		; wait long enough for last packet send			
	lwi	0000h
	sta	LocalLEDs
;	jsr	debugsetup
	jsr	init	
	jsr	initether
	jsr	initeeprom
	jsr	initipaddr

premainloop
	lda	lbpreset
	jmpnz	begin		; reset?		
mainloop
	lda	errorreg
	jmpnz	mainerr
	lwi	0
	sta	ErrorLED
	jmp	maincont
mainerr
	lwi	1
	sta	ErrorLED	
maincont
	lda	@t
	sta	LocalLEDs	; debug LED update
	lda	recvfcount	; in case there are more frames from previous IRQ
	jmpnz	startrecv
	lda	EtherBusIRQ  
	jmpnz	mainloop	; no receive interrupt idle
startrecv
	lda	USTimer
	sta	recvstart_ts
	loaddY	recvbufd	; 2 chars ahead to dump sync bytes
	jsr	EtherRecv2Mem
	jmpz	mainloop	; bad or no packet
	loaddY	recvbuf
	nop
	nop
	lwinbo	0800h	
	sub	@y,EtherTypeOff	; check ethertype
	jmpz	parseip		; 0800 = ip ethertype
	lwinbo	0806h
	sub	@y,EtherTypeOff
	jmpz	arpreply	
	nop
	nop	
	jmp	mainloop

arpreply

	lda	myip+0			; you talking to me?
	sub	@y,ArpTargetIPOff+0
	jmpnz	mainloop		; nope
	lda	myip+1
	sub	@y,ArpTargetIPOff+1
	jmpnz	mainloop		; nope
	loaddX	sendbuf
	loaddnbo	0806h,sendpkttype		
	lwi	64
	sta	sendpktsize
	jsr	clearsendpkt		; no data leakage
	jsr	makemacreplyhdr
	jsr 	makearpreplypkt
	jsr	EtherSendFromMem
	jmp	mainloop

parseip

	lda	myip+0		; You talkin to me?
	sub	@y,IPDestIPOff+0
	jmpnz	mainloop	; not for me
	lda	myip+1
	sub	@y,IPDestIPOff+1
	jmpnz	mainloop	; not for me
	lda	@y,IPTTL_ProtoOff
	sub	icmpprotonbo	; icmp echo?
	and	highbytemask		
	jmpz	icmpreply
	lda	@y,IPTTL_ProtoOff
	sub	udpprotonbo	; udp ? 
	and	highbytemask		
	jmpz	udpreply
	nop
	nop
	jmp 	mainloop	; otherwise ignore
 
icmpreply
	loaddX	recvbuf		; use recvbuf for send as we just re-write 
				; the mac, ip, and icmp headers and send back
	movd	recvpktsize,sendpktsize
	loaddnbo	0800h,sendpkttype		
	
	jsr	makemacreplyhdr
	jsr	makeipreplyhdr
	jsr	makeicmpreply
	lwi	MinusFourteen	; subtract the mac header length
	addto	recvpktsize
	lwinbo	icmpproto_ttl
	sta	@x,IPTTL_ProtoOff
	nop		
	movdnbox	recvpktsize,IPPackLenOff;
	jsr	EtherSendFromMem
	jmp 	mainloop

udpreply				; we start with Y pointing to 
					; beginning of packet
	lda	@y,UDPDestPortOff	; check if its LBP	
	sub	lbpport
	jmpnz	mainloop
	lda	@y,UDPLengthOff
	bswp				; from NBO to 
	sub	eightloc		; subtract UDP header size to get data size
	ashr				; bytes to words
	sta	lbprecvsize
	loaddX	sendbuf+UDPDataOff	; rx and tx ptrs point to data area
	loaddY	recvbuf+UDPDataOff	; for parse/return data
	lda	USTimer
	sta	recvend_ts
	jmp	lbpparse
parsedone
	sta	sendpktsize
	jmpz	premainloop		; 0 acc means nothing to send
	lwi	1
	addto	sendudpcount
	loaddX	sendbuf		  
	loaddY	recvbuf
	lwi	8		; udp header size
	addto	sendpktsize
	loaddnbo	0800h,sendpkttype		
	jsr	makemacreplyhdr
	jsr	makeipreplyhdr
	jsr	makeudpreply
	movdnbox	sendpktsize,UDPLengthOff;   
	lwi	20		; add ip header size
	addto	sendpktsize
	lwinbo	udpproto_ttl
	sta	@x,IPTTL_ProtoOff
	movdnbox	sendpktsize,IPPackLenOff;
	lwi	14		; add mac header size
	addto	sendpktsize
	lda	USTimer
	sta	sendstart_ts
	jsr	EtherSendFromMem
	lda	USTimer
	sta	sendend_ts
	jmp	premainloop		; 

EtherRecv2Mem
	sta	SetTP0
	lda	recvfcount	; already doing a multi frame recv, 
	jmpnz	recvframe	; so skip the prelims 	
	nop	
	lwi	E_ISR
	jsr	EtherRW
	lda	etherin
	sta	etherout
	lwi	E_ISR		; to clear any interrupt requests
	jsr	EtherWW		
	lwi	02000h
	and	etherin	
	jmpz	recvdone	; if not receive int, return (0)
	loadd	0,etherout	; disable interupts		
	lwi	E_IER
	jsr	EtherWW			
	lwi	E_RXFCTR	; get the frame count	
	jsr	EtherRW
	lwi	0FF00h		; frame count is in high byte
	and	etherin
	bswp
	sta	recvfcount
	jmpz	norecvframe
recvframe
	nop
	lwi	MinusOne
	addto	recvfcount	; decrement the frame count
	lwi	E_RXFHSR	; check the recv frame status
	jsr	EtherRW
	lwi	08000h		; RXFV ?
	and	etherin
	jmpz	badrecvpkt	
	lwi	00017h		; check crc/runts/mii errs 
	and	etherin
	jmpnz	badrecvpkt
	lwi	03C00h		; check IP CSUM errs
	and	etherin	
	jmpnz	badrecvpkt
	nop
	lwi	E_RXFHBCR		; get packet size
	jsr	EtherRW
	lwi	00FFFh			; max is 12 bits
	and	etherin
	sta	recvpktsize
	sta	recvpktloop
	jmpz	badrecvpkt		; 0 length packet  
	loadd	04000h,etherout
	lwi	E_RXFDPR		; clear recv data pointer
	jsr	EtherWW
	loadd	00238h,etherout		; enable DMA
	lwi	E_RXQCR
	jsr	EtherWW		;
	jsr	EtherRead		;dummy		
	jsr	EtherRead		;status
	jsr	EtherRead		;framesize
	add	threeloc		;round loop count up to long
	and	qamask
	sta	recvpktloop
	sub	maxrxpktsize
	jmpnc	badrecvpkt		; too big
	sta	EtherBusCS_In_Data 	; CS and address
recv2memloop
	lda	EtherBusRdData		; assert read strobe	
	nop				; 10 ns
	nop				; 20
	nop				; 30
	nop				; 40
	lda	EtherBusCS_In_Data	; 50 deassert read strobe and read data
	sta	@y,0
	lda	EtherBusRdData		; assert read strobe	
	nop				; 10 ns
	nop				; 20
	nop				; 30
	nop				; 40
	lda	EtherBusCS_In_Data	; 50 deassert read strobe and read data
	sta	@y,1
	lwi	MinusFour
	addto	recvpktloop
	addiy	2
	jmpnz	recv2memloop
	nop

	loadd	00230h,etherout		; enable DMA
	lwi	E_RXQCR
	jsr	EtherWW			;
	loadd	02800h,etherout		; re-enable interupts		
	lwi	E_IER
	jsr	EtherWW			
recvdone
	lwi	1
	addto	recvpktcount
	lwi	MinusSix		;adjust for CRC and 2 byte offset
	addto	recvpktsize
	sta	ClrTP0
	ret
badrecvpkt  
	loadd	00231h,etherout	; release bad pkt
	lwi	E_RXQCR
	jsr	EtherWW	
norecvframe
	loadd	02800h,etherout	; re-enable interupts		
	lwi	E_IER
	jsr	EtherWW			
	lwi	8
	orto	errorreg
	lwi	1
	addto	recvbadcount
	lwi	0h
	sta	ClrTP0
	ret	
			
EtherSendFromMem
	sta	SetTP1
	lda	sendpktsize		
	add	threeloc
	and	qamask
	sta	sendpktloop
	sub	maxtxpktsize
	jmpnc	sendsizeerror	
	lwi	0238h			; enable DMA
	sta	etherout
	lwi	E_RXQCR
	jsr	EtherWW
	lwi	08000h			; send control word
	jsr	EtherWrite
	lda	sendpktsize		; send packet size
	jsr	EtherWrite
	sta	EtherBusCS_Out_Data
sendfrommemloop				; send packet data
	lda	@x,0
	sta	EtherBusData		; write low data	
	sta	EtherBusWrData		; assert write strobe
	nop				; 10
	nop				; 20
	nop				; 30
	lda	@x,1			; 40	
	sta	EtherBusCS_Out_Data	; 50 de-assert write strobe
	sta	EtherBusData		; write high data	
	sta	EtherBusWrData		; assert write strobe	
	nop				; 10
	addix	2			; 20
	nop				; 30	
	nop				; 40	
	sta	EtherBusCS_Out_Data	; 50
	lwi	MinusFour
	addto	sendpktloop
	jmpnz	sendfrommemloop
	loadd	00230h,etherout		; disable DMA
	lwi	E_RXQCR			
	jsr	EtherWW			;
	loadd	00001h,etherout		;  manual enqueue
	lwi	E_TXQCR
	jsr	EtherWW	
	lwi	1
	addto	sendpktcount  
	sta	ClrTP1
	ret	
sendsizeerror
	lwi	1
	addto	sendbadcount
	lwi	16
	orto	errorreg
	sta	ClrTP1
	ret

EtherWW		
	sta	EtherBusData		; output address
	sta	EtherBusCS_Out_Add	; assert CS and drive bus
	sta	EtherBusWrAdd		; start address write
	nop				; 10
	nop				; 20
	nop				; 30
	nop				; 40
	sta	EtherBusCS_Out_Add	; 50 de-assert address write strobe
	lda	etherout		
	sta	EtherBusData		; write 
	sta	EtherBusCS_Out_Data	; set cmd low
	sta	EtherBusWrData		; start data write
	nop				; 10
	nop				; 20
	nop				; 30	
	nop				; 40
	sta	EtherBusCS_Out_Data	; 50 de-assert write strobe
	sta	EtherBusIdle
	ret

EtherRW				
	sta	EtherBusData
	sta	EtherBusCS_Out_Add	; enable data output/CS/ADD 	
	sta	EtherBusWrAdd		; assert write strobe
	nop				; 10
	nop				; 20
	nop				; 30
	nop				; 40
	sta	EtherBusCS_Out_Add	; 50 deassert write strobe
	sta	EtherBusCS_In_Data	; turnaround buffer
	sta	EtherBusRdData		;		
	nop				;
	nop				;
	nop				;
	nop				; 10
	nop				; 20
	nop				; 30
	nop				; 40
	lda	EtherBusData		; 50 read low data
	sta	etherin
	nop	  
	sta	EtherBusCS_In_Data	; deassert read strobe
	ret

EtherRead
	lda	EtherBusCS_In_Data 	; CS and address
	lda	EtherBusRdData		; assert read strobe	
	nop				; 10
	nop				; 20
	nop				; 30
	nop				; 40
	lda	EtherBusCS_In_Data	; deassert read strobe and read data
	ret

EtherWrite
	sta	EtherBusData		; write data 	
	sta	EtherBusCS_Out_Data	; CS if not already asserted
	sta	EtherBusWrData		; assert write strobe
	nop				; 10 ns
	nop				; 20
	nop				; 30
	nop				; 40
	sta	EtherBusCS_Out_Data	; 50 de-assert write strobe
	ret	

makeethermachdr
	movdx		destmac+0,0		; dest mac addres
	movdx		destmac+1,1		;
	movdx		destmac+2,2		;
	movdx		mymac+0,3		; sender mac addres
	movdx		mymac+1,4		;
	movdx		mymac+2,5		;
	movdx		sendpkttype,6		; Ethertype
	ret

makemacreplyhdr
	movdyx		EtherSAOff+0,EtherDAOff+0	; dest mac address (from recv)
	movdyx		EtherSAOff+1,EtherDAOff+1	; 
	movdyx		EtherSAOff+2,EtherDAOff+2	;
	movdx		mymac+0,3			; sender mac addres
	movdx		mymac+1,4			;
	movdx		mymac+2,5			;
	movdx		sendpkttype,6			; Ethertype
	ret

makearpreplypkt
	loaddnbox	00001h,7	; ethernet hardware type
	loaddnbox	00800h,8	; protocol type
	loaddnbox	00604h,9	; sizes
	loaddnbox	00002h,10	; 2 for reply
	movdx		mymac+0,11	; sender mac address
	movdx		mymac+1,12	;
	movdx		mymac+2,13	;
	movdx		myip+0,14	; sender ip address
	movdx		myip+1,15	;
makenewarpreplypkt			; rewrite from recv...
	movdyx		11,16		; target mac address (from recv pkt)
	movdyx		12,17		;
	movdyx		13,18		;
	movdyx		14,19		; target ip address (from recv pkt)
	movdyx		15,20		;
	ret

makeiphdr
	loaddnbox	04500h,7	; protocol and header length
	loaddnbox	00000h,8	; packet length
	loaddnbox	00000h,9	; identification
	loaddnbox	04000h,10	; flags = dont fragment
	loaddnbox	04011h,11	; TTL and protocol (udp default)
	loaddnbox	00000h,12	; header checksum (filled in by MAC)
	movdx		myip+0,13	; sender ip address (already in NBO)
	movdx		myip+2,14	;
	movdx		destip+0,15	; target ip address
	movdx		destip+1,16	;
	ret

makeipreplyhdr
	loaddnbox	04500h,7	; protocol and header length
	loaddnbox	00000h,8	; packet length
	loaddnbox	00000h,9	; identification
	loaddnbox	04000h,10	; flags = dont fragment
	loaddnbox	04011h,11	; TTL and protocol (udp default)
	loaddnbox	00000h,12	; header checksum (filled in by MAC)
	movdyx		13,15		; target ip address
	movdyx		14,16		;
	movdx		myip+0,13	; sender ip address
	movdx		myip+1,14	;
	ret

makeicmpreply	
	loaddnbox	00000h,17	; type (0) and code (0)
	loaddnbox	00000h,18	; header checksum (filled in by MAC)
;	loaddnbox	00000h,19	; identification and sequence #
	ret

makeudpreply
	movdyx		17,18		; copy recv pkt source port to dest port
	movdx		lbpport,17	; source port (LBPPort is already NBO)  
;	loaddnbox	0000h,19	; size, filled in by sender	
	loaddnbox	0000h,20	; UDP checksum filled in by MAC	
	ret

makeudpbootpreq
	loaddnbox	BPClientPort,17	; 
	loaddnbox	BPServerPort,18	;   
	loaddnbox	308,19		; size	
	loaddnbox	0000h,20	; UDP checksum filled in by MAC	
	ret

makebootpreq
	loaddnbox	00101h,21	; op and ethertype
	loaddnbox	00600h,22	; addrlen and hops		
	movdx		tid+0,23		
	movdx		tid+1,24
	loaddnbox	00001h,25	; seconds
	loaddnbox	08000h,26	; flags
	movdx		myip+0,27	; sender ip address (already in NBO)
	movdx		myip+1,28	;
	loaddnbox	00000h,29	; your ip address
	loaddnbox	00000h,30	; 
	movdx		destip+0,31	; dest IP 
	movdx		destip+1,32	;
	loaddnbox	00000h,33	; gateway ip address
	loaddnbox	00000h,34	; 
	movdx		mymac+0,35	; sender mac address
	movdx		mymac+1,36	;
	movdx		mymac+2,37	;
	ret				; the rest is silence	





	
	
.include "etherini.asm"
.include "delayms.asm"				
;.include "debugset.asm"
.include "lbpparse.asm"
.include "ethereep.asm"
.include "etherfls.asm"

ROMEnd	org	1fffh
	dw	0abcdh

.end


