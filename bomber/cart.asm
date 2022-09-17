        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Define consts
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JET_HEIGHT = 8                  ; # rows in the lookup table
BOMBER_HEIGHT = 8

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Init RAM vars and TIA regs
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        seg.u   Variables
        org     $80

JetXPosition            byte            ; player0 X pos
JetYPosition            byte            ; player0 Y pos
BomberXPosition         byte            ; player1 X pos
BomberYPosition         byte            ; player1 Y pos
JetSpritePtr            word            ; pointer to player0 sprite lookup table
JetColorPtr             word            ; pointer to player0 color lookup table
BomberSpritePtr         word            ; pointer to player1 sprite lookup table
BomberColorPtr          word            ; pointer to player1 color lookup table

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        seg     code
        org     $F000               ; defines the origin of the ROM

Start:          
        CLEAN_START                 ; clears stack, all TIA registers and RAM to 0

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Init ptrs to lookup table addrs
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        lda     #<JetSpriteFrame0       ; low-byte of JetSpriteFrame0
        sta     JetSpritePtr
        lda     #>JetSpriteFrame0       ; high-byte of JetSpriteFrame1
        sta     JetSpritePtr+1
        
        lda     #<JetColorFrame0       ; low-byte of JetColorFrame0
        sta     JetColorPtr
        lda     #>JetColorFrame0       ; high-byte of JetColorFrame1
        sta     JetColorPtr+1

        lda     #<BomberSpriteFrame0       ; low-byte of BomberSpriteFrame0
        sta     BomberSpritePtr
        lda     #>BomberSpriteFrame0       ; high-byte of BomberSpriteFrame1
        sta     BomberSpritePtr+1
        
        lda     #<BomberColorFrame0       ; low-byte of BomberColorFrame0
        sta     BomberColorPtr
        lda     #>BomberColorFrame0       ; high-byte of BomberColorFrame1
        sta     BomberColorPtr+1
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Init RAM vars and TIA regs
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        lda     #60
        sta     JetXPosition
        lda     #10
        sta     JetYPosition
        
        lda     #83
        sta     BomberXPosition
        lda     #54
        sta     BomberYPosition
        
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

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
        ;; Declare ROM lookup tables
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;---Graphics Data from PlayerPal 2600---

JetSpriteFrame0:        
        .byte #%00100100;$C8
        .byte #%10011001;$5A
        .byte #%11111111;$5A
        .byte #%01111110;$5A
        .byte #%00111100;$5A
        .byte #%00011000;$5A
        .byte #%00011000;$5A
        .byte #%00100100;$36
JetSpriteFrame1:        
        .byte #%00100100;$C8
        .byte #%01011010;$5A
        .byte #%01111110;$5A
        .byte #%00111100;$5A
        .byte #%00111100;$5A
        .byte #%00011000;$5A
        .byte #%00011000;$5A
        .byte #%00011000;$36
;---End Graphics Data---


;---Color Data from PlayerPal 2600---

JetColorFrame0: 
        .byte #$C8;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$36;
JetColorFrame1: 
        .byte #$C8;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$5A;
        .byte #$36;
;---End Color Data---

;---Graphics Data from PlayerPal 2600---

BomberSpriteFrame0:     
        .byte #%01011010;$32
        .byte #%00100100;$32
        .byte #%00100100;$32
        .byte #%11110111;$28
        .byte #%00100100;$32
        .byte #%11101111;$28
        .byte #%00100100;$32
        .byte #%00011000;$32
;---End Graphics Data---


;---Color Data from PlayerPal 2600---

BomberColorFrame0:      
        .byte #$32;
        .byte #$32;
        .byte #$32;
        .byte #$28;
        .byte #$32;
        .byte #$28;
        .byte #$32;
        .byte #$32;
;---End Color Data---

        ;; Complete ROM size with exactly 4KB
        org     $FFFC
        .word   Start             ; reset vector at $FFFC (where prog starts)
        .word   Start             ; interrupt vector at $FFFE (unused in VCS)
        
