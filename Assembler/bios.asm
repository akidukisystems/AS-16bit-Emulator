    
    #config codesize    auto
    #config filename    "bios.bin"
    #origin addr        0000h
    #enum   @CRLF       0A0Dh

    #enum   @setFlag    00h
    #enum   @clearFlag  01h
    #enum   @CF 0001h
    #enum   @PF 0002h
    #enum   @AF 0008h
    #enum   @ZF 0020h
    #enum   @SF 0040h
    #enum   @TF 0080h
    #enum   @IF 0100h
    #enum   @DF 0200h
    #enum   @OF 0400h

    #enum   @_date.yy_upper
    #enum   @_date.yy_lower
    #enum   @_date.MM
    #enum   @_date.dd

    #enum   @_time.hh
    #enum   @_time.mm
    #enum   @_time.ss
    
    #enum   @addr_ramSegment                CA00h   ; 変数領域のセグメント
    #enum   @addr_int_video_VRAMlastWrite   0000h   ; WORD 最後にVRAMに書いたアドレス

;   _/_/_/_/  Main Routine  _/_/_/_/
    
    CLI

    MOV     AX, C800h
    MOV     SS, AX
    MOV     SP, 2000h
    MOV     BP, SP
    XOR     SI, SI

    XOR     DS, DS                      ; 割り込みベクタテーブルの設定
    MOV     WORD[00h], int_diverr:      ; 除算エラー割り込み (00h)
    MOV     WORD[02h], F000h
    MOV     WORD[08h], int_nmi:         ; NMI割り込み (02h)
    MOV     WORD[0Ah], F000h
    MOV     WORD[18h], int_ud:          ; 無効オペコード割り込み (06h)
    MOV     WORD[1Ah], F000h
    MOV     WORD[40h], int_video:       ; ビデオ割り込み (10h)
    MOV     WORD[42h], F000h
    MOV     WORD[4Ch], int_disk:        ; ディスク割り込み (13h)
    MOV     WORD[4Eh], F000h
    MOV     WORD[58h], int_key:         ; キーボード割り込み (16h)
    MOV     WORD[5Ah], F000h
    MOV     WORD[68h], int_datetime:    ; 日付時刻割り込み（1Ah）
    MOV     WORD[6Ah], F000h
    MOV     WORD[70h], int_none:        ; ユーザタイマ割り込み (1Ch)
    MOV     WORD[72h], F000h
    MOV     WORD[104h], int_none:
    MOV     WORD[106h], F000h
    MOV     WORD[1C0h], int_none:       ; RTC割り込み (70h)
    MOV     WORD[1C2h], F000h

    MOV     AX, 41h
    OUT     85h, AX

    STI

    MOV     DS, F000h                   ; 文字列のあるセグメント
    MOV     SI, message1:               ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    MOV     AH, 02h
    INT     1Ah
    DBG

    MOV     AH, 04h
    INT     1Ah
    DBG

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h

    MOV     CX, 100                     ; 100*10ms待つ

waitBiosMenu_wait:
    MOV     AX, 10                      ; 10ms待つ
    OUT     F0h, AX                     ; ウェイト
    DEC     CX                          ; カウンタをデクリメントして、0ならブート処理
    JZ      waitBiosMenu_timeout:

    IN      AX, 80h                     ; キーが押されたか確認
    CMP     AX, 0                       ; 0（押されていない）なら戻る
    JE      waitBiosMenu_wait:

    IN      AX, 81h                     ; 押されたならキーコード取得
    PUSH    AX
    XOR     AX, AX
    OUT     8Fh, AX
    POP     AX
    CMP     AX, 123                     ; F12キー（123）ならBIOSセットアップ画面を出す
    JNE     waitBiosMenu_wait:
    JMP     BiosMenu_Entry:

