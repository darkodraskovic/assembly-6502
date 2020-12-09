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

;;; Draw 192 VISIBLE scanlines (kernel)

        ldx #$B6
        stx COLUBK              ; set the background color

        ldx #$84
        stx COLUPF              ; set the playfield color
        ldy 1
        sty CTRLPF              ; reflect playfield left half

;;; 7 scanlines of no playfield
        ldx #7
LoopPF1:
        sta WSYNC               ; wait for next scanline
        dex                     ; x--
        bne LoopPF1             ; loop while X != 0

;;; 7 scanlines of reflected horizontal line
        ldy #$e0                ; 0xe0 = 0b11100000 - first four bits are used and reversed to yield a pattern
        sty PF0
        ldy #$ff                ; 0xff = 0b11111111
        sty PF1
        ldy #$ff                ; 0xff = 0b11111111
        sty PF2

        ldx #7
LoopPF2:
        sta WSYNC               ; wait for next scanline
        dex                     ; x--
        bne LoopPF2             ; loop while X != 0

;;; 164 scanlines of reflected vertical line
        ldy #$20                ; 0x20 = 00100000 - first four bits are used and reversed to yield a pattern
        sty PF0
        ldy #0
        sty PF1
        sty PF2

        ldx #164
LoopPF3:
        sta WSYNC               ; wait for next scanline
        dex                     ; x--
        bne LoopPF3             ; loop while X != 0


;;; 7 scanlines of reflected horizontal line
        ldy #$e0
        sty PF0
        ldy #$ff
        sty PF1
        ldy #$ff
        sty PF2

        ldx #7
LoopPF4:
        sta WSYNC               ; wait for next scanline
        dex                     ; x--
        bne LoopPF4             ; loop while X != 0

;;; 7 scanlines of no playfield
        ldy #0
        sty PF0
        sty PF1
        sty PF2

        ldx #7
LoopPF5:
        sta WSYNC
        dex
        bne LoopPF5

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
