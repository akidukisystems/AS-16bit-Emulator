
    #config codesize    512
    #config filename    "type.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     SI, 7AD0h
    MOV     AH, 10h
    INT     21h

    FRET