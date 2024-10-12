#!/bin/bash
set -x -e
go install github.com/homeport/termshot/cmd/termshot@main
cargo install onefetch
COMMIT_COUNT=$(git log --pretty=format:'' | wc -l | xargs)
echo Commit count: $COMMIT_COUNT
if (( $COMMIT_COUNT % 69 == 0 ))   
then
    echo "easter egg, yay!"
    termshot --show-cmd --filename Writerside/assets/onefetch.png -- "onefetch --number-of-authors 0 -a html | lolcat"
else
    echo "normal. Yay."
    termshot --show-cmd --filename Writerside/assets/onefetch.png -- "onefetch --number-of-authors 0 -a c++"
fi