app_1:
        pusha
        push    esi
        mov     ah,     01h
        int     16h
        jz      near    .skip
        cmp     ah,     1ch
        je      near    .proc_cmd
        mov     ebx,    [ebx+5]              ;ebx = pointer to app info
        mov     eax,    [ebx+_ptr-app_1]
        cmp     eax,    250
        je      near    .proc_cmd
        inc     [ebx+_ptr-app_1]
        pusha
        add     ebx,    eax
        mov     ah,     0
        int     16h
        mov     [ebx+_val-app_1], al
        push    esi
        mov     esi,    General_Table
        and     eax,    255
        imul    eax,    eax,     2
        add     esi,    eax
        callsystem      Print_String
        pop     esi
        popa
  .skip:
        pop     esi
        popa
        retf
  .proc_cmd:
        push    ebx
  .proc_cmd_s:
        mov     ebx,    [0x500]   ;address of app info
        mov     ebx,    [ebx+5]   ;address of app
        add     ebx,    _val-app_1
        call    process_command
        pop     ebx
        jmp     process_command.end_processing
process_command:
        pusha
        push    esi
        mov     esi,    ebx
        dec     esi
  .proc_cmd_2:
        inc     esi
        pusha
        push    esi
        mov     esi,    newline
        callsystem      Print_String
        pop     esi
        popa
        mov     ebx,    [0x500]
        mov     ebx,    [ebx+5]
        add     ebx,    Shell_Table-app_1
  .prepare_entry:
        cmp     byte    [ebx],   0
        je      near    .unknown_entry
        dec     eax
        movzx   edx,    byte     [ebx]
        mov     edi,    ebx
        add     edi,    1
        call    near    .compare_entry
        jne     near    .prepare_entry_2
        movzx   ecx,    byte      [ebx]
        movzx   ecx,    word      [ebx+ecx+2]
        callsystem      ecx
        jmp     near    .wrong_entry
 .prepare_entry_2:
        push    eax
        movzx   eax,    byte      [ebx]
        add     ebx,    eax
        add     ebx,    4
        pop     eax
        jmp     near    .prepare_entry
  .unknown_entry:
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    unknown-app_1
        callsystem      Print_String
        pop     esi
        popa
        jmp     near    .unkentry2
  .wrong_entry:
        cmp     eax,    continue_running
        je      .continue
        mov     ecx,    256
        push    ebx
        mov     ebx,    [0x500]
        mov     ebx,    [ebx+5]
        sub     ecx,    [ebx+_ptr-app_1]
        pop     ebx
  .wrongentloop:
        cmp     byte    [esi],  ':'
        je      .proc_cmd_2
        inc     esi
        loop    .wrongentloop
  .unkentry2:
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    nonai_prompt-app_1
        callsystem      Print_String
        pop     esi
        popa
        pop     esi
        popa
        ret
  .end_processing:
        mov     ah,     0
        int     16h
        mov     esi,    [0x500]   ;address of app info
        mov     esi,    [esi+5]   ;address of app
        mov     dword   [esi+_ptr-app_1],       0
        mov     dword   [esi+_val-app_1],       0
        mov     dword   [esi+_val-app_1+4],     0
        mov     dword   [esi+_val-app_1+8],     0
        mov     dword   [esi+_val-app_1+12],    0
        jmp     near    app_1.skip
  .continue:
        pop     esi
        popa
        add     esp,    2
        jmp     app_1.proc_cmd_s
  .compare_entry:
        pusha
  .compentloop:
        cmp     edx,    0
        je      near    .compentret
        mov     al,     [edi+edx-1]
        cmp     al,     [esi+edx-1]
        jne     near    .compentret
        dec     edx
        jmp     near    .compentloop
 .compentret:
        popa
        ret
ls:
        pusha
        push    esi
        getalloc 2
        mov     ecx,    dword [esi]
        add     esi,    4
  .loop:
        add     esi,    16
        cmp     ecx,    0
        je      .ret
        push    esi
        callsystem    Print_String
        mov     esi,    separator
        callsystem    Print_String
        pop     esi
        dec     ecx
        jmp     near    .loop
  .ret:
        pop     esi
        popa
        ret
halt:
        jmp     near    $
makefile:
        pusha
        push    esi
        mov     ebx,    [esi+8]
        mov     ecx,    100
        callsystem addfile
        pop     esi
        popa
        ret
echo:
        push    esi
        add     esi,     5
        callsystem       Print_String
        pop     esi
        ret
