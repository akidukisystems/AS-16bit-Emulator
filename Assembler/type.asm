
    #config codesize    auto
    #config filename    "type.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AH, 20h
    MOV     SI, 7AD0h
    MOV     BX, 1700h
    MOV     ES, BX
    XOR     BX, BX
    INT     21h
    OR      AH, AH
    JNZ     notfound:

    PUSH    DS

    MOV     DS, ES
    MOV     SI, 0
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