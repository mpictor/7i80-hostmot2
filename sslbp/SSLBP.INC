;after start
;CSR	|   REMFAULT	|        STATE	|      STATUS	|      ERROR	|
;USR0	|        UNIT ID NUMBER            				|
;USR1	|        UNIT NAME                 				|
;USR2	|    GLOBAL RECORD POINTER	|    PROCESS RECORD POINTER  	|

;after doit
;CSR	|REMFLT | STATE	| STATUS|ERROR	|


;TYPES (contents of ram address)
;	<blank>	number of bits is hardware dependent	
;	ptr	10 bit address pointer
;	flag	16 bit value 0 is false, nonzero is true
;	uint	16 bit unsigned value 0..65535
;	int	16 bit signed value -32768..32767
;	ulong	32 bit unsigned value 0..4294967295
;	long	32 bit signed value -2147483648..2147483647
;	double	64 bit signed value -1.8E19..1.8E19

;PARAMETER		VALUE	TYPE	FUNCTION
;constants
majorrevision		1		%const	updated when parameters change, hi byte
minorrevision		42		%const	lo byte
whatisupport0		30324938h	%const	8I20
id0			80h		%const	8I20

whatisupport1		34364937h	%const	7I64
id1			74h		%const	7I64

interfacetype		12h		%const
interfacewidth		8		%const
gpioinputbits		0		%const
gpiooutputbits		0		%const
processortype		D8h		%const

true			0FFh	%const
false			0	%const

channelstride		50	%const	@X
;stringstride		16	%const	@Y	not used
uartstride		1	%const	@Z
hoststride		4	%const	@T

NUrpcrecvsize		8	%const  number of received chars from rpc
faultsize		2	%const  number of received chars from fault
lbpclrfaultsize		1	%const  number of received chars from LBP clear fault
lbpfaultsize		1	%const  number of received chars from LBP fault
clrfaultsize		2	%const  number of received chars from clrfault
txena			20h	%const  to turn on transmitter
rxoverrun		01h	%const  set when overrun detected
rxbreak			02h	%const  set when break detected
;defaultbaudrate		9600 %const
;defaultbaudrate		19200 %const
;defaultbaudrate		38400 %const
;defaultbaudrate		57600 %const
;defaultbaudrate		115200 %const
;defaultbaudrate		230400 %const
;defaultbaudrate		460800 %const
;defaultbaudrate		921600 %const
;defaultbaudrate		1250000 %const
defaultbaudrate		2500000 %const
;defaultbaudrate		5000000 %const
;defaultbaudrate		10000000 %const

;;timerrate		100000  %const	10uSec	;was
;;timerrate		200000  %const	5uSec
timerrate		500000  %const	2uSec ;rev40
;;;timeoutfudge		8     	%const	40 uSec for sslbp loop delay from 0..7 plus measurement jitter
timeoutfudge		20     	%const	40 uSec for sslbp loop delay from 0..7 plus measurement jitter
;was starttimeout		100	%const	1mSec default
;starttimeout		200	%const	1mSec default
starttimeout		200	%const	400uSec default

NUEightI20timeout		15	%const	150 uSec
NUSevenI64timeout		40	%const	400 uSec
ourlbptimeout		40	%const  bittimes 4 char times

setuptimerrate		5000  	%const	200 uSec  no slower
startstimeout		   6	%const	1.2 mSec 
startsruntimeout	 250	%const	50 mSec for flash

watchdogtime		500	%const	number of pwm rates
maxerrors		 20	%const	how many errors required to set status at startup

;defined rpc's
;standardrpc		BFh	%const	magic
standardrpc		BDh	%const	default
;altrpc			BFh	%const	
;EightI20RPC		BDh	%const  24 bytes available
;SevenI64RPC		BDh	%const  24 bytes available
;SevenI64RPC		BFh	%const  magic
unitRPC			BCh	%const	returns unitnumber
genericdiscRPC		BBh	%const	returns discovery

SevenI64watchdog	08h	%const  watchdog bit
		
uartoffset		0280h	%const	index register base

;interface masks for commandreg high byte
writemask		80h	%const
resetmask		40h	%const
requestmask		20h	%const
doitmask		10h	%const	data in doit is channel bitmask 

