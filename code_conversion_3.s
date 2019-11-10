.EQU SWI_EXIT, 0x11

@@ Input and Output
@@ Data segment begins
.DATA
@@ Input BCDNUM - binary coded decimal
BCDNUM: .word 0x92529679
@@ Output NUMBER - BCD equivalent hex number
NUMBER: .word 0x00

@@ Code segment begins
.TEXT
.global MAIN

MAIN:
    LDR R2, =BCDNUM
    @@ Store the BCD into register R1
    LDR R1, [R2]
    @@ Call for subroutine BCD_2_HEX and the result will be in register R0 via return from subroutine
    BL BCD_2_HEX
    LDR R2, =NUMBER
    @@ Store the result to address location pointed by NUMBER
    STR R0, [R2]
    swi SWI_EXIT

@@ Subroutine BCD_2_HEX
BCD_2_HEX:
    @@ Store contents of register R1-R4 and link register to stack and increment stack
    STMFD SP!, {R1-R4, LR}    
    LDR R1, [SP]
    @@ Inital condition
    @@ For multplication constant setting R4 to 10
    @@ For storing result of hex setting R0 to 0
    @@ For multplication in each iteration setting R2 to 1
    @@ which on each iteration will be 1, 10, 100, 1000, ....
    MOV R2, #1
    MOV R0, #0
    MOV R4, #10
    @@ working of subroutine
    @@ 92529679 as input in register R1
    @@ Logical and register of R1 with 0xF and get low nibble and store it in R3
    @@ Multiply R3 with R2 (0xa) since BCD is multiple of 10 
    @@ i.e., 9+70+600+9000+20000+500000+2000000+90000000 in hex will produce the result expected
BCD_2_HEX_LOOP:
    @@ Logical and store the LSB nibble in R3
    AND R3, R1, #0xF
    @@ Multiply R3 with R2 which will increment for each iteration form (1, 10, 100, ...)
    MUL R3, R3, R2
    @@ Add the result of multplication with register for each nibble
    ADD R0, R0, R3
    @@ Logical right shift by 4 bits or 1 nibble so that we will be getting next BCD number
    MOV R1, R1, LSR #4
    @@ Multiply R2 by 10 and store back to R2 for next iteration
    MUL R2, R2, R4
    @@ Compare the register R0 to check if there is any more nibble left if not skip the loop
    CMP R1, #0
    BNE BCD_2_HEX_LOOP
    @@ Store the content of register R0 to stack
    STMFD SP!, {R0}
    @@ Pop the content of stack to R0-R4 register and update PC for next instruction after branch
    LDMFD SP!, {R0-R4, PC}