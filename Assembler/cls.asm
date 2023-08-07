    
    #config codesize    512
    #config filename    "cls.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AH, 20h
    INT     10h

    FRET