;decodes
stopstart		08h	%const	type of start
normalstart		09h	%const
specialstart		0Ah	%const
datadiscovery		0Bh	%const

LBPstart		0Fh	%const
doit			10h	%const

doorbellmask		01h	%const

LBPDataSizeMask		 3	%const

chanrecvstring		0	%ptr	16 bytes, first to be able to use offsets
chanstate		16	%byte	state
chanerror		$	%byte	bitfield of error bits
chanerrorlog		$	%byte	bitfield of sticky errorbits
chanstatus		$	%byte	status
chancrccount		$	%byte
chancookiecount		$	%byte	
chanoverruncount	$	%byte	
chantimeoutcount	$	%byte
chanextracharcount	$	%byte
chanbreakcount		$	%byte
chanremfaultcount	$	%byte	
chanerrorcount		$	%byte	required number of errors to cause status error

chanLBPdatasize		$	%byte
chanid			$	%byte	id byte for 8I20,7I64 
chandisablecrc		$	%byte
NUchanfree0		$	%byte
;NUchanchktoomanyerrs	$	%byte   true at startup, false after blather
NUavovenotused		$	%byte   true at startup, false after blather

chanstarttime		$	%uint	start of timeout
chantimeout		$ 	%byte	error when deltatime is greater
changeneric		$	%byte   nonzero if generic
chanremfault		$	%byte
chanwhatiam		$ 	%ulong
chanbaudrate		$ 	%ulong
chanRPCrecvsize		$	%byte	
chanRPCxmitsize		$	%byte	
chanmeasuredtime	$	%byte	
NUchanLBPcompat		$	%byte	read from remote

;error bits
crcerrorbit		01h	%const
cookieerrorbit		02h	%const
overrunerrorbit		04h	%const
timeouterrorbit		08h	%const
extracharerrorbit	10h	%const
breakcharerrorbit	20h	%const
remfaulterrorbit	40h	%const
toomanyerrorbit		80h	%const

;status bits
noblatherbit		80h	%const true if not ready 
noidbit			40h	%const
errorstatbit		20h	%const

remfaultbit		01h	%const

;channel states
reset			0	%enum
starttimer		$	%enum
waittimeout		$	%enum

requestcookie		$	%enum
getcookie		$	%enum

setlbptimeout		$	%enum
checksetlbptimeout	$	%enum

clrlbpstatus		$	%enum
checkclrlbpstatus	$	%enum

requestlbpstatus	$	%enum
getlbpstatus		$	%enum
checklbpstatus		$	%enum

requestunitnumber	$	%enum
getunitnumber		$	%enum

requestid0		$	%enum
getid0			$	%enum
requestid1		$	%enum
getid1			$	%enum
requestid2		$	%enum
getid2			$	%enum
requestid3		$	%enum
getid3			$	%enum

checkid0		$	%enum	8I20 path
checkid1		$	%enum	7I64 path else generic path

clear7I64faults		$	%enum	7I64 from checkid1
check7I64faults		$	%enum

setswmode		$	%enum	generic
checkswmode		$	%enum

requestdiscovery	$	%enum	generic
getdiscovery		$	%enum

cleargen		$	%enum	generic, set outputs to 0
checkcleargen		$	%enum

setgenclrfaults		$	%enum	generic, clear clr fault flag
chksetgenclrfaults	$	%enum

reqgenclrfaults		$	%enum	generic, see if clr fault is cleared
getgenclrfaults		$	%enum

reqgenfaults		$	%enum	generic, check faults
getgenfaults		$	%enum
chkgenfaults		$	%enum	to blather

setclrfaults		$	%enum	8I20 from checkid0
checksetclrfaults	$	%enum

requestclrfaults	$	%enum	8I20
getclrfaults		$	%enum

requestfaults		$	%enum	8I20
getfaults		$	%enum
checkfaults		$	%enum

clearsetpoint		$	%enum	8I20
checkclearsetpoint	$	%enum

setpidena		$	%enum	8I20
checksetpidena		$	%enum

requestpidon		$	%enum	8I20
getpidon		$	%enum
checkpidon		$	%enum

requestpidonfaults	$	%enum	8I20
getpidonfaults		$	%enum
checkpidonfaults	$	%enum

