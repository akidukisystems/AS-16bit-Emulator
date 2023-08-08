#define true 1
#define false 0
#define none -1

#enum KEY_ENTER     = 13
#enum KEY_ESC       = 27
#enum KEY_F1        = 112
#enum KEY_F2
#enum KEY_F3
#enum KEY_F4
#enum KEY_F5
#enum KEY_F6
#enum KEY_F7
#enum KEY_F8
#enum KEY_F9
#enum KEY_F10
#enum KEY_F11
#enum KEY_F12
#enum KEY_BS        = 8
#enum KEY_TAB
#enum KEY_SHIFT     = 16
#enum KEY_CTRL
#enum KEY_ALT
#enum KEY_PAUSE
#enum KEY_SPACE     = 32
#enum KEY_PGUP
#enum KEY_PGDN
#enum KEY_END
#enum KEY_HOME
#enum KEY_ALLOWL
#enum KEY_ALLOWU
#enum KEY_ALLOWR
#enum KEY_ALLOWD
#enum KEY_INSERT    = 45
#enum KEY_DEL

#define CLR_BLACK           0, 0, 0
#define CLR_BLUE            0, 0, 192
#define CLR_GREEN           0, 192, 0
#define CLR_CYAN            0, 192, 192
#define CLR_RED             192, 0, 0
#define CLR_MAGENTA         192, 0, 192
#define CLR_BROWN           192, 64, 64
#define CLR_LIGHT_GRAY      192, 192, 192
#define CLR_DARK_GRAY       64, 64, 64
#define CLR_LIGHT_BLUE      0, 0, 255
#define CLR_LIGHT_GREEN     0, 255, 0
#define CLR_LIGHT_CYAN      0, 255, 255
#define CLR_LIGHT_RED       255, 0, 0
#define CLR_LIGHT_MAGENTA   255, 0, 255
#define CLR_YELLOW          192, 192, 0
#define CLR_WHITE           255, 255, 255

#module

    #deffunc initscr
        clrobj 0, -1
        pos 0, 0
        color 0, 0, 0 : boxf
        color 192, 192, 192
    return

    #deffunc softinitscr
        pos 0, 0
        color 0, 0, 0 : boxf
        color 192, 192, 192
    return

#global