cls:
        pusha
        push    esi
        push    edi
        mov     ebx,    1024
        xor     ecx,    ecx
        xor     edx,    edx
        xor     eax,    eax
        mov     esi,    1280
        callsystem      rect
        pop     edi
        getalloc 1
        mov     dword   [esi], 0
        pop     esi
        popa
        ret
regs:
        callsystem      regdump
        ret
ver:
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    ver_string-app_1
        callsystem      Print_String
        pop     esi
        ret
mem:
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    mem_string-app_1
        callsystem      Print_String
        mov     eax,    [0x4cffa]
        callsystem      print_hex
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    mem_string2-app_1
        callsystem      Print_String
        movzx   eax,    word    [0x4cfff]
        callsystem      print_hex
        pop     esi
        popa
        ret
cat:
        pusha
        push    esi
        mov     eax,    [esi+4]
        callsystem      findfilebyname
        mov     eax,    ecx
        cmp     edx,    err_nofile
        je      rootcmds.nofile
        getalloc 2
        push    eax
        imul    eax,    16
        add     eax,    esi
        add     eax,    4
        mov     esi,    [eax+5]
        mov     edx,    [eax+9]
        pop     eax
        xor     ebx,    ebx
 .loop:
        cmp     edx,    0
        je      .skip
        dec     edx
        mov     ecx,    [0x500]
        mov     ecx,    [ecx+5]
        add     ecx,    filebuf-app_1
        pusha
        mov     edx,    1
        callsystem      readfile
        popa
        push    esi
        movzx   esi,    byte    [ecx]
        imul    esi,    esi,    2
        add     esi,    General_Table
        callsystem      Print_String
        pop     esi
        inc     ebx
        jmp     .loop
 .skip:
        pop     esi
        popa
        ret
_pix:
        pusha
        push    esi
        add     esi, 4
        callsystem    parse_hex
        mov     ecx, eax
        add     esi, 5
        callsystem    parse_hex
        mov     edx, eax
        add     esi, 5
        callsystem    parse_hex
        callsystem pix
        pop     esi
        popa
        ret
proc:
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    proc_string-app_1
        callsystem      Print_String
        getalloc 0
        mov     eax,    [esi+4]
        callsystem    print_hex
        add     esi,    8
 .loop:
        cmp     eax,    0
        je      .ret
        pusha
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    newline_s-app_1
        callsystem      Print_String
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    proc_string2-app_1
        callsystem      Print_String
        pop     esi
        mov     eax,    [esi+1]
        callsystem      print_hex
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    proc_string3-app_1
        callsystem      Print_String
        pop     esi
        mov     eax,    [esi+5]
        callsystem      print_hex
        popa
        dec     eax
        add     esi,    9
        jmp     .loop
 .ret:
        pop     esi
        popa
        ret
write_hex:                           ; eax = id; ebx = source; ecx = offset; edx = length
        pusha
        push    esi
        push    ebx
        push    ecx
        push    edx
        push    esi
        add     esi,    15
        callsystem      parse_hex
        pop     esi
        push    esi
        push    eax
        mov     eax,    [esi+10]
        callsystem      findfilebyname
        pop     eax
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        xchg    al,     ah
        mov     dword   [esi+filebuf-app_1],    eax
        mov     eax,    ecx
        cmp     edx,    err_nofile
        je      .nofile
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        push    eax
        getalloc        2
        imul    eax,    16
        add     eax,    esi
        add     eax,    4
        mov     ecx,    [eax+9]
        pop     eax
        mov     ebx,    [0x500]
        mov     ebx,    [ebx+5]
        add     ebx,    filebuf-app_1
        mov     edx,    2
        callsystem      writefile
   .skip:
        pop     esi
        popa
        ret
 .nofile:
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    cat_string-app_1
        callsystem      Print_String
        jmp     .skip
runas:
        pusha
        push    esi
        mov     eax,    [esi+6]
        callsystem      findfilebyname
        cmp     edx,    err_nofile
        je      rootcmds.nofile
        mov     eax,    ecx
        callsystem      runappfromfile
  .skip:
        pop     esi
        popa
        ret
redo:
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        mov     [esi+_ptr-app_1],       0
        pop     esi
        mov     eax,    continue_running
        ret
