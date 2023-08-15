    ; AS-16 アセンブリ言語 入門 基本・条件分岐・メモリ操作編

    #config codesize    512
    #config filename    "memtest.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     DX, 1000h                   ; DXレジスタに1000hを格納します。

Repeat:
    MOV     [DX], FFFFh                 ; DXレジスタに格納されている値のメモリアドレスを参照し、FFFFhを格納します。
                                        ; WORDサイズのレジスタを指定すると、格納できる整数の範囲は 0～65535、BYTEサイズのレジスタを指定すると、格納できる整数の範囲は 0～255 になります。
    CMP     [DX], FFFFh                 ; DXレジスタに格納されている値のメモリアドレスを参照し、FFFFhと比較します。結果に応じて、フラグレジスタの各フラグがセット/リセットされます。
                                        ; ゼロフラグ、キャリーフラグ、パリティフラグ、サインフラグ、オーバーフローフラグなどが変更され、それぞれのフラグの立ち方によって、値の大小や正負を判別できます。
    JNE     Error:                      ; 直前の比較結果がNot Equal（等しくない）である場合、Errorラベルにジャンプします。

    ADD     DX, 2                       ; DXレジスタに2を加算します。
                                        ; FFFFhに1を加算すると、ラウンドアップして0000hに戻ることに留意してください。
    CMP     DX, 0000h                   ; DXレジスタと0000hを比較し、結果に応じてフラグレジスタの各フラグを変更します。
                                        ; DXレジスタは最初は1000hから始まり、2ずつ加算されていきます。DXレジスタが0000hの値になるときは、FFFEhに2を加算してラウンドアップしたときになります。
    JE      Done:                       ; 直前の比較結果がEqual（等しい）である場合、Doneラベルにジャンプします。

    JMP     Repeat:                     ; Repeatラベルに無条件でジャンプします。

Error:
    MOV     SI, message1:               ; エラーメッセージを出力します。
    MOV     AH, 0Eh
    INT     10h

    FRET                                ; プログラムを終了します。

Done:
    MOV     SI, message2:               ; 完了メッセージを出力します。
    MOV     AH, 0Eh
    INT     10h

    FRET                                ; プログラムを終了します。

message1:
    &DB     "Memory NG"
    &DW     CRLF
    &DB     0

message2:
    &DB     "Memory OK"
    &DW     CRLF
    &DB     0