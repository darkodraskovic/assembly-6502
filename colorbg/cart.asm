        processor 6502

        include "../atari2600/vcs.asm"
        include "../atari2600/macro.asm"

        seg code
        org $F000               ; defines the origin of the ROM

Start:          
        CLEAN_START             ; clears stack, all TIA registers and RAM to 0
        
Loop:          
        lda #$5A                ; load col val in A ($1E is NTSC yellow)
        sta COLUBK              ; store A to to BackgroundColor Address $09

        jmp Loop
        
        org $FFFC
        .word Start             ; reset vector at $FFFC (where prog starts)
        .word Start             ; interrupt vector at $FFFE (unused in VCS)
        
