# 対応命令
## 読み方
### オペランドの記号
+ r8...AH, AL, BH, BL, CH, CL, DH, DLの8bit汎用レジスタ。
+ r16...AX, BX, CX, DX, SI, DI, SP, BPの16bit汎用レジスタ。
+ m8...メモリ内BYTEサイズオペランド。暗示的にDSレジスタがセグメントレジスタとして使用されます
+ m16...メモリ内WORDサイズオペランド。暗示的にDSレジスタがセグメントレジスタとして使用されます
+ r/m8...r8またはm8のBYTEサイズオペランド
+ r/m16...r16またはm16のWORDサイズオペランド
+ sreg...CS, DS, ES, SSのいずれかのセグメントレジスタ
+ imm8...BYTEサイズ即値
+ imm16...WORDサイズ即値

### 読み方

    MOV ←(1)
        
        ↓(2)	↓(3)	↓(4)
        0x10	movb	dest[r/m8,imm8], src[r/m8,imm8]
        0x11	movw	dest[r/m16,sreg,imm16], src[r/m16,sreg,imm16]

        データを転送します。 ←(5)

        dest ← src ←(6)

        変更されるフラグ ←(7)
        (なし)

    (1)...アセンブラ上で識別されるニーモニック
    (2)...命令コード
    (3)...命令コードに対応する論理ニーモニック（無意味）
    (4)...使用可能なオペランドの種類
    (5)...説明
    (6)...命令の挙動を示す
    (7)...命令実行後のフラグレジスタへの影響
        

## MOV
### 構文
+ 0x10...movb dest[r/m8,imm8], src[r/m8,imm8]
+ 0x11...movw dest[r/m16,sreg,imm16], src[r/m16,sreg,imm16]
+ 0x11...movw dest[r/m8,r/m16,sreg,imm16], src[r/m8,r/m16,sreg,imm16] ※1

### 説明
第一オペランドに第二オペランドの値を格納します。
※1	双方のオペランドが[r/m8]の場合を除く

### 操作
dest ← src

### 変更されるフラグ
(なし)

## XCHG
### 構文
+ 0x13...xchg x[r/m16], y[r/m16]

### 説明
第一オペランドと第二オペランドの値を交換します。

### 操作
tmp ← x  
x ← y  
y ← x

### 変更されるフラグ
(なし)

## INC
### 構文
+ 0x20...incb x[r/m8]
+ 0x21...incw x[r/m16,sreg]

### 説明
オペランドの値をインクリメントします。

### 操作
x ← x+1  
setflagreg(x, OF|SF|ZF|PF)

### 変更されるフラグ
OF, SF, ZF, PF...結果に応じてセットされます

## DEC
### 構文
+ 0x22...decb x[r/m8]
+ 0x23...decw x[r/m16,sreg]

### 説明
オペランドの値をデクリメントします。

### 操作
x ← x-1  
setflagreg(x, OF|SF|ZF|PF)

### 変更されるフラグ
OF, SF, ZF, PF...結果に応じてセットされます

## ADD
### 構文
+ 0x24...addb dest[r/m8], src[r/m8,imm8]
+ 0x25...addw dest[r/m16,sreg], src[r/m16,sreg,imm16]

### 説明
第一オペランドに第二オペランドを加算し、第一オペランドに格納します。

### 操作
dest ← dest+src  
setflagreg(dest, OF|SF|ZF|AF|PF|CF)

### 変更されるフラグ
OF, SF, ZF, AF, PF, CF...結果に応じてセットされます

## SUB
### 構文
+ 0x26...subb dest[r/m8], src[r/m8,imm8]
+ 0x27...subw dest[r/m16,sreg], src[r/m16,sreg,imm16]

### 説明
第一オペランドに第二オペランドを減算し、第一オペランドに格納します。

### 操作
dest ← dest-src  
setflagreg(dest, OF|SF|ZF|AF|PF|CF)

### 変更されるフラグ
OF, SF, ZF, AF, PF, CF...結果に応じてセットされます

## MUL
### 構文
+ 0x28...mulb x[r/m8]
+ 0x29...mulw x[r/m16]

### 説明
オペランドとAX（オペランドのサイズがBYTEの場合はAL）を乗算し、DX:AX（オペランドのサイズがBYTEの場合はAX）に格納します。

### 操作
if operand_size==BYTE  
then(  
AX ← x * AL  
)else(  
tmp1 ← x * AX  
tmp2 ← tmp1 & $FFFF0000  
DX ← tmp2 <<< 16  
AX ← tmp1 & &0000FFFF  
)

### 変更されるフラグ
(なし)

## DIV
### 構文
+ 0x2A...divb x[r/m8]
+ 0x2B...divw x[r/m16]
### 説明
DX:AX（オペランドのサイズがBYTEの場合はAX）をオペランドで除算し、余りをDX（オペランドのサイズがBYTEの場合はAH）、商をAX（オペランドのサイズがBYTEの場合はAL）に格納します。
オペランドが0の場合は#DE ゼロ除算例外を発生させます。

### 操作
if x==0  
then(  
interrupt #DE  
exit  
)  
if operand_size==BYTE  
then(  
AH ← AX \ x  
AL ← AX / x  
)else(  
tmp1 ← DX <<< 16  
tmp1 ← tmp + AX  
DX ← tmp1 \ x  
AX ← tmp1 / x  
)

### 変更されるフラグ
(なし)
## CMP		b,w
### 構文
### 説明
### 操作
### 変更されるフラグ
## IN		w
### 構文
### 説明
### 操作
### 変更されるフラグ
## OUT		w
### 構文
### 説明
### 操作
### 変更されるフラグ
## PUSH	w
### 構文
### 説明
### 操作
### 変更されるフラグ
## POP		w
### 構文
### 説明
### 操作
### 変更されるフラグ
## HLT
### 構文
### 説明
### 操作
### 変更されるフラグ
## CALL	w
### 構文
### 説明
### 操作
### 変更されるフラグ
## RET
### 構文
### 説明
### 操作
### 変更されるフラグ
## CALLF	w
### 構文
### 説明
### 操作
### 変更されるフラグ
## RETF
### 構文
### 説明
### 操作
### 変更されるフラグ
## DBG
### 構文
### 説明
### 操作
### 変更されるフラグ
## JMP		w
### 構文
### 説明
### 操作
### 変更されるフラグ
## Jcc      w
### 構文
### 説明
### 操作
### 変更されるフラグ