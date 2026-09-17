include 'cmos.asm'
init_PIT:
        pusha
        mov     eax,    [0x8*4]
        mov     [OldPitVector], eax
        mov     eax,    NewPitVector
        mov     [0x8*4],        ax
        mov     [0x8*4+2],      cs
        outb    0x43,   0x36
        mov     eax,    clock_freq
        out     0x40,   al
        mov     al,     ah
        out     0x40,   al
        popa
        ret
NewPitVector:
        pusha
        outb    0x20,   0x20    ;interrupt acknowledged
        inc     [tickcount]
        add     [tick_accumulator],     clock_freq
        cmp     [tick_accumulator],     65536
        jb      .ret
        popa
        jmp     far     [OldPitVector]
  .ret:
        popa
        iret
sleep:
        pusha
        add     eax,    [tickcount]
 .await:
        pause
        cmp     [tickcount],    eax
        jb      .await
        popa
        ret
getRTCTime:
        mov     eax,    0x02
        call    readCMOSreg
        mov     bl,     al
        mov     eax,    0x04
        call    readCMOSreg
        mov     cl,     al
        mov     eax,    0x00
        call    readCMOSreg
        ret
getRTCDate:
        mov     eax,    0x07
        call    readCMOSreg
        mov     bl,     al
        mov     eax,    0x08
        call    readCMOSreg
        mov     cl,     al
        mov     eax,    0x09
        call    readCMOSreg
        ret
clock_freq = 11932
OldPitVector dd 0
tick_accumulator dd 0
tickcount dd 0