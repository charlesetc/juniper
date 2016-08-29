# main.jq

import "token" as token;
import "parser" as parser;

def add_numbers:
    [., [range(. | length)]]
    | transpose
    | map({ char: .[0], char_number: .[1] })
    ;

def main:
    split("")
    | add_numbers
    | [token::tokens]
    | parser::parentheses
    ;

main
