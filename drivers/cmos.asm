helpCMOSreg:
        movzx   ebx,    al
        call    readNMIbit
        or      al,     bl
        out     0x70,   al
        ret
readCMOSreg:
        push    ebx
        call    helpCMOSreg
        in      al,     0x71
        pop     ebx
        ret