write:                  ; eax = id; ebx = source; ecx = offset; edx = length
        pusha
        push    esi
        mov     eax,    [esi+6]
        callsystem      findfilebyname
        cmp     edx,    err_nofile
        je      rootcmds.nofile
        mov     eax,    ecx
        push    esi
        push    eax
        getalloc        2
        imul    eax,    16
        add     eax,    esi
        add     eax,    4
        mov     ecx,    [eax+9]
        pop     eax
        pop     esi
        mov     ebx,    esi
        add     ebx,    16
        push    eax
        add     esi,    11
        callsystem      parse_hex
        cmp     edx,    err_invalidhex
        je      .invalidhex
        mov     edx,    eax
        pop     eax
        callsystem      writefile
  .skip:
        pop     esi
        popa
        ret
 .invalidhex:
        pop     eax
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    hex_string-app_1
        callsystem      Print_String
        jmp     .skip
rootcmds:
    .nofile:
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    cat_string-app_1
        callsystem      Print_String
        jmp     .skip
   .skip:
        pop     esi
        popa
        ret
stat:
        pusha
        push    esi
        mov     eax,    [esi+5]
        callsystem      findfilebyname
        cmp     edx,    err_nofile
        je      rootcmds.nofile
        getalloc        2
        mov     eax,    ecx
        imul    eax,    16
        add     esi,    eax
        add     esi,    4
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    stat_string-app_1
        callsystem      Print_String
        pop     esi
        mov     eax,    [esi+9]
        callsystem      print_hex
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    stat_string2-app_1
        callsystem      Print_String
        pop     esi
        mov     eax,    [esi+5]
        callsystem      print_hex
        pop     esi
        popa
        ret
_pause:
        pusha
        mov     ah,     0
        int     16h
        mov     ah,     0
        int     16h
        popa
        ret
wipe:
        pusha
        push    esi
        mov     eax,    [esi+5]
        callsystem      findfilebyname
        cmp     edx,    err_nofile
        je      rootcmds.nofile
        getalloc        2
        mov     eax,    ecx
        imul    eax,    16
        add     esi,    eax
        add     esi,    4
        mov     dword   [esi+9],        0
        pop     esi
        popa
        ret
rename:
        pusha
        push    esi
        mov     eax,    [esi+7]
        callsystem      findfilebyname
        cmp     edx,    err_nofile
        je      rootcmds.nofile
        mov     eax,    ecx
        mov     ecx,    [esi+12]
        callsystem      renamefile
        pop     esi
        popa
        ret
ticks:
        pusha
        push    esi
        rdtsc
        push    eax
        mov     eax,    edx
        callsystem      print_hex
        pop     eax
        callsystem      print_hex
        pop     esi
        popa
        ret
help:
        pusha
        push    esi
        mov     esi,    Shell_Table
  .loop:
        cmp     byte    [esi],          0
        je      .ret
        inc     esi
        callsystem      Print_String
        dec     esi
        push    esi
        mov     esi,    [0x500]
        mov     esi,    [esi+5]
        add     esi,    mem_string2-app_1
        callsystem      Print_String
        pop     esi
        movzx   eax,    byte            [esi]
        add     esi,    eax
        add     esi,    4
        jmp     .loop
  .ret:
        pop     esi
        popa
        ret
.data:
_ptr dd 0
filebuf dq 0
_val:
times 256 db 0
unknown db 'unknown command',0
ver_string db 'v0.0.1.21',0
hex_string db 'invalid hex value!',0
mem_string db 'next block | amount',13,10,0
mem_string2 db '   ',0
cat_string db 'no file found',0
proc_string db '| amount |',13,10,0
proc_string2 db 'ticks ',0
proc_string3 db ' address ',0
nonai_prompt db 13,10,'> ',0
stat_string db 'size ',0
stat_string2 db ' at ',0
newline_s db 13,10,0
Shell_Table:
Shell_Table_Entry 'ls',2,ls
Shell_Table_Entry 'halt',4,halt
Shell_Table_Entry 'newfile',7,makefile
Shell_Table_Entry 'echo',4,echo
Shell_Table_Entry 'cls',3,cls
Shell_Table_Entry 'regs',4,regs
Shell_Table_Entry 'ver',3,ver
Shell_Table_Entry 'mem',3,mem
Shell_Table_Entry 'pix',3,_pix
Shell_Table_Entry 'proc',4,proc
Shell_Table_Entry 'cat',3,cat
Shell_Table_Entry 'write_hex',9,write_hex
Shell_Table_Entry 'runas',5,runas
Shell_Table_Entry 'redo',4,redo
Shell_Table_Entry 'write',5,write
Shell_Table_Entry 'stat',4,stat
Shell_Table_Entry 'pause',5,_pause
Shell_Table_Entry 'wipe',4,wipe
Shell_Table_Entry 'rename',6,rename
Shell_Table_Entry 'ticks',5,ticks
Shell_Table_Entry 'help',4,help
db 0
app_1l = $ - app_1