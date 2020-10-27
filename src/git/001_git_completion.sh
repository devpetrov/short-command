_catool_define_git_completion () {
eval "
    _git_$2_shortcut () {
        COMP_LINE=\"git $2\${COMP_LINE#$1}\"
        let COMP_POINT+=$((4+${#2}-${#1}))
        COMP_WORDS=(git $2 \"\${COMP_WORDS[@]:1}\")
        let COMP_CWORD+=1
        local cur words cword prev
        _get_comp_words_by_ref -n =: cur words cword prev
        _git_$2
    }
"
}

_catool_git_shortcut () {
    type _git_$2_shortcut &>/dev/null || _catool_define_git_completion $1 $2
    complete -o default -o nospace -F _git_$2_shortcut $1
}