waitBiosMenu_timeout:
    MOV     AH, 6                       ; キー入力をOFF
    MOV     AL, 1
    MOV     BH, 0
    INT     16h

    XOR     AX, AX

    MOV     AH, 0                       ; ディスク初期化
    INT     13h

    JC      fin:                        ; エラーだったらおわり

    MOV     AH, 2                       ; セクタ読み込み
    MOV     AL, 1                       ; 読み込むセクタ数
    MOV     CH, 0                       ; トラック番号 下位8bit
    MOV     CL, 1                       ; トラック番号 上位2bit + セクタ番号 6bit (セクタ番号のみ1から、それ以外は0から)
    MOV     DH, 0                       ; ヘッド番号
    MOV     DL, 0                       ; ディスク番号
    MOV     BX, 07C0h                   ; 格納先アドレス(セグメント)
    MOV     ES, BX
    MOV     BX, 0                       ; 格納先アドレス(オフセット)
    INT     13h

    JC      fin:                        ; エラーだったらおわり

    XOR     AX, AX
    MOV     DS, AX
    MOV     BX, WORD[7DFEh]             ; マジックコードを確認
    CMP     BX, AA55h
    JNE     fin:                        ; ブータブルでなかったらおわり


    XOR     AX, AX                      ; 0000:7C00 にジャンプ
    MOV     ES, AX    

    JF      7C00h

    MOV     DS, F000h                   ; 文字列のあるセグメント
    MOV     SI, message_osnotfound:     ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    JMP     fin:

;   _/_/_/_/  Functions  _/_/_/_/

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

    ; AH...変換種類
    ; BL...変換する値（raw）
    ; BX...変換する値（asciiまたはbcd）
    ; DL...変換された値（raw）
    ; DX...変換された値（asciiまたはbcd）
converts:
    CMP     AH, 00h
    JE      converts_hex2bcd:
    CMP     AH, 01h
    JE      converts_bcd2hex:
    CMP     AH, 02h
    JE      converts_bcd2ascii:
    CMP     AH, 03h
    JE      converts_ascii2bcd:

    RET

converts_hex2bcd:
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

    RET


converts_ascii2bcd:

    RET

;   _/_/_/_/  BIOS Menu  _/_/_/_/

BiosMenu_Entry:
    MOV     AH, 20h                     ; 画面クリア
    INT     10h                         ; ビデオ割り込み

    MOV     DS, F000h                   ; 文字列のあるセグメント
    MOV     SI, message_BiosMenu:       ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    MOV     AH, 6                       ; キー入力をON
    MOV     AL, 1
    MOV     BH, 1
    INT     16h

BiosMenu_Keywait:

    MOV     AX, 100                     ; 100ms待つ
    OUT     F0h, AX

    MOV     AX, 0                       ; 画面リフレッシュ無効
    OUT     30h, AX

    MOV     AH, 04h                     ; 時刻取得
    INT     1Ah

    PUSH    DX
    PUSH    CX

    XOR     BX, BX                      ; BCD値で年月日が渡されるので、ASCIIに変換
    MOV     BL, CH                      ; CH（年上2桁）をASCIIに
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h

    POP     CX

    XOR     BX, BX                      ; CL(年下2桁)
    MOV     BL, CL
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h

    MOV     AL, 2Fh                     ; スラッシュを表示"/"
    MOV     AH, 0Ah
    INT     10h

    POP     DX
    PUSH    DX

    XOR     BX, BX                      ; DH（月）
    MOV     BL, DH
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h

    MOV     AL, 2Fh                     ; "/"
    MOV     AH, 0Ah
    INT     10h

    POP     DX

    XOR     BX, BX                      ; DL（日）
    MOV     BL, DL
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h

    MOV     AL, 20h                     ; " "
    MOV     AH, 0Ah
    INT     10h

    MOV     AH, 02h                     ; 時刻を取得
    INT     1Ah

    PUSH    DX
    PUSH    CX

    XOR     BX, BX                      ; CH（時）
    MOV     BL, CH
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h

    MOV     AL, 3Ah                     ; ":"
    MOV     AH, 0Ah
    INT     10h

    POP     CX

    XOR     BX, BX                      ; CL（分）
    MOV     BL, CL
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h

    MOV     AL, 3Ah                     ; ":"
    MOV     AH, 0Ah
    INT     10h

    POP     DX

    XOR     BX, BX                      ; DH（秒）
    MOV     BL, DH
    MOV     AH, 02h
    CALL    converts:

    MOV     AL, DH                      ; 1桁目を出力
    MOV     AH, 0Ah
    INT     10h
    MOV     AL, DL                      ; 2桁目を出力
    MOV     AH, 0Ah
    INT     10h
                                        ; 画面更新時に同じ位置に日付時刻を表示するため、カーソル位置をもとに戻す
    MOV     AH, 03h                     ; カーソル位置を取得
    INT     10h
    SUB     BX, 13h                     ; BXにカーソル位置が格納されるので、13hを引く（日付時刻の表示）
    MOV     AH, 02h                     ; カーソル位置を設定
    INT     10h

    MOV     AX, 1                       ; 画面更新を開始
    OUT     30h, AX

    IN      AX, 80h                     ; キーが押されたか確認
    CMP     AX, 0                       ; 0（押されていない）なら戻る
    
    JE      BiosMenu_Keywait:

    IN      AX, 81h                     ; 押されたならキーコード取得
    PUSH    AX
    XOR     AX, AX
    OUT     8Fh, AX
    POP     AX
    CMP     AX, 27                      ; Escキー（27）ならリセット
    JNE     BiosMenu_Keywait:
    MOV     AX, 1                       
    OUT     FFh, AX

