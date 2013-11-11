; Ethernet chip 9346 bit bang read write routines
e_eepread			; read word 
	jsr	eeprefix
	lwi	EEReadCom
	jsr	eesendcom
	lda	eeaddr
	jsr	eesendaddr
	jsr	eereaddata
	sta	eedout
	jsr	eesuffix
	ret

e_eepwrite			; write word
	jsr	eeprefix
	lwi	EEWrEnCom
	jsr	eesendcom
	lwi	0003Fh		; all 1s address for write enable
	jsr	eesendaddr
	jsr	eesuffix
	jsr	eeprefix
	lwi	EEWriteCom
	jsr	eesendcom
	lda	eeaddr
	jsr	eesendaddr
	jsr	tsehigh
	jsr	eeupdate	
	lda	eedin
	jsr	eewritedata
	jsr	eesuffix
	jsr	eewaitforwrite	; wait for write to complete
	jsr	eeprefix
	lwi	EEWrEnCom
	jsr	eesendcom
	lwi	0h		; all 0s address for write disable
	jsr	eesendaddr
	jsr	eesuffix
	ret

clkhigh 
	lwi	EEClk	
	orto	eeshadow
	ret

clklow	lwi	~(EEClk)&0FFFFh	
	andto	eeshadow
	ret

cshigh 
	lwi	EECS	
	orto	eeshadow
	ret

cslow	lwi	~(EECS)&0FFFFh	
	andto	eeshadow
	ret

dout	jmpnz	dhigh
	nop
	nop
	lwi	~(EEDataOutBit)&0FFFFh	
	andto	eeshadow
	ret
dhigh	
	lwi	EEDataOutBit	
	orto	eeshadow
	ret

tsehigh 
	lwi	EETSEn	
	orto	eeshadow
	ret

tselow	lwi	~(EETSEn)&0FFFFh	
	andto	eeshadow
	ret

eeupdate
	sta	etherout
	lwi	E_EEPCR
	jsr	EtherWW
	ret

eetestbit
	lwi	E_EEPCR
	jsr	EtherRW
	lwi	EEDataInMask
	and	etherin
	ret

toggleeeclk
	jsr	clkhigh
	jsr	eeupdate
	jsr	clklow
	jsr	eeupdate	
	ret


eesendcom
	sta	temp0
	nop
	nop
	lwi	4
	and	temp0
	jsr	dout	; 
	jsr	eeupdate
	jsr	toggleeeclk
	lwi	2
	and	temp0
	jsr	dout ;
	jsr	eeupdate
	jsr	toggleeeclk
	lwi	1
	and	temp0
	jsr	dout	
	jsr	eeupdate
	jsr	toggleeeclk
	ret

eesendaddr
	sta	temp0
	lwi	0020h
	sta	eebitmask
	nop
	nop
eesaloop
	lda	temp0
	and	eebitmask
	jsr	dout	        ; 
	jsr	eeupdate	; update the address data output
	lda	eebitmask	; shift address mask right
	add	zeroloc		; clear carry
	rcr			; makes rotate a shift right
	sta	eebitmask
	jsr	clkhigh
	jsr	eeupdate
	jsr	clklow
	lda	eebitmask
	jmpnz	eesanext	; if end we clear tse at same time as clocklow
	nop
	nop
	jsr	tselow		; set data dir for read mode			
	jmp	eesalast	
eesanext	
	jsr	tsehigh
eesalast
	jsr	eeupdate	
	lda	eebitmask
	jmpnz	eesaloop
	nop
	nop
	ret

eeprefix
	lwi	0
	sta	eeshadow
	jsr	eeupdate
	lwi	EEAccessEnable | EETSEn | EECS	
	sta	eeshadow
	jsr	eeupdate
	ret

eesuffix
	lwi	EEIdle		;
	sta	eeshadow
	jsr	eeupdate
	ret

eereaddata			; read 16 data bit phase of EEPROM read	
	sta	temp0
	lwi	08000h
	sta	eebitmask
	jsr	toggleeeclk	; dummy 0 bit
eereadlp
	jsr	eetestbit
	jmpz	eerddata0
	lda	eebitmask
	orto	temp0
eerddata0
	jsr	toggleeeclk
	lda	eebitmask
	add	zeroloc		; clear carry
	rcr			; makes rotate a shift
	sta	eebitmask
	jmpnz	eereadlp
	lda	temp0
	nop
	ret

eewritedata
	sta	temp0
	lwi	08000h
	sta	eebitmask
	nop
	nop
eewritelp
	lda	temp0
	and	eebitmask
	jsr	dout
	jsr	eeupdate
	jsr	toggleeeclk
	lda	eebitmask
	add	zeroloc		; clear carry
	rcr			; makes rotate a shift
	sta	eebitmask
	nop
	jmpnz	eewritelp
	nop
	nop
	ret

eewaitforwrite
	lwi	50000		; about 20 ms before we give up waiting and set write error		
	sta	temp0
	lwi	EEAccessEnable | EECS	
	sta	eeshadow
	jsr	eeupdate
eewaitloop
	jsr	eetestbit
	jmpnz	eewaitdone
	lwi	MinusOne
	addto	temp0
	jmpnz	eewaitloop
	nop
	nop
	jmp	lbpwriteerr
eewaitdone
	jsr	eesuffix
	ret

