
    #config codesize    auto
    #config filename    "override.com"
    #origin addr 0
    #enum   @CRLF       0A0Dh

    MOV     SI, message:
    MOV     AH, 10h
    INT     21h

    FRET

message:
    &DB     "���񂽂��������m��ȃR�[�h"
    &DW     @CRLF
    &DB     "�΂������Ě������[�U�[��"
    &DW     @CRLF
    &DB     "�f�������t�̗��Ȃ�Ēm��R���Ȃ����낤"
    &DW     @CRLF
    &DB     "���ꂠ�͂�"
    &DW     @CRLF
    &DB     0