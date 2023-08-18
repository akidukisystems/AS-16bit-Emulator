
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

    MOV     AH, 2                       ; セクタ読み込み
    MOV     AL, 10h                     ; 読み込むセクタ数
    MOV     CH, 0                       ; トラック番号 下位8bit
    MOV     CL, 2                       ; トラック番号 上位2bit + セクタ番号 6bit (セクタ番号のみ1から、それ以外は0から)
    MOV     DH, 0                       ; ヘッド番号
    MOV     DL, 0                       ; ディスク番号
    MOV     BX, 07E0h                   ; 格納先アドレス(セグメント)
    MOV     ES, BX
    MOV     BX, 0                       ; 格納先アドレス(オフセット)
    INT     13h

    JNC     8800h                       ; エラーなかったらブート

    MOV     SI, message_err:            ; 文字列のあるオフセット
    MOV     AH, 0Eh                     ; テレタイプモード
    INT     10h                         ; ビデオ割り込み

fin:
    HLT
    JMP     fin:

message_booting:
    &DB     "Starting System..."
    &DB     0

message_err:
    &DB     "Failed"
    &DW     @CRLF
    &DB     "Could not read floppy disk."
    &DW     @CRLF
    &DB     0
    
    &RESBSF 510
    &DW     AA55h