
    #config codesize    512
    #config filename    "version.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     SI, string:
    MOV     AH, 0Eh
    INT     10h

    FRET

string:
    &DB     "AkidukiSystems SampleOS Version 0.7"
    &DB     0