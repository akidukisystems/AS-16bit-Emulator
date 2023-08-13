
    #config codesize    1024
    #config filename    "fileinfo.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AH, 1
    MOV     SI, 7AD0h
    INT     21h
    OR      AH, AH
    JNZ     notfound:

    MOV     SI, message_attr:
    MOV     AH, 10h
    INT     21h

    MOV     AH, 3
    MOV     BH, 1
    INT     21h

    TEST    AX, 01h
    JNZ     fileattr_readonly:

fileattr_readonly_ret:
    TEST    AX, 02h
    JNZ     fileattr_hide:

fileattr_hide_ret:
    TEST    AX, 04h
    JNZ     fileattr_system:

fileattr_system_ret:
    TEST    AX, 08h
    JNZ     fileattr_volume:

fileattr_volume_ret:
    TEST    AX, 10h
    JNZ     fileattr_dir:

fileattr_dir_ret:
    TEST    AX, 20h
    JNZ     fileattr_archive:

    JMP     fileattr_next:

fileattr_readonly:
    MOV     AL, 52h
    MOV     AH, 11h
    INT     21h
    JMP     fileattr_readonly_ret:

fileattr_hide:
    MOV     AL, 48h
    MOV     AH, 11h
    INT     21h
    JMP     fileattr_hide_ret:

fileattr_system:
    MOV     AL, 53h
    MOV     AH, 11h
    INT     21h
    JMP     fileattr_system_ret:

fileattr_volume:
    MOV     AL, 56h
    MOV     AH, 11h
    INT     21h
    JMP     fileattr_volume_ret:

fileattr_dir:
    MOV     AL, 44h
    MOV     AH, 11h
    INT     21h
    JMP     fileattr_dir_ret:

fileattr_archive:
    MOV     AL, 41h
    MOV     AH, 11h
    INT     21h

fileattr_next:
    ;MOV     AH, 3
    ;MOV     BH, 2
    ;INT     21h



    FRET

notfound:
    MOV     SI, message_notfound:
    MOV     AH, 10h
    INT     21h

    FRET

message_notfound:
    &DB     "file not found."
    &DW     @CRLF
    &DB     0

message_attr:
    &DB     "Attribute: "
    &DB     0
