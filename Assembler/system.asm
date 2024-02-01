
    #config codesize auto
    #config filename "system.sys"
    #origin addr        1100h
    #enum   @CRLF       0A0Dh

    #enum   @addr_beforeCall_SP             7AF0h
    #enum   @addr_beforeCall_SS             7AF2h
    #enum   @addr_beforeCall_BP             7AF4h
    #enum   @addr_keyboardDriver            7AF6h
    #enum   @addr_keyboardInterruptHandler  7AF8h

    CLI

    XOR     AX, AX
    MOV     SS, AX
    MOV     SP, 7C00h
    MOV     BP, SP
    MOV     DS, AX
    MOV     ES, AX

    MOV     WORD[84h], systemInternalInterrupt_21h:
    MOV     WORD[86h], 0                            ; 21h ソフトウェア割り込みサービス
    MOV     WORD[104h], keyboardInterrupt:
    MOV     WORD[106h], 0                           ; キーボード割込み
    MOV     WORD[@addr_keyboardInterruptHandler], 0 ; 割込み無効

    STI

    MOV     AH, 0
    MOV     AL, 2
    INT     10h

    MOV     AX, return_only:
    MOV     BX, 10h
    XOR     DX, DX
    DIV     BX
    MOV     WORD[@addr_keyboardDriver], AX

    MOV     AH, 20h                     ; 初期化
    INT     10h                         ; ビデオ割り込み

    MOV     SI, start.dat:              ; SI...検索対象のファイル名
    MOV     BX, 0510h                   ; ES:BX...読み込み先アドレス
    MOV     ES, BX
    XOR     BX, BX
    MOV     AH, 20h
    INT     21h
    OR      AH, AH
    JNZ     notfound_start.dat:

    MOV     AX, ES                      ; SI=ES*10h 検索対象
    XOR     DX, DX
    MOV     BX, 10h
    MUL     BX
    MOV     SI, AX
    MOV     BX, 0610h
    MOV     ES, BX                      ; ES=0610h 読み込み先
    XOR     BX, BX                      ; BX=0
    MOV     AH, 20h
    INT     21h

    MOV     AX, ES
    MOV     WORD[@addr_keyboardDriver], AX

    MOV     SI, version.com:            ; SI...検索対象のファイル名
    MOV     BX, 1500h                   ; ES:BX...読み込み先アドレス
    MOV     ES, BX
    XOR     BX, BX
    MOV     AH, 20h
    INT     21h
    OR      AH, AH
    JNZ     notfound_version.com:
  
    MOV     AX, ES                      ; AX...アドレス
    CALL    callfile:

    MOV     SI, message1:               ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:

    JMP     halt:

backspace:
    MOV     AH, 6                       ; キー入力をOFF
    MOV     AL, 1
    MOV     BH, 0
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], 0

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
    
    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:
    
    RET

backspace_not:
    XOR     BX, BX
    MOV     DS, BX                      ; データセグメントをもどす

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:
    
    RET


keyInterrupt:
    MOV     AH, 6                       ; キー入力をOFF
    MOV     AL, 1
    MOV     BH, 0
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], 0

    MOV     AH, 1                       ; キーが押されたか確認
    INT     16h                         ; 0（押されていない）ならループに戻る
    JZ      keyInterrupt_notanykeypushed:

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

keyInterrupt_notanykeypushed:
    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:
    
    RET



splitcommand:
    MOV     AH, 6                       ; キー入力をOFF
    MOV     AL, 1
    MOV     BH, 0
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], 0

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
    MOV     SI, 7AE0h                   ; SI...検索対象のファイル名
    MOV     BX, 1500h                   ; ES:BX...読み込み先アドレス
    MOV     ES, BX
    XOR     BX, BX
    MOV     AH, 20h
    INT     21h
    OR      AH, AH
    JNZ     doCommand_Fail.notfound:

    MOV     AH, 1
    MOV     SI, 7AE0h
    INT     21h
    MOV     AX, 20h
    MUL     CX
    ADD     AX, 8000h
    MOV     DI, AX

    CALL    checkExecutable:
    CMP     AX, 1
    JE      doCommand_Fail.notexec:

    MOV     SI, messageCRLF:
    MOV     AH, 0Eh
    INT     10h

    MOV     AX, 1500h
    CALL    callfile:                   ; ファイルを実行

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:
    
    RET
    


doCommand_Fail.notfound:
    MOV     SI, messageCRLF:
    MOV     AH, 0Eh
    INT     10h
    MOV     SI, message.notfound_cmd:
    INT     10h

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0              ; 入力文字数リセット

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:
    
    RET

