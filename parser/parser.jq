# parser.jq

def expression:
    {
        name: "expression",
        data: .,
        range: [
            first.range[0],
            last.range[1]
        ]
    }
    ;

def apply_parentheses:
    (.tokens | .[0]) as $tok
    | .tokens = .tokens[1:]
    | if $tok.name == "close_round" or $tok.name == null then
        . # return
    else
        if $tok.name == "open_round" then
            .ast as $ast
            | .ast = []
            | apply_parentheses
            | .ast = $ast + [.ast | expression]
        else
            .ast = .ast + [$tok]
        end
        | apply_parentheses
    end;

def parentheses:
    {tokens: ., ast: []}
    | apply_parentheses.ast
    ;

