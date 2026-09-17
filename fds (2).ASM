org 7c00h
include 'misc.inc'
loadkern:
        cld
        xor     ax,     ax
        mov     ss,     ax
        mov     sp,     0xe000
        mov     es,     ax
        mov     bx,     0x1000
        call    load_kernel
        mov     ax,     4f02h
        mov     bx,     411Bh
        int     10h
        jmp     0x0000:0x1000
disk_load:
    push dx

    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02

    int 0x13

    jc disk_error

    pop dx
    cmp dh, al
    jne disk_error
    ret

disk_error:
    jmp $
    load_kernel:
        mov bx, 0x1000
        mov dh, 54
        call disk_load
        ret
times 510 - ($-$$) db 0
dw 0xAA55
org 0x1000
use16
init:
        cli                         ; Disable interrupts during mode switch
        push    ds                  ; Save current real-mode segments
        push    es

        ; 1. Load a temporary Global Descriptor Table (GDT)
        lgdt    [gdt_pointer]

        ; 2. Switch to Protected Mode briefly
        mov     eax,    cr0
        or      al,     1
        mov     cr0,    eax

        ; 3. Force the segment cache registers to load 4GB limits
        mov     bx,     0x08        ; Offset to our 4GB Data Descriptor
        mov     ds,     bx
        mov     es,     bx

        ; 4. Switch back to Real Mode (Unreal Mode active!)
        mov     eax,    cr0
        and     al,     0xFE
        mov     cr0,    eax

        pop     es                  ; Restore real mode segment targets
        pop     ds
        sti                         ; Re-enable interrupts safely
        mov     dword  [0x80*4], call_convert
        mov     dword  [0x3*4], breakpoint_int
        mov     word  [0x4cfff], 0
        mov     dword [0x4cffa], 0x50000
        mov     dword [0x504], Print_String
        mov     dword [0x508], __malloc
        mov     dword [0x50c], pix
        mov     dword [0x510], rect
        mov     dword [0x514], __getalloc
        mov     dword [0x518], __free
        mov     dword [0x51c], chars_str
        mov     dword [0x520], render_icon
        mov     dword [0x524], renamefile
        mov     dword [0x528], runappfromfile
        mov     dword [0x52c], findfilebyname
        mov     dword [0x530], readfile
        mov     dword [0x534], writefile
        mov     dword [0x538], addfile
        mov     dword [0x53c], hang
        mov     dword [0x540], regdump
        mov     dword [0x544], print_hex
        mov     dword [0x548], parse_hex
        mov     dword [0x54c], copy
        mov     dword [0x550], rect_width
        mov     dword [0x554], addapps
        mov     dword [0x574], sleep
        mov     dword [0x578], tickcount
        push    eax
        mov     eax,    cr4
        or      eax,    11000000000b
        mov     cr4,    eax
        mov     eax,    cr0
        and     eax,    11111001b
        mov     cr0,    eax
        malloc  10001   ;correction
        malloc  12      ;correct
        malloc  16000
        malloc  buffer_len_bytes*2
        malloc  25*100
        pusha
        call    blast_reset
        popa
        call    init_PIT
        addprocesses  app_2,     app_2l
        addprocesses  StopWatch, StopWatch_len
        pop     eax
again:                                            ; execute processes
        getalloc                 0
        mov     edx,    dword           [esi+4]
        add     esi,    8
        xor     ecx,    ecx
!loop:
        cmp     ecx,    edx
        je      again
        sti
        inc     ecx
        push    esi
        push    ebx
        mov     ebx,    esi
        mov     [0x500], esi ;should be ONLY nonallocated address, for apps to use variables
        inc     dword   [esi+1]
        mov     esi,    [esi+5]
        push    eax
        mov     eax,    esi
        shr     eax,    4
        and     esi,    15
        push    cs
        push    .continue
        push    ax
        push    si
        retf            ;stack magic
 .continue:
        pop     eax
        pop     ebx
        pop     esi
        add     esi,    9
        jmp     !loop

__malloc:                          ;allocate
        push   esi
        xor    esi, esi
        imul   si, word [0x4cfff], 4
        push   ebx
        mov    ebx, [0x4cffa]
        mov    [esi+0x4d000], ebx
        pop    ebx
        pop    esi
        inc    word [0x4cfff]
        and    eax, 0xffff
        add    dword [0x4cffa], eax
        ret
