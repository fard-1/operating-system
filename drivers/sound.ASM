include "sound.inc"
include "sb16_2nd.ASM"
typecast AudioCast,     AudioProcess
copy_addver:
        pusha
  .loop:
        cmp     edx,    0
        jle     .ret
        movsx   eax,    word           [ebx]
        sar     eax,    3
        cvtsi2ss        xmm0,           eax
        movsx   eax,    word           [ecx]
        cvtsi2ss        xmm1,           eax
        movss   xmm2,   [esi+AudioCast.volume]
        mulss   xmm0,   xmm2
        addss   xmm0,   xmm1
        maxss   xmm0,   dword   [minaudio]
        minss   xmm0,   dword   [maxaudio]
        cvttss2si       eax,    xmm0
        mov     word    [ecx],          ax
        add     ebx,    2
        add     ecx,    2
        sub     edx,    2
        jmp     .loop
  .ret:
        popa
        ret
process_audio_rewrite:
        pusha
        push    esi
        getalloc        4
        xor     eax,    eax
        mov     ebx,    esi
  .loop:
        cmp     eax,    [ebx]
        je      .ret
        inc     eax
        cmp     dword   [ebx+eax*4],    0
        je      .loop           ;audio disabled
        mov     esi,    [ebx+eax*4]
        call    process_one_cast
        jmp     .loop
  .ret:
        pop     esi
        popa
        ret
addcast:
        pusha
        push    esi
        getalloc        4
        inc     eax
        mov     [esi+eax*4],    ebx
        pop     esi
        popa
        retf
removecast:
        pusha
        push    esi
        getalloc        4
        mov     [4+esi+eax*4],  ebx
        pop     esi
        popa
        retf
process_one_cast:
        pusha
        push    esi
        push    edi
        mov     ebx,    [esi+AudioCast.currentPtr]
        add     ebx,    [esi+AudioCast.copiedSize]
        xor     ecx,    ecx
 .repeat2:
        mov     edx,    [esi+AudioCast.size]
        sub     edx,    [esi+AudioCast.copiedSize]
        cmp     edx,    0
        je      .ret
        cmp     ecx,    buffer_len_bytes
        jae     .ret
        cmp     edx,    buffer_len_bytes
        jna     .notabove
        mov     edx,    buffer_len_bytes
        sub     edx,    ecx
        cmp     [esi+AudioCast.repeatSound],    1
        jne     .notabove
        sub     [esi+AudioCast.copiedSize],     1
   .notabove:
        add     ecx,    audio_buffer
        call    copy_addver
        sub     ecx,    audio_buffer
        add     [esi+AudioCast.copiedSize],     edx
        cmp     [esi+AudioCast.repeatSound],    1
        jne     .ret
        mov     eax,    [esi+AudioCast.copiedSize]
        cmp     eax,    [esi+AudioCast.size]
        je      .repeat
    .ret:
        pop     edi
        pop     esi
        popa
        ret
    .repeat:
        add     ecx,   [esi+AudioCast.size]
        mov     [esi+AudioCast.copiedSize],     0
        jmp     .repeat2
minaudio dd -32767.0
maxaudio dd 32767.0