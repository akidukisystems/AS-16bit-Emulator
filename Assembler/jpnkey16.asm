
    #config codesize    auto
    #config filename    "jpnkey16.sys"
    #origin addr 0
    #enum   @CRLF       0A0Dh

    ; lowerclasscode
    ; In...AL, BL
    ; Out..AL, BL
    ; FLAGS...Not Change
    ; 入力されたアスキーコードを、大文字のアルファベットから小文字に変換します
    ; BLレジスタの変更を許可しない場合は、BXレジスタをスタックにプッシュし、41h-5Ah以外の範囲に設定してからCALLしてください

    lowerclasscode:
        CMP     AL, 41h
        JGE     lowerclasscode.al:

    lowerclasscode.al_ret:
        CMP     BL, 41h
        JGE     lowerclasscode.bl:

        FRET

    lowerclasscode.al:
        CMP     AL, 5Ah
        JG      lowerclasscode.al_ret:
        ADD     AL, 20h
        JMP     lowerclasscode.al_ret:

    lowerclasscode.bl:
        CMP     BL, 5Ah
        JG      lowerclasscode.ret:
        ADD     BL, 20h

    lowerclasscode.ret:
        FRET