# main.jq

import "token" as token;
import "parser" as parser;
import "parser/lambda" as lambda;

def add_numbers:
    [., [range(. | length)]]
    | transpose
    | map({ char: .[0], char_number: .[1] })
    ;

def main:
    split("")
    | add_numbers
    | [token::tokens]
    | parser::accumulators
    | lambda::lambdas
    ;

main
