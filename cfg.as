/*

    cfg.as
        設定ファイル操作支援モジュール

*/


    #module CFG_AS

    #define true    1
    #define false   0
    #define none    -1
    
    #define done    0
    #define fail    1
    
    #define bool    int
    
    #enum varType_Label = 1
    #enum varType_Str
    #enum varType_Double
    #enum varType_Int
    #enum varType_Module
    #enum varType_COM
    
    #deffunc splitEx str in, array out, int sp
    
        inV = in
        arrayNum = 0
        index = 0
        flag_spell = 0
    
        if ( length ( out ) < 8 ) : {
    
            sdim out, strlen ( inV ) +1, 8
            
        } else {
    
            sdim out, strlen ( inV ) +1, length ( out )
    
        }
        
    
        repeat strlen ( inV )
    
            switch peek ( inV, cnt )
    
                case sp
    
                    if ( flag_spell ) : {
    
                        poke out.arrayNum, index, peek ( inV, cnt )
                        poke out.arrayNum, index +1, 0x00
    
                        index ++
    
                    } else {
    
                        arrayNum ++
                        out.arrayNum = ""
                        index = 0
    
                    }
    
                swbreak
    
                case '"'
    
                    if ( flag_spell ) : {
    
                        flag_spell = 0
    
                    } else {
    
                        flag_spell = 1
    
                    }
    
                swbreak
    
                default
    
                    poke out.arrayNum, index, peek ( inV, cnt )
                    poke out.arrayNum, index +1, 0x00
    
                    index ++
    
                swbreak
    
            swend
    
        loop
    
        dim inV 
        dim arrayNum
        dim index
        dim flag_spell
    
    return
    
    #deffunc splitExS str in, array out, int sp
    
        inV = in
        arrayNum = 0
        index = 0
        flag_spell = 0
    
        if ( length ( out ) < 8 ) : {
    
            sdim out, strlen ( inV ) +1, 8
            
        } else {
    
            sdim out, strlen ( inV ) +1, length ( out )
    
        }
        
    
        repeat strlen ( inV )
    
            switch peek ( inV, cnt )
    
                case sp
    
                    if ( flag_spell ) : {
    
                        poke out.arrayNum, index, peek ( inV, cnt )
                        poke out.arrayNum, index +1, 0x00
    
                        index ++
    
                    } else {
    
                        arrayNum ++
                        out.arrayNum = ""
                        index = 0
    
                    }
    
                swbreak
    
                case '"'
    
                    poke out.arrayNum, index, peek ( inV, cnt )
                    poke out.arrayNum, index +1, 0x00
    
                    index ++
    
                    if ( flag_spell ) : {
    
                        flag_spell = 0
    
                    } else {
    
                        flag_spell = 1
    
                    }
    
                swbreak
    
                default
    
                    poke out.arrayNum, index, peek ( inV, cnt )
                    poke out.arrayNum, index +1, 0x00
    
                    index ++
    
                swbreak
    
            swend
    
        loop
    
        dim inV 
        dim arrayNum
        dim index
        dim flag_spell
    
    return
    
    ; 設定ファイルを読み込み、モジュールを初期化します
    ; file=設定ファイル名
    #deffunc cfgAS_init str file
    
        Var_ConfigLine = ""
        Var_ThisConfigLine = ""
        Var_isLoad = 0
        sdim Var_ThisConfigLineArray
    
        exist file
        if ( strsize != -1 ) : {
    
            notesel Var_ConfigLine
            noteload file
            noteunsel
            Var_isLoad = 1
    
            return 0
        }
    
    return 1
    
    
    ; 設定ファイルにある項目を読み込みます
    ; name=項目名
    ; in=読み込み先の変数
    ; isRepraceCRLF=改行コード変換オプション（デフォルト:0）
    ; isRepraceCRLFに1をセットすると、項目の値に文字列"\n"があった場合、自動で改行コード(0x0D, 0x0A)に変換します。
    #define global cfgAS_read(%1, %2, %3=0) cfgAS_read_l@cfg_AS %1, %2, %3
    
    #deffunc local cfgAS_read_l str name, var in, int isRepraceCRLF
    
        if ( Var_isLoad == 0 ) : return 1
    
        Flag_isDone = 0
    
        notesel Var_ConfigLine
        repeat notemax
    
            noteget Var_ThisConfigLine, cnt
    
            if ( Var_ThisConfigLine == "" ) : continue
    
            splitEx Var_ThisConfigLine, Var_ThisConfigLineArray, '='
    
            if ( Var_ThisConfigLineArray.0 == name ) : {
    
                var_int_notype = 0
    
                switch vartype( in )
                case varType_Int
    
                    Flag_isDone = 1
                    in = int( Var_ThisConfigLineArray.1 )
    
                swbreak
                case varType_Double
    
                    Flag_isDone = 1
                    in = double( Var_ThisConfigLineArray.1 )
    
                swbreak
                case varType_Str
    
                    Flag_isDone = 1
                    in = Var_ThisConfigLineArray.1
                    if ( isRepraceCRLF ) : {
    
                        strrep in, "\\n", "\n"
        
                    }
    
                swbreak
                default
    
                    var_int_notype = 1
                    break
    
                swbreak
                swend   
    
            }
    
        loop
        noteunsel
    
        if ( var_int_notype ) : {
    
            return 2
        }
    
        if ( Flag_isDone ) : {
    
            return 0
    
        } else {
    
            return 3
    
        }
    
    
    
    ; 設定ファイルにある項目へ書き込みます
    ; name=項目名
    ; in=書き込み元の変数
    ; isOverWrite=上書きオプション（デフォルト:0）
    ; isOverWriteに1をセットすると、同じ項目があった場合、その項目の値に上書きします。
    ; 0をセットするか、省略した場合は、同じ項目があった場合には何もしません。
    #define global cfgAS_write(%1, %2, %3=0) cfgAS_write_l@cfg_AS %1, %2, %3
    
    #deffunc local cfgAS_write_l str name, var in, int isOverWrite
    
        if ( Var_isLoad == 0 ) : return 1
    
        Flag_isDone = 0
    
        notesel Var_ConfigLine
        repeat notemax
    
            noteget Var_ThisConfigLine, cnt
    
            if ( Var_ThisConfigLine == "" ) : continue
    
            splitEx Var_ThisConfigLine, Var_ThisConfigLineArray, '='
    
            if ( ( Var_ThisConfigLineArray.0 == name ) and isOverWrite ) : {
    
                var_int_notype = 0
    
                switch vartype( in )
                case varType_Int
    
                    Flag_isDone = 1
                    noteadd ""+ Var_ThisConfigLineArray.0 +"="+ in +"", cnt, 1
    
                swbreak
                case varType_Double
    
                    Flag_isDone = 1
                    noteadd ""+ Var_ThisConfigLineArray.0 +"="+ in +"", cnt, 1
    
                swbreak
                case varType_Str
    
                    Flag_isDone = 1
                    v_Temp_Str = in
    
                    strrep v_Temp_Str, "\n", "\\n"
    
                    noteadd ""+ Var_ThisConfigLineArray.0 +"=\""+ v_Temp_Str +"\"", cnt, 1
    
                swbreak
                default
    
                    var_int_notype = 1
                    break
    
                swbreak
                swend   
    
            }
    
        loop
    
        if ( var_int_notype ) : {
    
            noteunsel
            return 2
    
        }
    
    if ( Flag_isDone ) : {
    
        noteunsel
        return 0
    
    } else {
    
        if ( vartype(in) == varType_Str ) : {
    
            v_Temp_Str = in
    
            strrep v_Temp_Str, "\n", "\\n"
    
            noteadd ""+ name +"=\""+ v_Temp_Str +"\"", -1, 0
            noteunsel
            return 0
    
        }
    
        if ( ( vartype(in) == varType_Int ) or ( vartype( in ) == varType_Double ) ) : {
    
            noteadd ""+ name +"="+ in +"", -1, 0
            noteunsel
            return 0
    
        }
    
    }
    
    noteunsel
    return 3
    
    
    
    
    ; 設定ファイルから項目を削除します
    ; name=項目名
    #deffunc cfgAS_remove str name
    
        if ( Var_isLoad == 0 ) : return 1
    
        Flag_isDone = 0
    
        notesel Var_ConfigLine
        repeat notemax
    
            noteget Var_ThisConfigLine, cnt
    
            if ( Var_ThisConfigLine == "" ) : continue
    
            splitEx Var_ThisConfigLine, Var_ThisConfigLineArray, '='
    
            if ( Var_ThisConfigLineArray.0 == name ) : {
    
                    Flag_isDone = 1
                    notedel cnt
                    break
    
            }
    
        loop
    
        noteunsel
    
    if ( Flag_isDone ) : {
        
        return 0
    
    }
    return 3
    
    
    
    
    ; 設定ファイルの変更を保存します
    ; file=設定ファイル名
    #deffunc cfgAS_save str file
    
        if ( Var_isLoad == 0 ) : return 1
    
        notesel Var_ConfigLine
        notesave file
        noteunsel
    
    return 0
    
    
    
    ; モジュールをリセットします
    #deffunc cfgAS_reset
    
        if ( Var_isLoad == 0 ) : return 1
    
        Var_ConfigLine = ""
        Var_ThisConfigLine = ""
        Var_isLoad = 0
        sdim Var_ThisConfigLineArray
    
        noteunsel
        Var_isLoad = 0
    
    return 0
    
    
    #global