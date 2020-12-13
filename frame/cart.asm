        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        seg code
        org $F000               ; defines the origin of the ROM

Start:
        CLEAN_START             ; clears stack, all TIA registers and RAM to 0

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

;;; Draw 192 VISIBLE scanlines (kernel)

        ldx #$B6
        stx COLUBK              ; set the background color

        ldx #$84
        stx COLUPF              ; set the playfield color
        ldy 1
        sty CTRLPF              ; reflect playfield left half (CTRLPF register > D0 means reflect)

        ldx #192
Visible:
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
