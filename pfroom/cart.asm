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
        sta VBLANK              ; turn on VBLANK
        
        ;; generate 3 lines of VSYNC
        REPEAT 3
                sta WSYNC               ; second scanline
        REPEND

        lda #0
        sta VSYNC               ; turn off VSYNC

;;; VBLANK

        ;; let TIA output 37 scanlines of VBLANK
        REPEAT 37
        sta WSYNC               ; hit WSYNC and wait for the next scanline
        REPEND

        lda #0
        sta VBLANK              ; turn off VBLANK

;;; Draw 192 VISIBLE scanlines (kernel)

        ldx #$B6
        stx COLUBK              ; set the background color

        ldx #$84
        stx COLUPF              ; set the playfield color
        ldy 1
        sty CTRLPF              ; reflect playfield left half (CTRLPF register > D0 means reflect)

;;; 7 scanlines of no playfield
        REPEAT 7
                sta WSYNC       ; wait for next scanline
        REPEND

;;; 7 scanlines of reflected horizontal line
        ldy #$e0                ; 0xe0 = 0b11100000 - first four bits are used and reversed to yield a pattern
        sty PF0
        ldy #$ff                ; 0xff = 0b11111111
        sty PF1
        sty PF2

        REPEAT 7
                sta WSYNC               ; wait for next scanline
        REPEND

;;; 164 scanlines of reflected vertical line
        ldy #%00100000          ; high nibble is reversed to yield a pattern; low nibble is ignored
        sty PF0
        ldy #0
        sty PF1
        ldy #%10000000        
        sty PF2

        REPEAT 164
                sta WSYNC               ; wait for next scanline
        REPEND


;;; 7 scanlines of reflected horizontal line
        ldy #$e0
        sty PF0
        ldy #%11111111
        sty PF1
        sty PF2

        REPEAT 7
                sta WSYNC               ; wait for next scanline
        REPEND

;;; 7 scanlines of no playfield
        ldy #0
        sty PF0
        sty PF1
        sty PF2

        REPEAT 7
                sta WSYNC
        REPEND

;;; Output 30 VBLANK lines (overscan) to complete frame

        lda #2
        sta VBLANK              ; turn on VBLANK

        REPEAT 30
                sta WSYNC               ; wait for the next scanline
        REPEND

        jmp NextFrame

;;;  Complete ROM size to 4KB

        org $FFFC
        .word Start             ; reset vector at $FFFC (where prog starts)
        .word Start             ; interrupt vector at $FFFE (unused in VCS)
