
if [[ $# -eq 0 || $1 == "-h" || $1 == "--help" ]]; then
    printf "USAGE: ./reassemble_and_test.sh project_directory binary_path [compiler_flags]
 Take a project directory where the main makefile is located
 and the relative path of the main executable within the directory and:
 -Rebuild the project
 -Disassemble the binary
 -Reassemble the binary (substituting the old one and saving the old one in 'binary'.old)
 -Run the makefile's tests

 The reassembly uses the 'compiler_flags' arguments

 Example:
 ./reasemble_and_test.sh ../real_world_examples/grep-2.5.4 src/grep -lpcre

-The assembly code will be in ../real_world_examples/grep-2.5.4/src/grep.s
-The old binary will be  ../real_world_examples/grep-2.5.4/src/grep.old
"   
    exit
fi





red=`tput setaf 1`
green=`tput setaf 2`
normal=`tput sgr0`


dir=$1
exe=$2
shift
shift
compiler="gcc"

if [[ $# > 0 && $1 == "g++" ]]; then
    compiler="g++"
    shift
fi


printf "# Rebuilding project $dir\n"
if !( make clean -e -C $dir &>/dev/null  && make -e -C $dir &>/dev/null); then
    printf "# ${red}Initial compilation failed${normal}\n"
    exit 1
fi

#printf "# Stripping binary\n"
#strip --strip-unneeded "$dir/$exe"

printf "# Disassembling $exe into $exe.s\n"
if !(time(./disasm "$dir/$exe" -asm > "$dir/$exe.s") 2>/tmp/time.txt); then
    printf "# ${red}Disassembly failed${normal}\n"
    exit 1
fi
time=$(cat /tmp/time.txt| grep user| cut -f 2)
size=$(stat --printf="%s" "$dir/$exe")
printf "#Stats: Time $time Size $size\n"

printf "  OK\n"
printf "Copying old binary to $dir/$exe.old\n"
cp $dir/$exe $dir/$exe.old
printf "# Reassembling...\n"

if !($compiler "$dir/$exe.s" $@ -o  "$dir/$exe"); then
    printf "# ${red}Reassembly failed ${normal}\n"
    exit 1
fi

printf "  OK\n"
printf "# Testing\n"
if !(make check -C $dir); then
    printf "# ${red}Testing FAILED ${normal}\n\n"
else
    printf "# ${green}Testing SUCCEED ${normal}\n\n"
fi