doCommand_Fail.notexec:
    MOV     SI, messageCRLF:
    MOV     AH, 0Eh
    INT     10h
    MOV     SI, message.notexecutable:
    INT     10h

    MOV     SI, messageRet:             ; 文字列のあるオフセット
    MOV     AH, 0Eh
    INT     10h                         ; ビデオ割り込み

    MOV     BYTE[7B00h], 0              ; 入力文字数リセット

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h
    MOV     WORD[@addr_keyboardInterruptHandler], keyInterrupt:
    
    RET

checkExecutable:
    PUSHA
    PUSHF
    XOR     CX, CX
    ADD     DI, 8                       ; エントリ先頭から9バイトが拡張子
    MOV     DX, DI                      ; 拡張子の位置を記録しとく
    MOV     SI, checkExecutable.dat:

checkExecutable.loop:
    MOV     AX, [DI]                    ; 文字列読み込み
    MOV     BX, [SI]
    CALLF   WORD[@addr_keyboardDriver]                 ; 小文字にする
    CMP     AL, BL                      ; 比較して違うなら、他の拡張子か調べる
    JNE     checkExecutable.next:
    INC     CX                          ; 次の文字へ
    INC     DI
    INC     SI
    CMP     CX, 3                       ; 拡張子を比較し終えて、すべて一致なら続行（リターン）
    JNE     checkExecutable.loop:
    
    POPF
    POPA
    XOR     AX, AX                      ; 終了コード（AX）は0
    RET

checkExecutable.next:
    XOR     CX, CX
    MOV     DI, DX                      ; 記録しといた拡張子の位置を復元
    INC     SI                          ; お次の拡張子
    MOV     AX, [SI]                    ; 終端ならおしまい
    CMP     AL, 0
    JNE     checkExecutable.loop:

    POPF
    POPA
    MOV     AX, 1
    RET
    
checkExecutable.dat:              ; 実行可能な拡張子一覧
    &DB     "SYS"
    &DB     "COM"
    &DB     0

    ; AX...アドレス（セグメント）
    ; 戻り値 CF=0
callfile:
    PUSHA                               ; PUSH
    PUSH    DS
    PUSH    ES

    XOR     BX, BX                      ; 初期化
    MOV     CX, BX
    MOV     DX, BX
    MOV     SI, BX
    MOV     DI, BX

    MOV     DS, BX                      ; スタック状態を記録
    MOV     WORD[@addr_beforeCall_SP], SP
    MOV     WORD[@addr_beforeCall_SS], SS
    MOV     WORD[@addr_beforeCall_BP], BP
    MOV     SP, BX
    MOV     BP, BX

    MOV     DS, AX                      ; セグメントレジスタをCSと同じ場所に
    MOV     ES, AX
    MOV     SS, AX

    CALLF   AX                          ; far call

    XOR     BX, BX                      ; スタック状態を復帰
    MOV     DS, BX
    MOV     SP, WORD[@addr_beforeCall_SP]
    MOV     SS, WORD[@addr_beforeCall_SS]
    MOV     BP, WORD[@addr_beforeCall_BP]

    POP     ES                          ; POP
    POP     DS
    POPA

    CLC

    RET


    ; AH...乗数
    ; AL...基数
pow:
    CMP     AH, 0
    JE      pow_1:

    PUSH    BX
    PUSH    CX
    XOR     BX, BX
    MOV     BL, AH
    MOV     AH, 0
    MOV     DX, AX
    MOV     CX, 1

pow.loop:
    CMP     CX, BX
    JE      pow_fin:
    MUL     DX
    INC     CX
    JMP     pow.loop:

pow_1:
    MOV     DX, 1
    RET

pow_fin:
    POP     CX
    POP     BX
    MOV     DX, AX
    RET



; _/_/_/_/_/_/_/_/ DOS システム割込み _/_/_/_/_/_/_/_/

systemInternalInterrupt_21h:
    CMP     AH, 1
    JE      searchFile:                 ; ファイルを探す
    CMP     AH, 2
    JE      fileEntry2Addr:             ; ファイルのエントリからアドレスを計算する
    CMP     AH, 3
    JE      getFileInfo:                ; ファイル情報を取得
    CMP     AH, 4
    JE      fileEntry2Clst:             ; クラスタ番号を取得
    CMP     AH, 10h
    JE      printstrings:
    CMP     AH, 11h
    JE      printstring1:
    CMP     AH, 13h
    JE      clearscreen:
    CMP     AH, 20h
    JE      readfile:
    CMP     AH, 80h
    JE      converts:
    ;CMP     AH, 2Ah
    ;JE      readDate:
    ;CMP     AH, 2Ch
    ;JE      readTime:
    IRET

    ; AL...セット/リセット
    ; DX...編集するフラグ
