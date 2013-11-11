;Copyright (C) 2008 MESA Electronics.  All rights reserved.
;8I20INC.INC
;sample:	the time between iterations of the pid loop, see prescale and postscale

;TYPES (contents of ram address)
;	<blank>	number of bits is hardware dependent	
;	byte	8 bit unsigned value
;	bint	8 bit signed value
;	ptr	10 bit address pointer
;	flag	16 bit value 0 is false, nonzero is true
;	mask	16 bit mask bit true enables
;	uint	16 bit unsigned value 0..65535
;	int	16 bit signed value -32768..32767
;	ulong	32 bit unsigned value 0..4294967295
;	long	32 bit signed value -2147483648..2147483647
;	double	64 bit signed value -1.8E19..1.8E19
;	ebyte	8 bit unsigned value in eeprom
;	lit	literial value

;PARAMETER	VALUE	TYPE	FUNCTION
null		0	%ptr	uninitialized pointers point to dummy
dummy		#	%uint	default 16bit pointers point here 
dummyhi		$	%uint	default 32bit pointers point here 
pidena		$	%flag	set true to enable pid 
drivemode	$	%flag	false for voltage control, true for current control
pwm		$	%int	pwm value

phasek		$	%long	phase konstant
phasea		$	%long	phase accumulator, phasek is added to phasea each sample

;filter param
kqp		$	%uint	kpd*error added to pwm
kqi		$	%ulong	ki*error added to integralq each sample, high word added to pwm
;kqih		$	%uint	high word of ki not used
kqil		$ 	%uint	high word limit of ki, 32767 max

kdp		$	%uint	kpd*error added to pwm
kdi		$	%ulong	ki*error added to integralq each sample, high word added to pwm
;kdih		$	%uint	high word of ki not used
kdil		$ 	%uint	high word limit of ki, 32767 max

iu		#	%int	winding current
ib		$	%int	winding current

iv		#	%int	winding current
ic		$	%int	winding current

iw		#	%int	winding current
ia		$	%int	same as iw

busv		$	%uint	busvoltage
rawtemperature	$	%uint	
temperature	$	%uint	

gain		$	%uint	
angle		$	%uint		our reference angle

pwmres		$	%uint
pwmfactor	$	%uint
pwmlimit	$	%uint
halfpwm		$	%uint

upwm		$	%int	
vpwm		$	%int	
wpwm		$	%int	

deadzone	$	%uint	

ialpha		$	%int	1/2 iw
ibeta		$	%int
id		$	%int
iq		$	%int

vu		$	%int
vv		$	%int
vw		$	%int

ilimitmul	$	%uint	for current limit

fault		$	%flag	see con for values
clearfault	$	%flag	set true to clear faults, wait till cleared before reading fault
oldclearfault	$	%flag	
faultmask	$	%flag
startupstatus	$	%flag	not used see status

watchdogtime	$	%uint
watchdogtimer	$	%uint

qsetpoint	$	%int
dsetpoint	$	%int

busundervmin	$	%uint 
busundervmax	$	%uint
busoverv	$	%uint	
brakeonv	$	%uint	
brakeoffv	$	%uint

status		$	%flag	see bits for values

;************************* SYSTEM CONSTANTS **********************************
;software constants
cputype		$	%uint	CPU type
controltype	$	%uint	number of motor phases
swrevision	$	%uint	majorrev hibyte minorrev lobyte

sysclk		$	%long	CPU clock frequency

bigcookie	$	%ulong
biggercookie	$	%double
hwrevision	$	%uint	hwtype in hi byte revision in low byte
faulttimer	$	%uint	ignore faults until it times out
;************************* INTERNAL VARIABLES **********************************
trapaddress	$	%uint
trapnumber	$	%uint
trapcount	$	%uint
trapstatus	$	%uint
trapacc		$	%uint

;hardware constants
zero		$	%int	0
false		$	%flag	false
one		$	%int	1
true		$	%flag	true
minusone	$	%int	-1

delayreg	$	%uint	

invtable	$	%uint	start of invtable 

valpha		$	%int
vbeta		$	%int

vd		$	%int
vq		$	%int

sinetable	$	%uint	start of sinetable 
refsine		$	%int
refcosine	$	%int
iuoffset	$	%uint	
iwoffset	$	%uint	

bnderr		$	%int	bounded (@follow-@posenc)
mindspicpwm	$	%uint
maxdspicpwm	$	%uint

qset		$	%int	internal
dset		$	%int

qintegral	$  	%long	integral error accumulator
qintegralovf	$  	%int	overflow for integral

dintegral	$  	%long	integral error accumulator
dintegralovf	$  	%int	overflow for integral

diqdt		$	%int
diddt		$	%int

bootstraptimer	$	%uint	for bootstrap startup
oldpidena	$	%flag
oldwatchdogtime	$	%uint
oldiq		$	%int	for D
oldid		$	%int	for D

parktemp	$	%uint
operand		$	%long

hibit		$	%uint	half pwm scale

refangle	$	%uint
tempilimit	$	%uint	temp with full current derating
tempislope	$	%uint	65536/degrees of range below above
maxmodulei	$	%uint	10's of milliamps
maxcurrent	$	%uint	10's of milliamps positive
deratei		$	%uint	less than 65535 for derate
iloop		$	%uint	abs loop current

capture		$	%ptr	which variable
captureflag	$	%flag	start capture cleared when done
oldcapture	$	%flag	
capturecounter	$	%uint	which capture
pwmtemp		$	%uint	for bounding
propband	$	%uint

bootstrapvalue	$	%uint	for bootstrap startup
boottimermul	$	%uint	for bootstrap startup
pidon		$	%flag	true when pid is working
integbound	$	%uint	bound integrator input to this
tlimitsetpointi	$	%uint


test0	$	%uint
test1	$	%uint
test2	$	%uint
test3	$	%uint
test4	$	%uint
test5	$	%uint
test6	$	%uint
test7	$	%uint
test8	$	%uint
test9	$	%uint
test10	$	%uint

test11	$	%int
test12	$	%int
test13	$	%int
test14	$	%int
test15	$	%int
test16	$	%int
test17	$	%int

unitnumber	$	%ulong	for identification

blinktimer	$	%uint
blink		$	%uint

lastinclude	$	%uint	marker

;************************* NON VOLATILE VARIABLES **********************************
nvmaxmodulei	0	%eword	AD units
nvmaxcurrent	$	%eword	10's of milliamps positive
nvbaudrate	$	%eword
nvrembaudrate	$	%eword
nvcrcenable	$	%eword
nvkqp		$	%eword
nvkqilo		$	%eword
nvkqihi		$	%eword
nvkqil		$ 	%eword

nvkdp		$	%eword
nvkdilo		$	%eword
nvkdihi		$	%eword
nvkdil		$ 	%eword
nvqsetpoint	$	%eword
nvdsetpoint	$	%eword
nvdeadzone	$	%eword
nvfaultmask	$	%eword	a 1 causes an external fault
nvbusundervmin	$	%eword	10's of millivolts below this sets fault
nvbusundervmax	$	%eword	10's of millivolts above this clears fault
nvbusoverv	$	%eword	
nvbrakeonv	$	%eword	
nvbrakeoffv	$	%eword
nvpwmrate	$	%eword
nvtempilimit	$	%eword	temp with full current derating
nvtempislope	$	%eword	65536/degrees of range below above
nvintegbound	$	%eword	bound integrator input to this
nvfree		$	%eword

nvcookie	126	%eword
