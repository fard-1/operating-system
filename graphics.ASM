chars_row:
        pusha
        push    edi
        mov     edi,    8
        dec     ecx
  .loop:
        cmp     edi,    0
        je      .ret
        dec     edi
        inc     ecx
        rol     al,     1
        test    al,     1
        je      .loop
        push    eax
        mov     eax,  0xbbbbbb
        call    pix
        pop     eax
        jmp     .loop
   .ret:
        pop     edi
        popa
        ret
chars_one:
        pusha
        ; 1. Isolate the character and clear ALL other bits
        movzx   eax, al          ; EAX = 0x000000[char]
        
        ; 2. Perform the math using 32-bit registers to prevent overflow
        imul    eax, eax, 16     ; EAX = offset
        add     eax, Char_000    ; EAX = physical address in kernel
        
        ; 3. Move the final result to SI for the loop
        mov     si, ax           
        mov     ebx, 16
   .loop:
        test    ebx, ebx
        jz      .ret
        
        ; 4. Force read from Segment 0
        push    ds
        xor     ax, ax
        mov     ds, ax
        mov     al, [si]         ; Read the font byte
        pop     ds
        
        pusha
        call    chars_row
        popa
        
        inc     edx              ; Next line on screen
        inc     si               ; Next byte in font
        dec     ebx
        jmp     .loop
   .ret:
        popa
        ret
chars_str:
    push    eax
    push    ebx
.loop:
    mov     al, [ds:esi]
    inc     esi          ; NOW advance to the next character
    test    al, al
    jz      .done
    cmp     al, 10
    je      .lf
    cmp     al, 13
    je      .cr
    cmp     cx, 1280
    je      .toomuch
    push    esi          ; Save the current string pointer
    push    ecx          ; Save current X (so chars_one doesn't ruin it)
    call    chars_one
    pop     ecx          ; Restore X
    pop     esi          ; Restore string pointer

    add     ecx, 8       ; Move X forward
    jmp     .loop
.done:
    pop     ebx
    pop     eax
    ret
.toomuch:
    xor     ecx, ecx
.lf:
    add     edx, 16
    jmp     .loop
.cr:
    xor     ecx, ecx
    jmp     .loop
rect_width:
        push    ebx
        push    esi
        add     esi,    ecx
        add     ebx,    edx
        call    rect
        pop     esi
        pop     ebx
        ret
Print_String:                                 ; writes
        pusha
        push    esi
        getalloc 1
        movzx   edx,    word    [esi]
        movzx   ecx,    word    [esi+2]
        pop     esi
        push    esi
        call    chars_str
        getalloc 1
        cmp     dx,     1024
        jl      .skip
        mov     dx,     0
        pusha
        push    esi
        push    edi
        xor     ecx,    ecx
        xor     edx,    edx
        xor     eax,    eax
        mov     esi,    1280
        mov     ebx,    1024
        call    rect
        pop     edi
        pop     esi
        popa
  .skip:
        mov     [esi],dx
        mov     [esi+2],cx
        pop     esi
        popa
        ret
render_icon:
        pusha
        push        esi
        xor         bh,         bh
   .reset:
        xor         bl,         bl
        push        ecx
   .loop:
        mov         eax,        [ds:esi]
        add         esi,        4
        inc         bl
        inc         ecx
        pusha
        call        pix
        popa
        cmp         bl,         32
        jne         .loop
        pop         ecx
        inc         edx
        inc         bh
        cmp         bh,         32
        jne         .reset
   .ret:
        pop         esi
        popa
        ret
pix:
        push    esi
        push    eax
        imul    esi,    edx,    1280
        add     esi,    ecx
        lea     esi,    [0xe0000000+esi+esi*2]
        mov     [esi],  ax
        shr     eax,    16
        mov     [esi+2],        al
        pop     eax
        pop     esi
        ret
rect:                          ;rectangle between (ecx,edx) and (esi,ebx)
        pusha
        push    edi
        mov     edi,    ecx
  .loop:
        inc     ecx
        call    pix
        cmp     ecx,    esi
        jle     .loop
        mov     ecx,    edi
        inc     edx
        cmp     edx,    ebx
        jle     .loop
        pop     edi
        popa
        ret