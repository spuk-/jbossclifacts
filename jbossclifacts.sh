#!/bin/sh

# This Ansible module makes a very crude and error prone (didn't check all possible cases, "works for me")
# conversion from jboss-cli.sh output to JSON so as to provide facts to Ansible.
# How to use:
# - put it somewhere in your ANSIBLE_MODULES paths, ansible.cfg's library paths, or role/library/ directory
# - run the file name as a task

# parse ansible args
. "$1"

# Args:
# - jbossclish: path to jboss-cli.sh
# - controller: argument to --controller
# TODO:
# - authentication

"$jbossclish" --connect ${controller:+"--controller=$controller"} --commands='/:read-resource(recursive=true)' | sed -r -e '
    1i{ "ansible_facts" : { "jbossfacts" :
    s/=> *(undefined|true|false)/: "\1"/g
    s/=>/:/g
    s/\((.*):(.*)\)(,)?/{\1:\2}\3/
    s/expression "(.*)"/"expression \1"/
    s/([0-9])L/\1/
    /"hash" : bytes/ { :1; N; /}}]/!s/[\n ]//g; t1 }
    /"hash"/s/ ?0x(..),?/\1/g
    /"hash" ?: ?bytes ?\{/s/bytes ?\{ ?([0-9a-fA-F]+)/"\1"/
    /}}],$/s/}}],$/}],/
    /line\.separator.*:[^"]+"$/{ N; s/\n/\\n/ }
    $a} }
'
