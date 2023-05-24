    
    #config codesize    512
    #config filename    "cls.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    JMP     100h
    &DB     "CM"
    &RESBSF 100h

    MOV     AH, 20h
    INT     10h

    FRET