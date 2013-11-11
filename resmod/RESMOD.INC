
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
rambegin	0          
ramend		255

;constants
interfacetype		12h		%const
interfacewidth		32		%const
majorrevision		1		%const	updated when parameters change, hi byte
minorrevision		0		%const	lo byte
whatisupport0l		4937h		%const	7I
whatisupport0h		3934h		%const	49
id0			79h		%const	7I49
gpioinputbits		0		%const
gpiooutputbits		0		%const
processortype		B3h		%const
numberofchannels	6		%const

;id information
interfacetypeloc	0	%byte
interfacewidthloc	1	%byte
majorrevisionloc	2	%byte
minorrevisionloc	3	%byte
gpioinputbitsloc	4	%byte
gpiooutputbitsloc	5	%byte
processortypeloc	6	%byte
numberofchannelsloc	7	%byte
whatisupport0loc	8	%ulong
whatisupport1loc	9	%ulong
whatisupport2loc	10	%ulong
whatisupport3loc	11	%ulong

null		16	%ptr	
zeroloc		17	%ptr	
oneloc		18	%ptr	
minusoneloc	19	%ptr
loopiloc	20	%ptr	
loopjloc	21	%ptr
indexiloc	22	%ptr	
indexjloc	23	%ptr
temp1loc	24	%ptr
temp2loc	25	%ptr
bit2loc		26	%ptr
bit3loc		27	%ptr
bit5loc		28	%ptr	
bit8loc		29	%ptr
bit9loc		30	%ptr		
bit10loc	31	%ptr		
bit11loc	32	%ptr
bit12loc	33	%ptr
bit13loc	34	%ptr
bit14loc	35	%ptr	
bit15loc	36	%ptr	
bit31loc	37	%ptr
daqplusstart	38	%ptr
daqminusstart	39	%ptr
daqcountloc	40	%ptr
bitmask12	41	%ptr
bitmask10	42	%ptr
wgmagnitudeloc	43	%ptr
syncloc		44	%ptr
sintablelenloc	45	%ptr
hostokcountloc	46	%ptr
daqhalfloc	47	%ptr
lsineloc	48	%ptr
lcosloc		49	%ptr
langleloc	50	%ptr
loffsetloc	51	%ptr
comcountloc	52	%ptr	
commandloc	53	%ptr
dtrackigain	54	%ptr
dtrackpgain	55	%ptr
topwordmask	56	%ptr
daqmoderegsh	57	%ptr
wavetablelenloc 58	%ptr
summplus	64	%ptr 12 locs
summminus	80	%ptr 12 locs
ppsumm		96	%ptr 12 locs	
setupdaqloc	112	%ptr doit flag
phasecomp	120	%ptr 6 locs
velocityloc	128	%ptr 6 locs	
rangleloc	136	%ptr 6 locs	
posinteg	144	%ptr 6 locs		
samplitude	152	%ptr 6 locs
trackigainloc	160	%ptr 6 locs
trackpgainloc	168	%ptr 6 locs

;hardware

commandreg	1024	%ptr	host interface command register
datareg		1025	%ptr	host interface data register

daqmodereg	1026	%ptr	daq system SPI mode register
daqstatusreg	1026	%ptr	read only count + buffer half flag (bit 8)

daqclear	1027	%ptr	daq system clear
daqdatalowhalf	3072	%ptr	daq data region 0 3072..3583
daqdatahighhalf	3584	%ptr	daq data region 0 3584..4095
daqpitch	12	%ptr	distance between samples on same channel
wgratereg	1028	%ptr	wavegen 16 bit phase accum 
wglengthreg	1029	%ptr	wavegen 10 bit table length reg
wgpdmratereg	1030	%ptr	wavegen 8 bit pdm rate 
wgtableptrreg	1031	%ptr	wavegen table pointer reg 
wgtabledatareg	1032	%ptr	wavegen table data reg

pwren		1033	%ptr	resolver power enable (1 in lsb = on)

daqcycount	1034	%ptr	cycle counter

settestbit	1035	%ptr	our external debug test bit set
clrtestbit	1036	%ptr	our external debug test bit clear
hsintrate	1037	%ptr	high speed integrate rate
hstatus		1038	%ptr	host channel status register
vrambegin	1040	%ptr	start of write only interface registers
virambegin	1048	%ptr	write to high speed interface integrator	
prambegin	1056	%ptr    readback high speed interface integrator

sintable	2048	%ptr	start of 1024x16 sine table 

sintablelength	1024	%uint   
wavetablelength	256	%uint