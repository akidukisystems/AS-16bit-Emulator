    #config codesize    auto
    #config filename    "bench.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    CLI

    PUSH DS

    XOR AX, AX
    MOV DS, AX

    MOV SI, WORD[70h]
    MOV DI, WORD[72h]

    MOV WORD[70h], getRTC:         ; RTC割り込み (70h)

    POP AX

    MOV WORD[72h], AX

    MOV DS, AX

    XOR DX, DX

    STI

    XOR CX, CX

loop:
    MOV AX, FFFFh
    INC AX
    ADD AX, FFFFh
    INC AX

    CMP CX, 0FFFh
    JE loopend:

    INC CX

    JMP loop:

loopend:
    DBG

    CLI

    PUSH DS

    XOR AX, AX
    MOV DS, AX

    MOV WORD[70h], SI
    MOV WORD[72h], DI

    POP DS

    STI

    FRET



getRTC:
    INC DX
    IRET