setwatchdog		$	%enum	8I20
checksetwatchdog	$	%enum

blather0		$	%enum	wait for doorbell
blather1		$	%enum

send8I20		$	%enum
recv8I20		$	%enum	

send7I64		$	%enum
recv7I64		$	%enum	

sendLBP			$	%enum
recvLBP			$	%enum

sendgeneric		$	%enum
recvgeneric		$	%enum	

;deadend		$	%enum	don't use doesn't clear command reg

;ram start
;id information
interfacetype		0	%byte
interfacewidth		$	%byte
majorrevision		$	%byte
minorrevision		$	%byte
;gpioinputbits		$	%byte
;gpiooutputbits		$	%byte
channelstart		$	%byte	;added rev 34
channelstride		$	%byte	
processortype		$	%byte
numberofchannels	$	%byte
whatisupport0		$	%ulong
whatisupport1		$	%ulong
whatisupport2		$	%ulong
whatisupport3		$	%ulong
whatisupport4		$	%ulong
whatisupport5		$	%ulong
whatisupport6		$	%ulong
whatisupport7		$	%ulong
	
;preset variables
zero			$	%byte	
one			$	%byte	
NUthree			$	%byte
true			$	%byte
NUcookie		$	%byte

;variables
charcount		$	%byte
charcrccount		$	%byte
temp			$	%byte
deltatime		$	%uint
dividend		$	%double	for div subroutine
divisor			$	%ulong	for div subroutine
muldivcount		$	%byte
NUshiftleft		$	%ulong
chanloop		$	%byte
loop			$	%byte
exploop			$	%byte
exptemp			$	%byte
starttype		$	%byte
initialized		$	%byte	flag
nchannelmask		$	%byte
LBPcommand		$	%byte
LBPaddress		$	%uint
sendrecvloop		$	%byte
commandtoprocess	$	%byte	set by setupcode and always valid

;bit field
whichchanbits		$	%byte	rotating one
notwhichchanbits	$	%byte	rotating zero

startbits		$	%byte	start request bitfield
stopbits		$	%byte	stop request bitfield
notreadybits		$	%byte	chan not ready
notstartbits		$	%byte	not started
requestbits		$	%byte	doit request when bit set
invalidbits		$	%byte	invalid when bit set
notdonebits		$	%byte	notdone when bit set
blatherbits		$	%byte	set by blather cleared by first doit
runningbits		$	%byte	set by first doit

saveXL			$	%byte	
saveXH			$	%byte	
looptimer		$	%byte
NUtimerrate		$	%long
timerdiv		$	%uint
starttimeout		$	%byte
runtimeout		$	%byte
looptime		$	%byte

test0			$	%byte
test1			$	%byte
test2			$	%byte
test3			$	%byte
testlong0		$	%long
last			$	%ptr

channel0		070h	%ptr	50 byte space per channel
channel1		0A2h	%ptr
channel2		0D4h	%ptr
channel3		106h	%ptr
channel4		138h	%ptr
channel5		16Ah	%ptr
channel6		19Ch	%ptr
channel7		1CEh	%ptr

;rpc	BDh,tl,th,al,ah,crc
;recv data 
;8I20
invalidstatus		80H	%const
statusl			0	%const
statush			1	%const
faultl			2	%const
faulth			3	%const
busvl			4	%const
busvh			5	%const
temperaturel		6	%const
temperatureh		7	%const

;rpc	BDh,0,1,2,3,4,5,6,7,crc
;from uart read buffer
getreaddata0		0	%byte	alway fault byte for generic
getreaddata1		1	%byte
getreaddata2		2	%byte
getreaddata3		3	%byte
getreaddata4		4	%byte
getreaddata5		5	%byte
getreaddata6		6	%byte
getreaddata7		7	%byte
getreaddata8		8	%byte
getreaddata9		9	%byte
getreaddata10		10	%byte
getreaddata11		11	%byte
getreaddata12		12	%byte
getreaddata13		13	%byte
getreaddata14		14	%byte
getreaddata15		15	%byte

;7I64
inbits			0	%const
outbits			0	%const
ain1ain0		4	%const

