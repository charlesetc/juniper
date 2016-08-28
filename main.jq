import "token" as token;

def main:
    split("")
    | [., [range(. | length)]]
    | transpose
    | map({ char: .[0], char_number: .[1] })
    | token::tokens
    ;

main
