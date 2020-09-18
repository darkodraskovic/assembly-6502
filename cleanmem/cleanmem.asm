        processor 6502
        seg code
        org $F000               ; define code origin at $F000

Start:
        sei                     ; disable interrupts
        cld                     ; disable BCD decimal mode, i.e. cl(lear) d flag
        ldx #$FF                ; loads x reg with #$FF
        txs                     ; transfer x reg to S(tack)P(ointer) reg

;;; Clears the Zero Page region ($00 to $FF)
;;; I.e. the entire TIA reg spc and RAM

        lda #0                  ; accu reg = 0
        ldx #$FF                ; X reg = #$FF

MemLoop:
        sta $0,X                ; store val in accu (#0) in mem pos $0 + val in X
        dex                     ; X--
        bne MemLoop             ; loop until X == 0 (z-flag set)

;;; Fill ROM size to 4KB

        org $FFFC
        .word Start             ; reset vector at $FFFC (where prog starts)
        .word Start             ; interrupt vector at $FFFE (unused in VCS)

