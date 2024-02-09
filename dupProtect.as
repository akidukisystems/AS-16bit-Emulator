/*

    dupProtect.as
        重複起動防止モジュール

*/

#module dupProtect

    #uselib "kernel32.dll"
    #func  CloseHandle  "CloseHandle"  int
    #cfunc CreateMutex  "CreateMutexA" int, int, sptr
    #cfunc GetLastError "GetLastError"

    #define ERROR_ALREADY_EXISTS    183

    ; モジュールを初期化します
    ; checkDup命令の後に記述しないでください！
    #deffunc initDup

        hMutex = 0

    return

    ; すでに同じプロセスが起動されているか確認します
    ; MUTEX_NAME=ミューテックス名（他の無関係なプロセスと重複しないよう、開発者名/ソフトウェア名を入れることを推奨します）
    #defcfunc checkDup str MUTEX_NAME

        if ( hMutex == 0 ) {

            logmes MUTEX_NAME

            hMutex = CreateMutex( 0, 0, "hsp3_"+ MUTEX_NAME )

            if ( GetLastError() == ERROR_ALREADY_EXISTS ) {

                return 1

            } else {

                return 0

            }

        }

    return

    ; チェック時に生成したミューテックスを消去します。
    ; プロセス終了時に自動で実行されます。
    #deffunc CleanupDupProtect onexit

        if ( hMutex != 0 ) {

            CloseHandle hMutex
            hMutex = 0

        }

    return

#global