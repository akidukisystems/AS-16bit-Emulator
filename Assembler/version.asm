
    #config codesize    auto
    #config filename    "version.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     SI, string:
    MOV     AH, 10h
    INT     21h

    FRET

string:
    &DB     "AkidukiSystems SampleOS Version 0.8"
    &DB     0