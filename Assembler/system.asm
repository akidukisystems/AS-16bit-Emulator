
    #config codesize 2048
    #config filename "system.sys"
    #origin addr 8800h
    #enum   @CRLF       0A0Dh
    
    XOR     AX, AX
    MOV     SS, AX
    MOV     SP, 7C00h
    MOV     DS, AX
    MOV     ES, AX

    MOV     WORD[8200h], AX
    MOV     AX, return_only:
    MOV     BX, 10h
    DIV     BX
    MOV     WORD[7AF4h], AX

    MOV     AH, 20h                     ; 初期化
    INT     10h                         ; ビデオ割り込み

    MOV     SI, start.dat:              ; SI...検索対象のファイル名
    CALL    searchFile:
    JCXZ    notfound_start.dat:
    CALL    fileEntry2Addr:

    MOV     SI, AX                      ; SI...検索対象のファイル名
    CALL    searchFile:
    CALL    fileEntry2Addr:
    MOV     BX, 10h
    DIV     BX
    MOV     WORD[7AF4h], AX

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
    JE      splitcommand:

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



splitcommand:
    MOV     SI, 7B02h
    MOV     DI, 7AE0h
    XOR     CX, CX

splitcommand.loop:
    MOV     AX, [SI]
    CMP     AL, 20h
    JE      splitcommand.split:
    CMP     AL, 0
    JE      splitcommand.end:
    MOV     [DI], AL
    INC     SI
    INC     DI
    JMP     splitcommand.loop:

splitcommand.split:
    INC     CX
    MOV     DI, 7AE0h
    MOV     BX, CX
    MOV     AX, 10h
    MUL     BX
    SUB     DI, AX
    INC     SI
    JMP     splitcommand.loop:

splitcommand.end:
    DBG
    MOV     SI, 7AE0h                   ; SI...検索対象のファイル名
    DBG
    CALL    searchFile:
    DBG
    JCXZ    doCommand_Fail:
    DBG

    CALL    fileEntry2Addr:
    DBG

    CMP     [AX], 40AFh
    DBG

    JE      callfile:                   ; ファイルを実行

doCommand_notexecutable:
    MOV     SI, message.notexecutable:
    MOV     AH, 0Eh
    INT     10h
    JMP     callfile_ret:
    
doCommand_Fail:
    MOV     SI, message.notfound_cmd:
    MOV     AH, 0Eh
    INT     10h

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0              ; 入力文字数リセット

    JMP     keyloop:

doCommand_kakutyoushi:
    PUSHA
    PUSHF
    XOR     CX, CX
    ADD     DI, 8                       ; エントリ先頭から9バイトが拡張子
    MOV     DX, DI                      ; 拡張子の位置を記録しとく
    MOV     SI, doCommand_kakutyoushi.dat:

doCommand_kakutyoushi.loop:
    MOV     AX, [DI]                    ; 文字列読み込み
    MOV     BX, [SI]
    CALLF   WORD[7AF4h]                 ; 小文字にする
    CMP     AL, BL                      ; 比較して違うなら、他の拡張子か調べる
    JNE     doCommand_kakutyoushi.next:
    INC     CX                          ; 次の文字へ
    INC     DI
    INC     SI
    CMP     CX, 3                       ; 拡張子を比較し終えて、すべて一致なら続行（リターン）
    JNE     doCommand_kakutyoushi.loop:
    
    POPF
    POPA
    XOR     AX, AX                      ; 終了コード（AX）は0
    RET

doCommand_kakutyoushi.next:
    XOR     CX, CX
    MOV     DI, DX                      ; 記録しといた拡張子の位置を復元
    INC     SI                          ; お次の拡張子
    MOV     AX, [SI]                    ; 終端ならおしまい
    CMP     AL, 0
    JNE     doCommand_kakutyoushi.loop:

    POPF
    POPA
    MOV     AX, 1
    RET
    
doCommand_kakutyoushi.dat:              ; 実行可能な拡張子一覧
    &DB     "SYS"
    &DB     "COM"
    &DB     0



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

callfile_ret:
    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み


    MOV     BYTE[7B00h], 0

    JMP     keyloop:

searchFile:
    PUSH    AX
    PUSH    BX
    PUSH    DX
    PUSH    DI
    PUSH    SI
    XOR     CX, CX

searchFile_fileentry:
    MOV     DI, 8000h
    MOV     AX, CX                      ; CXはファイルエントリのカウンタ 20hをかけるとファイルエントリの先頭になる
    MOV     BX, 20h
    MUL     BX
    ADD     DI, AX

