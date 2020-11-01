        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        seg code
        org $F000               ; defines the origin of the ROM

Start:
        CLEAN_START             ; clears stack, all TIA registers and RAM to 0

NextFrame:

;;; VSYNC

        lda #2
        sta VSYNC               ; turn on VSYNC

        ;; generate 3 lines of VSYNC
        sta WSYNC               ; first scanline
        sta WSYNC               ; second scanline
        sta WSYNC               ; third scanline

        lda #0
        sta VSYNC               ; turn off VSYNC

;;; VBLANK

        lda #2
        sta VBLANK              ; turn on VBLANK

        ;; let TIA output 37 scanlines of VBLANK
        ldx #37                 ; X = 37 (to count 37 scanlines)
LoopVBlank:
        sta WSYNC               ; hit WSYNC and wait for the next scanline
        dex                     ; x--
        bne LoopVBlank          ; loop while X != 0

        lda #0
        sta VBLANK              ; turn off VBLANK

;;; Draw 192 visible scanlines (kernel)

        ldx #192                ; counter for visible scanlines
LoopVisible:
        stx COLUBK              ; set the background color
        sta WSYNC               ; wait for next scanline
        dex                     ; x--
        bne LoopVisible         ; loop while X != 0

;;; Output 30 VBLANK lines (overscan) to complete frame

        lda #2
        sta VBLANK              ; turn on VBLANK

        ldx #30                 ; counter for 30 scanlines
LoopOverscan:
        sta WSYNC               ; wait for the next scanline
        dex                     ; X--
        bne LoopOverscan        ; loop while X != 0

        jmp NextFrame

;;;  Complete ROM size to 4KB

        org $FFFC
        .word Start             ; reset vector at $FFFC (where prog starts)
        .word Start             ; interrupt vector at $FFFE (unused in VCS)
