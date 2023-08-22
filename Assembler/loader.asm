
    #config codesize auto
    #config filename "loader.sys"
    #origin addr        5100h
    #enum   @CRLF       0A0Dh

    MOV     AX, 5100h
    MOV     SP, AX
    MOV     BP, AX
    XOR     AX, AX
    MOV     SS, AX
    MOV     ES, AX

    MOV     SI, systemfile:
    MOV     BX, 0110h
    MOV     ES, BX
    XOR     BX, BX
    CALL    readfile:

    JC      filenotfound:

    JMP     1100h

filenotfound:
    MOV     SI, msgerr:
    MOV     AH, 0Eh
    INT     10h

    JMP     fin:

    ; searchfile
    ; in
    ;   SI...ファイル名があるアドレス
    ; out
    ;   FLAGS...
    ;     AL... 0: ファイルあり
    ;           1: ファイルなし
    ;   CX...ファイルエントリ
searchFile:
    PUSH    AX
    PUSH    BX
    PUSH    DX
    PUSH    DI
    PUSH    DS
    PUSH    SI
    XOR     CX, CX
    MOV     DS, CX

searchFile_fileentry:
    MOV     DI, 8000h
    MOV     AX, CX                      ; CXはファイルエントリのカウンタ 20hをかけるとファイルエントリの先頭になる
    MOV     BX, 20h
    MUL     BX
    ADD     DI, AX

searchFile_filenameCMP:
    MOV     AX, [SI]                    ; 文字が空だったり終端の場合はラベルendに
    CMP     AL, 0
    JZ      searchFile_filenameend:
    CMP     AL, 2Eh
    JZ      searchFile_filenameStrKakutyo:

    MOV     BX, [DI]                    ; 文字がスペースの場合も
    CMP     BL, 20h
    JE      searchFile_filenameend:
    CMP     BL, 0                       ; 空エントリの場合はFATの終端とみなす
    JE      searchFile_Fail:
    CMP     BL, E5h                     ; 削除済エントリ
    JE      searchFile_not:

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

    JE      searchFile_filenameEqual:

    JMP     searchFile_filenameCMP:


searchFile_filenameStrKakutyo:
    PUSH    DI
    AND     DI, 000Fh                   ; 拡張子の識別をする前に、ファイル名が一致してるか確認
    CMP     DI, 8                       ; 8バイト分比較済（つまり、ファイル名は一致）の場合はスキップ
    POP     DI
    JGE     searchFile_filenameStrKakutyo_skip:

    PUSH    BX                          ; 比較しきってない場合は、今指してるFATの文字がスペース
    MOV     BX, [DI]                    ; （つまり、ファイル名一致）の場合はOK
    CMP     BL, 20h                     ; スペースではない場合は、探すファイル名と今見ているファイル名が違うのでjmp
    POP     BX

    JNE     searchFile_not:

searchFile_filenameStrKakutyo_skip:
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
    POP     DS
    POP     DI
    POP     DX
    POP     BX
    POP     AX
    XOR     CX, CX
    MOV     AH, 1
    RET

searchFile_filenameEqual:
    POP     SI
    POP     DS
    POP     DI
    POP     DX
    POP     BX
    POP     AX
    MOV     AH, 0
    RET



fileEntry2Clst:
    PUSH    BX
    PUSH    DI
    PUSH    DS
    MOV     AX, 0
    MOV     DS, AX
    MOV     AX, CX                      ; ファイルエントリの番号 * ファイルエントリのサイズ + 先頭クラスタ番号 + FATがある位置
    MOV     BX, 20h                     ; これでクラスタ番号が格納されているところがわかる
    MUL     BX
    MOV     DI, 8000h
    ADD     DI, AX
    ADD     DI, 16h

    MOV     AX, [DI]                    ; ファイルがあるクラスタの番号を読む
    POP     DS
    POP     DI
    POP     BX
    RET



getFileSize:
    PUSH    DI
    PUSH    DS
    PUSH    BX
    MOV     AX, 0
    MOV     DS, AX
    MOV     AX, CX
    MOV     BX, 20h
    MUL     BX
    MOV     DI, 8000h
    ADD     DI, AX
    POP     BX

    ADD     DI, 18h
    MOV     AX, [DI]
    ADD     DI, 2
    MOV     DX, [DI]

    POP     DS
    POP     DI
    RET



    ; SI...ファイル名
    ; ES:BX...格納先アドレス
    ; 戻り値 CF
    ;           =0...成功
    ;           =1...失敗　ファイルがありません
readfile:
    PUSH    BX

    CALL    searchFile:
    OR      AH, AH
    JNZ     readfile.notfound:

    CALL    getFileSize:
    MOV     BX, 512
    XOR     DX, DX
    DIV     BX

    PUSH    AX

    CALL    fileEntry2Clst:
    XOR     DX, DX                      ; クラスタ番号からセクタ位置を取得
    MOV     BX, 2
    MUL     BX
    INC     AL
    MOV     CL, AL

    MOV     AH, 0                       ; ディスク初期化
    INT     13h

    POP     AX

    JC      fin:                        ; エラーだったらおわり

    MOV     AH, 2                       ; セクタ読み込み
    INC     AL                          ; 読み込むセクタ数
    MOV     CH, 0                       ; トラック番号 下位8bit
                                        ; トラック番号 上位2bit + セクタ番号 6bit (セクタ番号のみ1から、それ以外は0から)
    MOV     DH, 0                       ; ヘッド番号
    MOV     DL, 0                       ; ディスク番号
    POP     BX

    INT     13h

    CLC

    RET

readfile.notfound:
    POP     BX
    STC
    RET



fin:
    HLT
    JMP     fin:



msgerr:
    &DB     "Could not boot system."
    &DB     0

systemfile:
    &DB     "SYSTEM.SYS"
    &DB     0