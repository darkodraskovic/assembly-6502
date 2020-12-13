        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        seg code
        org $F000               ; defines the origin of the ROM

Start:
        CLEAN_START             ; clears stack, all TIA registers and RAM to 0

Init:
        ldx #$B6
        stx COLUBK              ; set the background color

        ldx #$84
        stx COLUPF              ; set the playfield color
        ldy #0
        sty CTRLPF              ; reflect playfield left half (CTRLPF register > D0 means reflect)

Frame:

;;; VSYNC

        lda #2
        sta VSYNC               ; turn on VSYNC
        sta VBLANK              ; turn on VBLANK
        
        ;; generate 3 lines of VSYNC
        REPEAT 3
                sta WSYNC               ; second scanline
        REPEND

        lda #0
        sta VSYNC               ; turn off VSYNC

;;; VBLANK

        ;; let TIA output 37 scanlines of VBLANK
        ldx #37
VBlank: 
        sta WSYNC               ; hit WSYNC and wait for the next scanline
        dex
        bne VBlank

        lda #0
        sta VBLANK              ; turn off VBLANK

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Draw 192 VISIBLE scanlines (kernel)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

        ldx #192
        ldy #0
        jmp Visible

PFLine0:
        ldy #0
        lda #%00000000
        sta PF0
        lda #%11111111
        sta PF1
        lda #%00000000
        sta PF2
        jmp Draw

PFLine1:
        lda #%11110000
        sta PF0
        lda #%00000000
        sta PF1
        lda #%11111011
        sta PF2
        jmp Draw

Visible:
        iny
        cpy #2                  ; alternate pattern every n-th line
        beq PFLine0
        bne PFLine1
Draw:     
        sta WSYNC
        dex
        bne Visible

;;; Output 30 VBLANK lines (overscan) to complete frame

        lda #2
        sta VBLANK              ; turn on VBLANK

        ldx #30
Overscan:       
        sta WSYNC               ; wait for the next scanline
        dex
        bne Overscan

        jmp Frame

;;;  Complete ROM size to 4KB

        org $FFFC
        .word Start             ; reset vector at $FFFC (where prog starts)
        .word Start             ; interrupt vector at $FFFE (unused in VCS)
