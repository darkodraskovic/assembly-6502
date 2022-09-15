validate_exit() {
    if [ $? != 0 ]; then
        exit 1
    fi
}

DASM_EXE=dasm
STELLA_EXE=stella

SRC_DIR=cleanmem
ROOT_DIR=~/Development/assembly-6502
DEBUG=false

WIN=false
if [ "$OSTYPE" = "msys" ]; then
    WIN=true
    ROOT_DIR="c:/Users/darko/Development/assembly-6502"
    # TODO:
    # DASM_EXE=dasm
    # STELLA_EXE=stella
fi

while getopts "s:d" option; do
    case $option in
        s)
            SRC_DIR=$OPTARG
            ;;
        d)
            DEBUG=true
            ;;        
    esac
done


cd $SRC_DIR

$DASM_EXE *.asm -f3 -v0 -ocart.bin -lcart.lst -scart.sym
validate_exit

if [ $DEBUG == true ]; then
    stella -debug cart.bin
    exit
fi

$STELLA_EXE cart.bin

