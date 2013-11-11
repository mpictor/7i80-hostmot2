.MSFIRST
#include global.equ
#include resmod.equ
;todo
; normalize all resolver data
; auto adjust phase per channel (pick best offset at startup)
;			
;program		resmod resolver input module code for 7I49 

begin
	nop	
	nop			; majik pipeline foo
	nop
	jsr	init/2		; initialize c+v	
				; then fall into host/process loop
	jsr	tenksetup/2	; default is 10 KHz
	jsr	setupdaqwave/2
	;**************************************************************
hostloop
	lda	commandreg
	sta	commandloc
	sta	Y		; save address part		
	and	bit31loc	; fast fragile way to check if theres a request
	jmpz	nocom/2		; if not, run rest of code	
	nop
	lda	commandloc
	and     bit11loc	; start bit = 0x800
	jmpnz	checkcoms/2
	lda	commandloc
	and	bit15loc
	jmpz 	read/2
	lda	datareg		
	sta	@Y		; do write
	jmp	finish/2		
read	lda	@Y
	sta	datareg	
finish	
	sta	commandreg
nocom
	lda	daqcycount	; check if its time to do a process cycle	
	nop			; (once per resolver sine wave cycle)
	jmpz	hostloop/2	; do host interface while waiting for DAQ
	nop
	nop
	sta	daqcycount	; OK DAQ time :this decrements the daq request count 
	sta	settestbit
				; resolver data processing section :
	jsr	dodaq/2		; get our data
	jsr	phasedet/2	; compare with reference angle
	jsr	integrate/2	; integrate error
	jsr	calcsamp/2	; calculate channel signal amplitude
	jsr	stopspin/2	; zero velocity and mark as bad
				; any channels with low amplitude

	sta	clrtestbit
	lxwi	1		; increment every sample	
	addto	hostokcountloc
	jmp	hostloop/2
	
checkcoms
	lxwi	3
	and	commandloc
	jmpz	hnextdone/2	; no setup so do setup wave	
	sub	oneloc
	jmpnz	hnext0/2
	nop			; no uncond jumps in cond jmp shadow
	nop
	jsr	twodotfiveksetup/2
	jmp	hnextdone/2
hnext0
	sub	oneloc
	jmpnz	hnext1/2
	nop			; no unconditional jumps in cond jump shadow	
	nop
	jsr	fiveksetup/2
	jmp	hnextdone/2
hnext1
	sub	oneloc	
	jmpnz	hnextdone/2
	nop
	nop
	jsr	tenksetup/2
	
hnextdone
	jsr	setupdaqwave/2
backtohost
	lxwi	0h
	sta	commandreg
	nop
	nop
	jmp	hostloop/2	; back to hostloop	


	;**************************************************************
setupdaqwave			; sets up the sine wave gen table based on the
				; wgmagnitude
	lxwi	0
	sta 	loopiloc
	lxwi	sintable	
	sta	X
	nop
wgloop	
	lda	loopiloc
	sta	wgtableptrreg	; set up our wavegen table ptr	
	lda	@X		; get signed 16 bit sine data	
	lhwi	0		; drop all but low 16 bits
	mulss	wgmagnitudeloc	; scale
	wswp			; result in low 16
	rcr			; shr by 3
	rcr
	add	bit12loc
	rcr			; for 12 bit rounded unsigned
	addix	4		; inc sine table pointer
	and	bitmask12	; just 12 bits please
	sta	temp1loc
	lda	syncloc
	sub	loopiloc
	jmpnz	wgupdate/2	; not sync
	lda	bit13loc	
	orto	temp1loc
	nop
	nop
	nop
wgupdate
	lda	temp1loc
	sta	wgtabledatareg	
	lda	loopiloc	; inc wavgen table pointer	
	add	oneloc
	sta	loopiloc	
	sub	wavetablelenloc	;
	jmpnz	wgloop/2			
	nop
	nop	
	jmp	@R	; return


dodaq	;**************************************************************
	; DAQ system puts data in RAM, alternating halves of RAM buffer
	; each carrier cycle, we see which half is active and chose other
	; half for our calculations. We accumulate daccount samples starting 
        ; at 0 degrees (daqplusstart) and accumulate dacccount samples 
	; starting at the equivalent offset of 180 degrees 
        ; (daqminusstart) we the subtract the minus from the plus data
	; for our synchronously detected and averaged sine/cos amplitudes

	lxwi	daqdatahighhalf	; default chose high half of daq buffer
	sta	daqhalfloc	; could use temp but this is for debug
	lda	daqstatusreg		
	and	bit8loc		; see which buffer half is active
	jmpz	dodaq1/2	; if low is active, use high half
	lxwi	daqdatalowhalf	; otherwise use low half
	sta	daqhalfloc
