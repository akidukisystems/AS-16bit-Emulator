@echo off

    echo Target^> "%1"
    if "%1" == "os" (
        call :os
        call :makeimg
        call :copy
    )
    if "%1" == "app" (
        call :app
        call :makeimg
        call :copy
    )
    if "%1" == "bios" (
        call :bios
        call :copy
    )
    if "%1" == "makeimg" (
        call :makeimg
    )
    if "%1" == "copy" (
        call :copy
    )
    if "%1" == "clean" (
        call :clean
    )
    if "%1" == "cleanbin" (
        call :cleanbin
    )
    if "%1" == "all" (
        call :bios
        call :os
        call :app
        call :makeimg
        call :copy
    )
    if "%1" == "" (
        call :bios
        call :os
        call :app
        call :makeimg
        call :copy
    )

    exit /b

:bios
    echo make^> bios
    cd Assembler\
    asm.exe bios.asm
    cd ..\
    exit /b

:os
    echo make^> os
    cd Assembler\
    asm.exe boot.asm
    asm.exe loader.asm
    asm.exe system.asm
    asm.exe jpnkey16.asm
    cd ..\
    exit /b

:app
    echo make^> app
    cd Assembler\
    asm.exe dir.asm
    asm.exe cls.asm
    asm.exe exit.asm
    asm.exe version.asm
    asm.exe type.asm
    asm.exe del.asm
    asm.exe bench.asm
    cd ..\
    exit /b

:makeimg
    echo make^> makeimg
    Assembler\diskmake.exe make
    exit /b

:copy
    echo make^> copy
    copy /y /b Assembler\bios.bin bios.bin
    copy /y /b Assembler\fdisk0.img fdisk0.img
    exit /b

:clean
    echo make^> clean
    del /s hsptmp
    del /s obj
    del /s packfile
    del /s *.ax
    del /s Assembler\hsptmp
    del /s Assembler\obj
    del /s Assembler\packfile
    del /s Assembler\*.ax
    del /s Assembler\*.dbg
    del /s Assembler\*.com
    del /s Assembler\*.sys
    del /s Assembler\*.bin
    del /s Assembler\*.img
    del /s error.txt
    del /s dump_*.bin
    del /s dump_*.txt
    del /s stacktrace.txt

    exit /b

:cleanbin
    echo make^> cleanbin
    del Assembler\*.com
    del Assembler\*.sys
    del Assembler\*.bin
    del Assembler\*.img
    exit /b