fin:
    HLT                                 ; CPUを停止
    JMP     fin:

;   _/_/_/_/  Data  _/_/_/_/

message1:
    &DB "AkidukiSystems 16bit Emulator  Version 0.11 Debug"
    &DW @CRLF
    &DB "AkidukiSystems BIOS Version 0.3"
    &DW @CRLF
    &DB "Press [F12] to Setup Utility"
    &DW @CRLF
    &DB 0

message_osnotfound:
    &DB "Operation System is not found."
    &DW @CRLF
    &DB 0

message_BiosMenu:
    &DB "AkidukiSystems BIOS Setup Utility"
    &DW @CRLF
    &DW @CRLF
    &DB "BIOS Version: 0.3"
    &DW @CRLF
    &DB "BIOS Date: "
    &DW @_date.yy_upper
    &DW @_date.yy_lower
    &DB "/"
    &DW @_date.MM
    &DB "/"
    &DW @_date.dd
    &DB " "
    &DW @_time.hh
    &DB ":"
    &DW @_time.mm
    &DB ":"
    &DW @_time.ss
    &DW @CRLF
    &DB "Vendor: AkidukiSystems"
    &DW @CRLF
    &DB "Current DateTime: "
    &DB 0

;   _/_/_/_/  Interrupt Routine  _/_/_/_/

int_diverr:                             ; 除算エラー割り込み (00h)
    DBG
    IRET

int_nmi:                                ; NMI割り込み (02h)
    DBG
    CLI
    JMP     int_die:

int_ud:                                 ; 無効オペコード割り込み (06h)
    DBG
    CLI
    JMP     int_die:

int_die:
    HLT
    JMP     int_die:
    

int_video:                              ; ビデオ割り込み (10h)
    CMP     AH, 0Ah                     ; 文字書き込み
    JE      int_video_charput:
    CMP     AH, 0Eh                     ; テレタイプモード
    JE      int_video_teretype:
    CMP     AH, 20h                     ; 画面クリア
    JE      int_video_clear:
    CMP     AH, 02h                     ; 画面クリア
    JE      int_video_setcursor:
    CMP     AH, 03h                     ; 画面クリア
    JE      int_video_getcursor:

    IRET

int_video_setcursor:
    PUSH    DS
    MOV     DS, @addr_ramSegment        ; 最後にVRAMに書いたアドレスを見つける
    MOV     WORD[@addr_int_video_VRAMlastWrite], BX
    POP     DS

    IRET

int_video_getcursor:
    PUSH    DS
    MOV     DS, @addr_ramSegment        ; 最後にVRAMに書いたアドレスを見つける
    MOV     BX, WORD[@addr_int_video_VRAMlastWrite]
    POP     DS

    IRET

int_video_charput:
    PUSH    BX
    PUSH    DX
    PUSH    DS

    MOV     DS, @addr_ramSegment        ; 最後にVRAMに書いたアドレスを見つける
    MOV     BX, WORD[@addr_int_video_VRAMlastWrite]

    CMP     AL, 7Fh
    JE      int_video_charput_del:

    XOR     DX, DX
    MOV     DL, AL
    MOV     DS, C6D4h                   ; VRAMに文字書き込み
    MOV     [BX], DX
    INC     BX

