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
    PUSH    DI
    PUSH    SI

    MOV     BL, DL
    MOV     AH, 4
    MOV     DI, 1000h
    CALL    converts:

    MOV     AH, 0Eh
    MOV     SI, message_fin:
    INT     10h

    MOV     AH, 0Eh
    MOV     SI, 1000h
    INT     10h

    POP     SI
    POP     DI

    CLI

    PUSH DS

    XOR AX, AX
    MOV DS, AX

    MOV WORD[70h], SI
    MOV WORD[72h], DI

    POP DS

    STI

    FRET

message_fin:
    &DB     "Benchmark score: "
    &DW     @CRLF
    &DB     0



getRTC:
    INC DX
    IRET



    ; AH...変換種類
    ; BL...変換する値（raw）
    ; BX...変換する値（asciiまたはbcd）
    ; DL...変換された値（raw）
    ; DX...変換された値（asciiまたはbcd）
converts:
    PUSH    CX

    CMP     AH, 00h
    JE      converts_hex2bcd:
    CMP     AH, 01h
    JE      converts_bcd2hex:
    CMP     AH, 02h
    JE      converts_bcd2ascii:
    CMP     AH, 03h
    JE      converts_ascii2bcd:

    CMP     AH, 04h
    JE      converts_hex2ascii:   

    POP     CX

    RET

converts_hex2bcd:
    XOR     CX, CX
    MOV     CL, 0

converts_hex2bcd.loop:
    MOV     BH, 0Ah                     ; 10で割ると、余りがBCDの1桁に相当する
    MOV     AX, BL
    DIV     BH
    MOV     CH, AH                      ; 余りをCHに移し、リピート時にpushする

    PUSH    CX

    CMP     AL, 0                       ; 商が0になったらおしまい
    JE      converts_hex2bcd.done:

    INC     CL                          ; CLは桁数 CHから戻すときに使う
    MOV     BL, AL

    JMP     converts_hex2bcd.loop:

converts_hex2bcd.done:
    XOR     DX, DX

converts_hex2bcd.done.loop:
    POP     CX
    XOR     AX, AX
    
    PUSH    DX                          ; 何桁目か計算し、CLにかける
    MOV     AH, CL
    MOV     AL, 10h
    CALL    pow:
    MOV     BX, DX

    XOR     DX, DX
    XOR     AX, AX
    MOV     AL, CH
    MUL     BX
    POP     DX
    ADD     DX, AX                      ; かけたもの同士で加算していくと、BCDコードになる

    CMP     CL, 0
    JNE     converts_hex2bcd.done.loop:
    
    POP     CX

    RET

    ; AH...乗数
    ; AL...基数
pow:
    CMP     AH, 0
    JE      pow_1:

    PUSH    BX
    PUSH    CX
    XOR     BX, BX
    MOV     BL, AH
    MOV     AH, 0
    MOV     DX, AX
    MOV     CX, 1

pow.loop:
    CMP     CX, BX
    JE      pow_fin:
    MUL     DX
    INC     CX
    JMP     pow.loop:

pow_1:
    MOV     DX, 1
    RET

pow_fin:
    POP     CX
    POP     BX
    MOV     DX, AX
    RET



converts_bcd2hex:
    POP     CX

    RET

converts_bcd2ascii:

    MOV     AX, BX
    AND     AL, 0Fh
    ADD     AL, 30h
    MOV     AH, 0
    PUSH    AX

    MOV     AX, BX
    AND     AL, F0h
    SHR     AL, 4
    ADD     AL, 30h
    MOV     AH, 0
    PUSH    AX

    MOV     AX, BX
    AND     AH, 0Fh
    ADD     AH, 30h

    XOR     CX, CX
    MOV     CL, AH

    POP     AX
    MOV     DH, AL

    POP     AX
    MOV     DL, AL

    POP     CX

    RET


converts_ascii2bcd:

    POP     CX

    RET


converts_hex2ascii:
    XOR     CX, CX
    MOV     CL, 0

converts_hex2ascii.loop:
    MOV     BH, 0Ah                     ; 10で割ると、余りがBCDの1桁に相当する
    MOV     AX, BL
    DIV     BH
    MOV     CH, AH                      ; 余りをCHに移し、リピート時にpushする

    PUSH    CX

    CMP     AL, 0                       ; 商が0になったらおしまい
    JE      converts_hex2ascii.done:

    INC     CL                          ; CLは桁数 CHから戻すときに使う
    MOV     BL, AL

    JMP     converts_hex2ascii.loop:

converts_hex2ascii.done:
    XOR     DX, DX

converts_hex2ascii.done.loop:
    POP     CX

    ADD     CH, 30h

    MOV     [DI], CH

    INC     DI

    CMP     CL, 0
    JNE     converts_hex2ascii.done.loop:
    
    POP     CX

    RET