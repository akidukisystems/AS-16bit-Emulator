
    #module

    // id=ウィンドウID
    // style=メッセージボックスのスタイル
    // maxInput=メッセージボックスの最大入力文字数
    // size_x=メモリ上のウィンドウサイズX
    // size_y=メモリ上のウィンドウサイズY
    // mode=ウィンドウモード
    // pos_x=ウィンドウ位置X
    // pos_y=ウィンドウ位置Y
    // winsize_x=ウィンドウサイズX
    // winsize_y=ウィンドウサイズY
    #deffunc func_init_msglib int id, int style, int maxInput, int size_x, int size_y, int mode, int pos_x, int pos_y

        text = ""

        screen id, size_x, size_y, mode, pos_x, pos_y
        mesbox text, size_x, size_y -24, style, maxInput
        objid = stat


    return

    #deffunc putmes_msglib str msg

        text += msg
        objprm objid, text

    return

    #define global init_msglib(%1=0, %2=1, %3=-1, %4=640, %5=480, %6=0, %7=-1, %8=-1) func_init_msglib %1, %2, %3, %4, %5, %6, %7, %8


    #global

    init_msglib 0, 0, 0
    putmes_msglib "this is a pen"