int_video_charput_del_ret:
    MOV     DS, @addr_ramSegment        ; 最後にVRAMに書いたアドレスを書き込む
    MOV     WORD[@addr_int_video_VRAMlastWrite], BX

    POP     DS
    POP     DX
    POP     BX

    IRET

int_video_charput_del:
    CMP     BX, 0
    JE      int_video_charput_del_ret:
    DEC     BX
    MOV     DS, C6D4h
    XOR     DX, DX
    MOV     [BX], DX
    JMP     int_video_charput_del_ret:

int_video_teretype:
    PUSH    AX
    PUSH    BX
    PUSH    DX
    PUSH    DS
    PUSH    SI

    MOV     DX, DS                      ; 文字列アドレスのあるセグメントレジスタをDXに退避

    MOV     DS, @addr_ramSegment        ; 最後にVRAMに書いたアドレスを見つける
    MOV     BX, WORD[@addr_int_video_VRAMlastWrite]
    MOV     DS, DX                      ; データセグメントを元に戻す

int_video_teretype.loop:
    MOV     AX, [SI]                    ; [DS:SI] にある文字コードを読む
    MOV     AH, 0                       ; AHを終端文字にする
    MOV     DS, C6D4h                   ; VRAM(C6D4:0000) にセグメントを設定
    MOV     [BX], AX                    ; VRAM に文字コードを書く
    MOV     DS, DX                      ; セグメントレジスタを文字コードのある場所に戻す
    CMP     AL, 0                       ; 終了コードがあったらおしまい
    JZ      int_video_teretype.fin:
    INC     BX                          ; 次にポインタを進める
    INC     SI
    CMP     BX, 12C0h
    JL      int_video_teretype.loop:    ; VRAMをはみ出しそうならやめる

int_video_teretype.fin:
    MOV     DS, @addr_ramSegment        ; 一番最後に書いたアドレスを格納
    MOV     WORD[@addr_int_video_VRAMlastWrite], BX
    MOV     DS, DX                      ; データセグメントを元に戻す

    POP     SI
    POP     DS
    POP     DX
    POP     BX
    POP     AX

    IRET

int_video_clear:
    PUSH    BX
    PUSH    DS

    MOV     DS, C6D4h                   ; VRAMを選択
    XOR     BX, BX

int_video_clear.loop:
    CMP     [BX], 0                     ; 終了コードか確認
    JE      int_video_clear.fin:

    MOV     [BX], 0                     ; 終了コードでないなら、終了コードに置き換えして次の文字へ
    INC     BX
    JMP     int_video_clear.loop:

int_video_clear.fin:
    MOV     DS, @addr_ramSegment        ; 最後に書いたアドレスを初期化
    MOV     WORD[@addr_int_video_VRAMlastWrite], 0

    POP     DS
    POP     BX

    IRET



int_disk:
    CMP     AH, 0                       ; 初期化
    JE      int_disk_init:
    CMP     AH, 2                       ; 読み込み
    JE      int_disk_read:
    CMP     AH, 3                       ; 書き込み
    JE      int_disk_write:


    IRET

int_disk_init:
    PUSH    DX

    MOV     DX, 1                       ; ディスクを初期化
    OUT     28h, DX
    IN      DX, 20h                     ; エラー確認
    MOV     DL, AH

    POP     DX

    CMP     AH, 0
    JNZ     int_disk_init_err:          ; エラーあったらおわり

    MOV     AL, @clearFlag              ; CFクリア
    MOV     DX, @CF
    CALL    editFlag:

    IRET

int_disk_init_err:
    MOV     AL, @setFlag                ; CFセット
    MOV     DX, @CF
    CALL    editFlag:

    IRET

int_disk_read:
    PUSH    BX

    XOR     BX, BX
    MOV     BX, DL
    OUT     26h, BX                     ; ヘッド番号2bit
    MOV     BX, DH
    OUT     27h, BX                     ; ディスク番号2bit

    MOV     BX, 5
    OUT     28h, BX                     ; ディスク選択
    IN      BX, 20h                     ; エラー確認
    JNZ     int_disk_read_diskerr:

    POP     BX

