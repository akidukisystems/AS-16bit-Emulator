    #config codesize    auto
    #config filename    "del.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AH, 1
    MOV     SI, 7AD0h
    INT     21h
    OR      AH, AH
    JNZ     notfound:

    MOV     AX, CX
    XOR     DX, DX
    MOV     BX, 20h
    MUL     BX

    ADD     AX, 7C00h
    ADD     AX, 400h
    MOV     BX, AX

    PUSH    DS
    XOR     AX, AX
    MOV     DS, AX
    MOV     [BX], E5h
    ADD     BX, 400h
    MOV     [BX], E5h
    POP     DS

    MOV     AH, 03h
    MOV     AL, 4
    MOV     CH, 0
    MOV     CL, 2
    MOV     DH, 0
    MOV     DL, 0
    MOV     BX, 0
    MOV     ES, BX
    MOV     BX, 8000h

    INT     13h

    FRET

notfound:
    MOV     SI, message_notfound:
    MOV     AH, 10h
    INT     21h

    FRET

message_notfound:
    &DB     "file not found."
    &DW     @CRLF
    &DB     0