__getalloc:                            ;get address
        cmp    ax, word [0x4cfff]
        jge    .err
        mov    esi,     [eax*4+0x4d000]
        ret
   .err:
        mov    ax, err_noalloc
        ret
__free:                                    ;remove
        cmp    ax, word [0x4cfff]
        jge    .err
        push   esi
        xor    esi, esi
        imul   si, ax, 4
        add    esi, 0x4d000
        mov    ebx, [esi]
        mov    dword [esi], 0
        pop    esi
        inc    ax
        cmp    ax, word [0x4cfff]
        jne    .ret
        dec    word [0x4cfff]
        mov    [0x4cffa], ebx
   .ret:
        ret
   .err:
        mov    ax, err_noalloc
        ret

include "apps\shell.ASM"
include "apps\ui.ASM"
StopWatch:
file "apps\stopwatch.bin"
StopWatch_len = $ - StopWatch
parse_hex:
    push    ebx
    push    ecx
    push    esi
    mov     ecx,  4
    xor     eax, eax        ; Clear the result register
.loop:
    jecxz   .done           ; Exit if length is 0
    movzx   ebx, byte [esi] ; Load the next character
    cmp     ebx, '0'        ; validate hex awfully
    jl      .nohex
    cmp     ebx, 'f'
    jg      .nohex
    ; Convert ASCII '0'-'9' (48-57) to 0-9
    sub     bl, '0'
    cmp     bl, 9
    jbe     .is_digit
    
    ; Convert ASCII 'A'-'F' (65-70) or 'a'-'f' (97-102) to 10-15
    and     bl, 0xDF        ; Force uppercase (handles 'a' and 'A')
    sub     bl, 7           ; Jump the gap between '9' and 'A' (ASCII 58-64)
    
.is_digit:
    shl     eax, 4          ; Shift current total left by 4 bits
    or      al, bl          ; Add the new hex digit (0-15)
    
    inc     esi
    dec     ecx
    jmp     .loop
.done:
    pop     esi
    pop     ecx
    pop     ebx
    ret
.nohex:
    xor     eax, eax
    mov     edx, err_invalidhex
    jmp     .done
print_hex:
        pusha
        push    esi
        mov     ecx,    8
  .loop:
        jecxz   .ret
        rol     eax,    4
        mov     esi,    eax
        and     esi,    15
        add     esi,    hexvals
        movzx   esi,    byte    [esi]
        imul    esi,    esi,    2
        add     esi,    General_Table
        call    Print_String
        dec     ecx
        jmp     .loop
  .ret:
        pop     esi
        popa
        ret
regdump:
        push    eax
        push    esi
        mov     esi,    eax_string
        call    Print_String
        call    print_hex
        mov     esi,    ebx_string
        call    Print_String
        mov     eax,    ebx
        call    print_hex
        mov     esi,    ecx_string
        call    Print_String
        mov     eax,    ecx
        call    print_hex
        mov     esi,    edx_string
        call    Print_String
        mov     eax,    edx
        call    print_hex
        pop     esi
        push    esi
        mov     esi,    esi_string
        call    Print_String
        pop     esi
        push    esi
        mov     eax,    esi
        call    print_hex
        mov     esi,    edi_string
        call    Print_String
        mov     eax,    edi
        call    print_hex
        mov     esi,    esp_string
        call    Print_String
        mov     eax,    esp
        call    print_hex
        mov     esi,    ebp_string
        call    Print_String
        mov     eax,    ebp
        call    print_hex
        pop     esi
        pop     eax
        ret

copy:
        pusha
  .loop:
        cmp     edx,    0
        je      .ret
        mov     al,      byte            [ebx]
        mov     byte    [ecx],           al
        inc     ebx
        inc     ecx
        dec     edx
        jmp     .loop
  .ret:
        popa
        ret
addapps:
        pusha
        push    esi
        malloc  ebx
        pop     esi
        movzx   eax,    word   [0x4cfff]
        dec     eax
        push    edi
        mov     edi,    esi
        getalloc eax
        mov     edx,    ebx
        mov     ecx,    esi
        mov     ebx,    edi
        pop     edi
        call    copy
        getalloc 0
        inc     dword    [esi+4]
        imul    eax,    dword   [esi+4],   9
        mov     [eax+esi+4],   ecx
        popa
        ret

hang:
        jmp     $
call_convert:                                  ;call to system functions
        call    di
        iret
