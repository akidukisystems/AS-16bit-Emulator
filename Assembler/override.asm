
    #config codesize    auto
    #config filename    "override.com"
    #origin addr 0
    #enum   @CRLF       0A0Dh

    MOV     SI, message:
    MOV     AH, 10h
    INT     21h

    FRET

message:
    &DB     "あんたが書いた杜撰なコード"
    &DW     @CRLF
    &DB     "ばっか持て囃すユーザーよ"
    &DW     @CRLF
    &DB     "吐いた言葉の裏なんて知る由もないだろう"
    &DW     @CRLF
    &DB     "哀れあはれ"
    &DW     @CRLF
    &DB     0