
app_2:
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        cmp     [esi+initui-app_2],     0
        je      near    .initui
  .afterinit:
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        movzx   ecx,    [esi+mouse_x-app_2]
        movzx   edx,    [esi+mouse_y-app_2]
        mov     eax,    0xffffff
        callsystem      pix
        mov     eax,    0x000000
        dec     ecx
        callsystem      pix
        inc     ecx
        inc     edx
        callsystem      pix
        sub     edx,    2
        callsystem      pix
        inc     ecx
        inc     edx
        callsystem      pix
        mov     [esi+drawui-app_2],     0
        mov     [esi+initui-app_2],     1
        mov     esi,    [esi+buf_main-app_2]
        mov     eax,    [esi]
        sub     esi,    28
  .loop:
        cmp     eax,    0
        je      near    .mouse_handle
        add     esi,    32
        dec     eax
        cmp     byte    [esi+20],       1
        jne     near    .skip_rendering_window_frame
        pusha
        push    esi
        push    edi
        mov     edi,    esi
        mov     ecx,    [esi]
        mov     edx,    [esi+4]
        mov     ebx,    [esi+12]
        mov     esi,    [esi+8]
        mov     eax,    0xffffff
        add     edx,    p_size
        callsystem      rect_width
        sub     edx,    p_size
        mov     ebx,    p_size
        mov     eax,    0xff94de
        callsystem      rect_width
        mov     eax,    0x000000
        mov     ebx,    2
        callsystem      rect_width
        mov     esi,    [edi+8]
        add     edx,    [edi+12]
        add     edx,    p_size
        callsystem      rect_width
        mov     edx,    [edi+4]
        mov     ebx,    [edi+12]
        add     ebx,    p_size
        mov     esi,    2
        callsystem      rect_width
        add     ecx,    [edi+8]
        callsystem      rect_width
        pop     edi
        pop     esi
        popa
        mov     byte    [esi+20],       0
 .skip_rendering_window_frame:
        push    eax
        inc     eax
        call    near    Render_Window_Elements
        pop     eax
        jmp     near    .loop
  .mouse_handle:
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     ah,     1
        int     16h
        jz      near    .return
        cmp     ah,     50h
        je      near    .mouse_down
        cmp     ah,     48h
        je      near    .mouse_up
        cmp     ah,     4Bh
        je      near    .mouse_left
        cmp     ah,     4Dh
        je      near    .mouse_right
  .return:
        pop     esi
        popa
        retf
  .mouse_down:
        inc     [esi+mouse_y-app_2]
  .popkey:
        mov     [esi+drawui-app_2],     1
        xor     eax,    eax
        int     16h
        jmp     near    .return
  .mouse_up:
        dec     [esi+mouse_y-app_2]
        jmp     near    .popkey
  .mouse_left:
        dec     [esi+mouse_x-app_2]
        jmp     near    .popkey
  .mouse_right:
        inc     [esi+mouse_x-app_2]
        jmp     near    .popkey
  .initui:
        push    esi
        pusha
        push    eax
        pusha
        push    esi
        mov     eax,    0x007700
        xor     ecx,    ecx
        xor     edx,    edx
        mov     esi,    1280
        mov     ebx,    1024
        callsystem      rect_width
        pop     esi
        popa
        mov     eax,    [0x4cffa]
        mov     [esi+buf_main-app_2],   eax
        mov     eax,    2048
        callsystem      __malloc
        pop     eax
        mov     esi,    [esi+buf_main-app_2]
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        sub     esi,    app_2
        mov     [0x558],        esi
        mov     [0x55c],        esi
        mov     [0x560],        esi
        mov     [0x564],        esi
        mov     [0x568],        esi
        mov     [0x56c],        esi
        mov     [0x570],        esi
        mov     [0x57c],        esi
        add     dword   [0x558],        Create_Window
        add     dword   [0x55c],        Add_Element
        add     dword   [0x560],        canvas_pix
        add     dword   [0x564],        canvas_read
        add     dword   [0x568],        getcursorpos
        add     dword   [0x56c],        getcursorpos_rel
        add     dword   [0x570],        Get_Event
        add     dword   [0x57c],        Update_Element
        popa
        pop     esi
        jmp     near    .afterinit
Create_Window:
        pusha
        push    eax
        mov     [esi+drawui-app_2],     1
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     esi,    [esi+buf_main-app_2]
        imul    eax,    dword   [esi],  32
        inc     dword   [esi]
        add     esi,    eax
        add     esi,    4
        pop     eax
        mov     [esi],  eax
        mov     [esi+4],        ebx
        mov     [esi+8],        ecx
        mov     [esi+12],       edx
        mov     eax,            [0x4cffa]
        mov     [esi+16],       eax
        mov     byte    [esi+20],       1
        malloc                  256
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     esi,    [esi+buf_main-app_2]
        popa
        retf
Get_Event:
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     [esi+drawui-app_2],     1
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        sub     esi,    28
        movzx   eax,    word    [esi+21]
        movzx   ecx,    word    [esi+25]
        movzx   edx,    word    [esi+27]
        movzx   ebx,    word    [esi+29]
        mov     word   [esi+21],        0
        mov     dword   [esi+25],       0
        mov     dword   [esi+29],       0
        pop     esi
        retf
