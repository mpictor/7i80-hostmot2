; simple lbp parser
; y is lbp code source
; ext hostmot2 memory is default lbp memory
; enter with Y pointing to LBP code to parse
; and X pointing to returned data 
; a null command or out of data terminates the parsing  
; 

lbpparse
	lda	y	
	add	lbprecvsize	; already in words	
	sta	lasty
	lda	x
	sta	startx
lbpparsenext
	lda	@y
	sta	lbpcommand
	nop
	addiy	1		; skip command
	lwi	LBPCountMask	; data items in 7 bits
	and	lbpcommand
	jmpz	lbpparseerr
	sta	loopiloc	; setup loop			
	lwi	LBPContAndMemMask
	and	lbpcommand	; is this address space 0 ?
	jmpnz	parse_misc
	lwi	LBPSizeMask
	and	lbpcommand			
	sub	lbpsize4		; only 32 bit data
	jmpnz	lbpparseerr
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	dataxferla	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr0
	addiy	1		; skip over address
	jmp	dataxfer
dataxferla
	lda	lbpaddr0
dataxfer
	sta	ExtAdd		; we always set the ext address
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	wrloop
rdloop
	sta	StartExtRead
	lda	x		; send check buffer limit
	sub	sendbuflimit
	jmpnc	lbpmemerr
	lda	lbpcommand
	sta	ExtAddrInc	; and only incs if set
	lda	ExtData+0
	sta	@x,0
	lda	ExtData+1
	sta	@x,1
	lwi	MinusOne
	addto	loopiloc
	addix	2
	jmpnz	rdloop
	lda	ExtAdd		; use the hardware address to update LBPs
	sta	lbpaddr0	; address counter when done
	jmp	lbpcomdone
wrloop
	lda	@y,0
	sta	ExtData+0				
	lda	@y,1
	sta	ExtData+1				
	lda	y
	sub	recvbuflimit
	jmpnc	lbpmemerr
	sta	StartExtWrite
	addiy	2		; skip over data
	lda	lbpcommand	; magic hardware decodes inc bit
	sta	ExtAddrInc	; and only incs if set
	lwi	MinusOne
	addto	loopiloc
	jmpnz	wrloop
	nop
	lda	ExtAdd		; use the hardware address to update LBPs
	sta	lbpaddr0	; address counter when done
lbpcomdone
	lda	y
	sub	lasty
	jmpc	lbpparsenext	; carry until y = last y = done parsing
lbpparsedone
	lwi	1
	addto	recvudpcount
	lwi	0
	sta	eepromwena
	lda	x
	sub	startx		; should be no carry
	rcl			; so this is OK
	jmp	parsedone	; with sendpktsize in acc				
lbpparseerr
	lwi	1
	orto	errorreg
	lwi	0FFFFh
	sub	lbpparseerrors
	jmpz	errorexit	; dont wrap
	lwi	1
	addto	lbpparseerrors
	jmp	errorexit
lbpmemerr
	lwi	2
	orto	errorreg
	lwi	0FFFFh
	sub	lbpmemerrors
	jmpz	errorexit	; dont wrap
	lwi	1
	addto	lbpmemerrors
	jmp	errorexit	; return with 0
lbpwriteerr
	lwi	4
	orto	errorreg
	lwi	0FFFFh
	sub	lbpwriteerrors
	jmpz	errorexit	; dont wrap
	lwi	1
	addto	lbpwriteerrors
errorexit
	lwi	0
	sta	eepromwena	; always disable eeprom write enable  
	stsp	; clear stack pointer in case we got 
		; to here from the middle of a subroutine
	jmp	parsedone	; return with 0

parse_misc
	lwi	LBPMemSpaceMask		; we do space 4 first
	and	lbpcommand		; since its used in real time
	sub	mem4space
	jmpz	parse_4
	lwi	LBPMemSpaceMask
	and	lbpcommand
	sub	mem1space
	jmpz	parse_1
	lwi	LBPMemSpaceMask
	and	lbpcommand
	sub	mem2space
	jmpz	parse_2
	lwi	LBPMemSpaceMask
	and	lbpcommand
	sub	mem3space
	jmpz	parse_3
	lwi	LBPMemSpaceMask
	and	lbpcommand
	sub	mem7space
	jmpz	parse_7
	lwi	LBPMemSpaceMask
	and	lbpcommand
	sub	mem6space
	jmpz	parse_6
	lwi	LBPMemSpaceMask
	and	lbpcommand