int_disk_read_loop:
    PUSH    DX

    OUT     22h, BX                     ; 書き込み先オフセット
    MOV     DX, ES
    OUT     23h, DX                     ; 書き込み先セグメント

    XOR     DX, DX
    MOV     DX, CL
    OUT     25h, DX                     ; トラック上位2bit, セクタ6bit ttssssss
    MOV     DX, CH
    OUT     24h, DX                     ; トラック下位8bit tttttttt

    MOV     DX, 3
    OUT     28h, DX                     ; 読み込み
    IN      20h, DX                     ; エラー確認
    JNZ     int_disk_read_readerr:

    POP     DX

    DEC     AL
    CMP     AL, 0
    JZ      int_disk_read_fin:
    INC     CL
    ADD     BX, 512
    JMP     int_disk_read_loop:

int_disk_read_diskerr:
    POP     BX
    MOV     AL, @setFlag                ; CFセット
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_disk_read_readerr:
    POP     DX
    MOV     AL, @setFlag                ; CFセット
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_disk_read_fin:
    MOV     AL, @clearFlag              ; CFクリア
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_disk_write:
    PUSH    BX

    XOR     BX, BX
    MOV     BX, DL
    OUT     26h, BX                     ; ヘッド番号2bit
    MOV     BX, DH
    OUT     27h, BX                     ; ディスク番号2bit

    MOV     BX, 5
    OUT     28h, BX                     ; ディスク選択
    IN      BX, 20h                     ; エラー確認
    JNZ     int_disk_write_diskerr:

    POP     BX

int_disk_write_loop:
    PUSH    DX

    OUT     22h, BX                     ; 読み込み先オフセット
    MOV     DX, ES
    OUT     23h, DX                     ; 読み込み先セグメント

    XOR     DX, DX
    MOV     DX, CL
    OUT     25h, DX                     ; トラック上位2bit, セクタ6bit ttssssss
    MOV     DX, CH
    OUT     24h, DX                     ; トラック下位8bit tttttttt

    MOV     DX, 4
    OUT     28h, DX                     ; 読み込み
    IN      20h, DX                     ; エラー確認
    JNZ     int_disk_write_writeerr:

    POP     DX

    DEC     AL
    CMP     AL, 0
    JZ      int_disk_write_fin:
    INC     CL
    ADD     BX, 512
    JMP     int_disk_write_loop:

int_disk_write_diskerr:
    POP     BX
    MOV     AL, @setFlag                ; CFセット
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_disk_write_writeerr:
    POP     DX
    MOV     AL, @setFlag                ; CFセット
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_disk_write_fin:
    MOV     DX, 8
    OUT     28h, DX
    MOV     AL, @clearFlag              ; CFクリア
    MOV     DX, @CF
    CALL    editFlag:
    IRET



int_key:
    CMP     AH, 00h
    JE      int_key_ReadInput:
    CMP     AH, 01h
    JE      int_key_ReadStatus:
    ;CMP     AH, 02h
    ;JE      int_key_ReadShiftFlag:
    ;CMP     AH, 05h
    ;JE      int_key_WriteData:
    CMP     AH, 06h
    JE      int_key_ChangeGetKey:

    IRET

int_key_ReadStatus:
    IN      AX, 80h                     ; キーが押されたか確認
    CMP     AX, 0                       ; 0（押されていない）
    JE      int_key_ReadStatus_NoData:

    MOV     AL, 1
    MOV     DX, 0020h
    CALL    editFlag:

    PUSH    AX
    AND     AL, 20h
    CMP     AL, 0
    POP     AX
    JE      int_key_ReadStatus_DownScale:

    IN      AX, 81h

    CMP     AL, 106
    JGE     int_key_ReadStatus_NotASCII?x:

    CMP     AL, 8
    JGE     int_key_ReadStatus_NotASCII?a:

int_key_ReadStatus_NotASCII?a_ret:
    CMP     AL, 27
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 33
    JGE     int_key_ReadStatus_NotASCII?b:

int_key_ReadStatus_NotASCII?b_ret:
    CMP     AL, 45
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 46
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 91
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 92
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 93
    JE      int_key_ReadStatus_NotASCII:

    CMP     AL, 112
    JGE     int_key_ReadStatus_NotASCII?c:
