
debugsetup
	lwi	01100h
	sta 	ExtAdd
	lwi	0FFFFh		; 0xFFFFFF = all out
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	01104h
	sta 	ExtAdd
	lwi	0FFFFh		; 0xFFFFFF = all out
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	01108h
	sta 	ExtAdd
	lwi	0FFFFh		; 0xFFFFFF = all out
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	0110Ch
	sta 	ExtAdd
	lwi	0FFFFh		; 0xFFFFFF = all out
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	01000h
	sta 	ExtAdd
	lwi	0h		; 
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	01004h
	sta 	ExtAdd
	lwi	0h		; 
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	01008h
	sta 	ExtAdd
	lwi	0h		; 
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	lwi	0100Ch
	sta 	ExtAdd
	lwi	0h		; 
	sta	ExtData+0
	sta	ExtData+1
	sta	StartExtWrite	
	nop
	nop
	nop
	ret
