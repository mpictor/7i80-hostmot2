;Little Binary Protocol
;Copyright (C) 2008 MESA Electronics.  All rights reserved.

;TOKEN			VALUE	TYPE	FUNCTION
;Direct
LBPADDDATA		00h	%byte	Address or Data

LBPCOMMAND		40h	%byte	Command function

LBPWRITE		20h	%byte	Write command

LBPD1			00h	%byte	One byte data
LBPD2			01h	%byte	Two byte data
LBPD4			02h	%byte	Four byte data
LBPD8			03h	%byte	Eight byte data

LBPA0			00h	%byte	No address included, Last address used
LBPA2			04h	%byte	Two byte address included
LBPINC			08h	%byte	Increment address

LBPRPCINCDATA		10h	%byte	Write includes data within RPC

;FIFO Wait token for FIFO with timeout
LBPFIFO		50h	%byte	FIFO command

LBPQRH		00h	%byte	Wait for Queued Readback FIFO half full
LBPQRE		01h	%byte	Wait for Queued Readback FIFO not empty
LBPIRH		02h	%byte	Wait for Immediate Readback FIFO half full
LBPIRE		03h	%byte	Wait for Immediate Readback FIFO not empty
LBPQFH		04h	%byte	Wait for Queued Command/data FIFO not half full
LBPQFF		05h	%byte	Wait for Queued Command/data FIFO not full
LBPIFH		06h	%byte	Wait for Immediate Command/data FIFO not half full
LBPIFF		07h	%byte	Wait for Immediate Command/data FIFO not full

;Rpc
LBPRPC			80h	%byte	Rpc commands 0..63
LBPRPCEND		00h	%byte	End of Rpc marker

LBPLOCAL	C0h	%byte	LBP Local Functions 0..31

;LBP Local R/W locations Read at Cx Write at Ex
LBPLISTEN	C0h	%byte	Unit to listen
LBPSTATUS	C1h	%byte	Error status 0 for no errors
LBPENACRC	C2h	%flag	Non-zero to enable CRCs
LBPCRCERRS	C3h	%byte	Number of CRC errors
;LBPENASEQ	C4h	%flag	Non-zero to enable Sequence
;LBPSEQ		C5h	%byte	Sequence number
LBPREMSWMODE	C6h	%byte	Software mode of remote device

LBPREMCLRFAULT	C7h	%flag	Write true to clear faults, false when complete

LBPRPCMEM	CAh	%flag	Non-zero to allow access to RPC memory 
LBPCHARTIMEOUT  CBh	%byte	Command frame timeout in (n + 1 Milliseconds USB)
				(bit times for serial)
LBPNONVOL	CCh	%flag	Set to access Non Volatile memory

;LBP Special locations
;Read only
LBPCARDNAME0	D0h	%byte	Cardname character0, Read only
LBPCARDNAME1	D1h	%byte	Cardname character1, Read only
LBPCARDNAME2	D2h	%byte	Cardname character2, Read only
LBPCARDNAME3	D3h	%byte	Cardname character3, Read only
LBPCAPABILITY	D4h	%byte	Capability bits
LBPREMREVISION	D5h	%byte	Software revision of remote device
LBPREMHWMODE	D6h	%byte	Hardware Mode of remote device
LBPREMFAULT	D7h	%byte	Fault status of remote device

LBPADDRESSL	D8h	%byte	Current address Low byte, Read only
LBPADDRESSH	D9h	%byte	Current address High byte, Read only
LBPVERSION	DAh	%byte	Software Version, Read only
LBPUNITID	DBh	%byte	UnitId Read only 	
LBPRPCPITCH	DCh	%byte	RPC pitch, Read only
LBPRPCSIZEL	DDh	%byte	RPC Memory size Low byte, Read only
LBPRPCSIZEH	DEh	%byte	RPC Memory size High byte, Read only
LBPREADCOOKIE	DFh	%byte	Returns 5Ah

;Write only
;LBPSETLOCK0	F0h	%byte	Reset by protected function
;LBPSETLOCK1	F1h	%byte	Reset by protected function
;LBPSETLOCK2	F2h	%byte	Reset by protected function
;LBPSETLOCK3	F3h	%byte	Reset by protected function

LBPSETLEDS	F7h	%byte	Set LEDS
LBPSETADDRESSL	F8h	%byte	Current address Low byte, Write only
LBPSETADDRESSH	F9h	%byte	Current address High byte, Write only
LBPADDADDRESS	FAh	%byte	Add byte to Current address, Write only

LBPSETUNITID	FDh	%byte	Non-Volatile Listen Unit ID, Write only 
LBPPROCRESET	FEh	%byte	Resets processor when 5A hex is written
LBPWRITERESET	FFh	%byte	Resets parser

LBPFUNCTIONMASK	C0h	%byte
LBPRWMASK	F0h	%byte
LBPRPCNUMMASK   3Fh	%byte
LBPLOCALNUMMASK 1Fh	%byte
LBPLOCALSPECIAL 10h	%byte
LBPFIFOSELMASK	07h	%byte

LBPRESETCODE	5Ah	%byte	Must write this to reset
LBPCOOKIECODE	5Ah	%byte	Returned by LBPREADCOOKIE

LBPTRUE		FFh	%flag	Byte true
LBPFALSE	00h	%flag	Byte false
;NonVol types
LBPNONVOLEEPROM	01h	%byte	
LBPNONVOLFLASH	02h	%byte	
LBPFLASHERASE	FEh	%byte	
LBPFLASHWRITE	FDh	%byte	

LBPFLASHOFFSET		8000h	%ptr
LBPFLASHERASESIZE    	8004h	%ptr
LBPFLASHWRITESIZE    	8005h	%ptr
LBPFLASHCOMMIT       	8007h	%ptr

;Capability codes
LBPCRCCAPABLE		01h
LBPFIFOCAPABLE		02h
LBPEEPROMCAPABLE	04h
LBPFLASHCAPABLE		08h
LBPINDIRECTCAPABLE	10h

;LBP Status bits
LBPCRCERR		01h	
;LBPTXCSUMERR		02h	
;LBPSEQERR		04h
LBPWDOGERR		08h
LBPBUFFERERR		10h
LBPINVALIDADDERR	20h		Access to protected memory or I/O
LBPTIMEOUTERR		40h		Timeout waiting for complete Command
LBPFIFOTIMEOUTERR	80h		Timeout waiting for FIFO

