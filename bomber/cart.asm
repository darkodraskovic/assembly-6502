        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        seg.u   Variables
        org     $80

JetXPosition            byte            ; player0 X pos
JetYPosition            byte            ; player0 Y pos
BomberXPosition         byte            ; player1 X pos
BomberYPosition         byte            ; player1 Y pos

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        seg     code
        org     $F000               ; defines the origin of the ROM

Start:          
        CLEAN_START                 ; clears stack, all TIA registers and RAM to 0

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Init RAM vars and TIA regs
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        lda     #60
        sta     JetXPosition
        lda     #10
        sta     JetYPosition

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Display and frame render loop
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FrameStart:
        
        ;; Display 3 VSYNC and 37 VBLANK scanlines
        lda     #2
        sta     VBLANK          ; turn on vertical blank
        sta     VSYNC           ; turn on vertical sync

        REPEAT  3               ; wait 3 vertical sync lines
        sta     WSYNC
        REPEND
        
        lda     #0
        sta     VSYNC           ; turn off vertical sync

        ldx     #37             ; wait 37 lines of vertical blank
VBlankLoop:     
        sta     WSYNC
        dex
        bne     VBlankLoop
        
        sta     VBLANK          ; turn off vertical blank

        lda     #$84            ; blue
        sta     COLUBK
        lda     #$c4            ; green
        sta     COLUPF

        lda     #$f0
        sta     PF0
        lda     #$fc
        sta     PF1
        lda     #0
        sta     PF2
        lda     #00000001       ; enable PF reflection
        sta     CTRLPF

        ;; Display 192 visible scanlines
        ldx     #192
VisibleLineLoop:
        sta     WSYNC
        dex
        bne     VisibleLineLoop

        ;; Display 30 overscan scanlines
        lda     #2
        sta     VBLANK          ; turn on VBLANK
        
        ldx     #30
OverscanLoop:
        dex
        bne     OverscanLoop
        
        lda     #0
        sta     VBLANK          ; turn off VBLANK
        
        jmp     FrameStart

        ;; Complete ROM size with exactly 4KB
        org     $FFFC
        .word   Start             ; reset vector at $FFFC (where prog starts)
        .word   Start             ; interrupt vector at $FFFE (unused in VCS)
        