editFlag:
    CMP     AL, 0
    JE      editFlag_Set:
    CMP     AL, 1
    JE      editFlag_del:
    RET

editFlag_Set:
    PUSH    AX                          ; フラグ編集
    PUSH    BX
    MOV     AX, SP
    ADD     AX, 10
    MOV     BX, [AX]
    OR      BX, DX
    MOV     [AX], BX
    POP     BX
    POP     AX
    RET

editFlag_del:
    PUSH    AX                          ; フラグ編集
    PUSH    BX
    MOV     AX, SP
    ADD     AX, 10
    MOV     BX, [AX]
    NOT     DX
    AND     BX, DX
    MOV     [AX], BX
    POP     BX
    POP     AX
    RET

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

    CALLF   WORD[@addr_keyboardDriver]                 ; 文字を小文字化

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

    CALLF   WORD[@addr_keyboardDriver]                 ; 文字を小文字化

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
    IRET

searchFile_filenameEqual:
    POP     SI
    POP     DS
    POP     DI
    POP     DX
    POP     BX
    POP     AX
    MOV     AH, 0
    IRET

fileEntry2Addr:
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

    MOV     BX, [DI]                    ; ファイルがあるクラスタの番号を読む
    MOV     AX, 2
    MUL     BX
    MOV     BX, 512                     ; クラスタ番号 * クラスタあたりのセクタ数 * セクタあたりのサイズ + 7C00h
    MUL     BX                          ; これでファイルの場所がわかる
    ADD     AX, 7C00h
    POP     DS
    POP     DI
    POP     BX
    IRET

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
    IRET

getFileInfo:
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

    CMP     BH, 1
    JE      getFileInfo_attr:           ; 属性
    CMP     BH, 2
    JE      getFileInfo_createTime:     ; 作成時刻
    CMP     BH, 3
    JE      getFileInfo_createDate:     ; 作成日付
    CMP     BH, 4
    JE      getFileInfo_accessDate:     ; アクセス日付
    CMP     BH, 5
    JE      getFileInfo_updateTime:     ; 更新時刻
    CMP     BH, 6
    JE      getFileInfo_updateDate:     ; 更新日付
    CMP     BH, 7
    JE      getFileInfo_clst:           ; クラスタ位置
    CMP     BH, 8
    JE      getFileInfo_filesize:       ; ファイルサイズ

    JMP     getFileInfo_ret:

getFileInfo_attr:
    ADD     DI, 0Bh
    MOV     AX, [DI]
    MOV     AH, 0
    JMP     getFileInfo_ret:

getFileInfo_createTime:
    ADD     DI, 0Ch
    MOV     AX, [DI]
    JMP     getFileInfo_ret:

getFileInfo_createDate:
    ADD     DI, 0Eh
    MOV     AX, [DI]
    JMP     getFileInfo_ret:

getFileInfo_accessDate:
    ADD     DI, 10h
    MOV     AX, [DI]
    JMP     getFileInfo_ret:

getFileInfo_updateTime:
    ADD     DI, 12h
    MOV     AX, [DI]
    JMP     getFileInfo_ret:

getFileInfo_updateDate:
    ADD     DI, 14h
    MOV     AX, [DI]
    JMP     getFileInfo_ret:

getFileInfo_clst:
    ADD     DI, 16h
    MOV     AX, [DI]
    JMP     getFileInfo_ret:

getFileInfo_filesize:
    ADD     DI, 18h
    MOV     AX, [DI]
    ADD     DI, 2
    MOV     DX, [DI]

getFileInfo_ret:
    POP     DS
    POP     DI
    IRET

printstrings:
    MOV     AH, 0Eh
    INT     10h
    IRET

printstring1:
    MOV     AH, 0Ah
    INT     10h
    IRET

clearscreen:
    MOV     AH, 20h
    INT     10h
    IRET


    ; SI...ファイル名
    ; ES:BX...格納先アドレス
    ; 戻り値 CF
    ;           =0...成功
    ;           =1...失敗　ファイルがありません
