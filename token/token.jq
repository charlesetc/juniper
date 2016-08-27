
def space:
    {tokens: ., index: 0, acc: []}
    | while(.tokens[.index]==" "; {tokens: .tokens, index: (.index+1), acc: (.acc + [" "])});
# def single_token: number // space;
def tokens: split("") | space;
