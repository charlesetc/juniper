
def take_while(f):
    {lines: ., index: 0} 
    | [
        while(
            .lines[.index] | f;
            {lines: .lines, index: (.index+1)}
        )
    ] | last | {token: .lines[:.index+1], text: .lines[.index+1:]};

def space:
    take_while(.==" ");

def tokens: split("") | space;