readfile:
    PUSH    BX

    MOV     AH, 1
    INT     21h
    OR      AH, AH
    JNZ     readfile.notfound:

    MOV     AH, 3                       ; ファイルサイズを取得
    MOV     BH, 8
    INT     21h
    MOV     BX, 512
    XOR     DX, DX
    DIV     BX

    PUSH    AX

    MOV     AH, 4                       ; ファイルのクラスタ番号を取得
    INT     21h
    XOR     DX, DX                      ; クラスタ番号からセクタ位置を取得
    MOV     BX, 2
    MUL     BX
    INC     AL
    MOV     CL, AL

    MOV     AH, 0                       ; ディスク初期化
    INT     13h

    POP     AX

    JC      halt:                        ; エラーだったらおわり

    MOV     AH, 2                       ; セクタ読み込み
    INC     AL                          ; 読み込むセクタ数
    MOV     CH, 0                       ; トラック番号 下位8bit
                                        ; トラック番号 上位2bit + セクタ番号 6bit (セクタ番号のみ1から、それ以外は0から)
    MOV     DH, 0                       ; ヘッド番号
    MOV     DL, 0                       ; ディスク番号
    POP     BX

    INT     13h

    MOV     AH, 0
    IRET

readfile.notfound:
    POP     BX
    MOV     AH, 1
    IRET

    ; AL...変換種類
    ; BL...変換する値（raw）
    ; BX...変換する値（asciiまたはbcd）
    ; DL...変換された値（raw）
    ; DX...変換された値（asciiまたはbcd）
    ; CX...変換された値（asciiまたはbcd）
converts:
    CMP     AL, 00h
    JE      converts_hex2bcd:
    CMP     AL, 01h
    JE      converts_bcd2hex:
    CMP     AL, 02h
    JE      converts_bcd2ascii:
    CMP     AL, 03h
    JE      converts_ascii2bcd:

    IRET

converts_hex2bcd:
    PUSH    CX
    XOR     CX, CX
    MOV     CL, 0

converts_hex2bcd.loop:
    MOV     BH, 0Ah                     ; 10で割ると、余りがBCDの1桁に相当する
    MOV     AX, BL
    DIV     BH
    MOV     CH, AH                      ; 余りをCHに移し、リピート時にpushする

    PUSH    CX

    CMP     AL, 0                       ; 商が0になったらおしまい
    JE      converts_hex2bcd.done:

    INC     CL                          ; CLは桁数 CHから戻すときに使う
    MOV     BL, AL

    JMP     converts_hex2bcd.loop:

converts_hex2bcd.done:
    XOR     DX, DX

converts_hex2bcd.done.loop:
    POP     CX
    XOR     AX, AX
    
    PUSH    DX                          ; 何桁目か計算し、CLにかける
    MOV     AH, CL
    MOV     AL, 10h
    CALL    pow:
    MOV     BX, DX

    XOR     DX, DX
    XOR     AX, AX
    MOV     AL, CH
    MUL     BX
    POP     DX
    ADD     DX, AX                      ; かけたもの同士で加算していくと、BCDコードになる

    CMP     CL, 0
    JNE     converts_hex2bcd.done.loop:

    POP     CX
    IRET

converts_bcd2hex:
converts_bcd2ascii:

    MOV     AX, BX
    AND     AL, 0Fh
    ADD     AL, 30h
    MOV     AH, 0
    PUSH    AX

    MOV     AX, BX
    AND     AL, F0h
    SHR     AL, 4
    ADD     AL, 30h
    MOV     AH, 0
    PUSH    AX

    MOV     AX, BX
    AND     AH, 0Fh
    ADD     AH, 30h

    XOR     CX, CX
    MOV     CL, AH

    POP     AX
    MOV     DH, AL

    POP     AX
    MOV     DL, AL

    IRET


converts_ascii2bcd:

    IRET



keyboardInterrupt:
    CMP     WORD[@addr_keyboardInterruptHandler], 0
    JE      keyboardInterrupt:

    CALL    WORD[@addr_keyboardInterruptHandler]

    IRET

keyboardInterrupt:
    IRET



notfound_start.dat:
    MOV     SI, start.dat:
    MOV     AH, 0Eh
    INT     10h
    MOV     SI, messageNotFound:
    INT     10h

    JMP     halt:

notfound_version.com:
    MOV     SI, version.com:
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
    &DW     @CRLF
    &DB     "Ready..."
    &DW     @CRLF
    &DB     ">"
    &DB     0

message.notfound_cmd:
    &DB     "Not found this file."
    &DB     0

message.notexecutable:
    &DB     "Not executable file."
    &DB     0

messageRet:
    &DW     @CRLF
    &DB     ">"
    &DB     0

messageCRLF:
    &DW     @CRLF
    &DB     0

messageNotFound:
    &DB     " is not found."
    &DW     @CRLF
    &DB     0

start.dat:
    &DB     "START.DAT"
    &DB     0

version.com:
    &DB     "VERSION.COM"
    &DB     0