searchFile_filenameCMP:
    MOV     AX, [SI]                    ; 文字が空だったり終端の場合はラベルendに
    CMP     AL, 0
    DBG
    JZ      searchFile_filenameend:
    CMP     AL, 2Eh
    DBG
    JZ      searchFile_filenameStrKakutyo:

    MOV     BX, [DI]                    ; 文字がスペースの場合も
    CMP     BL, 20h
    DBG
    JE      searchFile_filenameend:
    CMP     BL, 0                       ; 空エントリの場合はFATの終端とみなす
    DBG
    JE      searchFile_Fail:
    CMP     BL, FFh                     ; 削除済エントリ
    DBG
    JE      searchFile_not:

    CALLF   WORD[7AF4h]                 ; 文字を小文字化

    DBG
    CMP     AL, BL                      ; 文字が一緒ならループ続行
    JE      searchFile_filenameCorrect:

    JMP     searchFile_not:

searchFile_filenameCorrect:
    INC     SI
    INC     DI

    POP     AX
    MOV     BX, SI
    SUB     BX, 08h
    CMP     AX, BX
    PUSH    AX
    DBG

    JE      searchFile_filenameEqual:

    JMP     searchFile_filenameCMP:


searchFile_filenameStrKakutyo:
    MOV     DI, 8000h
    MOV     AX, CX                      ; CXはファイルエントリのカウンタ 20hをかけるとファイルエントリの先頭になる
    MOV     BX, 20h
    MUL     BX
    ADD     DI, AX
    ADD     DI, 8
    INC     SI

searchFile_filenameStrKakutyo.loop:
    MOV     AX, [SI]                    ; 文字が空だったり終端の場合はラベルendに
    CMP     AL, 0
    JZ      searchFile_filenameStrKakutyo.end:

    MOV     BX, [DI]                    ; 文字がスペースの場合も
    CMP     BL, 20h
    JE      searchFile_filenameStrKakutyo.end:

    CALLF   WORD[7AF4h]                 ; 文字を小文字化

    CMP     AL, BL                      ; 文字が一緒ならループ続行
    JE      searchFile_filenameStrKakutyoCorrect:

    JMP     searchFile_not:

searchFile_filenameStrKakutyoCorrect:
    INC     SI
    INC     DI

    POP     AX
    MOV     BX, SI
    SUB     BX, 0Ch
    CMP     AX, BX
    PUSH    AX
    JE      searchFile_filenameEqual:

    JMP     searchFile_filenameStrKakutyo.loop:

searchFile_filenameStrKakutyo.end:
    MOV     AX, [DI]                    ; ファイル名の終端に来て、文字数が一緒なら一致
    MOV     BX, [SI]
    CMP     AL, BL
    JZ      searchFile_filenameEqual:
    JMP     searchFile_not:


searchFile_filenameend:
    MOV     AX, [DI]                    ; ファイル名の終端に来て、文字数が一緒なら一致
    SUB     AL, 20h
    MOV     BX, [SI]
    CMP     AL, BL
    JZ      searchFile_filenameEqual:
    JMP     searchFile_not:

searchFile_not:
    INC     CX
    POP     SI                          ; 不一致なら次のファイルへ, SIをpop
    PUSH    SI

    CMP     CX, 16                      ; 検索終わったら、当てはまるファイル名はない
    JE      searchFile_Fail:

    JMP     searchFile_fileentry:

searchFile_Fail:
    POP     SI
    POP     DI
    POP     DX
    POP     BX
    POP     AX
    XOR     CX, CX
    RET

searchFile_filenameEqual:
    POP     SI
    POP     DI
    POP     DX
    POP     BX
    POP     AX
    RET

fileEntry2Addr:
    PUSH    BX
    PUSH    DI
    MOV     AX, CX                      ; ファイルエントリの番号 * ファイルエントリのサイズ + 先頭クラスタ番号 + FATがある位置
    MOV     BX, 20h                     ; これでクラスタ番号が格納されているところがわかる
    MUL     BX
    MOV     DI, 8000h
    ADD     DI, AX
    ADD     DI, 16h

    MOV     BX, [DI]                    ; ファイルがあるクラスタの番号を読む
    MOV     AX, 2
    MUL     BX
    MOV     BX, 512                     ; クラスタ番号 * クラスタあたりのセクタ数 * セクタあたりのサイズ + 7C00h
    MUL     BX                          ; これでファイルの場所がわかる
    ADD     AX, 7C00h
    POP     DI
    POP     BX
    RET



notfound_start.dat:
    MOV     SI, start.dat:
    MOV     AH, 0Eh
    INT     10h
    MOV     SI, messageNotFound:
    INT     10h

halt:
    HLT
    JMP     halt:

    &RESB0
return_only:
    FRET


message1:
    &DB     "AkidukiSystems SampleOS Version 0.4"
    &DW     @CRLF
    &DB     "Ready..."
    &DW     @CRLF
    &DB     ">"
    &DB     0

message.notfound_cmd:
    &DW     @CRLF
    &DB     "Not found this command."
    &DB     0

message.notexecutable:
    &DW     @CRLF
    &DB     "Not executable file."
    &DB     0

messageRet:
    &DW     @CRLF
    &DB     ">"
    &DB     0

messageNotFound:
    &DB     " is not found."
    &DB     0

start.dat:
    &DB     "START.DAT"
    &DB     0