int_key_ReadStatus_NotASCII?c_ret:

    CMP     AL, 144
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 145
    JE      int_key_ReadStatus_NotASCII:
    CMP     AL, 229
    JE      int_key_ReadStatus_NotASCII:

    CMP     AL, BAh
    JE      int_key_ReadStatus_DownScale_JP?_ret:
    CMP     AL, BBh
    JE      int_key_ReadStatus_DownScale_JP?_ret:

    CMP     AL, 31h
    JGE     int_key_ReadStatus_UpScale_Num?:

int_key_ReadStatus_UpScale_Num?_ret:
    CMP     AL, 41h
    JGE     int_key_ReadStatus_UpScale_Alp?:

int_key_ReadStatus_UpScale_Alp?_ret:
    CMP     AL, 30h
    JE      int_key_ReadStatus_Raw:
    CMP     AL, 20h
    JE      int_key_ReadStatus_Raw:

    CMP     AL, E2h
    JE      int_key_ReadStatus_UpScale_Back:

    CMP     AL, C0h
    JE      int_key_ReadStatus_UpScale_JP:
    CMP     AL, DBh
    JGE     int_key_ReadStatus_UpScale_JP?:
int_key_ReadStatus_UpScale_JP?_ret:

    MOV     AH, AL
    SUB     AL, 80h
    IRET

int_key_ReadStatus_UpScale_Num?:
    CMP     AL, 39h
    JG      int_key_ReadStatus_UpScale_Num?_ret:

    MOV     AH, AL
    SUB     AL, 10h
    IRET

int_key_ReadStatus_UpScale_Alp?:
    CMP     AL, 5Ah
    JG      int_key_ReadStatus_UpScale_Alp?_ret:

    MOV     AH, AL
    IRET

int_key_ReadStatus_UpScale_JP?:
    CMP     AL, DEh
    JG      int_key_ReadStatus_UpScale_JP?_ret:

int_key_ReadStatus_UpScale_JP:
    MOV     AH, AL
    SUB     AL, 60h
    IRET

int_key_ReadStatus_UpScale_Back:
    MOV     AH, AL
    MOV     AL, 5Fh
    IRET



int_key_ReadStatus_DownScale:
    IN      AX, 81h

    CMP     AL, 16
    JE      int_key_ReadStatus_NoData:

    CMP     AL, BAh
    JE      int_key_ReadStatus_DownScale_JP:
    CMP     AL, BBh
    JE      int_key_ReadStatus_DownScale_JP:

    CMP     AL, 31h
    JGE     int_key_ReadStatus_DownScale_Num?:

int_key_ReadStatus_DownScale_Num?_ret:
    CMP     AL, 41h
    JGE     int_key_ReadStatus_DownScale_Alp?:

int_key_ReadStatus_DownScale_Alp?_ret:
    CMP     AL, 30h
    JE      int_key_ReadStatus_Raw:
    CMP     AL, 20h
    JE      int_key_ReadStatus_Raw:

    CMP     AL, E2h
    JE      int_key_ReadStatus_DownScale_Back:

    CMP     AL, C0h
    JE      int_key_ReadStatus_DownScale_JP:
    CMP     AL, DBh
    JGE     int_key_ReadStatus_DownScale_JP?:

int_key_ReadStatus_DownScale_JP?_ret:

    MOV     AH, AL
    SUB     AL, 90h
    IRET

int_key_ReadStatus_DownScale_Num?:
    CMP     AL, 39h
    JG      int_key_ReadStatus_DownScale_Num?_ret:

    MOV     AH, AL
    IRET

int_key_ReadStatus_DownScale_Alp?:
    CMP     AL, 5Ah
    JG      int_key_ReadStatus_DownScale_Alp?_ret:

    MOV     AH, AL
    ADD     AL, 20h
    IRET

int_key_ReadStatus_DownScale_JP?:
    CMP     AL, DEh
    JG      int_key_ReadStatus_DownScale_JP?_ret:

int_key_ReadStatus_DownScale_JP:
    MOV     AH, AL
    SUB     AL, 80h
    IRET

int_key_ReadStatus_DownScale_Back:
    MOV     AH, AL
    MOV     AL, 5Ch
    IRET

int_key_ReadStatus_Raw:
    MOV     AH, AL
    IRET

int_key_ReadStatus_NoData:
    MOV     AL, @setFlag
    MOV     DX, @ZF
    CALL    editFlag:
    IRET