;	sub	mem0space
	jmpz	parse_0c
	nop
	nop
	jmp	lbpparseerr

parse_7				; lbp read only space
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer7c
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize2
	jmpnz	lbpparseerr	; only 16 bit access allowed
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	dataxferla7	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr7
	addiy	1		; skip over address
	jmp	dataxfer7
dataxferla7
	nop
	lda	lbpaddr7
dataxfer7
	ashr			; change to word address
	sta	z		; 
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwriteerr
lbpread7
	lda	z
	sub	sixteenloc
	jmpnc	lbpmemerr
	lda	@z,mem7
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread7ni
	lwi	2		; lbpaddr tracks byte addresses
	addto	lbpaddr7
	addiz	1
lbpread7ni
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread7
	nop
	nop
	jmp	lbpcomdone

dataxfer7c
	jsr	cssetup
lbpread7c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr	
	lda	@z,mem7c
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread7nic
	lwi	2
	addto	lbpcaddr
	addiz	1
lbpread7nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread7c
	nop
	nop
	jmp	lbpcomdone

parse_6				; lbp read only space
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer6c
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize2
	jmpnz	lbpparseerr	; only 16 bit access allowed
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	dataxferla6	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr6
	addiy	1		; skip over address
	jmp	dataxfer6
dataxferla6
	lda	lbpaddr6
dataxfer6
	ashr			; change to word address
	sta	z		; 
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwrite6
lbpread6
	lda	z
	sub	sixteenloc
	jmpnc	lbpmemerr
	lda	@z,mem6
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread6ni
	lwi	2
	addto	lbpaddr6
	addiz	1
lbpread6ni
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread6
	nop
	nop
	jmp	lbpcomdone
lbpwrite6
	lda	z
	sub	sixteenloc
	jmpnc	lbpmemerr
	lda	@y
	sta	@z,mem6
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpwrite6ni
	lwi	2
	addto	lbpaddr6
	addiz	1		
lbpwrite6ni
	lwi	MinusOne
	addto	loopiloc
	addiy	1
	jmpnz	lbpwrite6
	lda	ledmodeset	;
	sta	LEDMode				
	lwi	mem6
	sta	temp0
	lwi	01Fh
	and	leddebugptr
	ashr
	add	temp0			
	sta	t
	jmp	lbpcomdone

dataxfer6c
	jsr	cssetup
lbpread6c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@z,mem6c
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread6nic
	lwi	2
	addto	lbpcaddr
	addiz	1
lbpread6nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread6c
	nop
	nop
	jmp	lbpcomdone

parse_4				; lbp timer/utility
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer4c	; control space
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize2
	jmpnz	lbpparseerr	; only 16 bit access allowed
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	dataxferla4	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr4
	addiy	1		; skip over address
	jmp	dataxfer4
dataxferla4
	lda	lbpaddr4
dataxfer4
	ashr			; change to word address
	sta	z		; 
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwrite4
lbpread4
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	z
	nop
	jmpnz	m4read1		; 0 is timestamp
	lda 	USTimer
	nop
	jmp	m4readdone
m4read1
	lda	z
	sub	oneloc
	jmpnz	m4read2
	lda	uwait
	nop
	jmp	m4readdone	; read of wait location returns last wait time
m4read2
	lda	z
	sub	twoloc
	jmpnz	m4read3
	lda	@z,mem4		; read of htimeout is normal read
	nop
	jmp	m4readdone	; 
m4read3
	lda	z
	sub	threeloc
	jmpnz	m4read4567
	lwi	01h		; mask for refout bit		
	sta	htimermask
	jsr	waitforhtimer	; wait for refout or timeout
	jmp	m4readdone
m4read4567	
	lda	z
	sub	fourloc
	jmpnz	rhtime1
	lwi	02h		; mask for htimer1
	sta	htimermask
	jsr	waitforhtimer
	jmp	m4readdone
