    
    #config codesize    512
    #config filename    "cls.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AH, 13h
    INT     21h

    FRET