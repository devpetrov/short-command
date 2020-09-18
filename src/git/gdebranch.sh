gdebranch ()
{
    if [ -n "$(git status --porcelain -uno)" ] ; then
        printf "\n Working tree not clean\n NOTE: Untracked files don't matter and are not shown in the list bellow.\n"
        printf "\n"
        git status --short -uno

        printf "\n Clean up with git reset --hard [y/N]: "
        read CLEANUP

        if [ -z "${CLEANUP}" ] ; then
            CLEANUP=n
        fi

        if [ "$CLEANUP" != "${CLEANUP#[Yy]}" ] ; then
            git reset --hard --quiet
        else
            printf "\n Please, commit, stash or reset your changes and try again.\n"
    
            return 1
        fi
    fi

    git fetch origin master --quiet
    TARGET='origin/master';
    
    BRANCH_LIST=$(git branch --merged $TARGET --format="%(refname:short)" | grep -v '^master$')
    
    if [ -z "$BRANCH_LIST" ] ; then
        printf "\n No merged branches to be removed.\n"
        return;
    fi  

    printf "\nBranches to be removed:\n"
    printf "\n"

    printf "$BRANCH_LIST\n" | sed -e 's/^.*$/\t&/'

    printf "\nDo you want to continue? [y/N]: "
    read CONTINUE

    if [ -z "${CONTINUE}" ] ; then
        CONTINUE=n
    fi

    if [ "$CONTINUE" != "${CONTINUE#[Yy]}" ] ; then
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

        if [ "master" != "$CURRENT_BRANCH" ] ; then
            SWITCHED=1
            git checkout master --quiet
        else
            SWITCHED=0
        fi
        
        printf "\n"
        printf "$BRANCH_LIST\n" | while read -r BRANCH_TO_DELETE ; do
            if [ "master" != "$BRANCH_TO_DELETE" ] ; then
                git branch -d $BRANCH_TO_DELETE
            fi
        done

        BRANCHES=$(git branch --format="%(refname:short)" | grep "^$CURRENT_BRANCH$")
        
        if [ 1 -eq $SWITCHED -a -n "$BRANCHES" ] ; then
            git checkout $CURRENT_BRANCH --quiet
        fi

        printf "\nDone.\n"
    fi
}
