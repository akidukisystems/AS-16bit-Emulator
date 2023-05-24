
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
    IN      AX, 80h                     ; キーが押されたか確認
    CMP     AX, 0                       ; 0（押されていない）ならループに戻る
    JE      keyloop:

    MOV     BL, AL
    AND     BL, 10h
    CMP     BL, 10h
    JE      doCommand:

    IN      AX, 81h                     ; 押されたならキーコード取得

    MOV     DS, 07B0h                   ; 9000hを基準にメモリ操作

    MOV     BH, BYTE[0000h]             ; 入力された文字を9002h以降に、文字数を9000hに記録
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
    MOV     BX, [DI]
    CMP     BL, 20h
    JE      doCommand_filenameend:

    CMP     AL, BL                      ; 文字が一緒ならループ続行
    JE      doCommand_filenameCorrect:

    JMP     doCommand_not:

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
    
    DBG

    CMP     [AX], 40AFh

    JE      callfile:
callfile_ret:

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0

    JMP     keyloop:

callfile:
    MOV     BX, 10h
    DIV     BX

    DBG

    PUSHA
    PUSH    DS
    PUSH    ES

    XOR     BX, BX
    MOV     CX, BX
    MOV     DX, BX
    MOV     SI, BX
    MOV     DI, BX
    MOV     BP, BX

    MOV     DS, BX
    MOV     WORD[7AF0h], SP
    MOV     WORD[7AF2h], SS
    MOV     SP, BX

    MOV     DS, AX
    MOV     ES, AX
    MOV     SS, AX

    CALLF   AX

    XOR     BX, BX
    MOV     DS, BX
    MOV     SP, WORD[7AF0h]
    MOV     SS, WORD[7AF2h]

    POP     ES
    POP     DS
    POPA
    DBG

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