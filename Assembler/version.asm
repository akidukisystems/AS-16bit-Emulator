
    #config codesize    512
    #config filename    "version.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    JMP     100h
    &RESBSF 100h

    MOV     SI, string:
    MOV     AH, 0Eh
    INT     10h

    FRET

string:
    &DB     "AkidukiSystems SampleOS Version 0.5"
    &DB     0