# token.jq

def take_while(f):
    {lines: ., index: 0} 
    | [
        while(
            .lines[.index] | f;
            {lines: .lines, index: (.index+1)}
        )
    ]
    | last
    | {token: .lines[:.index+1], text: .lines[.index+1:]}
    ;

def space:
    take_while(.==" ");

def number:
    take_while(. > "0" and . < "9");

def make_token(name): {token: name, text: .[1:]};

def single_char_token:
    .[0] as $char
    | if $char == "(" then
        make_token("open")
    elif $char == ")" then
        make_token("close")
    else null end;

def TOKENS: [space, number, single_char_token];

def single_token:
    # not the most efficient
    [
        TOKENS
        | .[]
        | select(.token!=null)
    ]
    | first
    ;

def tokens:
    {text: ., tokens: []}
    | [
        while(
            .text != null;
            {
                text: .text | single_token.text,
                tokens: (.tokens + (.text | [single_token.token]))
            }
        )
    ]
    | .[].tokens
    | last
    | select(.!=null)
    ;
