
    #config codesize    512
    #config filename    "test.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    JMP     100h
    &DB     "CM"
    &RESBSF 100h

    MOV     SI, message:
    MOV     AH, 0Eh
    INT     10h

    FRET

halt:
    HLT
    JMP     halt:

message:
    &DW     @CRLF
    &DB     "HELLO WORLD!"
    &DW     @CRLF
    &DB     0
