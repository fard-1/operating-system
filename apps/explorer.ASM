org 0x0
include '..\misc.inc'
explorer:
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
        jmp     AfterInit.skip
Init:
        mov     esi,    [esi+5]
        add     [esi+WndElements+12],   esi
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
        push    ebx
        push    esi
        getalloc 2
        mov     ebx,    [esi]
        add     esi,    4
 .loop:
        cmp     ebx,    0
        je      .ret

        int3
        add     esi,    16
        dec     ebx
        pusha
        push    esi
        mov     eax,    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     ebx,    esi
        add     ebx,    WndElements
        mov     [ebx+12],       eax
        add     word    [ebx+4],        50
        mov     edi,    [0x55c]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        mov     eax,    [esi+windowID]
        dec     eax

        int3
        call    far     [esi+Hcall_buf]
        pop     esi
        popa
        jmp     .loop
 .ret:
        pop     esi
        pop     ebx
        jmp     near    word    AfterInit
windowID dd 0
Hcall_buf:
dd 0
EventOnetime db 0
FirstString db "Open",0
WndElements:
        wnd_element ui_text,50,100,0,0
        wnd_element ui_list_terminator,0,0,0,0
explorer_len = $ - explorer