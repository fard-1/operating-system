include         "../misc.inc"
org     0x0
use16
StopWatch:
        pusha
        push    esi
        push    edi
        mov     esi,    [0x500]
        cmp     dword   [esi+1],    1
        jne     near    .skip
        mov     esi,    [esi+5]
        mov     eax,    [0x4cffa]
        mov     [esi+textPTR],  eax
        mov     [esi+WndElements+44],   eax
        lea     eax,    [esi+ResetString]
        mov     [esi+WndElements+76],   eax
        lea     eax,    [esi+MarkerString]
        mov     [esi+WndElements+108],   eax
        mov     eax,    15
        callsystem      [0x508]
        mov     edi,    [0x558]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        mov     eax,    100
        mov     ebx,    100
        mov     ecx,    400
        mov     edx,    400
        call    far     [esi+Hcall_buf]
        mov     eax,    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     eax,    [eax]
        mov     [esi+windowID], eax
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
   .skip:
        mov     eax,    [0x584]
        mov     eax,    [eax]
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     ebx,    [esi+textPTR]
        add     ebx,    11
        mov     ecx,    2
        sub     eax,    [esi+timer]
        call    near    write_hex
        sub     ebx,    2
        push    ecx
        push    edx
        xor     edx,    edx
        mov     ecx,    60
        div     ecx
        mov     edi,    eax
        mov     eax,    edx
        pop     edx
        pop     ecx
        call    near    write_hex
        mov     eax,    edi
        push    ecx
        push    edx
        xor     edx,    edx
        mov     ecx,    60
        mov     edi,    eax
        div     ecx
        mov     eax,    edx
        pop     edx
        pop     ecx
        sub     ebx,    2
        call    near    write_hex
        mov     eax,    edi
        push    ecx
        push    edx
        xor     edx,    edx
        mov     ecx,    60
        div     ecx
        pop     edx
        pop     ecx
        mov     ecx,    4
        sub     ebx,    4
        call    near    write_hex
        mov     edi,    [0x57c]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        mov     eax,    [esi+windowID]
        mov     ebx,    0
        call    far     [esi+Hcall_buf]
        inc     ebx
        call    far     [esi+Hcall_buf]
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
        mov     [esi+eventID],  0
        mov     [esi+marker],   0
  .endeventprocess:
        pop     edi
        pop     esi
        popa
        retf
eventprocess:
        pusha
        push    esi
        mov     [esi+eventID],  bl
        and     ebx,     255
        cmp     ebx,    3
        jne     .marker
        mov     eax,    [0x584]
        mov     eax,    [eax]
        mov     [esi+timer],    eax
  .endeventprocess:
        pop     esi
        popa
        jmp     StopWatch.endeventprocess
  .marker:
        cmp     bl,     0
        je      .endeventprocess
        cmp     [esi+marker],   1
        je      .endeventprocess
        mov     [esi+marker],   1
        mov     ecx,    [0x4cffa]
        mov     eax,    15
        callsystem      [0x508]
        add     word    [esi+WndNewMarker+6],    20
        mov     ebx,    [esi+textPTR]
        mov     edx,    15
        callsystem      [0x54c]
        mov     [esi+WndNewMarker+12],           ecx
        mov     ebx,    esi
        add     ebx,    WndNewMarker
        mov     eax,    [esi+windowID]
        mov     edi,    [0x55c]
        push    edi
        shr     edi,    4
        mov     [esi+Hcall_buf+2], di     ;segment
        pop     edi
        and     edi,    15
        mov     [esi+Hcall_buf], di
        dec     eax
        call    far     [esi+Hcall_buf]
        jmp     .endeventprocess
write_hex:
        push    ecx
        push    esi
        push    edi
        add     ebx,    ecx
        dec     ebx
        mov     edi,    [0x500]
        mov     edi,    [edi+5]
  .loop:
        push    ecx
        mov     ecx,    10
        mov     edx,    0
        div     ecx
        pop     ecx
        mov     esi,    edx
        and     esi,    15
        add     esi,    hexvals
        add     esi,    edi
        push    edx
        mov     edx,    [esi]
        mov     [ds:ebx],       dl
        pop     edx
        dec     ebx
        loop    .loop
        add     ebx,    ecx
        mov     byte    [ds:ebx],       ':'
        pop     edi
        pop     esi
        pop     ecx
        ret
initapp db 0
textPTR dd 0
windowID dd 0
timer dd 0
eventID db 0
hexvals db "0123456789"
marker db 0
ResetString db 'Reset',0
MarkerString db 'Marker',0
WndElements:
        wnd_element ui_rect,50,50,200+65536*16,0xffffff
        wnd_element ui_text,50,50,0,0
        wnd_element ui_button,50,100,100+65536*50,0
        wnd_element ui_button,160,100,100+65536*50,0
        wnd_element ui_list_terminator,0,0,0,0
WndNewMarker:
        wnd_element ui_text,0,30,0,0
        wnd_element ui_list_terminator,0,0,0,0
Hcall_buf:
        times   2       dd      0
StopWatch_len = $ - StopWatch