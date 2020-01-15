#!/bin/sh

# Split a file path and print only the last component

IN=$1

tokens=$(echo $IN | tr "/" "\n")

last_token=""
for tok in $tokens
do
 last_token=$tok
done

echo $last_token