;hardware
commandregl	0200h	%byte	host interface command register ;5A00
commandregh	0201h	%byte	host interface command register
datareg		0202h	%byte	host interface data register	;5B00
hostdoorbell	0203h	%byte	LSB set on write to host interface command register
				;write to clear

settestbit	0220h	%byte	our external debug test bit set
clrtestbit	0221h	%byte	our external debug test bit clear

hardwaretimer	0222h	%uint	read timer, write phaseacc

hardwarecrc	0224h	%byte	write char read crc
resetcrc	0225h	%byte	write to resetcrc

clock		0230h	%ulong	clock frequency in Hertz
hardnchannel	0234h	%byte	number of channels

uartdata	00h	%byte	read=rx write=tx
uartbitratel	10h	%byte	lo byte both rx and tx
uartbitratem	20h	%byte	hi byte
uartbitrateh	30h	%byte	hi byte
rxfifocount	40h	%byte	write clears
rxmode		50h	%byte	
txfifocount	60h	%byte	write clears
txmode		70h	%byte	

controlparam0	0300h	%ptr		;5C00
error		0	%byte	read	normal
status		$	%byte	read	normal
state		$	%byte	read	normal
csrremfault	$	%byte	read	0 until successful doit

NOTUSEDenable		0	%byte	write	normal	nonzero to enable
NOTUSEDnwritebytes	$	%byte	write	normal	number of write bytes
NOTUSEDnreadbytes	$	%byte	write	normal  number of read bytes
NOTUSEDwhichrpc	$	%byte	write	normal	which rpc
LBPcommand	00h	%ulong	write setup	MS byte LS word is address
CSRSWMode	03h	%byte	write

;doorbell0	0700h	%ptr	LSB set if host write to controlparam0

hostparam0	0320h	%ptr	;offsets;5D00	
outbits		20h	%ulong	write	normal	7I64
theangle	20h	%uint	write	normal
torque		22h	%int	write	normal
LBPwritedatal	20h	%ulong	write	setup
getwritedata0	20h	%byte	write	normal
getwritedata1	21h	%byte	write	normal
getwritedata2	22h	%byte	write	normal
getwritedata3	23h	%byte	write	normal

remtemperature	20h	%uint	read	normal
inbits		20h	%ulong	read	normal	7I64
voltage		22h	%uint	read	normal
LBPreaddatal	20h	%ulong	read	setup
unitnum		20h	%ulong	read	before doit
putreaddata0	20h	%byte	read 	normal
putreaddata1	21h	%byte	read 	normal
putreaddata2	22h	%byte	read 	normal
putreaddata3	23h	%byte	read 	normal

hostparam1	0340h	%ptr		;5E00
;offsets
;unused		40h	%uint	write
;unused		42h	%uint	write
whoiam		40h	%ulong	read	before doit
getwritedata4	40h	%byte	write	normal
getwritedata5	41h	%byte	write	normal
getwritedata6	42h	%byte	write	normal
getwritedata7	43h	%byte	write	normal

ain1ain0	40h	%ulong	read	7i64
;remstatus and remfault are updated when faults are read
remstatus	40h	%uint	read	lbpstatus hi byte 8I20 status lo byte
remfault	42h	%uint	read	8I20 faults
LBPwritedatah	40h	%ulong	write	setup
LBPreaddatah	40h	%ulong	read	setup
putreaddata4	40h	%byte	read 	normal
putreaddata5	41h	%byte	read 	normal
putreaddata6	42h	%byte	read 	normal
putreaddata7	43h	%byte	read 	normal

hostparam2	0360h	%ptr		;5F00
;USR2	|RWSIZE???????|#PARAM	|RWSIZE	|
;offsets
;unused		60h	%uint	write
;unused		62h	%uint	write

;database	60h	%uint	read
;databasepitch	62h	%byte	read
;nparams		63h	%byte	read	before doit
;new names R33
PTOC		60h	%uint	read
GTOC		62h	%uint	read

putreaddata8	60h	%byte	read 	normal
putreaddata9	61h	%byte	read 	normal
putreaddata10	62h	%byte	read 	normal
putreaddata11	63h	%byte	read 	normal

getwritedata8	60h	%byte	write	normal
getwritedata9	61h	%byte	write	normal
getwritedata10	62h	%byte	write	normal
getwritedata11	63h	%byte	write	normal
