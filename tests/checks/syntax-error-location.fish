#RUN: %fish -C 'set -g fish %fish' %s

# A $status used as a command should not impact the location of other errors.
echo 'echo foo | exec grep # this exec is not allowed!

$status

 # The error might be found here!' | $fish 2>| string replace -r '(.*)' '<$1>'

# CHECK: <fish: The 'exec' command can not be used in a pipeline>
# CHECK: <echo foo | exec grep # this exec is not allowed!>
# CHECK: <           ^>

echo 'true | time false' | $fish 2>| string replace -r '(.*)' '<$1>'
# CHECK: <fish: The 'time' command may only be at the beginning of a pipeline>
# CHECK: <true | time false>
# CHECK: <       ^>


echo '

(true one)
(true two)

# more things
' | $fish 2>| string replace -r '(.*)' '<$1>'

# CHECK: <fish: Command substitutions not allowed>
# CHECK: <(true one)>
# CHECK: <^>

$fish -c 'echo "unfinished "(subshell' 2>| string replace -r '.*' '<$0>'
# CHECK: <fish: Unexpected end of string, expecting ')'>
# CHECK: <echo "unfinished "(subshell>
# CHECK: <                  ^>

$fish -c 'echo "unfinished "$(subshell' 2>| string replace -r '.*' '<$0>'
# CHECK: <fish: Unexpected end of string, expecting ')'>
# CHECK: <echo "unfinished "$(subshell>
# CHECK: <                   ^>

$fish -c 'echo "ok $(echo still ok)syntax error: \x"' 2>| string replace -r '.*' '<$0>'
# CHECK: <fish: Invalid token '"ok $(echo still ok)syntax error: \x"'>
# CHECK: <echo "ok $(echo still ok)syntax error: \x">
# CHECK: <                         ^>

echo "function error" >$TMPDIR/error.fish
$fish -c "set -g fish_function_path $(string escape $TMPDIR); error"
# CHECKERR: ~/temp/error.fish (line 1): Missing end to balance this function definition
# CHECKERR: function error
# CHECKERR: ^
# CHECKERR: from sourcing file ~/temp/error.fish
# CHECKERR: source: Error while reading file '{{.*}}/error.fish'
# CHECKERR: fish: Unknown command: error
# CHECKERR: fish:
# CHECKERR: set -g fish_function_path {{.*}}; error
# CHECKERR: ^
