
    #config codesize    auto
    #config filename    "dir.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh
    #num    @filecnt    0400h

    MOV     WORD[@filecnt], 0
    
    XOR     CX, CX          ; データセグメントをいじるので0にする
    MOV     DS, CX
    MOV     DI, CX

fileread:
    MOV     AX, CX          ; ファイルエントリ番号 * 20h + 8000h で、ファイルエントリの先頭（ファイル名の先頭）を計算
    MOV     BX, 20h         ; CXはファイルエントリ番号
    MUL     BX
    ADD     AX, 8000h
    MOV     BX, AX

    MOV     DX, [BX]        ; ファイル名先頭読み込み BXはポインタ
    CMP     DL, E5h
    JE      deletedfile:    ; 削除済エントリ
    XOR     DX, DX

    MOV     DS, ES
    PUSH    CX
    MOV     CX, WORD[@filecnt]

    PUSH    AX
    PUSH    BX
    MOV     AX, CX          ; 6ファイルごとに改行する
    CMP     AX, 0
    JE      fileread.crlf_ret:
    MOV     BX, 6
    DIV     BX
    CMP     DX, 0
    JE      fileread.crlf:

fileread.crlf_ret:
    INC     WORD[@filecnt]
    XOR     BX, BX
    MOV     DS, BX

    POP     BX
    POP     AX
    POP     CX

    PUSH    CX              ; CXはこの後使うのでpush
    XOR     CX, CX
    
filenameloop:
    MOV     DX, [BX]        ; ファイル名読み込み BXはポインタ
    CMP     DL, 20h
    JE      kakutyo_a:      ; 空白なら別処理
    CMP     DL, 0
    JE      owari2:         ; 空ならおわり
    MOV     AL, DL
    MOV     AH, 11h
    INT     21h             ; 取得した文字を表示
    INC     BX              ; 次の文字へ
    INC     CX
    CMP     CX, 8           ; 8文字進んだら拡張子へ
    JE      kakutyo:
    JMP     filenameloop:

kakutyo_a:
    INC     CX              ; 空白だったので ファイル名のポインタを拡張子まで移動
    INC     DI              ; 表示がずれるので移動した量を記録
    INC     BX
    CMP     CX, 8
    JNE     kakutyo_a:

kakutyo:
    MOV     AL, 2Eh         ; ドットを表示
    MOV     AH, 11h
    INT     21h

kakutyoloop:
    MOV     DX, [BX]        ; 拡張子の文字取得
    CMP     DL, 20h         ; 空白なら別処理
    JE      umeru:
    MOV     AL, DL
    MOV     AH, 11h         ; 表示する
    INT     21h
    INC     BX              ; 次の文字
    INC     CX
    CMP     CX, 11
    JE      owari:          ; 拡張子もおわったらおしまい
    JMP     kakutyoloop:

umeru:
    INC     CX              ; 拡張子が2文字以下なら空白で埋める
    MOV     AL, 20h
    MOV     AH, 11h
    INT     21h
    CMP     CX, 11
    JNE     umeru:

deletedfile:
    INC     CX
    CMP     CX, 16          ; 次のファイルエントリへ、16個見たらおわり
    JNE     fileread:
    MOV     DS, ES             ; リターン
    MOV     SI, message1:
    MOV     AH, 10h
    INT     21h
    FRET

owari:
    CMP     DI, 0           ; ファイル名が8文字より少なかったら、表示ずれを防ぐため埋める
    JNE     umerukakutyo:
    MOV     AL, 20h         ; ファイル名がくっつかないようスペースを入れる
    MOV     AH, 11h
    INT     21h

    POP     CX              ; CXを戻す このCXはファイルエントリ番号
    INC     CX
    CMP     CX, 16          ; 次のファイルエントリへ、16個見たらおわり
    JNE     fileread:
    MOV     DS, ES             ; リターン
    MOV     SI, message1:
    MOV     AH, 10h
    INT     21h
    FRET

owari2:
    POP     CX              ; リターン
    MOV     DS, ES
    FRET

umerukakutyo:
    DEC     DI              ; ファイル名の移動した量の分埋める
    MOV     AL, 20h
    MOV     AH, 11h
    INT     21h
    CMP     DI, 0
    JNE     umerukakutyo:
    JMP     owari:

fileread.crlf:
DBG
    MOV     SI, message1:
    DBG
    MOV     AH, 10h
    DBG
    INT     21h
    JMP     fileread.crlf_ret:

message1:
    &DW     @CRLF
    &DB     0