gh ()
{
    : ${1:?"Provide subcommand."}

    git stash "$@"
}

# --register-name gh