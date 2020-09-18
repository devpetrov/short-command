gbnew () {
    : ${1:?"Provide branch name"}
    FROM="${2:-origin/master}"

    git fetch origin master --quiet
    BRANCH=`echo $1 | tr '\n' ' ' | tr -s ' ' | sed -e 's/[^[:alnum:]]/-/g;s/^[^[:alnum:]]*//;s/[^[:alnum:]]*$//;s/-[[:alnum:]]*/\L&/2g' | tr -s '-'`
    git checkout -b $BRANCH $FROM
}