rhtime1	lda	z
	sub	fiveloc
	jmpnz	rhtime2
	lwi	04h		;mask for htimer2
	sta	htimermask
	jsr	waitforhtimer
	jmp	m4readdone
rhtime2	lda	z
	sub	sixloc
	jmpnz	rhtime3
	lwi	08h		;mask for htimer3
	sta	htimermask
	jsr	waitforhtimer
	jmp	m4readdone
rhtime3
	lwi	010h
	sta	htimermask
	jsr	waitforhtimer	;mask for htimer4			
m4readdone
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread4ni
	lwi	2
	addto	lbpaddr4
	addiz	1
lbpread4ni
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread4
	nop
	nop
	jmp	lbpcomdone
lbpwrite4
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@y
	sta	@z,mem4		; we always do the store even though 
	lda	z		; it may in fact be unused
	jmpnz	m4write1	; 0 is timestamp so write is a no-op
	nop
	nop
	jmp	m4writedone
m4write1
	lda	z
	sub	oneloc		; wait loc
	jmpnz	m4write2
	lda	USTimer
	sta	usstarttime	
	nop	
	jsr	waitforustimer	; write of wait location results in us wait of N
	jmp	m4writedone	
m4write2
	lda	z
	sub	twoloc		; timeout loc (mem write was already done)
	jmpnz	m4write3
	nop	
	nop		
	jmp	m4writedone	
m4write3
	lda	z
	sub	threeloc
	jmpnz	m4write4567
	lwi	01h		; mask for refout bit		
	sta	htimermask
	jsr	waitforhtimer	; wait for refout or timeout
	jmp	m4writedone
m4write4567	
	lda	z
	sub	fourloc
	jmpnz	whtime1
	lwi	02h		; mask for htimer1
	sta	htimermask
	jsr	waitforhtimer
	jmp	m4writedone
whtime1	lda	z
	sub	fiveloc
	jmpnz	whtime2
	lwi	04h		;mask for htimer2
	sta	htimermask
	jsr	waitforhtimer
	jmp	m4writedone
whtime2	lda	z
	sub	sixloc
	jmpnz	whtime3
	lwi	08h		; mask for htimer3
	sta	htimermask
	jsr	waitforhtimer
	jmp	m4writedone
whtime3				; no more possibilities
	lwi	010h		; mask for htimer4		
	sta	htimermask
	jsr	waitforhtimer		
m4writedone
	addiz	1		; skip over write data
	lwi	LBPIncAddrMask	; 
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpwrite4ni
	lwi	2
	addto	lbpaddr4
lbpwrite4ni
	lwi	MinusOne
	addto	loopiloc
	addiy	1
	jmpnz	lbpwrite4
	nop
	nop
	jmp	lbpcomdone

dataxfer4c
	jsr	cssetup
lbpread4c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@z,mem4c
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread4nic
	lwi	2
	addto	lbpcaddr
	addiz	1
lbpread4nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread4c
	nop
	nop
	jmp	lbpcomdone

parse_0c			; user control space
	jsr	cssetup
lbpread0c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@z,mem0c
	sta	@x
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread0nic
	lwi	2
	addto	lbpcaddr
	addiz	1
lbpread0nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread0c
	nop
	nop
	jmp	lbpcomdone

parse_1				; Ethernet chip space
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer1c
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize2
	jmpnz	lbpparseerr	; only 16 bit access allowed
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	dataxferla1	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr1
	addiy	1		; skip over address
	jmp	dataxfer1
dataxferla1
	lda	lbpaddr1
dataxfer1
	ashr			; change to word address
	sta	z		; for control space only
	lwi	2
	and	lbpaddr1
	jmpz	patchethlow
	lwi	0C000h
	or	lbpaddr1
	sta	lbpethaddr
	jmp	dataxfer1a
patchethlow
	lwi	03000h
	or	lbpaddr1
	sta	lbpethaddr
dataxfer1a
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwrite1
lbpread1
	lwi	00F00h
	and	lbpethaddr
	jmpnz	lbpmemerr	
	nop
	lda	lbpethaddr
	jsr	EtherRW
	lda	etherin
	sta	@x	
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread1ni
	lwi	2
	addto	lbpaddr1
	lwi	2
	addto	lbpethaddr