addfile:
        pusha
        push    esi
        getalloc 2
        inc     dword   [esi]
        imul    eax,    dword   [esi],  16
        add     eax,    esi
        add     eax,    4
        mov     [eax],  ebx
        mov     dword   [eax+9],        0
        add     ecx,    8
        malloc  ecx
        sub     ecx,    8
        movzx   edx,    word    [0x4cfff]
        dec     edx
        getalloc edx
        mov     [eax+5], esi
        pop     esi
        popa
        ret
writefile:                ; eax = id; ebx = source; ecx = offset; edx = length
        pusha
        push    esi
        getalloc 2
        imul    eax,    16
        add     eax,    esi
        add     eax,    4
        mov     esi,    [eax+5]
        push    ecx
        add     ecx,    8
        add     ecx,    esi
        call    copy
        pop     ecx
        add     ecx,    edx
        cmp     ecx,    [eax+9]
        jle     .skip
        mov     [eax+9],        ecx
  .skip:
        pop     esi
        popa
        ret
readfile:       ; eax = id, ebx = offset, ecx = ;destination edx = length
        pusha
        push    esi
        getalloc 2
        imul    eax,    16
        add     eax,    esi
        add     eax,    4
        mov     esi,    [eax+5]
        add     ebx,    esi
        add     ebx,    8
        call    copy
        pop     esi
        popa
        ret
findfilebyname:
        push    ebx
        push    esi
        getalloc 2
        xor     edx,    edx
        xor     ecx,    ecx
        mov     ebx,    [esi]
        add     esi,    4
 .loop:
        add     esi,    16
        inc     ecx
        cmp     ebx,    0
        je      .no_file
        cmp     [esi],  eax
        je      .ret
        dec     ebx
        jmp     .loop
 .ret:
        pop     esi
        pop     ebx
        ret
 .no_file:
        xor     ecx,    ecx
        mov     edx,    err_nofile
        jmp     .ret
runappfromfile:
        pusha
        push    esi
        getalloc        2
        imul    eax,    16
        add     eax,    esi
        add     eax,    4
        push    ebx
        push    esi
        mov     esi,    [eax+5]
        add     esi,    8
        mov     ebx,    [eax+9]
        callsystem    addapps
        pop     esi
        pop     ebx
        pop     esi
        popa
        ret
renamefile:
        pusha
        push    esi
        getalloc        2
        imul    eax,    16
        add     esi,    eax
        add     esi,    4
        mov     [esi],  ecx
        pop     esi
        popa
        ret
include "graphics.ASM"
breakpoint_int:
        push    esi
        mov     esi,    bpstring
        call    Print_String
        pop     esi
        call    regdump
        pusha
        mov     ah,     0
        int     16h
        popa
        iret
crash:
        push    esi
        mov     esi,    crash_string
        call    Print_String
        pop     esi
        call    regdump
        cli
        jmp     $
readNMIbit:
        in      al,     0x70
        and     eax,    128
        ret
include 'drivers\sound.ASM'
include 'drivers\timer.asm'
teststring db 'test',0
teststring_len = $ - teststring
teststring2 db 'above, lies.',0
teststring2_len = $ - teststring2
separator db ' ',0
bpstring db 13,10,'* BREAKPOINT HIT *',13,10,0
crash_string db 13,10,'*CRASH DETECTED* (eax = exception)',13,10,0
warn_data:
file 'icons/warn.bin'
lel_data:
file 'icons/lel.bin'
newline db 13,10,0
testaudio  AudioProcess testsound,      800,    1, 3.6
testaudio2  AudioProcess testsound,      798,    1, 3.4
testsound:
  times 50      dw      8192,   8192
  times 50      dw      -8192,  -8192
    times 50    dw      8192,   8192
  times 50      dw      -8192,  -8192
eax_string db 'eax: ',0
ebx_string db ' ebx: ',0
ecx_string db ' ecx: ',0
edx_string db ' edx: ',0
esi_string db ' esi: ',0
edi_string db ' edi: ',0
esp_string db ' esp: ',0
ebp_string db ' ebp: ',0
hexvals db '0123456789abcdef'
General_Table:
times 256 db %-1,0
align 4
gdt_start:
    dw 0, 0, 0, 0                   ; Null Descriptor
    dw 0xFFFF, 0, 0x9200, 0x008F    ; 4GB flat data segment descriptor (Base=0, Limit=0xFFFFF, Granular)
gdt_end:

gdt_pointer:
    dw gdt_end - gdt_start - 1      ; GDT Limit
    dd gdt_start                    ; GDT Base Address
Char_000:
file 'font-terminus.bin'