int_key_ReadStatus_NotASCII?a:
    CMP     AL, 19
    JG      int_key_ReadStatus_NotASCII?a_ret:
    JMP     int_key_ReadStatus_NotASCII:

int_key_ReadStatus_NotASCII?b:
    CMP     AL, 40
    JG      int_key_ReadStatus_NotASCII?b_ret:
    JMP     int_key_ReadStatus_NotASCII:

int_key_ReadStatus_NotASCII?c:
    CMP     AL, 123
    JG      int_key_ReadStatus_NotASCII?c_ret:
    JMP     int_key_ReadStatus_NotASCII:

int_key_ReadStatus_NotASCII?x:
    MOV     AH, AL
    SUB     AL, 64
    IRET

int_key_ReadStatus_NotASCII:
    MOV     AL, 0
    IRET



int_key_ReadInput:
    IN      AX, 80h                     ; キーが押されたか確認
    CMP     AL, 0                       ; 0（押されていない）
    JE      int_key_ReadInput:

    PUSH    AX
    AND     AL, 20h
    CMP     AL, 0
    POP     AX
    JE      int_key_ReadInput_DownScale:

    IN      AX, 81h

    PUSH    AX
    XOR     AX, AX
    OUT     8Fh, AX
    POP     AX

    CMP     AL, 16
    JE      int_key_ReadInput:

    CMP     AL, BAh
    JE      int_key_ReadInput_DownScale_JP?_ret:
    CMP     AL, BBh
    JE      int_key_ReadInput_DownScale_JP?_ret:

    CMP     AL, 31h
    JGE     int_key_ReadInput_UpScale_Num?:

int_key_ReadInput_UpScale_Num?_ret:
    CMP     AL, 41h
    JGE     int_key_ReadInput_UpScale_Alp?:

int_key_ReadInput_UpScale_Alp?_ret:
    CMP     AL, 30h
    JE      int_key_ReadInput_Raw:
    CMP     AL, 20h
    JE      int_key_ReadInput_Raw:

    CMP     AL, E2h
    JE      int_key_ReadInput_UpScale_Back:

    CMP     AL, C0h
    JE      int_key_ReadInput_UpScale_JP:
    CMP     AL, DBh
    JGE     int_key_ReadInput_UpScale_JP?:

int_key_ReadInput_UpScale_JP?_ret:

    MOV     AH, AL
    SUB     AL, 80h
    IRET

int_key_ReadInput_UpScale_Num?:
    CMP     AL, 39h
    JG      int_key_ReadInput_UpScale_Num?_ret:

    MOV     AH, AL
    SUB     AL, 10h
    IRET

int_key_ReadInput_UpScale_Alp?:
    CMP     AL, 5Ah
    JG      int_key_ReadInput_UpScale_Alp?_ret:

    MOV     AH, AL

    IRET

int_key_ReadInput_UpScale_JP?:
    CMP     AL, DEh
    JG      int_key_ReadInput_UpScale_JP?_ret:

int_key_ReadInput_UpScale_JP:
    MOV     AH, AL
    SUB     AL, 60h
    IRET

int_key_ReadInput_UpScale_Back:
    MOV     AH, AL
    MOV     AL, 5Fh
    IRET



int_key_ReadInput_DownScale:
    IN      AX, 81h

    PUSH    AX
    XOR     AX, AX
    OUT     8Fh, AX
    POP     AX

    CMP     AL, 16
    JE      int_key_ReadInput:

    CMP     AL, BAh
    JE      int_key_ReadInput_DownScale_JP:
    CMP     AL, BBh
    JE      int_key_ReadInput_DownScale_JP:

    CMP     AL, 31h
    JGE     int_key_ReadInput_DownScale_Num?:

int_key_ReadInput_DownScale_Num?_ret:
    CMP     AL, 41h
    JGE     int_key_ReadInput_DownScale_Alp?:

int_key_ReadInput_DownScale_Alp?_ret:
    CMP     AL, 30h
    JE      int_key_ReadInput_Raw:
    CMP     AL, 20h
    JE      int_key_ReadInput_Raw:

    CMP     AL, E2h
    JE      int_key_ReadInput_DownScale_Back:

    CMP     AL, C0h
    JE      int_key_ReadInput_DownScale_JP:
    CMP     AL, DBh
    JGE     int_key_ReadInput_DownScale_JP?:

