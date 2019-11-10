.EQU SWI_EXIT, 0x11

@@ Input and Output
@ A_DIGIT - ascii value
@ H_DIGIT - show equivalent value in low nibble else for error shows 0xFF
@@ Data segment
.DATA
A_DIGIT: .byte 0x43
H_DIGIT: .byte 0x00
@ For alignment since two byte are used
.align

@@ Code segment
.TEXT
@@ Exposing MAIN to global
.global MAIN

@@ MAIN subroutine
MAIN:
    LDR R2, =A_DIGIT        @ Load A_DIGIT address to regitser R2
    LDRB R1, [R2]           @ Load the contents of register R2 to register R1
    MOV R2, #48             @ Move immediate value 48 to register R2 to compare if value in register R1 is less than R2
    MOV R3, #10             @ If the value in register R1 is greater than 48 and subtracting it from R2
                            @ If the result is less than 10 it is digit
    BL IS_DIGIT             @ The above said logic is implemented in IS_DIGIT subroutine
    CMP R0, #0xFF           @ After execution of IS_DIGIT subroutine if register R0 is 0xFF then it is not digit
    BNE EXIT                @ If the comparison fails with Z flag not set then it means given A_DIGIT is digit jump to EXIT
    MOV R2, #65             @ Else check whether given A_DIGIT is ascii from A to F by setting register R2 to 65
                            @ Move immediate value 65 to register R2 to compare if value in register R1 is less than R2
    MOV R3, #6              @ If the value in register R1 is greater than 65 and subtracting it from R2
                            @ If the result is less than 6 then it is between ascii A-F
    BL IS_ALPHA             @ The above said logic is implemented in IS_ALPHA subroutine
    CMP R0, #0xFF           @ After execution of IS_ALPHA subroutine if register R0 is 0xFF then it is not alphabet between A-F
    BNE EXIT                @ If the comparison fails with Z flag not set then it means given A_DIGIT is between A-F jump to EXIT
    MOV R2, #97             @ Else check whether given A_DIGIT is ascii from a to f by setting register R2 to 97
                            @ Move immediate value 97 to register R2 to compare if value in register R1 is less than R2
    MOV R3, #6              @ If the value in register R1 is greater than 97 and subtracting it from R2
    BL IS_ALPHA             @ The above said logic is implemented in IS_ALPHA subroutine
    CMP R0, #0xFF           @ After execution of IS_ALPHA subroutine if register R0 is 0xFF then it is not alphabet between a-f
EXIT:
    LDR R2, =H_DIGIT        @ Store the H_DIGIT address in register R2
    STRB R0, [R2]           @ Store byte in register R0 to address location referred by register R2
    swi SWI_EXIT            @ Make software interrupt to exit the programm

IS_DIGIT:
    STMFD SP!, {R1-R3, LR}  @ Store content of register R1-R3 and link register in Stack and increment stack pointer
    LDRB R0, [SP]           @ Store the top of stack to register R0 which is essentially R1
    LDR R1, [SP, #4]        @ Store the 2nd top of stack to register R1 which is essentially R2
    LDR R2, [SP, #8]        @ Store the 3rd top of stack to register R1 which is essentially R3
    CMP R0, R1              @ Compare register R0 and R1 i.e., value of A_DIGIT with 48
    BLT NOT_DIGIT           @ If R0 is less than 48 it means given A_DIGIT is not digit
    SUB R0, R0, R1          @ Subtract contents of R0 with R1 and store back in R0
    CMP R0, R2              @ Compare register R0 and R2 i.e., value of R0 is less than R2 which means A_DIGIT is between 0-9
    BLT IS_DIGIT_EXIT       @ If the condition got satisfied jump to IS_DIGIT_EXIT
NOT_DIGIT:                  @ If the given A_DIGIT is not a digit set R0 to 0xFF
    MOV R0, #0xFF           @ Storing 0xFF is register R0 for not a digit
IS_DIGIT_EXIT:
    STMFD SP!, {R0}         @ Storing content of R0 in stack and incrementing stack
    LDMFD SP!, {R0-R3, PC}  @ Pop the content of stack and store in registers R0-R3 and change the PC
                            @ for continuing execution from the next statement of branch which is in LR

IS_ALPHA:
    STMFD SP!, {R1-R3, LR}  @ Store content of register R1-R3 and link register in Stack and increment stack pointer
    LDRB R0, [SP]           @ Store the top of stack to register R0 which is essentially R1
    LDR R1, [SP, #4]        @ Store the 2nd top of stack to register R1 which is essentially R2
    LDR R2, [SP, #8]        @ Store the 3rd top of stack to register R1 which is essentially R3
    CMP R0, R1              @ Compare register R0 and R1 i.e., value of A_DIGIT with 65 or 97
    BLT NOT_ALPHA           @ If R0 is less than 48 it means given A_DIGIT is not alphabet
    SUB R0, R0, R1          @ Subtract contents of R0 with R1 and store back in R0
    CMP R0, R2              @ Compare register R0 and R2 i.e., value of R0 is less than R2 which means A_DIGIT is between A-F or a-f
    ADDLT R0, R0, #10       @ If A_DIGIT is between A-F or a-f subtracting it from 65 or 97 will have 0-6 value but it is not expected
                            @ So adding 10 to the value so it will sum upto A-F
    BLT IS_ALPHA_EXIT
NOT_ALPHA:                  @ If the given A_DIGIT is not a alphabet set R0 to 0xFF
    MOV R0, #0xFF           @ Storing 0xFF is register R0 for not a alphabet
IS_ALPHA_EXIT:
    STMFD SP!, {R0}         @ Storing content of R0 in stack and incrementing stack
    LDMFD SP!, {R0-R3, PC}  @ Pop the content of stack and store in registers R0-R3 and change the PC
                            @ for continuing execution from the next statement of branch which is in LR

