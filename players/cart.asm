        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DECLARE VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

        seg.u Variables     ; seg.u is uninitialised segment
        org $80             ; RIOR (RAM) start address

P0Height ds 1           ; define space of 1 byte for player 0 height
P1Height ds 1           ; define space of 1 byte for player 1 height
SbHeight ds 1           ; define space of 1 byte for score height

;;; alternatively
;; P0Height .byte
;; P1Height .byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; ROM CODE segment starts at $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        seg Code
        org $F000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Clean RAM and TIA and init vars
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
        CLEAN_START    ; macro to clean memory and TIA

        ldx #$80       ; background color
        stx COLUBK

        lda #%1111     ; playfield color
        sta COLUPF

        lda #10        ; A = 10
        sta P0Height   ; P0Height = A
        sta P1Height   ; P1Height = A
        sta SbHeight   ; SbHeight = A

        lda #$48       ; player 0 color
        sta COLUP0

        lda #$C6       ; player 1 color
        sta COLUP1

        ldy #%00000010 ; CTRLPF D1 set to 1 means (score)
        sty CTRLPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Start new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; VSYNC

Start:
        lda #2
        sta VBLANK     ; turn VBLANK on
        sta VSYNC      ; turn VSYNC on

        REPEAT 3
            sta WSYNC  ; first three VSYNC scanlines
        REPEND

        lda #0
        sta VSYNC      ; turn VSYNC off

;;; VBLANK

        ldx #37
VBlank:
        sta WSYNC
        dex
        bne VBlank

        lda #0
        sta VBLANK     ; turn VBLANK off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the 192 VISIBLE SCANLINES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VisibleScanlines:

;;; 10 empty scanlines at the top of the frame
        ldx #10
Background1:
        sta WSYNC
        dex
        bne Background1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 10 scanlines for the scoreboard number
;; Data is in array of bytes defined at address NumberBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldy #0
ScoreboardLoop:
        lda NumberBitmap,Y
        sta PF1
        sta WSYNC
        iny
        cpy SbHeight
        bne ScoreboardLoop

        lda #0
        sta PF1        ; disable playfield

        ldx #50
Background2:
        sta WSYNC
        dex
        bne Background2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 10 scanlines per player graphics
;;; Data is in array of bytes defined at address PlayerBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldy #0
Player0Loop:
        lda PlayerBitmap,Y
        sta GRP0
        sta WSYNC
        iny
        cpy P0Height
        bne Player0Loop

        lda #0
        sta GRP0       ; disable player 0 graphics

        ldy #0
Player1Loop:
        lda PlayerBitmap,Y
        sta GRP1
        sta WSYNC
        iny
        cpy P1Height
        bne Player1Loop

        lda #0
        sta GRP1       ; disable player 1 graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Draw the remaining 102 scanlines (192-90)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #102
Background3:
        sta WSYNC
        dex
        bne Background3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Output 30 VBLANK overscan lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ldx #30
Overscan:
        sta WSYNC
        dex
        bne Overscan

        jmp Start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; BITMAPS - add these bytes in the last ROM addresses
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        org $FFE8
PlayerBitmap:
        .byte #%11111111
        .byte #%11111111
        .byte #%10011001
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
        .byte #%11111111
        .byte #%11000011
        .byte #%11111111
        .byte #%11111111

        org $FFF2
NumberBitmap:
        .byte #%00001110
        .byte #%00001110
        .byte #%00000010
        .byte #%00000010
        .byte #%00001110
        .byte #%00001110
        .byte #%00001000
        .byte #%00001000
        .byte #%00001110
        .byte #%00001110

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Complete ROM size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    org $FFFC
    .word Init
    .word Init
