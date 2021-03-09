        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        seg.u Variables
        org $80

PlayerYPos byte                 ; player sprite y coordinate
PlayerHeight equ 9              ; player sprite y coordinate

        seg code
        org $F000               ; defines the origin of the ROM

Start:
        CLEAN_START             ; clears stack, all TIA registers and RAM to 0
        lda #192
        sta PlayerYPos
        lda #$48
        sta COLUP0

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

        ldx #$B7
        stx COLUBK              ; set the background color

        ldx #$85
        stx COLUPF              ; set the playfield color
        ldy 1
        sty CTRLPF              ; reflect playfield left half (CTRLPF register > D0 means reflect)
        ;; ldy #%10110000
        ;; sty PF0
        ;; ldy #%11111101
        ;; sty PF1
        ;; ldy #%11111101
        ;; sty PF2

        ldx #192                ; there are 192 scanlines
Visible:
        sta WSYNC
        txa                     ; scanline -> A
        sbc PlayerYPos          ; m = scanline - PlayerYpos
        bpl ContinueVisible     ; if m >= 0
        adc PlayerHeight        ; n < 0; n = m + PlayerHeight
        bpl DrawPlayer          ; if 0 <= n < PlayerHeight

ContinueVisible:
        dex
        bne Visible

Animation:
        dec PlayerYPos
        lda PlayerYPos
        sec                     ; set carry
        cmp PlayerHeight        ; m = PlayerYpos - PlayerHeight
        bcs ContinueAnimation   ; carry set means m >= 0
        lda #192                ; else reset player y pos
        sta PlayerYPos

ContinueAnimation:

;;; Output 30 VBLANK lines (overscan) to complete frame

        lda #2
        sta VBLANK              ; turn on VBLANK

        ldx #30
Overscan:
        sta WSYNC               ; wait for the next scanline
        dex
        bne Overscan

        jmp Frame

DrawPlayer:
        tay                     ; Y = idx of player bmp line
        lda PlayerBitmap,Y      ; A = the address of player bmp + Y; A = Yth byte
        sta GRP0
        lda PlayerColor,Y       ; A = the address of player col + Y; A = Yth byte
        sta COLUP0
        jmp ContinueVisible

;;; Inverted bitmap: first draw the last line, than second to last, etc.
;;; Reach the first line when the (scanline - player pos) + player height eq 0; this sets GRP0 to zero
PlayerBitmap:
        .byte %00000000 ; |        |
        .byte %11000000 ; |XX      |
        .byte %11110000 ; |XXXX    |
        .byte %11111100 ; |XXXXXX  |
        .byte %11111111 ; |XXXXXXXX|
        .byte %11111111 ; |XXXXXXXX|
        .byte %11111100 ; |XXXXXX  |
        .byte %11110000 ; |XXXX    |
        .byte %11000000 ; |XX      |

PlayerColor:
        byte #$48
        byte #$58
        byte #$68
        byte #$78
        byte #$88
        byte #$98
        byte #$88
        byte #$78
        byte #$68
        byte #$58

;;;  Complete ROM size to 4KB

        org $FFFC
        .word Start             ; reset vector at $FFFC (where prog starts)
        .word Start             ; interrupt vector at $FFFE (unused in VCS)
