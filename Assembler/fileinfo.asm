
    #config codesize    1024
    #config filename    "fileinfo.com"
    #origin addr        0
    #enum   @CRLF       0A0Dh

    MOV     AL, 1
    MOV     SI, 7AD0h
    INT     21h
    OR      AL, AL
    JNZ     notfound:

    MOV     AL, 3
    MOV     BL, 1
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
    MOV     SI, message_readonly:
    MOV     AH, 0Eh
    INT     10h
    JMP     fileattr_readonly_ret:

fileattr_hide:
    MOV     SI, message_hide:
    MOV     AH, 0Eh
    INT     10h
    JMP     fileattr_hide_ret:

fileattr_system:
    MOV     SI, message_system:
    MOV     AH, 0Eh
    INT     10h
    JMP     fileattr_system_ret:

fileattr_volume:
    MOV     SI, message_volume:
    MOV     AH, 0Eh
    INT     10h
    JMP     fileattr_volume_ret:

fileattr_dir:
    MOV     SI, message_dir:
    MOV     AH, 0Eh
    INT     10h
    JMP     fileattr_dir_ret:

fileattr_archive:
    MOV     SI, message_archive:
    MOV     AH, 0Eh
    INT     10h

fileattr_next:
    ;MOV     AL, 3
    ;MOV     BL, 2
    ;INT     21h



    FRET

notfound:
    MOV     SI, message_notfound:
    MOV     AH, 0Eh
    INT     10h

    FRET

message_notfound:
    &DB     "file not found."
    &DW     @CRLF
    &DB     0

message_attr:
    &DB     "Attribute..."
    &DB     0

message_readonly:
    &DB     "R "
    &DB     0

message_hide:
    &DB     "H "
    &DB     0

message_system:
    &DB     "S "
    &DB     0

message_volume:
    &DB     "V "
    &DB     0

message_dir:
    &DB     "D "
    &DB     0

message_archive:
    &DB     "A "
    &DB     0
