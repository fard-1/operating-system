err_nofile = 0xf000
err_noalloc = 0xf001
err_invalidhex = 0xf002
warn_outofwindow = 0xc000
continue_running = 0x0010
ui_text = 0x0000
ui_rect = 0x0001
ui_frame = 0x0002
ui_icon = 0x0003
ui_separator_horz = 0x0004
ui_separator_vert = 0x0005
ui_canvas = 0x0006
ui_button = 0x0007
ui_progressbar = 0x0008
ui_list_terminator = 0xffff
E_NOEVENT = 0x0000
E_BUTTONPRESS = 0x0001
p_size = 16
;misc
macro typecast name, type {
    virtual at 0
        name type
    end virtual
}
macro delay nms {
        mov     ah,86h
        if      nms < 10000h
        xor     cx,cx
        else
        mov     cx,nms shr 16
        end if
        mov     dx,nms and 0FFFFh
        int     15h
}
macro wnd_element type,x,y,param1,param2 {
        dd      type
        dw      x,      y
        dd      param1, param2
        times   16      db      0
}
;io
macro   outb    port,   data    {
        mov     dx,     port
        mov     al,     data
        out     dx,     al
}
macro   inb     port    {
        mov     dx,     port
        in      al,     dx
}
;alloc
macro malloc w {
        push    eax
        mov     eax, w
        callsystem   [0x508]
        pop     eax
}
macro getalloc i {
        push    eax
        mov     eax, i
        callsystem    [0x514]
        pop     eax
}
macro free i {
        push    eax
        mov     eax, i
        callsystem    [0x518]
        pop     eax
}
;stack
macro pusha {
        push    eax
        push    ebx
        push    ecx
        push    edx
}
macro popa {
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
}
;processes
macro addprocesses ptr,len {
        push    ebx
        push    esi
        mov     esi, ptr
        mov     ebx, len
        callsystem    addapps
        pop     esi
        pop     ebx
}
macro callsystem addr {
        push    edi
        mov     edi,    addr
        int     0x80
        pop     edi
}
;shell
macro Shell_Table_Entry str,len,ptr {
    db len,str,0
    dw ptr
}