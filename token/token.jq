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

def alias(name):
    .token = if .token != null then
        {name: name, data: .token | add}
        else null end;

def space:
    take_while(.==" " or .=="\t") | alias("space");

def number:
    take_while(. > "0" and . < "9") | alias("number");

def break_symbols:
    "();:{}[].,* \n\t";

def ident:
     take_while(inside(break_symbols) | not) | alias("ident");

def quote(q):
    .[1:]
    | take_while(.!=q)
    | .text = .text[1:]
    | alias("string")
    ;

def comment:
    if (.[:2] | add) == "--" then
        take_while(.!="\n")
    else
        empty
    end
    | alias("comment");

def make_token(name): {token: {name: name}, text: .[1:]};

def single_token:
    .[0] as $char
    | if $char == "(" then
        make_token("open_round")
    elif $char == ")" then
        make_token("close_round")
    elif $char == "{" then
        make_token("open_curly")
    elif $char == "}" then
        make_token("close_curly")
    elif $char == "." then
        make_token("dot")
    elif $char == "\n" or $char == ";" then
        make_token("newline")
    elif $char == "-" then
        comment // make_token("hyphen")
    elif $char == "*" then
        make_token("star")
    elif $char == ":" then
        make_token("colon")
    elif $char == " " then
        space
    elif $char == "\"" or $char == "'" then
        quote($char)
    elif $char > "0" and $char < "9" then
        number
    elif $char == null then
        null
    else 
        # treat it as an ident
        ident
    end;

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
