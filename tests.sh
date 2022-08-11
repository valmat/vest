#/usr/bin/env bash

#force=--force
force=

cd "$(dirname "$0")"

test_dir="$1"
if [ -z $1 ]; then
    test_dir="source"
fi
rdmd_options="$2"
if [ -z $2 ]; then
    rdmd_options=" -w -debug"
fi

cd $test_dir

reset="\033[0m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
blue="\033[1;34m"
magenta="\033[1;35m"
cyan="\033[1;36m"
gray="\033[0;37m"


echo -e "\n${magenta} Tests for ${cyan}${test_dir}${reset}\n"

padchars="___________________________________________________________________"


for file in `find -L . -type f -name '*.d'`; do
    cmd="rdmd -unittest -main -i $force $rdmd_options $file"
    echo -e "  ${gray}${cmd}${reset}"
    if ! $cmd; then
        printf "  ${yellow}%s${gray}%s${red}[Test failed]${reset}\n" $file "${padchars:${#file}}"
        exit 1;
    else
        printf "  ${yellow}%s${gray}%s${green}[Test passed]${reset}\n" $file "${padchars:${#file}}"
    fi
done;

echo -e "\n${yellow}$padchars\n\n\t\t${green}All tests passed successfully!\n${yellow}$padchars\n${reset}\n"


