
    #config codesize    512
    #config filename    "exit.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    JMP     100h
    &DB     "CM"
    &RESBSF 100h

    MOV     AH, 20h
    INT     10h

    MOV     SI, message:
    MOV     AH, 0Eh
    INT     10h

    CLI

halt:
    HLT
    JMP     halt:

message:
    &DB     "It's now safe to turn off your computer."
    &DW     @CRLF
    &DB     0
