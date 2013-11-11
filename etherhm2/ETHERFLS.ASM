; FPGA SPI flash read write erase routines
readfl				; read double 
	lwi	FlashRead
	sub 	flcommflag	
	jmpz	readflcon	; already read command we skip the preliminaries
	lwi	FlashRead
	sta	flcommflag
	lwi	0
	sta	FPGASPICS	; assert CS;
	lwi	FlashReadCom	
	jsr	sendspibyte	;
	jsr	sendspiaddr
readflcon
	lwi	0
	jsr	sendspibyte
	sta	fldata+0		; byte 0
	lwi	0
	jsr	sendspibyte
	bswp	
	orto	fldata+0		; byte 1
	lwi	0
	jsr	sendspibyte
	sta	fldata+1		; byte 2
	lwi	0
	jsr	sendspibyte
	bswp	
	orto	fldata+1		; byte 3
	ret

readflid			; read ID 
	lwi	0		; assert CS
	sta	FPGASPICS
	lwi	FlashReadIDCom	
	jsr	sendspibyte	;
	jsr	sendspiaddr
	lwi	0
	jsr	sendspibyte
	sta	fldata+0
	lwi	0
	sta	fldata+1
	lwi	0FFFFh		; de-assert CS
	sta	FPGASPICS
	ret

writefl				; write double
	lwi	FlashWrite
	sub	flcommflag	; if this is not the first access after 
	jmpz	writeflcon	; a command we skip the preliminaries
	lwi	FlashWrite
	sta	flcommflag
	jsr	spiwriteena	
	lwi	0		; assert CS
	sta	FPGASPICS
	lwi	FlashWritePageCom
	jsr	sendspibyte
	jsr	sendspiaddr
writeflcon
	lda	fldata+0
	jsr	sendspibyte
	lda	fldata+0
	bswp
	jsr	sendspibyte
	lda	fldata+1
	jsr	sendspibyte
	lda	fldata+1
	bswp
	jsr	sendspibyte
	ret

erasefl				; erase flash sector
	jsr	spiwriteena	
	lwi	0		; assert CS
	sta	FPGASPICS
	lwi	FlashEraseSecCom
	jsr	sendspibyte
	jsr	sendspiaddr
	lwi	3000
	jsr	spicommit
	lwi	FlashIdle	
	sta	flcommflag	; and prime for next op
	ret

finishfl
	lwi	FlashWrite	; are we in the middle of a page write?
	sub	flcommflag
	jmpz  	finishwrite	; if so, commit it
	lwi	0FFFFh		; otherwise just back to idle mode
	sta	FPGASPICS	
	lwi	FlashIdle
	sta	flcommflag
	ret
finishwrite
	lwi	5
	jsr	spicommit
	lwi	FlashIdle
	sta	flcommflag
	ret


spicommit			; commit a pending write or erase
	sta	loopjloc	; settimeout
	lwi	0FFFFh	
	sta	FPGASPICS	; commit write
spicommitl
	jsr	spireadstatus
	and 	oneloc		; check WIP bit
	jmpz	spicommitdone
	nop
	lwi	1
	jsr	delayms		; wait one ms
	lwi	MinusOne
	addto	loopjloc
	jmpnz	spicommitl
	nop
	nop			 
	jmp	lbpwriteerr
spicommitdone
	jsr	spiwritedis
	ret		

sendspibyte
	sta	FPGASPIData
sendspibytel
	nop
	lwi	2
	and	FPGASPICS
	jmpnz	sendspibytel		
	lwi	000FFh
	and	FPGASPIData
	sta	flspibyte
	ret

sendspiaddr
	lda	fladdr+1	; byte 2 of address
	jsr	sendspibyte	
	lda	fladdr+0	; byte 1 of address
	bswp
	jsr	sendspibyte
	lda	fladdr+0	; byte 0 of address
	jsr	sendspibyte
	ret

spireadstatus
	lwi	0
	sta	FPGASPICS
	lwi	FlashReadStatusCom
	jsr	sendspibyte
	lwi	0
	jsr	sendspibyte
	lwi	0FFFFh
	sta	FPGASPICS
	lda	flspibyte
	ret

spiwriteena
	lwi	0		; assert CS
	sta	FPGASPICS
	lwi	FlashWriteEnaCom	
	jsr	sendspibyte	
	lwi	1		; deassert CS
	sta	FPGASPICS
	ret

spiwritedis
	lwi	0		; assert CS
	sta	FPGASPICS
	lwi	FlashWriteDisCom	
	jsr	sendspibyte	
	lwi	1		; deassert CS
	sta	FPGASPICS
	ret

