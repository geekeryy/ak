#!/bin/bash
# Bash Menu Script Example
trap 'onCtrlC' INT
function onCtrlC () {
    sleep 100
    echo 'Ctrl+C is captured'
    trap 'exit 1' INT
}

while true; do
    echo 'I am working!'
     sleep 1
done
PS3='Please enter your choice: '
options=("Option 12" "Option 22" "Option 32" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Option 1")
            echo "you chose choice 1"
            ;;
        "Option 2")
            echo "you chose choice 2"
            ;;
        "Option 3")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done