Add_Element:
        pusha
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     [esi+drawui-app_2],     1
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        add     esi,    4
        mov     esi,    [esi+16]
        imul    eax,    dword   [esi],  32
        add     esi,    eax
        add     esi,    4
        mov     ecx,    esi
        add     ecx,    32
  .loop:
        inc     dword   [esi]
        cmp     word    [ebx],  ui_list_terminator
        je      near    .ret
        mov     edx,    32
        callsystem      [0x54c]
        mov     byte    [ecx+16],       1
        cmp     word    [ebx],  ui_canvas
        je      near    .allocate_canvas_memory
  .continue:
        add     ebx,    32
        add     ecx,    32
        jmp     near    .loop
  .ret:
        pop     esi
        popa
        retf
  .allocate_canvas_memory:
        mov     eax,    [0x4cffa]
        mov     [ecx+12],        eax
        movzx   edx,    byte    [ecx+10]
        movzx   ecx,    byte    [ecx+11]
        imul    ecx,    edx
        malloc  ecx
        jmp     near    .continue
canvas_pix:
        pusha
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        add     esi,    4
        mov     esi,    [esi+16]
        shl     ebx,    5
        add     esi,    ebx
        add     esi,    36
        mov     eax,    [esi+12]
        push    eax
        movzx   eax,    byte    [esi+10]
        imul    edx,    eax
        pop     eax
        add     edx,    ecx
        imul    edx,    edx,    4
        add     edx,    eax
        mov     [edx],  edi
        pop     esi
        popa
        retf
Update_Element:
        pusha
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        sub     esi,    28
        mov     esi,    [esi+16]
        shl     ebx,    5
        add     esi,    ebx
        add     esi,    36
        mov     byte    [esi+16],       1
        pop     esi
        popa
        retf
canvas_read:
        pusha
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        add     esi,    4
        mov     esi,    [esi+16]
        shl     ebx,    5
        add     esi,    ebx
        add     esi,    36
        mov     eax,    [esi+12]
        push    eax
        movzx   eax,    byte    [esi+10]
        imul    edx,    eax
        pop     eax
        add     edx,    ecx
        imul    edx,    edx,    4
        add     edx,    eax
        mov     edi,    [edx]
        pop     esi
        popa
        retf
getcursorpos:
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        movzx   ecx,    [esi+mouse_x-app_2]
        movzx   edx,    [esi+mouse_y-app_2]
        pop     esi
        retf
getcursorpos_rel:
        push    eax
        push    esi
        xor     ebx,    ebx
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        movzx   ecx,    [esi+mouse_x-app_2]
        movzx   edx,    [esi+mouse_y-app_2]
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        add     esi,    4
        sub     ecx,    [esi]
        sub     edx,    [esi+4]
  .return:
        pop     esi
        pop     eax
        retf
  .errors:
        mov     ebx,    warn_outofwindow
        jmp     .return
