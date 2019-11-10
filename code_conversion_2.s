.EQU SWI_EXIT, 0x11

@@ Input and Output
@@ Data segment begins
.DATA
@ STRING - ascii value 
STRING: .asciz "11010010"
@STRING: .asciz "11010710"
@ NUMBER - equivalent hex value for BIT stream in STRING
NUMBER: .byte 0x00
@ ERROR - if there is an error in STRING then set ERROR to 0xFF else 0x00
ERROR: .byte 0x00

@@ Text segment begins
.TEXT
.global MAIN

MAIN:
    LDR R2, =STRING
    @@ Branch and link to BINARY_2_HEX subroutine
    BL BINARY_2_HEX
    LDR R2, =NUMBER
    LDR R3, =ERROR
    STRB R0, [R2]          
    STRB R1, [R3]
    swi SWI_EXIT

@@ Convert the BIT stream to equivalent hex. If BIT stream is not valid set ERROR to 0xFF
BINARY_2_HEX:
    @@ Push the NUMBER and link register to stack
    STMFD SP!, {R2, LR}
    @@ Register R0 is used to store the hex value for the bit stream
    MOV R0, #0x00
    @@ Register R1 is used to store if there is an error
    MOV R1, #0x00
    @@ Loop till the end of the stream which is identified by 0x00
BINARY_2_HEX_LOOP:
    @@ Load the byte content of register R2 to R3 and increment R2 by 1
    LDRB R3, [R2], #1
    @@ Compare the end of bit stream is reached or not
    CMP R3, #0x0
    @@ If the end of bit stream is reached branch to BINARY_2_HEX_EXIT
    BEQ BINARY_2_HEX_EXIT
    @@ Make logical shift left of register R0 by 1 to accomadate equivalent of bit stream
    MOV R0, R0, LSL #1
    @@ Check if current byte is ascii equivalent 0
    CMP R3, #48
    @@ If so branch to the begining of loop
    BEQ BINARY_2_HEX_LOOP
    @@ Check if current byte is ascii equivalent 1
    CMP R3, #49
    @@ If the byte in register R3 is not 1 or 0 then it is error in input bit stream then move to SET_ERROR label
    BNE SET_ERROR
    @@ Else make logical OR of register R0 with 1 and store the result in back to R0
    ORR R0, R0, #1
    @@ Branch to BINARY_2_HEX_LOOP for next byte
    B BINARY_2_HEX_LOOP
SET_ERROR:
    @@ If error is triggered then store the register R0 to 0x00 (NUMBER)
    MOV R0, #0x00
    @@ If error is triggered then store the register R1 to 0xFF (ERROR)
    MOV R1, #0xFF
BINARY_2_HEX_EXIT:
    @@ Store the content of register R0 and R1 to stack
    STMFD SP!, {R0-R1}
    @@ Pop the content of stack to register R0-R2 and update PC for next instruction from where subroutine got invoked
    LDMFD SP!, {R0-R2, PC}