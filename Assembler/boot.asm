
    #config codesize 512
    #config filename "boot.bin"
    #origin addr 7C00h
    #enum   @CRLF       0A0Dh

    JMP     entry:
    NOP

    &DB     "AS16EMLT"
BPB_SectorSize:
    &DW     512
BPB_SectorPerTruck:
    &DW     18
BPB_TruckPerCyls:
    &DW     80
BPB_Heads:
    &DB     2
BPB_SectorPerCluster:
    &DB     2
BPB_Sectors:
    &DW     2880
BPB_Label:
    &DB     "NO NAME     "
BPB_FATs:
    &DB     2
BPB_FATpos:
    &DB     8
BPB_FATsize:
    &DW     1
    &DB     "AFAT16  "
    &RESBSF 30h

entry:
    XOR     AX, AX
    MOV     SS, AX
    MOV     SP, 7C00h
    MOV     BP, SP
    MOV     DS, AX
    MOV     ES, AX

    MOV     SI, message_booting:        ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    MOV     AH, 0                       ; ディスク初期化
    INT     13h

    JC      fin:                        ; エラーだったらおわり

    MOV     AX, 0207h                   ; セクタ読み込み
                                        ; 読み込むセクタ数
    MOV     CX, 0002h                   ; トラック番号 下位8bit
                                        ; トラック番号 上位2bit + セクタ番号 6bit (セクタ番号のみ1から、それ以外は0から)
    MOV     DX, 0                       ; ヘッド番号
                                        ; ディスク番号
    MOV     BX, 7E00h                   ; 格納先アドレス(オフセット)
    INT     13h

    JNC     boot:                       ; エラーなかったらブート

    MOV     SI, message_err:            ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    MOV     SI, message_notreaddisk:    ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

fin:
    HLT
    JMP     fin:

boot:
    XOR     CX, CX
    MOV     BX, CX
    MOV     SI, loaderFileName:

boot.startSearch:
    MOV     AX, 20h
    MUL     BX

    MOV     DI, 8000h
    ADD     DI, AX
    
boot.loop:
    CMP     [DI], [SI]
    JNE     boot.nextfile:

    INC     CX
    INC     DI
    INC     SI

    CMP     CX, 11
    JE      boot.found:

    JMP     boot.loop:

boot.nextfile:
    CMP     BX, 16
    JE      boot.notfound:
    INC     BX
    JMP     boot.startSearch:

boot.found:
    MOV     AX, 20h
    MUL     BX

    ADD     AX, 8016h                   ; クラスタ番号を取得
    MOV     DX, [AX]
    MOV     AX, DX

    MOV     BX, 2                       ; クラスタ番号からセクタ位置を取得
    MUL     BX
    INC     AL
    MOV     CL, AL

    MOV     AH, 0                       ; ディスク初期化
    INT     13h

    JC      fin:                        ; エラーだったらおわり

    MOV     AX, 0202h                   ; セクタ読み込み
                                        ; 読み込むセクタ数
    MOV     CH, 0                       ; トラック番号 下位8bit
                                        ; トラック番号 上位2bit + セクタ番号 6bit (セクタ番号のみ1から、それ以外は0から)
    MOV     DX, 0                       ; ヘッド番号
                                        ; ディスク番号
    MOV     BX, 5100h

    INT     13h

    JMP     5100h

boot.notfound:
    MOV     SI, message_err:            ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    MOV     SI, message_notfoundfile:   ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

    JMP     fin:

    

message_booting:
    &DB     "Starting System..."
    &DB     0

message_err:
    &DB     "Failed"
    &DW     @CRLF
    &DB     0

message_notreaddisk:
    &DB     "Could not read floppy disk."
    &DW     @CRLF
    &DB     0

message_notfoundfile:
    &DB     "LOADER.SYS is not found."
    &DW     @CRLF
    &DB     0

loaderFileName:
    &DB     "LOADER  SYS"
    &DB     0
    
    &RESBSF 510
    &DW     AA55h