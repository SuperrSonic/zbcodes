// SA3 Ring Saver Japanese ROM Version
// Hooks to the 'hide HUD' flag set once the goal is reached
// in order to add up the total ring count to the FLASH savedata.

.gba

.open "Sonic Advance 3 JP.gba","SA3_RingSaverJP.gba",0x08000000 

//SaveFlash EQU 0x08001FCD


.org 0x08000510
dh 0xE00A     ;branches to the bl that writes the savefile
dh 0x0000     ;branching here makes it so that finishing a level always writes to flash
dw 0x00000000 ;since the rest of the functions won't be used I am nop-ing them
dw 0x00000000
dw 0x00000000
dw 0x00000000
dw 0x00000000

// Write 3 to use 0x03000E1C for FLASH space, this prevents the game from blanking this 32bit space
// It is where the ring count will be stored by the game
.org 0x08001534
dh 0x2903 ;original 0x2905


.org 0x08E76050

// SA3 has a lot of empty space at the end of the ROM
.area 0x189FB0

.align 4

.func RingSaver
	ldr r1,=0x0300094C  ;ring count
	ldrh r0,[r1]        ;read ring count
	
	;lsl r0, r0, #16    ;higher 16 bits
	;lsr r0, r0, #16    ;sets the position right
	
	;ldr r1,=0x0E007FF0 ;save addr, FLASH cannot be written directly
	
	ldr r1,=0x03000E1C  ;IWRAM save addr, works
	ldr r2,[r1]
	
	add r0,r0,r2        ;there's wrap around to 0
	
	ldr r2,=0x0F423F    ;by setting a limit of 999,999 rings wrap around won't occur
	cmp r0,r2
	bgt exceeded
	
	str r0,[r1]         ;write count to IWRAM, which the game will copy to flash
	
	b finish

exceeded:
	str r2,[r1]         ;you've gone over the ring limit
	b finish

finish:
	;this is a rewrite of the code that sets the hide HUD flag 
	ldr r0,=0x03000924 ;holds bool for hide HUD
	ldr r1,[r0]        ;read it
	ldr r2,=0x0100     ;load to r2 the OR params
    orr r1,r2
    str r1,[r0]        ;write it back to IWRAM
	
	add sp,#0x4        ;og instruction
	ldr r1,=0x080532F5 ;exit back
	mov r15,r1         ;r15 is the pc, it's an alternate long branch

.pool
.endfunc
.endarea


// Hooking into the hide HUD enabler
.org 0x080532EC
	ldr r0,=0x08E76050
	mov r15,r0

.pool

.close