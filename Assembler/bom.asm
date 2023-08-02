    #config codesize    512
    #config filename    "bom.com"
    #origin addr 0
    #enum   @CRLF       0A0Dh

    JMP     100h
    &RESBSF 100h

    MOV     AH, 0
    INT     13h

    MOV     AH, 3
    MOV     AL, 20h
    MOV     CH, 0
    MOV     CL, 1
    MOV     DH, 0
    MOV     DL, 0
    MOV     BX, 8000h
    MOV     ES, BX
    MOV     BX, 0
    INT     13h

    FRET