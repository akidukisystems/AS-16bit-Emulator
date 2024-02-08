#module dupProtect

#uselib "kernel32.dll"
#func  CloseHandle  "CloseHandle"  int
#cfunc CreateMutex  "CreateMutexA" int, int, sptr
#cfunc GetLastError "GetLastError"

#define ERROR_ALREADY_EXISTS    183

#deffunc initDup

    hMutex = 0

return

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


    #deffunc CleanupDupProtect onexit
    if ( hMutex != 0 ) {

        CloseHandle hMutex
        hMutex = 0

}
return

#global