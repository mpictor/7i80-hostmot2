delayms
	sta 	delay0
delay0loop
	lwi	14286
	sta	delay1
	nop
	nop
delay1loop
	lwi	MinusOne
	addto	delay1
	nop
	nop
	jmpnz	delay1loop
	lwi	MinusOne	
	addto	delay0
	jmpnz	delay0loop
	nop
	nop
	ret