int_key_ReadInput_DownScale_JP?_ret:

    MOV     AH, AL
    SUB     AL, 90h
    IRET

int_key_ReadInput_DownScale_Num?:
    CMP     AL, 39h
    JG      int_key_ReadInput_DownScale_Num?_ret:

    MOV     AH, AL
    IRET

int_key_ReadInput_DownScale_Alp?:
    CMP     AL, 5Ah
    JG      int_key_ReadInput_DownScale_Alp?_ret:

    MOV     AH, AL
    ADD     AL, 20h
    IRET

int_key_ReadInput_DownScale_JP?:
    CMP     AL, DEh
    JG      int_key_ReadInput_DownScale_JP?_ret:

int_key_ReadInput_DownScale_JP:
    MOV     AH, AL
    SUB     AL, 80h
    IRET

int_key_ReadInput_DownScale_Back:
    MOV     AH, AL
    MOV     AL, 5Ch
    IRET

int_key_ReadInput_Raw:
    MOV     AH, AL
    IRET

int_key_ChangeGetKey:
    CMP     AL, 0
    JE      int_key_ChangeGetKey.in:
    CMP     AL, 1
    JE      int_key_ChangeGetKey.out:
    IRET

int_key_ChangeGetKey.in:
    IN      AX, 8Eh
    TEST    AX, 1
    JNZ     int_key_ChangeGetKey.in_Enable:
    MOV     AL, @clearFlag
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_key_ChangeGetKey.in_Enable:
    MOV     AL, @setFlag
    MOV     DX, @CF
    CALL    editFlag:
    IRET

int_key_ChangeGetKey.out:
    CMP     BH, 0
    JE      int_key_ChangeGetKey.out_clear:
    CMP     BH, 1
    JE      int_key_ChangeGetKey.out_set:
    IRET

int_key_ChangeGetKey.out_clear:
    IN      AX, 8Eh
    AND     AX, FFFEh
    OUT     8Eh, AX
    IRET

int_key_ChangeGetKey.out_set:
    IN      AX, 8Eh
    OR      AX, 1
    OUT     8Eh, AX
    IRET


int_datetime:
    CMP     AH, 02h
    JE      int_datetime_readTime:
    CMP     AH, 04h
    JE      int_datetime_readDate:
    IRET

int_datetime_readTime:
    MOV     AX, 04h                 ; 時
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:
    PUSH    DX

    MOV     AX, 05h                 ; 分
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:
    PUSH    DX

    MOV     AX, 06h                 ; 秒
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:
    MOV     AX, DX
    MOV     DH, AL

    POP     AX                      ; 分
    MOV     CL, AL

    POP     AX                      ; 時
    MOV     CH, AL

    MOV     DL, 0

    PUSH    DX
    MOV     AL, @clearFlag
    MOV     DX, @CF
    CALL    editFlag:
    POP     DX

    IRET

int_datetime_readDate:
    MOV     AX, 0Ah                 ; 世紀
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:
    PUSH    DX

    MOV     AX, 00h                 ; 年
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:

    MOV     BX, DX

    POP     DX                      ; DX = 世紀, BX = 年

    CMP     BX, 00h                 ; 年=00hのとき以外に、世紀から1を引くことで、西暦年上2桁を求められる
    JNE     int_datetime_readDate.dc:

int_datetime_readDate.dc.ret:
    PUSH    DX
    PUSH    BX

    MOV     AX, 01h                 ; 月
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:
    PUSH    DX

    MOV     AX, 03h                 ; 日
    OUT     90h, AX
    MOV     AX, 01h
    OUT     91h, AX
    IN      AX, 92h
    XOR     BX, BX
    MOV     BL, AL
    MOV     AH, 0
    CALL    converts:
    MOV     AX, DX
    
    MOV     DL, AL
    POP     AX
    MOV     DH, AL

    POP     AX
    MOV     CL, AL

    POP     AX
    MOV     CH, AL

    MOV     AH, 0

    PUSH    DX
    MOV     AL, @clearFlag
    MOV     DX, @CF
    CALL    editFlag:
    POP     DX

    IRET
    

int_datetime_readDate.dc:
    DEC     DX
    JMP     int_datetime_readDate.dc.ret:


int_none:
    IRET                                ; 割り込みだけど特に何もしない