# token.jq

def take_while(f):
    {lines: ., index: 0} 
    | [
        while(
            .lines[.index:] | map(.char) | f;
            {lines: .lines, index: (.index+1)}
        )
    ]
    | last
    | {token: .lines[:.index+1], text: .lines[.index+1:]}
    ;

def alias(name):
    .token = if .token != null then
        {
            name: name,
            data: .token | map(.char) | add,
            range: .token | map(.char_number) | [first, last+1]
        }
        else null end;

def space:
    take_while(.[0]==" " or .[0]=="\t") | alias("space");

def number:
    take_while(.[0] > "0" and .[0] < "9") | alias("number");

def break_symbols:
    "();:{}[].,-+* \n\t";

def ident:
     take_while(.[0] | inside(break_symbols) | not) | alias("ident");

def quote(q):
    .[1:]
    | take_while(.[0]!=q)
    | .text = .text[1:]
    | alias("string")
    ;

def if_chars(chars; f):
    if (.[:(chars | length)] | map(.char) | add) == chars then
        f
    else
        empty
    end;

def advance(n):
    .text = .text[n:];

def line_comment:
    if_chars("--"; take_while(.[0]!="\n"))
    | alias("comment");

def multiline_comment:
    if_chars("(*"; take_while(.[:2]| add !="*)"))
    # trim the '(*' at the beginning of the token
    | .token = .token[2:]
    # and ignore the '*)' remaining to be parsed
    | advance(2)
    | alias("comment")
    ;

def make_token(name):
    {
        token: {
            name: name,
            range: .[0].char_number | [., .+1],
        },
        text: .[1:],
    };

def single_token:
    .[0].char as $char
    | if $char == "(" then
        multiline_comment
        // make_token("open_round")
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
        line_comment
        // make_token("hyphen")
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
