
    #config codesize 1024
    #config filename "system.sys"
    #origin addr 8800h
    #enum   @CRLF       0A0Dh
    
    XOR     AX, AX
    MOV     SS, AX
    MOV     SP, 7C00h
    MOV     DS, AX
    MOV     ES, AX

    MOV     WORD[8200h], AX

    MOV     AH, 20h                     ; 初期化
    INT     10h                         ; ビデオ割り込み

    MOV     SI, message1:               ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

keyloop:
    MOV     AH, 1                       ; キーが押されたか確認
    INT     16h
    JZ      keyloop:                    ; 0（押されていない）ならループに戻る

    XOR     AX, AX
    INT     16h                         ; 押されたならキーコード取得

    CMP     AH, 8                       ; BSキー押下
    JE      backspace:

    CMP     AH, 13                      ; Enterキー押下
    JE      doCommand:

    MOV     DS, 07B0h                   ; 7B00hを基準にメモリ操作
    MOV     BH, BYTE[0000h]             ; 入力された文字を7B02h以降に、文字数を7B00hに記録
    ADD     BH, 0002h
    MOV     [BH], AL
    INC     BH
    MOV     [BH], 0
    SUB     BH, 0002h
    MOV     BYTE[0000h], BH
    XOR     BX, BX
    MOV     DS, BX                      ; データセグメントをもどす

    MOV     AH, 0Ah
    INT     10h

    JMP     keyloop:

backspace:
    MOV     DS, 07B0h                   ; 7B00hにある文字数を読み込む
    MOV     BH, BYTE[0000h]
    CMP     BH, 0                       ; 文字数が0の場合は終了
    JE      backspace_not:
    
    MOV     AL, 7Fh                     ; DEL文字を描画（一文字削除）
    MOV     AH, 0Ah
    INT     10h

    ADD     BH, 0002h                   ; 7B02h以降にある文字の終端を削除し、文字数を-1
    DEC     BH
    MOV     [BH], 0
    SUB     BH, 0002h
    MOV     BYTE[0000h], BH
    XOR     BX, BX
    MOV     DS, BX                      ; データセグメントをもどす
    
    JMP     keyloop:

backspace_not:
    XOR     BX, BX
    MOV     DS, BX                      ; データセグメントをもどす
    JMP     keyloop:

doCommand:
    MOV     SI, 7B02h                   ; SIは入力されたコマンド、DIは検索対象のファイル名
    XOR     CX, CX

doCommand_fileentry:
    MOV     DI, 8000h
    MOV     AX, CX                      ; CXはファイルエントリのカウンタ 20hをかけるとファイルエントリの先頭になる
    MOV     BX, 20h
    MUL     BX
    ADD     DI, AX

doCommand_filenameCMP:
    MOV     AX, [SI]                    ; 文字が空だったり終端の場合はラベルendに
    CMP     AL, 0
    JZ      doCommand_filenameend:

    MOV     BX, [DI]                    ; 文字がスペースの場合も
    CMP     BL, 20h
    JE      doCommand_filenameend:

    CMP     AL, 41h
    JGE     doCommand_filenameCMP_al:

doCommand_filenameCMP_al_ret:
    CMP     BL, 41h
    JGE     doCommand_filenameCMP_bl:

doCommand_filenameCMP_bl_ret:
    CMP     AL, BL                      ; 文字が一緒ならループ続行
    JE      doCommand_filenameCorrect:

    JMP     doCommand_not:

doCommand_filenameCMP_al:
    CMP     AL, 5Ah
    JG      doCommand_filenameCMP_al_ret:
    ADD     AL, 20h
    JMP     doCommand_filenameCMP_al_ret:

doCommand_filenameCMP_bl:
    CMP     BL, 5Ah
    JG      doCommand_filenameCMP_bl_ret:
    ADD     BL, 20h
    JMP     doCommand_filenameCMP_bl_ret:

doCommand_filenameCorrect:
    INC     SI
    INC     DI

    CMP     SI, 7B0Ah                   ; ファイル名を検証し終わったら一致
    JE      doCommand_filenameEqual:

    JMP     doCommand_filenameCMP:

doCommand_filenameend:
    MOV     AX, [DI]                    ; ファイル名の終端に来て、文字数が一緒なら一致
    SUB     AL, 20h
    MOV     BX, [SI]
    CMP     AL, BL
    JZ      doCommand_filenameEqual:
    JMP     doCommand_not:

doCommand_not:
    INC     CX
    MOV     SI, 7B02h                   ; 不一致なら次のファイルへ

    CMP     CX, 16                      ; 検索終わったら、当てはまるファイル名はない
    JE      doCommand_Fail:

    JMP     doCommand_fileentry:

doCommand_Fail:
    MOV     SI, message2:
    MOV     AH, 0Eh
    INT     10h

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0

    JMP     keyloop:

doCommand_filenameEqual:
    MOV     AX, CX                      ; ファイルエントリの番号 * ファイルエントリのサイズ + 先頭クラスタ番号 + FATがある位置
    MOV     BX, 20h                     ; これでクラスタ番号が格納されているところがわかる
    MUL     BX
    ADD     AX, 16h
    MOV     DI, 8000h
    ADD     DI, AX

    MOV     BX, [DI]                    ; ファイルがあるクラスタの番号を読む
    MOV     AX, 2
    MUL     BX
    MOV     BX, 512                     ; クラスタ番号 * クラスタあたりのセクタ数 * セクタあたりのサイズ + 7C00h
    MUL     BX                          ; これでファイルの場所がわかる
    ADD     AX, 7C00h

    CMP     [AX], 40AFh

    JE      callfile:
callfile_ret:

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0

    JMP     keyloop:

callfile:
    MOV     BX, 10h                     ; ファイルの先頭アドレスを10で割り、CSレジスタで使えるようにする
    DIV     BX

    PUSHA                               ; PUSH
    PUSH    DS
    PUSH    ES

    XOR     BX, BX                      ; 初期化
    MOV     CX, BX
    MOV     DX, BX
    MOV     SI, BX
    MOV     DI, BX
    MOV     BP, BX

    MOV     DS, BX                      ; スタック状態を記録
    MOV     WORD[7AF0h], SP
    MOV     WORD[7AF2h], SS
    MOV     SP, BX

    MOV     DS, AX                      ; セグメントレジスタをCSと同じ場所に
    MOV     ES, AX
    MOV     SS, AX

    CALLF   AX                          ; far call

    XOR     BX, BX                      ; スタック状態を復帰
    MOV     DS, BX
    MOV     SP, WORD[7AF0h]
    MOV     SS, WORD[7AF2h]

    POP     ES                          ; POP
    POP     DS
    POPA

    JMP     callfile_ret:


fin:
    HLT
    JMP     fin:

message1:
    &DB     "AkidukiSystems SampleOS Version 0.1"
    &DW     @CRLF
    &DB     "Ready..."
    &DW     @CRLF
    &DB     ">"
    &DB     0

message2:
    &DW     @CRLF
    &DB     "Not found this command."
    &DB     0

message3:
    &DW     @CRLF
    &DB     "great."
    &DW     @CRLF
    &DB     0

messageRet:
    &DW     @CRLF
    &DB     ">"
    &DB     0