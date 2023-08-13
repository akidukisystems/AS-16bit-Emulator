
    #config codesize    512
    #config filename    "type.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AH, 1
    MOV     SI, 7AD0h
    INT     21h
    OR      AH, AH
    JNZ     notfound:

    MOV     AH, 2
    INT     21h

    PUSH    DS
    XOR     BX, BX
    MOV     DS, BX
    MOV     SI, AX
    MOV     AH, 10h
    INT     21h
    POP     DS

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