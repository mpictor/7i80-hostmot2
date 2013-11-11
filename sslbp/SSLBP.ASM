;SSLBP.ASM
;TODO
;see if clearrecv is necessary to save space
;check  jumpshadowpipe at the end of sendsuffix

;report remote faults during blather

;make a check timer which restarts after error for those instructions
;that do not loop
;
;fix too many errors bug when using checktimer

;rewrite decby2	movd	dividend_double,timerdiv_word
;	decd	timerdiv_word	
;	decd	timerdiv_word	
;	movd	timerdiv_word,hardwaretimer_uint

;only recalculate baudrate if different
;maybe get rid of notreadybits 
;rename chanid

;if channel not started no doit but indicate error

;change logerrors to subroutine if needed

;use generic blather for 7I64 after setting sizes
;see if remfault bit cleared in 8I20 after faults cleared
;	if not use generic fix

;possibly remove seterr from deadendinc

;fix possibility of looping indefinitely in checkclrfaults
;add provision for clearing 8I20 status and LBP status (LBPPROCRESET?)
;do divide with bytes
;global recv buffer
;subroutine to get data and verify recv buffer for correct crc
;now we have 1/4 of ram (write protected) for constants and send strings

;NOTES
;after start wait for command reg cleared then not ready is valid
;#DEFINE SMALL
;/* No (unconditional jumps) or (calls) or (reads with side effects) in the 2 instruction shadow of conditional jumps
;/* Two pipes required after stab of variable until ldab
;/* Three pipes required after store of Index register until ldab @X
;/* Two pipes required after store of Index register before addi index reg
;/* Two pipes required after addi index reg before store at Index register 

;INDEX REGISTER USAGE
;X: channel
;Y: used as temp in recvstring subroutine
;Z: uart
;T: host

;TODO
;rewrite loops for 0 
;add LBPCAPABILITY for crc's

.include "\product\dumb8\DUMB8W.mac"
.include "\product\dumb8\DUMB8SW.mac"
.include "\product\dumb8\struct8.mac"
.include "\dspic\lbp.equ"
.include "\softdmc\dspic\8i20inc.equ"
;include "DUMB8S.mac"
.include "ssLBP.mac"
.include "ssLBP.jmp" ;jumptable
.include "ssLBP.equ"
zeros	equ	zero_byte

eom	set	2047	;leave room for rom cookie

#DEFINE	ones	one_byte

;************************ CODE ********************************************
	org	0
	nop
	nop
	nop	;necessary for the next instruction to execute
	initmem				;only once
	commandcomplete		;init clear pending commands

	begin
		ldab	initialized_byte
		ifnz
			ldab	commandtoprocess_byte	;something to do
			orb	stopbits_byte		;not finished stopping
			orb	blatherbits_byte	;still blathering
			ifnz
				ldab	hardwaretimer_uint
				subb	looptimer_byte
				stab	looptime_byte
				movs	hardwaretimer_uint,looptimer_byte

		 		loaddX	channel0_ptr
				loaddZ	uartoffset_const
				loaddT	controlparam0_ptr

				loads	1,whichchanbits_byte
				loads	~1&255,notwhichchanbits_byte

				forr	chanloop_byte,numberofchannels_byte;do all channels
					ldab	stopbits_byte
					andb	whichchanbits_byte
					ifnz
						initchannel
					endif
				
					ldab	startbits_byte
					andb	whichchanbits_byte
					ifnz
						dochannel
					endif

					ldab	@X,chanerrorlog_byte
					stab	@T,error_byte
					ldab	@X,chanstatus_byte
					stab	@T,status_byte
					ldab	@X,chanstate_byte
					stab	@T,state_byte
					ldab	@X,chanremfault_byte
					stab	@T,csrremfault_byte

					addiX	channelstride_const	;setup for next
					addiZ	uartstride_const		
					addiT	hoststride_const
;next channel
					ldab	whichchanbits_byte
					addtob	whichchanbits_byte	;shl
					xorb	true_byte		;invert
					stab	notwhichchanbits_byte
				nextr	chanloop_byte

				ife	doit_const,commandtoprocess_byte
					ldab	notreadybits_byte	;
					xorb	true_byte

					andb	startbits_byte	;rev 33 only started channels
					andb	nchannelmask_byte
					andb	requestbits_byte
					andb	notdonebits_byte
					ifz	;all requests of ready channels have been processed
						ldab	whichchanbits_byte
						ortob	runningbits_byte
						ldab	notwhichchanbits_byte
						andtob	blatherbits_byte

						ldab	invalidbits_byte
						stab	datareg_byte
						commandcomplete	;clear doit
						datapipe
					endif
				endif

				ife	normalstart_const,commandtoprocess_byte
					ldab	notstartbits_byte
					andb	notreadybits_byte
					andb	nchannelmask_byte
					ifz	;all channels have started or errored
						ldab	notreadybits_byte
						xorb	true_byte
						andtob	startbits_byte

						ldab	notreadybits_byte
						stab	datareg_byte
						commandcomplete	;clear normal start
						datapipe
					endif
				endif

				ife	LBPstart_const,commandtoprocess_byte
					ldab	notstartbits_byte
					andb	notreadybits_byte
					andb	nchannelmask_byte
					ifz	;all channels have started or errored	
						ldab	notreadybits_byte
						xorb	true_byte
						andtob	startbits_byte

						ldab	notreadybits_byte
						stab	datareg_byte
						commandcomplete	;clear lbp start
						datapipe
					endif
				endif

				ife	stopstart_const,commandtoprocess_byte
					ldab	commandregl_byte
					ifnz
						ldab	stopbits_byte
						stab	datareg_byte
						andb	nchannelmask_byte ;mask here to allow channels not there be reported 
									  ;but allow command to complete
						ifz
							commandcomplete	;clear stop start
						endif
					endif
				endif
			endif	;commandtoprocess
		else	;not initialized
			globalinit	;slooooow, initialize variables and hardware
			sets	initialized_byte
			ife	stopstart_const,commandtoprocess_byte;rest cleared
				ldab	commandregl_byte
				ifz
					commandcomplete	;stopstart
				endif
			endif
		endif
	
		checkforcommand
	 again

;************************ SUBROUTINES ********************************************
.include "SSLBP.SUB"

;************************ REVSIONS ********************************************
;revision	equ	0
;from sserial
;no sequences
;added toomanyerror_bit for excessive timeouts
;added jumpshadow pipes before send macros
;write 0 to rxmode to disable rx masks
;set readybits before sendLBP for setup
;set readybits before send for normal
;revision	equ	1
;added 7i64 support
;changed ready status to notready and added remnotrdy to status reg
;changed start/stop to init on rising edge of start
;added chanextracharcount inc and clear rxfifo if extra char
;jumpshadowpipe before ldab	initialized_byte
;updatehost in init

;minorrevision	3
;only 1 checkid
;added more status bits
;
;minorrevision	4
;init if stopped
;init chanid
;clear invalidbits only if status =0
;minorrevision	5
;clrstatus	errorstatbit_const|remfaultbit_const in doit to make not sticky
;jumptable dochannel
;8bit checktimer
;reset timeouts before blather
;set timeouts long in setup
;fixed bug in clrstatus, needs()
;removed checktimer ifc in recvLBP
;if timeout err in 8i20 recv try again
;if timeout err in 7i64 or lbp recv try again
;minorrevision	6
;added notdonebits cleared after complete or error
;removed bogus clrcommandreg
;removed readybit
;added startbits and notstartbits
;added starttypes
;full decode for start,doit
;added validcommand clear command reg for invalid commands
;minorrevision 8 sent to andy
;minorrevision 9 sent to andy
;set toomanyerrorbit in deadend

;minorrevision 10
;only clear not done if toomanyerror
;don't clear chanerrors in starttimeout
;set toomanyerror in deadendatx
;implemented invalid command command clear
;deadendinc before seterror
;fixed checkcookie,checkid etc. restart only if current error
;added channotreadyerror if we cannot clear faults first
;added channotreadyerror if we cannot clear faults after pidon 
;rewrote doblather18I20 with no starttimer if error
;fixed incorrect track in checkid0
;added indirect mainrpc in start

;minorrevision 11
;added nchannelmask
;fixed jumpshadow errors with checker

;minorrevision 12
;no doit if stopped

;minorrevision 13
;added setuptimeout
;use maxerrors and compare chanerrorcount
;use prog divider for timer
;different base timers for setup and normal

;minorrevision 14
;use X for both chan and recv strings to free Y
;added start and runtimeouts for both start and starts

;need to add host doorbell newcheckcommand doesn't work

;minorrevision 15
;fixed runtimeout

;minorrevision 16
;remove invalidid_enum, doesn't clear command reg
;added clrnotstart in else of checkid1
;fixed channelstride=48
;added hostdoorbell
;clear hostdoorbell in initmem and init
;retry in blather if timeout or crc error

;minorrevision 17
;go back to send in setup mode if timeout err and clr request and done
;set runtimeout before going to sendLBP state

;minorrevision 18

;minorrevision 19
;add generic support
;place cardid in interface1
;remove 8i20 faults in docheckfaults_enum		
;made seterror a subroutine
;removed extra clrfaults for 7I64
;removed unneeded states for put etc

;minorrevision 20
;0 stop global
;bit mask stop
;zero ram at start
;removed command_byte 
;removed commandl_byte
;removed commandh_byte
;use commandpending to only allow one decode
;fixed putreaddata4..7
;fixed startbits to indicate which channel started
;used if else then for processcommand
;removed commandpending

;minorrevision 21
;prepare for strings in ram
;clear generic outputs before clearing faults for 7I71
;removed orb	@X,1 in getgenclrfaults
;sendsuffix falls through to settimer 46 inst free
;removed deadend_enum	48 inst free
;stop per channel so broken channels can be stopped and restarted
;if channel is not responding do round robin checking so that when it is 
;  ready so it can be restarted
;unitnumber for generic devices return options byte 2
;added rwsize returned in chanid
;removed jumpshadow in dec@X
;moved RTT and TTR from seterr to sslbp.sub
;don't clear invalid if chanerror so error indicates failure in datareg
;added get receive size to cleargeneric
;added nibblemask_byte
;added genericRPCrecvsize macro
;clear remfaultbit when faults are verified cleared generic and 7i64
;added input and output data size reporting

;minorrevision 21
;rewrote sl subroutine to use data in place

;minorrevision 22
;rewrite nibblemask using SHRN
;added sendsendsuffix subroutine saved 17 instructions
;adding measureRPCtime
;added clrrequest to initchan
;initialize chantimeout_byte in initchan (may not be necessary)
;added chanerrorlog which are the sticky error bits fixed seterrorsub

;chanerror is cleared at start or doit
;logerrors occurs during blather and after recv
;only call checktimer in else of recvstring
;added blather bits
;changed timer to 5uSec
;added recvstring0
;use generic blather for 7I64 after setting sizes

;minorrevision 23
;only stop command is valid if commandtoprocess isn't clear when doorbell rings
;added chanrwsize_byte,calculate for all
;fixed error ifnz in blather bits
;added rwsize in user2
;changed chan size to 50
;added chandatabase

;minorrevision 24
;added writeback instructions
;saved 99 instructions
;added datapipes
;move commandcomplete to first of ifs to avoid datapipes
;rewrote sendLBPstring
;fixed sendclrgenricstring to skip if no output 
;released to matt shaver and andy

;minorrevision 25
;clear hostparam2 at startup
;added break check and breakerrorcount
;added runningbits for fault reporting
;renamed rwsize to discovery

;minorrevision 26
;added fault generation to state20
;can't use LBPUNITID,LBPPROCDATA,LBPDISCOVERY because of 
;   backwards compability with 7I64 and 8I20

;minorrevision 27
;removed idbyte
;alway put remfault in top byte of csr
;added set swmode from csr
	
;minorrevision 28
;added 	andb	nchannelmask_byte to stop
;clear rx errors in reset state					
;released

;minorrevision 29
;fixed starts timer
;added update chanremfault_byte in state 26

;minorrevision 30
;three nops necessary at beginning for ldib to work

;minorrevision 31
;in dogetgenclrfaults_enum	
;rev31			deadendincatX	chanremfaultcount_byte
;rev31			seterror	remfaulterrorbit_const
;fixed decd,decq bug in dumb8sw

;minorrevision 32
;added reporting of 8I20 faults in docheckfaults

;minorrevision 33
;renamed discovery variables

;fixed BUG if doit if channel not started causes command reg to not clear
;  also stopall won't fixit
; added startbits in doit check
;removed jumpshadowpipe in discovery

;minorrevision 34
;added remote programming feature
;changed checkstatus to checkerror in recvLBP
;added workaround in getunitnumber for generics without setup unitnumber RPC
;added channelstart and channelstride
;
;removed test0 in \product\dumb8\
;minorrevision 35
;
;added 	ldab	@X,0 stab @X,chanremfault_byte	in dogetgenfaults_enum
;to report invalid swmode which is a fault
;no more instruction space
;minorrevision 36
;removed rev 35 changes
;added  stab @X,chanremfault_byte in dochkgenclrfaults_enum
;1 instruction left

;minorrevision 37
;removed three_byte
;removed cookie_byte
;added chandisablecrc
;removed timerrate_long use divisor_ulong
;rewrote setcarry at end of recv subroutine
;new processor with stack
;remove TTR RTT
;change STAB	RL	to PUSH
;changed sslbp.bat for new processor instructions
;docheckswmode_enum	
;	ldib	0
;	call	recvstring
;	call	recvstring0
;rewrote initchannel
;added mov*16@Xq same size but faster than 4 calls to sl
;rewrote clrd in settimersub

;minorrevision 38
;fixed bug in initchannel; andto changes acc

;minorrevision 39
;if crc error in recvstring subroutine don't satisfy number of chars
;removed crc checking in sslbp.jmp
;added else dostarttimer_enum in dochecklbpstatus_enum 
;added and docheckswmode_enum	
;added checktimerrestart
;replaced checktimer with checktimerrestart where there was no option

;minorrevision 40
;rewrote divoq in dumb8w.mac using addtoq
;changed timerdiv_word timediv_uint
;changed LBPaddress_word LBPaddress_uint
;zero chanbreakcount in clearfaults
;added to blather	ldib	toomanyerrorbit_const
;			andb	@X,chanerrorlog_byte
;			ifz
;				loads@X	blather0_enum,chanstate_byte
;			endif
;added rxoverrun detection in sendprefix
;removed clr rxfifo in sendprefix (done in seterror)
;no rounding or incrementing in inituart 
;added looptime and looptimer
;removed chanchktoomanyerrors
;rearranged sendLBP macro beginning and added the following to avoid invalid command
;added	ldib	LBPCOMMAND_byte
;	andb	LBPcommand_byte	
;	ifz
;		clrrequest
;		jmp	finish
;	endif
;T not needed in global init
;timer set to 2uS
;added ife@X to save temp in recvLBP 
;remove clrnotdone in recvLBP
;added clrinvalid to LBP if not toomany errors
;clear command after writing data reg

;minorrevision 41
;fixed timerfudge back to 40uS

;minorrevision 42
;a uflbp bug which restored the baudrates before all the chars were sent
;  broke the 8I20 in setup mode which broke writes
;  this caused sslbp to loop in checklbpstatus and crash sslbp
;  the following is to fix that possibility

;changed gobacktostart to checktimerrestart 
;added seterror	remfaulterrorbit_const in dochecklbpstatus_enum
;added deadendincatX	chanremfaultcount_byte
;
;maybe remove checking the reset of the lbpstatus if more room is needed
	.END
