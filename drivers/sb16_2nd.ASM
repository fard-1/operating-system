
macro delay {
    out 0xed, al
}

blast_reset:
    ; --- Step 1: Reset Sound Blaster 16 DSP ---
    mov dx, [sb_base]
    add dx, 0x06        ; DSP Reset Register
    mov al, 1
    out dx, al
    delay
    xor al, al
    out dx, al          ; Complete reset pulse

    ; Wait for Ready Signal (0xAA) from DSP
    mov cx, 0xFFFF
.wait_reset:
    mov dx, [sb_base]
    add dx, 0x0E        ; Data Available Status Register
    in al, dx
    and al, 0x80
    jnz .read_ready
    loop .wait_reset
    jmp .error

.read_ready:
    mov dx, [sb_base]
    add dx, 0x0A        ; Read Data Register
    in al, dx
    cmp al, 0xAA
    jne .error

    call        routine_of_sb16_driver
.poll_loop:
    pusha
.poll_loop2:
    cmp  [transfer], 1
    jne  .poll_loop2
    popa
    ret

.error:
    ret
routine_of_sb16_driver:
; --- Step 2: Configure 16-Bit DMA Controller (Channel 5) ---
    mov al, 0x05        ; Mask bit set, Channel 5
    out 0xD4, al        ; 16-bit DMA Mask Register
    delay

    mov al, 0
    out 0xD8, al        ; Clear 16-bit DMA Flip-Flop
    delay

    mov al, 0x49        ; Single mode + Write/Playback + Channel 5
    out 0xD6, al        ; 16-bit DMA Mode Register
    delay

    ; Compute 32-bit physical address of the audio buffer
    xor eax, eax
    add eax, audio_buffer

    ; Word-align address for 16-bit High-DMA
    shr eax, 1

    ; Send 16-bit word offset to DMA Channel 5 Address Register
    mov dx, 0xC4        ; Channel 5 Base Address Port
    out dx, al          ; Low byte
    delay
    mov al, ah
    out dx, al          ; High byte
    delay

    ; Send Page Register (Bits 16-23 of original address)
    xor eax, eax
    add eax, audio_buffer
    shr eax, 16
    out 0x8B, al        ; Channel 5 Page Port
    delay

    ; Send Word Count (Total Bytes / 2) - 1
    mov ax, buffer_len_bytes
    shr ax, 1           ; Convert bytes to words
    dec ax              ; Count is 0-indexed
    mov dx, 0xC6        ; Channel 5 Word Count Port
    out dx, al          ; Low byte
    delay
    mov al, ah
    out dx, al          ; High byte
    delay

    ; Unmask (Enable) DMA Channel 5
    mov al, 0x01        ; Clear mask bit, Channel 5
    out 0xD4, al
    delay

    ; --- Step 3: Configure DSP Sampling Rate (44100 Hz) ---
    mov al, 0x41        ; DSP Command 0x41: Set Output Sampling Rate
    call dsp_write
    mov ax, 44100       
    mov al, ah          ; High byte
    call dsp_write
    mov ax, 44100
    call dsp_write      ; Low byte

    ; --- Step 4: Start 16-Bit DSP Playback ---
    mov al, 0xb6        ; Command 0xB6: 16-bit  FIFO Playback
    call dsp_write
    mov al, 0x30        ; Mode: Stereo, Signed PCM
    call dsp_write

    ; Send Block Size in Sample Words (Total Bytes / 2) - 1
    mov ax, buffer_len_bytes
    shr ax, 1           
    dec ax              
    mov bl, al
    mov al, al          ; Low byte
    call dsp_write
    mov al, ah          ; High byte
    call dsp_write
    mov  dword  [0xd*4],        handler ;its fine (handler < 0x10000)
    mov  [transfer],            0
    sti
    in  al, 0x21        ; READ:  Get the current mask byte from the Master PIC
    and al, 0xDF        ; AND:   Clear bit 5 (0xDF = 11011111b) while keeping all other masks intact
    out 0x21, al        ; WRITE: Send the updated byte back to the Master PIC
    ; --- Step 5: FIXED HARDWARE POLLING LOOP ---
    ; Instead of polling the glitchy 16-bit DMA counter, we poll the 
    ; Sound Blaster DSP interrupt status port until it flags completion.
    ret
dsp_write:
    push dx
    push ax
.wait:
    mov dx, [sb_base]
    add dx, 0x0C        ; Write Status Port
    in al, dx
    and al, 0x80        ; Check if DSP busy
    jnz .wait
    pop ax
    mov dx, [sb_base]
    add dx, 0x0C        ; Write Data Port
    out dx, al
    pop dx
    ret
handler:
    pusha
    push        esi
    push        edi
    mov al, 0x05
    out 0xD4, al        ; Lock DMA Channel 5 back down

    ; --- Step 7: Clear Hardware Lines ---
    mov dx, [sb_base]
    add dx, 0x0F        ; Acknowledge 16-bit audio on SB16
    in al, dx

    mov al, 0x20
    out 0x20, al        ; Clear PIC
    out 0xA0, al
    call      routine_of_sb16_driver
 ; --- Step 6: Instantly Mask DMA to stop subsequent buzzing ---


    mov ecx,    buffer_len_bytes
    dec ecx
  .loop:
    mov byte    [audio_buffer+ecx],     0
    loop        .loop
    ;int3
    call    process_audio_rewrite
    mov     [transfer], 1
    ; Success Message
    pop       edi
    pop       esi
    popa
    iret
sb_base             dw 0x220
transfer            db 0
buffer_len_bytes   = 0x4000
audio_buffer = 0x565a0