lbpread1ni
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread1
	nop
	nop
	jmp	lbpcomdone
lbpwrite1
	lwi	00F00h
	and	lbpethaddr
	jmpnz	lbpmemerr	
	lda	@y
	sta	etherout
	lda	lbpethaddr
	jsr	EtherWW
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpwrite1ni
	lwi	2
	addto	lbpaddr1
	lwi	2
	addto	lbpethaddr
	addiz	1
lbpwrite1ni
	lwi	MinusOne
	addto	loopiloc
	addiy	1
	jmpnz	lbpwrite1
	nop
	nop
	jmp	lbpcomdone

dataxfer1c
	jsr	cssetup
lbpread1c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@z,mem1c	; from mem1c const area
	sta	@x		; to xmit buf
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread1nic	; no inc
	lwi	2
	addto	lbpcaddr
	addiz	1
lbpread1nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread1c
	nop
	nop
	jmp	lbpcomdone
parse_2				; lbp ethernet EEPROM space
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer2c
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize2
	jmpnz	lbpparseerr	; only 16 bit access allowed
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	dataxferla2	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr2
	addiy	1		; skip over address
	jmp	dataxfer2
dataxferla2
	lda	lbpaddr2
dataxfer2
	ashr			; change to word address
	sta	z		; for control space only
	sta	eeaddr
dataxfer2a
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwrite2
lbpread2
	lwi	0FFC0h
	and	eeaddr
	jmpnz	lbpmemerr
	nop
	nop
	jsr	e_eepread
	lda	eedout
	sta	@x	
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread2ni
	lwi	2
	addto	lbpaddr2
	lwi	1
	addto	eeaddr
lbpread2ni
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread2
	nop
	nop
	jmp	lbpcomdone
lbpwrite2
	lwi	03602h		; private eeprom write enable (includes MAC)
	sub	eepromwena
	jmpz	lbpwr2all	; no lower address bound
	lwi	05A02h		; public eeprom enable (no MAC access)
	sub	eepromwena
	jmpnz	lbpwriteerr
	lwi	15		; word address must be 15 or more
	sub	eeaddr
	jmpnc	lbpwriteerr	
lbpwr2all
	lwi	0FFC0h
	and	eeaddr
	jmpnz	lbpmemerr
	lda	@y
	sta	eedin
	jsr	e_eepwrite
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpwrite2ni
	lwi	2
	addto	lbpaddr2
	lwi	1
	addto	eeaddr
lbpwrite2ni
	lwi	MinusOne
	addto	loopiloc
	addiy	1
	jmpnz	lbpwrite2
	nop
	nop
	jmp	lbpcomdone

dataxfer2c
	jsr	cssetup
lbpread2c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@z,mem2c	; from mem2c const area
	sta	@x		; to xmit buf
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread2nic	; no inc
	lwi	2
	addto	lbpcaddr
	addiz	1
lbpread2nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread2c
	nop
	nop
	jmp	lbpcomdone

parse_3				; lbp FPGA flash EEPROM space
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer3c
	lwi	LBPAddrThereMask ; check if address in command
	and	lbpcommand
	jmpz	dataxferla3	; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpaddr3
	addiy	1		; skip over address
	jmp	dataxfer3
dataxferla3
	lda	lbpaddr3
dataxfer3
	sta	z		; for control space only
	lwi	LBPControlMask
	and	lbpcommand
	jmpnz	dataxfer3c
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize4
	jmpnz	lbpparseerr	; only 32 bit flash access allowed
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwrite3
lbpread3
	lda	x					;  check sendbuffer limit
	sub	sendbuflimit
	jmpnc	lbpmemerr
	lda	lbpaddr3
	jmpz	readfaddr
	sub	fourloc
	jmpz	readfdata
	sub	fourloc
	jmpz	readflids
	nop
	nop
	jmp	lbpmemerr
readfaddr
	jsr	finishfl	; finish any op in progress
	lda	fladdr+0
	sta	@x,0	
	lda	fladdr+1
	sta	@x,1	
	jmp	readnext3
