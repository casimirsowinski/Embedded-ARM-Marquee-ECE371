@ Casimir Sowinski
@ ECE-371
@ Design Project 2
@ Part 2 (with extra credit)
@ 12/12/14
@ This program keeps the current status of the push button in R12 (1 to strobe lights
@ and 0 to hold them off). There are 4 modes: scroll left slow, scroll left right, scroll
@ right slow, and scroll right fast

.text
.global _start
.global INT_DIRECTOR
_start:
		LDR 	R13, =STACK1		@ Point to base of STACK for SVC mode
		ADD 	R13, R13,#0X1000	@ Point to top of STACK
		CPS 	#0x12			@ Switch to IRQ mode
		LDR 	R13, =STACK2		@ Point to IRQ stack
		CPS 	#0x13			@ Back to SVC mode
		LDR 	R0, =0x4804C000	@ Base address for GPIO1 registers
		ADD 	R4, R0,#0x190		@ Address of GPIO1_CLEARDATAOUT register
		MOV 	R7, #0x01E00000	@ Load value to turn off all LEDs
		STR 	R7, [R4]		@ Write to GPIO1_CLEARDATAOUT register
		MOV	R12, #0		@ For speed toggle, 0=fast, 1=slow
		MOV	R9, #0			@ For direction toggle
@ Program GPIO1_21-24 as outputs
		ADD 	R1, R0,#0x0134 	@ Make GPIO1_OE register address
		LDR 	R6, [R1]		@ READ current GPIO1 Output Enable register
		LDR 	R7, =0xFE1FFFFF	@ Word to enable GPIO1_21-24 as outputs (0 enables)
		AND 	R6, R7, R6		@ Clear bits 21-24 (MODIFY)
		STR 	R6, [R1]		@ WRITE to GPIO1 Output Enable register
@ Detect falling edge on GPIO1_31 and enable to assert POINTRPEND1
		ADD 	R1, R0, #0x14C	@ R1 = address of GPIO1_FALLINGDETECT register
		MOV 	R2, #0x80000000	@ LOAD VALUE FOR BIT 31
		LDR 	R3, [R1]		@ READ GPIO1_FALLINGDETECT register
		ORR 	R3, R3, R2		@ Modify (set bit 31)
		STR 	R3, [R1]		@ Write back
		ADD 	R1, R0, #0x34		@ Create addresss of GPIO1_IRQSTATUS_SET_0 register
		STR 	R2, [R1]		@ enable GPIO1_31 request on POINTRPEND1
@ Initialize INTC
		LDR 	R1,= 0x482000E8	@ Address of INTC_MIR_CLEAR3 register
		MOV 	R2, #0x04		@ Value to unmask INTC INT 98, GPIOINT1A
		STR 	R2, [R1]		@ Write to INTC_MIR_CLEAR3 register
@ Make sure processor IRQ enabled in CPSR
		MRS 	R3, CPSR		@ Copy CPSR to R3
		BIC 	R3, #0x80 		@ Clear bit 7
		MSR 	CPSR_c, R3		@ Write back to CPSR
@ Wait for interrupt
HOLD_LOOP:   
		CMP	R12, #1		@ Look at R12 (toggle) to strobe or hold		
		BEQ	DIRECTION
		BNE	HOLD_LOOP		@ To hold the LEDs off
DIRECTION:
		CMP	R9, #1			@ Compare direction variable
		BEQ	STROBE_LOOP_A		@ Strobe down
		BNE	STROBE_LOOP_B		@ Strobe up	
STROBE_LOOP_A:		
		MOV	R3, #0x00040000	@ Load wait time
		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER0_A:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER0_A		@ Repeat while still time						
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg		
		MOV	R5, #0x00200000	@ Load word for LED0
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg		
		CMP	R12, #0		@ Check for interrupt update
		BEQ	HOLD_LOOP		@ Branch to HOLD_LOOP if appropriate						
		MOV	R3, #0x00040000	@ Load wait time
		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER1_A:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER1_A		@ Repeat while still time		
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg		
		MOV	R5, #0x00400000	@ Load word for LED1
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg		
		CMP	R12, #0		@ Check for interrupt update
		BEQ	HOLD_LOOP		@ Branch to HOLD_LOOP if appropriate					
		MOV	R3, #0x00040000	@ Load wait time
		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER2_A:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER2_A		@ Repeat while still time		
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg			
		MOV	R5, #0x00800000	@ Load word for LED2
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg		 	
 		CMP	R12, #0		@ Check for interrupt update
		BEQ	HOLD_LOOP		@ Branch to HOLD_LOOP if appropriate 		
 		MOV	R3, #0x00040000	@ Load wait time
 		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER3_A:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER3_A		@ Repeat while still time		
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg		
		MOV	R5, #0x01000000	@ Load word for LED3
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg				
		CMP	R12, #0		@ Check for interrupt update
		B	HOLD_LOOP		@ Branch to HOLD_LOOP (Unconditional)		