dodaq1
	rtt			; save return address
	lxwi	summplus	; first do the plus parts
	sta	Y
	lda	daqplusstart	; in units of conversions = 12X	
	add	daqhalfloc	; our ptr to daq buffer half	
	sta	X
	jsr	dodaqaccum/2
	lxwi	summminus	; next do the minus parts
	sta	Y
	lda	daqminusstart	; in units of conversions = 12X	
	add	daqhalfloc	; our ptr to daq buffer half	
	sta	X
	jsr	dodaqaccum/2
	lxwi	ppsumm		; now we subtract the summ- from summ+
	sta	Z
	lxwi	summplus
	sta	Y
	lxwi	summminus
	sta 	X
	ttr			; restore return register
	nop
	lda	@Y+,0		; sine ch 0
	sub	@X+,0
	sta	@Z+,0
	lda	@Y+,1		; cos ch 0
	sub	@X+,1
	sta	@Z+,1
	lda	@Y+,2		; sine ch 1
	sub	@X+,2
	sta	@Z+,2		
	lda	@Y+,3		; cos ch 1	
	sub	@X+,3
	sta	@Z+,3
	lda	@Y+,4		; sine ch 2
	sub	@X+,4
	sta	@Z+,4
	lda	@Y+,5		; cos ch 2
	sub	@X+,5
	sta	@Z+,5
	lda	@Y+,6		; sine ch 3
	sub	@X+,6
	sta	@Z+,6
	lda	@Y+,7		; cos ch 3
	sub	@X+,7
	sta	@Z+,7
	lda	@Y+,8		; sine ch 4
	sub	@X+,8
	sta	@Z+,8
	lda	@Y+,9		; cos ch 4
	sub	@X+,9
	sta	@Z+,9
	lda	@Y+,10		; sine ch 5
	sub	@X+,10
	sta	@Z+,10
	lda	@Y+,11		; cos ch 5
	sub	@X+,11
	sta	@Z+,11
	nop
	nop	
	jmp	@R		; return


	;**************************************************************
dodaqaccum			; accumulate daqcount samples starting at X
	lda 	daqcountloc	; leave result in sin/cos summ table
	sta 	loopiloc	
	lxwi	0
	sta	@Y+,0		; clear target accumulators
	sta	@Y+,1
	sta	@Y+,2		
	sta	@Y+,3
	sta	@Y+,4
	sta	@Y+,5
	sta	@Y+,6
	sta	@Y+,7
	sta	@Y+,8
	sta	@Y+,9
	sta	@Y+,10
	sta	@Y+,11
daqloop
	lda	@X+,0		; sine ch 0
	addto	@Y+,0
	lda	@X+,1		; cos ch 0
	addto	@Y+,1
	lda	@X+,2		; sine ch 1
	addto	@Y+,2
	lda	@X+,3		; cos ch 1	
	addto	@Y+,3
	lda	@X+,4		; sine ch 2
	addto	@Y+,4
	lda	@X+,5		; cos ch 2
	addto	@Y+,5
	lda	@X+,6		; sine ch 3
	addto	@Y+,6
	lda	@X+,7		; cos ch 3
	addto	@Y+,7
	lda	@X+,8		; sine ch 4
	addto	@Y+,8
	lda	@X+,9		; cos ch 4
	addto	@Y+,9
	lda	@X+,10		; sine ch 5
	addto	@Y+,10
	lda	@X+,11		; cos ch 5
	addto	@Y+,11
	addix	daqpitch
	lda 	loopiloc
	sub	oneloc	
	sta	loopiloc
	jmpnz	daqloop/2
	nop			; no unconditional jumps in jump shadow
	nop
	nop
	jmp	@R		; return;

sinecos				; lookup sine and cos with table interpolation
				; 16 bit = 2PI, 16 bit result
	nop
	nop			; allow sta of langle to propogate
	lxwi	1024
	mulsu	langleloc	; base pointer (shr 6 for 10 bit pointer)
	wswp	
	and	bitmask10
	sta	X		; base address in sine table
	add	oneloc
	and	bitmask10
	sta	Y		; base +1 mod 1024			
	lxwi	03Fh
	and	langleloc	; get offset part
	mulsu	bit10loc	; shr 6 	
	sta	loffsetloc	;		
	lda	@Y+,sintable	; table at ptr +1
	sub	@X+,sintable	; get diff
	nop			; wait for sta loffsetloc
	mulsu	loffsetloc	; multiply by offset
	wswp			; in low word
	add	@X+,sintable	; add base		
	lhwi	0		; clear high
	sta	lsineloc
	nop
	jmp	@R		; return with value in acc


	;**************************************************************
