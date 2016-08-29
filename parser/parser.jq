# parser.jq

def accumulator(name):
    {
        name: name,
        data: .,
        range: [
            first.range[0],
            last.range[1]
        ]
    }
    ;

def apply(name; open; close):
    (.tokens | .[0]) as $tok
    | if $tok.name == "expression" or $tok.name =="block" then
        (.tokens | .[0]).data = (
            {tokens: $tok.data, ast: []}
            | apply(name; open; close).ast
        )
    else
        .
    end
    | (.tokens | .[0]) as $tok
    | .tokens = .tokens[1:]
    | if $tok.name == close or $tok.name == null then
        . # return
    else
        if $tok.name == open then
            .ast as $ast
            | .ast = []
            | apply(name; open; close)
            | .ast = $ast + [.ast | accumulator(name)]
        else
            .ast = .ast + [$tok]
        end
        | apply(name; open; close)
    end;

def apply_parentheses:
    apply("expression"; "open_round"; "close_round");

def apply_curlies:
    apply("block"; "open_curly"; "close_curly");

def apply_angles:
    apply("struct"; "open_angle"; "close_angle");

def accumulators:
    {tokens: ., ast: []}
    | apply_parentheses.ast
    | {tokens: ., ast: []}
    | apply_curlies.ast
    #| apply_angles.ast
    ;