STROBE_LOOP_B:		
		MOV	R3, #0x00040000	@ Load wait time
		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER3_B:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER3_B		@ Repeat while still time		
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg		
		MOV	R5, #0x01000000	@ Load word for LED3
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg				
		CMP	R12, #0		@ Check for interrupt update
		BEQ	HOLD_LOOP		@ Branch to HOLD_LOOP if appropriate					
		MOV	R3, #0x00040000	@ Load wait time
		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER2_B:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER2_B		@ Repeat while still time		
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg				
		MOV	R5, #0x00800000	@ Load word for LED2
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg		 	
 		CMP	R12, #0		@ Check for interrupt update
		BEQ	HOLD_LOOP		@ Branch to HOLD_LOOP if appropriate 		
 		MOV	R3, #0x00040000	@ Load wait time
 		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER1_B:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER1_B		@ Repeat while still time		
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg		
		MOV	R5, #0x00400000	@ Load word for LED1
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg		
		CMP	R12, #0		@ Check for interrupt update
		BEQ	HOLD_LOOP		@ Branch to HOLD_LOOP if appropriate					
		MOV	R3, #0x00040000	@ Load wait time
		MUL	R4, R11, R3		@ Prepare speed factor
		ADD	R3, R3, R4		@ Add speed factor
USER0_B:	
		SUBS	R3, #1			@ Decrement wait time
		BNE	USER0_B		@ Repeat while still time						
		MOV	R5, #0x01E00000	@ Load value to select all USER LEDs
		LDR 	R6, =0x4804C190	@ Load address of GPIO_CLEARDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO1_CLEARDATAOUT reg		
		MOV	R5, #0x00200000	@ Load word for LED0
		LDR	R6, =0x4804C194	@ Load address for GPIO1_SETDATAOUT reg
		STR	R5, [R6]		@ Write to GPIO_SETDATAOUT reg		
		CMP	R12, #0		@ Check for interrupt update
		B	HOLD_LOOP		@ Branch to HOLD_LOOP (Unconditional)		
INT_DIRECTOR:
		STMFD 	SP!, {R0-R3, LR}	@ Push registers on stack
		LDR 	R0, =0X482000F8	@ Address of INTC-PENDING_IRQ3 register
		LDR 	R1, [R0]		@ Read INTC-PENDING_IRQ3 register
		TST 	R1, #0X00000004	@ TEST BIT 2
		BEQ 	PASS_ON		@ Not from GPIOINT1A, go to back to wait loop, Else 
		LDR 	R0, =0X4804C02C	@ Load GPIO1_IRQSTATUS_0 register address
		LDR 	R1, [R0]		@ Read STATUS register
		TST 	R1, #0x80000000	@ Check if bit 14 =1
		BNE 	BUTTON_SVCB		@ If bit 14 =1, then button pushed
		BEQ 	PASS_ON		@ If bit 14 =0, then go to back to wait loop
PASS_ON:
    		LDMFD 	SP!, {R0-R3,LR}	@ Restore registers
    		SUBS 	PC, LR, #4		@ Pass execution on to wait LOOP for now
BUTTON_SVCB:
		MOV 	R1, #0x80000000	@ Value to turn off GPIO1_14 Interrupt request
		 				@ This will turn off INTC interrupt request also
		STR 	R1, [R0]		@ Write to GPIO1_IRQSTATUS_0 register
@ Turn off NEWIRQA bit in INTC_CONTROL, so processor can respond to new IRQ
		LDR 	R0, =0x48200048	@ Address of INTC_CONTROLregister
		MOV 	R1, #01		@ Value to clear bit 0
		STR 	R1, [R0]		@ Write to INTC_CONTROLregister	
@ Handle toggle
		LDR	R5, =TOGGLE		@ Load address to TOGGLE
		LDR	R6, [R5]		@ Get value of TOGGLE
		SUBS	R6, #0x01		@ Subtract 1 for test
		BMI	TURN_OFF
		B	TURN_ON			
TURN_ON:		
		MOV	R12, #1		@ Toggle R12
		LDR	R5, =TOGGLE		@ Load address of TOGGLE
		MOV	R6, #0x00		@ New value for TOGGLE
		STR	R6, [R5]		@ Write TOGGLE		
		CMP	R11, #1		@ Look at R12 (toggle) to strobe or hold
		BEQ	TOGGLEA		@ To stobe the LEDs
		BNE	TOGGLEB		@ To hold the LEDs off
@ Toggle code, to switch speeds and directions of LED scrolling
TOGGLEA:	
		MOV	R11, #0		@ To switch speeds, 0 is slow, 1 is fast
		CMP	R9, #1			@ Compare direction toggle
		BEQ	TOGGLEC		@ Direction down
		BNE	TOGGLED		@ Direction up
		B	RETURN				
TOGGLEB:
		MOV	R11, #1		@ To switch speeds, 0 is slow, 1 is fast
		B	RETURN
TOGGLEC:							
		MOV	R9, #0			@ To switch directions
		B	RETURN				
TOGGLED:							
		MOV	R9, #1			@ To switch directions
		B	RETURN				
TURN_OFF:
		MOV	R12, #0		@ Toggle R12
		MOV	R6, #0x01		@ New Value for TOGGLE
		STR	R6, [R5]		@ Write TOGGLE
		B	RETURN		
RETURN:
		LDMFD 	SP!, {R0-R3, LR}	@ Restore registers
		SUBS	PC, LR, #4		@ Return from IRQ interrupt procedure			
.align 	2
SYS_IRQ:	.WORD 0			@ Location to store systems IRQ address
.data
STACK1:	.rept 1024
		.word 0x0000
		.endr
STACK2:	.rept 1024
		.word 0x0000
		.endr
TOGGLE:	.byte 0x01			@ First value for remembering setting
.END
