# lambda.jq

# This is builtin on some jq versions,
# apparently not on mine. Also, want
# this to be portable, so..
def walk(f):
  . as $in
  | if type == "object" then
      reduce keys[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
  elif type == "array" then map( walk(f) ) | f
  else f
  end;

def lambda_arguments:
    . as $original 
    # if there's a colon before a newline on the top level:
    | if .data |  map(.name) | [.[] | select(.=="newline" or .=="colon")] | .[0] == "colon"  then
        {data: .data, arguments: [], out: []}
        | while(
            (.data | length) > 0;
            .data[0] as $item
            | if $item.name == "colon" then
                .out = .data
                | .data = []
            else
                .arguments += [$item]
                | .data = .data[1:]
            end
        )
        | . as $modified
        | $original | .data = $modified | {arguments: .arguments, body: .body}
    else
        # if there are no colons, it's all a body
        .data = {arguments: [], body: .data} | debug
    end
    ;

def lambdas:
    walk(if type=="object" and .name == "block" then lambda_arguments else . end);