phasedet			; phase detect input vs reference angle
	
	lxwi	0
	sta	Z
	sta 	T
	rtt			; save return address
	lxwi	numberofchannels
	sta	loopiloc
phasedetloop				
	lda	@Z+,prambegin
	sta	@Z+,rangleloc
	wswp			; in low half for angle
	add	bit14loc	; = 90 degrees so we get cosine from lookup
	sta	langleloc
	jsr	sinecos/2	; cos of langle
	lda	@T+,ppsumm+0	; sine adc data	
	mulss	lsineloc
	sta	temp1loc
	lda	@Z+,rangleloc
	wswp			; in low half for angle
	sta	langleloc
	jsr	sinecos/2	; sine of langle
	lda	@T+,ppsumm+1	; cos adc data	
	mulss	lsineloc
	sub	temp1loc
	sta	@Z+,phasecomp
	addiz	1
	addit	2
	lda	loopiloc
	sub	oneloc
	sta	loopiloc
	jmpnz	phasedetloop/2
	ttr			; restore return address
	nop
	nop
	nop
	jmp	@R

	;**************************************************************

integrate			; second order integrator
	lxwi	0
	sta	Z
	lxwi	numberofchannels
	sta	loopiloc
integrateloop
	lxwi	0
	sub	@Z+,phasecomp	; error
;	sta	vrambegin+7	; kludge to get error
	wswp			; get in low half	
	sta	temp2loc	; error in low 16 bits	
	mulsu	@Z+,trackigainloc; I term gain	
	addto	@Z+,velocityloc	; try new addto
	sta	@Z+,vrambegin
	sta	temp1loc
	lda	temp2loc
	mulsu	@Z+,trackpgainloc; P term gain 
	nop
	add	temp1loc
	sta	@Z+,virambegin	; into hs integrator
	addiz	1
	lda	loopiloc
	sub	oneloc
	sta	loopiloc
	jmpnz	integrateloop/2
	nop
	nop
	jmp	@R
	
	;**************************************************************

	;**************************************************************


calcsamp 			; calculate all channels amplitude squared values
	lxwi	0
	sta	Z
	sta 	T
	lxwi	numberofchannels
	sta	loopiloc
calcsamploop
	lda	@T+,ppsumm+0	; sine part
	mulss	@T+,ppsumm+0	; sine squared
	sta	temp1loc	; save sine squared
	lda	@T+,ppsumm+1		
	mulss	@T+,ppsumm+1	; cos squared
	nop
	add	temp1loc	; sin sq + cos sq
	sta	@Z+,samplitude
	addit	2
	addiz	1
	lda	loopiloc
	sub	oneloc
	sta	loopiloc
	jmpnz	calcsamploop/2
	nop
	nop
	jmp	@R

stopspin			; stop uncontrolled velocity on channels with no input
	lxwi	0
	sta	Z
	sta	temp1loc
	lda	oneloc		
	sta	temp2loc
	lxwi	numberofchannels
	sta	loopiloc
stopspinloop
	lda	@Z+,samplitude	; this allows dynamic changing of resolver connections
	and	topwordmask	
	jmpnz	ssnoerr/2	
	sta	@Z+,velocityloc
	sta	@Z+,virambegin
	lda	temp2loc	; mask	
	orto	temp1loc	; error flags
ssnoerr
	lda	temp2loc	; rotate mask	
	rcl
	sta	temp2loc
	addiz	1
	lda	loopiloc
	sub	oneloc
	sta	loopiloc
	jmpnz	stopspinloop/2
	lda	temp1loc
	sta	hstatus	
	jmp 	@R

twodotfiveksetup
		; 2.5 khz setup
	lxwi	419		; for 256 x 2.5 KHz
	sta	hsintrate
	lxwi	8		; 8 samples
	sta	daqcountloc
	lxwi	05000h
	sta	dtrackpgain	; default tracking pgain
	lxwi	0500h
	sta	dtrackigain	; default tracking igain
	lxwi	0FCh		; 180 degrees (42 samples total for wave so 12x21)	
	sta	daqminusstart
	lxwi	0		; 0 degrees	
	sta	daqplusstart
	lxwi	0347h		; was 0D1Ch
	sta	wgratereg	; for 2.5 KHz
	llwi	0E14Dh		; 14 bits + CPOL +12 MHz
	lhwi	02804h		; convert rate and count
	sta	daqmodereg
	sta	daqmoderegsh
	lxwi	29		; was 116		
	sta	syncloc		; ~ 40 degrees phase shift
	jmp 	allsetup/2