readfdata
	jsr	readfl
	lwi	4		; increment flash address pointer
	addto	fladdr+0
	lwi	0
	addcto	fladdr+1	
	jmp	readnext3s
readflids
	jsr	finishfl	; finish any op in progress	
	jsr	readflid
readnext3s
	lda	fldata+0
	sta	@x,0
	lda	fldata+1
	sta	@x,1
readnext3
	lwi	MinusOne
	addto	loopiloc
	nop
	addix	2
	jmpnz	lbpread3
	nop
	nop
	jmp	lbpcomdone
lbpwrite3
	lda	lbpaddr3
	jmpz	writefaddr
	sub	fourloc
	jmpz	writefdata
	sub	eightloc
	jmpz	eraseit
	nop
	nop
	jmp	lbpmemerr
writefaddr
	jsr	finishfl	; finish any op in progress
	lda	@y,0
	sta	fladdr+0
	lda	@y,1	
	sta	fladdr+1
	jmp	writenext3
eraseit
	jsr	finishfl	; finish any op in progress
	lwi	05A03h		; eeprom enable?
	sub	eepromwena
	jmpnz	lbpwriteerr
	nop
	nop
	jsr	erasefl
	jmp	writenext3
writefdata
	lwi	05A03h		; eeprom enable?
	sub	eepromwena
	jmpnz	lbpwriteerr
	lda	@y,0
	sta	fldata+0
	lda	@y,1
	sta	fldata+1
	jsr	writefl
	lwi	4		; increment flash address pointer
	addto	fladdr+0
	lwi	0
	addcto	fladdr+1	
writenext3
	lwi	MinusOne
	addto	loopiloc
	addiy	2
	jmpnz	lbpwrite3
	nop
	nop
	jmp	lbpcomdone

dataxfer3c
	jsr	cssetup
lbpread3c
	lda	z
	sub	eightloc
	jmpnc	lbpmemerr
	lda	@z,mem3c	; from mem3c const area
	sta	@x		; to xmit buf
	lwi	LBPIncAddrMask	
	and	lbpcommand	; see if we need to inc address
	jmpz	lbpread3nic	; no inc
	lwi	3
	addto	lbpcaddr
	addiz	1
lbpread3nic
	lwi	MinusOne
	addto	loopiloc
	addix	1
	jmpnz	lbpread3c
	nop
	nop
	jmp	lbpcomdone

cssetup
	lwi	LBPSizeMask
	and	lbpcommand
	sub	lbpsize2
	jmpnz	lbpparseerr	; only 16 bit access allowed
	lwi	LBPWriteMask
	and	lbpcommand
	jmpnz	lbpwriteerr	; no writes allowed
	lwi	LBPAddrThereMask	; check if address in command
	and	lbpcommand
	jmpz	csnoadd		; no, get local pointer
	lda	@y		; yes, read from stream
	sta	lbpcaddr
	addiy	1		; skip over address
	jmp	csadd		; 	
csnoadd
	lda	lbpcaddr
csadd
	ashr
	sta	z
	ret

waitforhtimer
	lwi	0
	sta	hustimerdelta	
	lda	USTimer
	sta	hustimerstart
	lda	HTimerBits	; old state to current state
	and	htimermask
	sta	oldhtimerstate
htimerwloop
	lda	HTimerBits
	and 	htimermask
	sta	htimerstate	
	jmpz	hwaitlow	; low so check timeout
	lda	oldhtimerstate
	jmpz	htimerret	; if state =t and oldstate = f. we're done
hwaitlow
	lda	htimerstate
	sta	oldhtimerstate
hchecktimeout
	lda	USTimer		; read hardware timer
	sub	hustimerstart	; subtract start time for delta time
	sta	hustimerdelta	; save delta for reporting
	sub	htimeout	; max wait time
	jmpc	htimerwloop	; if max wait time is > delta, keep waiting
	lwi	020h		; set hm2timeout error
	orto	errorreg
htimerret
	lda	hustimerdelta	; return with how long we waited
 	ret

waitforustimer
	lda	USTimer		; read hardware timer
	sub	usstarttime	; subtract start time for delta time
	sub	uwait		; if wait time is > delta keep waiting
	jmpc	waitforustimer
	nop
	nop
	ret