Render_Window_Elements:
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     esi,    [esi+buf_main-app_2]
        shl     eax,    5
        add     esi,    eax
        sub     esi,    28
        mov     ecx,    [esi]
        mov     edx,    [esi+4]
        mov     ebx,    esi
        mov     esi,    [esi+16]
        add     esi,    4
        mov     eax,    dword   [esi]
  .loop:
        cmp     eax,    0
        je      near    .ret
        dec     eax
        add     esi,    32
        cmp     dword   [esi],  ui_button
        je      .process_button
  .continue_rendering:
        cmp     byte    [esi+16],       1
        jne     near    .loop
        pusha
        push    esi
        cmp     dword   [esi],  ui_text
        je      .render_text
        cmp     dword   [esi],  ui_rect
        je      .render_rect
        cmp     dword   [esi],  ui_frame
        je      .render_frame
        cmp     dword   [esi],  ui_icon
        je      .render_icon
        cmp     dword   [esi],  ui_separator_horz
        je      .render_separator_horz
        cmp     dword   [esi],  ui_separator_vert
        je      .render_separator_vert
        cmp     dword   [esi],  ui_canvas
        je      .render_canvas
        cmp     dword   [esi],  ui_button
        je      .render_button
        cmp     dword   [esi],  ui_progressbar
        je      .render_progress_bar
 .continue:
        pop     esi
        popa
        jmp     near    .loop
  .ret:
        pop     esi
        popa
        ret
  .render_text:
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        mov     esi,    [esi+12]
        callsystem      chars_str
        jmp     near    .continue
  .render_rect:
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        movzx   ebx,    word    [esi+10]
        mov     eax,    [esi+12]
        movzx   esi,    word    [esi+8]
        callsystem      rect_width
        jmp     near    .continue
 .render_icon:
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        mov     esi,    [esi+8]
        callsystem      render_icon
        jmp     near    .continue
  .render_frame:
        push    ebp
        mov     ebp,    esi
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        movzx   ebx,    word    [esi+10]
        mov     eax,    0xd3d3d3
        movzx   esi,    word    [esi+8]
        callsystem      rect_width
        mov     ebx,    1
        xor     eax,    eax
        callsystem      rect_width
        add     dx,     [ebp+10]
        callsystem      rect_width
        sub     dx,     [ebp+10]
        movzx   ebx,    word    [ebp+10]
        mov     esi,    1
        callsystem      rect_width
        add     cx,     [ebp+8]
        callsystem      rect_width
        pop     ebp
        jmp     near    .continue
 .render_separator_horz:
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        mov     esi,    [esi+8]
        add     ecx,    eax
        add     edx,    ebx
        mov     eax,    0
        mov     ebx,    4
        callsystem      rect_width
        jmp     near    .continue
 .render_separator_vert:
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        mov     eax,    0
        mov     ebx,    [esi+8]
        mov     esi,    4
        callsystem      rect_width
        jmp     near    .continue
   .render_canvas:
        push        edi
        mov         edi,        [esi+12]
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        xor     bh,     bh
   .render_canvas_reset:
        xor         bl,         bl
        push        ecx
   .render_canvas_loop:
        mov         eax,        [ds:edi]
        add         edi,        4
        inc         bl
        inc         ecx
        callsystem  pix
        cmp         bl,         [esi+10]
        jne         near        .render_canvas_loop
        pop         ecx
        inc         edx
        inc         bh
        cmp         bh,         [esi+11]
        jne         near        .render_canvas_reset
   .render_canvas_ret:
        pop         edi
        jmp         near        .continue
   .render_button:
        push    ebp
        mov     ebp,    esi
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        pusha
        movzx   ebx,    word    [esi+10]
        mov     eax,    0xd3d3d3
        movzx   esi,    word    [esi+8]
        callsystem      rect_width
        mov     ebx,    1
        xor     eax,    eax
        callsystem      rect_width
        add     dx,     [ebp+10]
        callsystem      rect_width
        sub     dx,     [ebp+10]
        movzx   ebx,    word    [ebp+10]
        mov     esi,    1
        callsystem      rect_width
        add     cx,     [ebp+8]
        callsystem      rect_width
        popa
        mov     esi,    ebp
        pop     ebp
        pusha
        push    esi
        movzx   eax,    word    [esi+8]
        movzx   ebx,    word    [esi+10]
        shr     eax,    1
        shr     ebx,    1
        add     ecx,    eax
        add     edx,    ebx
        sub     edx,    4
        mov     esi,    [esi+12]
        push    esi
        mov     eax,    0
  .render_buttonstrlen:
        cmp     byte    [ds:esi],       0
        je      .render_strlenret
        inc     esi
        inc     eax
        jmp     .render_buttonstrlen
  .render_strlenret:
        shl     eax,    2
        sub     ecx,    eax
        pop     esi
        callsystem      chars_str
        pop     esi
        popa
  .render_return:
        jmp     near    .continue
 .process_button:
        pusha
        push    esi
        push    ebx
        push    eax
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        mov     eax,    ecx
        mov     ebx,    edx
        push    esi
        getalloc        0
        add     esi,    8
        mov     esi,    [esi+5] ;coincidence
        movzx   ecx,    [esi+mouse_x-app_2]
        movzx   edx,    [esi+mouse_y-app_2]
        pop     esi
        sub     ecx,    eax
        sub     edx,    ebx
        pop     eax
        pop     ebx
        cmp     cx,     [esi+8]
        ja      .process_button_return
        cmp     dx,     [esi+10]
        ja      .process_button_return
        mov     dword   [ebx+21],       E_BUTTONPRESS
        mov     word    [ebx+25],       cx
        mov     word    [ebx+27],       dx
        inc     eax
        mov     word    [ebx+29],       ax
  .process_button_return:
        pop     esi
        popa
        jmp     near    .continue_rendering
   .render_progress_bar:
        push    ebp
        mov     ebp,    esi
        movzx   eax,    word    [esi+4]
        movzx   ebx,    word    [esi+6]
        add     ecx,    eax
        add     edx,    ebx
        pusha
        movzx   eax,    word    [esi+8]
        imul    ax,     word    [esi+12]
        push    eax
        push    edx
        push    ecx
        mov     ecx,    100
        xor     edx,    edx
        div     ecx
        mov     esi,    eax
        pop     ecx
        pop     edx
        pop     eax
        mov     ebx,    20
        mov     eax,    0x357EC7
        callsystem      rect_width
        popa
        movzx   esi,    word    [ebp+8]
        mov     ebx,    1
        xor     eax,    eax
        callsystem      rect_width
        add     dx,     21
        callsystem      rect_width
        sub     dx,     21
        mov     ebx,    21
        mov     esi,    1
        callsystem      rect_width
        add     cx,     [ebp+8]
        callsystem      rect_width
        pop     ebp
        jmp     near    .continue
initui db 0
drawui db 0
buf_main dd 0
mouse_x dw 1
mouse_y dw 1
click db 0
callbuffer: dd 0
app_2l = $ - app_2