org 0x0
include '..\misc.inc'
launcher:
        pusha
        push    esi
        push    edi
        mov     esi,    [0x500]
        cmp     dword   [esi+1],    1
        je      near    word        Init
        mov     esi,    [esi+5]
AfterInit:
        mov     eax,    [esi+windowID]
        mov     edi,    [0x570]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        call    far     [esi+Hcall_buf]
        cmp     eax,    E_BUTTONPRESS
        je      eventprocess
        mov     [esi+EventOnetime],     0
     .skip:
        mov     esi,    [esi+5]
        pop     edi
        pop     esi
        popa
        retf
eventprocess:
        cmp     [esi+EventOnetime],     1
        je      AfterInit.skip
        mov     [esi+EventOnetime],     1
        cmp     ebx,    2
        jne     .app1
        addprocesses    [0x594],        [0x598]
        jmp     AfterInit.skip
    .app1:
        addprocesses    [0x58c],        [0x590]
        jmp     AfterInit.skip
Init:
        mov     esi,    [esi+5]
        add     [esi+WndElements+12],   esi
        add     [esi+WndElements+44],   esi
        mov     edi,    [0x558]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        xor     eax,    eax
        xor     ebx,    ebx
        mov     ecx,    250
        mov     edx,    400
        call    far     [esi+Hcall_buf]
        mov     eax,    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     eax,    [eax]
        mov     [esi+windowID], eax
        int3
        mov     ebx,    esi
        add     ebx,    WndElements
        mov     edi,    [0x55c]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        dec     eax
        call    far     [esi+Hcall_buf]
        jmp     near    word    AfterInit
windowID dd 0
Hcall_buf:
dd 0
EventOnetime db 0
FirstString db "Stopwatch",0
String2 db "Explorer",0
WndElements:
        wnd_element ui_button,50,100,100+65536*50,FirstString
        wnd_element ui_button,50,160,100+65536*50,String2
        wnd_element ui_list_terminator,0,0,0,0
launcher_len = $ - launcher