fiveksetup
		; 5 khz setup
	lxwi	839		; 256 x 5 KHz
	sta	hsintrate
	lxwi	8		; 8 samples
	sta	daqcountloc
	lxwi	05000h
	sta	dtrackpgain	; default tracking pgain
	lxwi	0500h
	sta	dtrackigain	; default tracking igain
	lxwi	0		; 0 degrees into table for +DAQ	
	sta	daqplusstart
	lxwi	09Ch		; 180 degrees into table for DAQ-	
	sta	daqminusstart
	lxwi	068Eh
	sta	wgratereg	; for 5/4.8 KHz
	llwi	0014Dh		; 14 bits + CPOL +12 MHz
	lhwi	01804h		; convert rate (50/66 MHz) and count (26)
	sta	daqmodereg
	sta	daqmoderegsh
	lxwi	36		; was 144		
	sta	syncloc		; ~ 50 degrees phase shift
	jmp 	allsetup/2

tenksetup
		; 10 khz setup
	lxwi	1678		; for 256 x 10 KHz
	sta	hsintrate	
	lxwi	5		; 5 +samples, 5 -samples
	sta	daqcountloc
	lxwi	08000h
	sta	dtrackpgain	; default tracking pgain
	lxwi	0800h
	sta	dtrackigain	; default tracking igain
	lxwi	0		; 0 degrees into table for +DAQ	
	sta	daqplusstart
	lxwi	054h		; = 7 samples = 180 degrees into table for DAQ-	
	sta	daqminusstart
	lxwi	0D1Ch		; was 03470h

	sta	wgratereg	; for 10/9.6 KHz
	llwi	0014Dh		; 14 bits + CPOL +12 MHz
	lhwi	00B04h		; convert rate (50/66 MHz) and count (13) 
	sta	daqmodereg
	sta	daqmoderegsh
	lxwi	45		; was 180 		
	sta	syncloc		; ~63 degrees phase shift

allsetup
	lxwi	2		; pdmrate = clklow/(N+1)
	sta	wgpdmratereg	; 16/16.6666 MHz	
	lxwi	00FFh
	sta	wglengthreg	; 256 length table
	lxwi	3600h		; half scale drive
	sta	wgmagnitudeloc	
	lda	dtrackpgain
	sta	trackpgainloc+0
	sta	trackpgainloc+1
	sta	trackpgainloc+2
	sta	trackpgainloc+3
	sta	trackpgainloc+4
	sta	trackpgainloc+5
	lda	dtrackigain
	sta	trackigainloc+0
	sta	trackigainloc+1
	sta	trackigainloc+2
	sta	trackigainloc+3
	sta	trackigainloc+4
	sta	trackigainloc+5
	jmp	@R


init	; constant and variable initialization	
	; first zero all of RAM in a loop
	lxwi	254
	sta 	ramend
	lxwi	rambegin
	sta	X
initloop
	lxwi	0
	sta	@X+,0
	addix	1
	lda	X
	sub	ramend
	jmpnz	initloop/2
	; then rest of initialization
	lxwi 	interfacetype
	sta	interfacetypeloc
	lxwi 	interfacewidth
	sta	interfacewidthloc
	lxwi 	majorrevision
	sta	majorrevisionloc
	lxwi 	minorrevision
	sta	minorrevisionloc
	llwi 	whatisupport0l
	lhwi	whatisupport0h
	sta	whatisupport0loc
	lxwi	gpioinputbits
	sta	gpioinputbitsloc
	lxwi	gpiooutputbits
	sta	gpiooutputbitsloc
	lxwi	processortype
	sta	processortypeloc
	lxwi	numberofchannels
	sta	numberofchannelsloc
	lxwi	0
	sta	commandreg	; clear any pending commands
	lhwi	08000h		; note depends on low half being 0
	sta	bit31loc
	lhwi	0FFFFh		; note depends on low half being 0
	sta	topwordmask
	lxwi	1
	sta 	oneloc
	lxwi	4
	sta	bit2loc
	lxwi	8
	sta	bit3loc
	lxwi	020h
	sta	bit5loc
	lxwi	03Fh
	sta	hstatus
	lxwi	0100h
	sta	bit8loc
	lxwi	0200h
	sta	bit9loc
	lxwi	00400h
	sta	bit10loc
	lxwi	0800h
	sta	bit11loc
	lxwi	01000h
	sta	bit12loc
	lxwi	02000h
	sta	bit13loc
	llwi	04000h
	sta	bit14loc
	llwi	08000h
	sta	bit15loc
	lxwi	-1
	sta	minusoneloc
	lxwi	03FFh
	sta	bitmask10
	lxwi	0FFFh
	sta	bitmask12
	lxwi	sintablelength
	sta	sintablelenloc	
	lxwi	wavetablelength
	sta	wavetablelenloc	
	jmp	@R	

	org	07FFh	;weird word addressing = 1K doubles
	dw	0abcdh	
.end