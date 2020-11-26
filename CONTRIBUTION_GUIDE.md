# Contribute to Shoco (Short Command)
This document contains guidelines on how to contribute to this project.

## How do you contribute
You are welcome to contribute to Shoco (Short Command):

- Reporting a bug or
- requesting for a feature or
- asking questions or
- creating any other type of issue in [GitHub](https://github.com/chaos-drone/short-command/issues).
- Implementing feature or fixing bug by yourself.

## Basic steps for submitting changes:

1. If you will be working on unreported issue you should first create one in GitHub: https://github.com/chaos-drone/short-command/issues.
1. Make sure you are familiar with the naming conventions (bellow in this document).
1. Follow the [GitHub flow](https://githubflow.github.io/)

## Names
Main entities of Shoco (Short Command) are Bash aliases and functions. For further reference they are going to be called "names".

## Making code changes
In the repository each name is in its own file. When releasing a version all the files are merged into one big file.<br>
You should test your changes in that merged state.<br>
[short-command-sdk](https://github.com/chaos-drone/short-command-sdk) is a tool that will do the merging for you.
There are installation and usage instructions in its [README](https://github.com/chaos-drone/short-command-sdk/blob/master/README.md)

## Naming convention
*NB! Currently the project is in its alpha stage. The following conventions may change. Look up this document regularly.*

In order to be really useful for productivity Shoco (Short Command) tries to be consistent with its names.

The following conventions apply for naming:

- Each command has it's reserved letter.
- Each subcommand has it's reserved letter.
- Same subcommands for different commands do not necessarily use the same letter.<br>
For example: *gl* and *dl* respectively stand for *git pull* and *docker logs*

Trailing "x" stands for `&& exit` meaning that the shell will exit after successful execution of the first command.
E.g. `dcsx` is `docker-compose stop && exit`

### Git conventions
Git names MUST start with **g** followed by

- *a* for *add*
- *b* for *branch*
- *c* for *commit*
    - *a* for *-a | --all*
    - *d* for *--amend*
    - *m* for *-m | --message*
- *e* for *reset*
- *f* for *config*
    - *g* for *--global*
- *g* for *log*
- *h* for *stash*
    - *a* for *apply*
    - *d* for *drop*
    - *o* for *pop*
    - *u* for *push*
        - *u* for *-u | --include-untracked*
        - *m* for *-m | --message*
- *k* for *checkout*
    - *b* for *-b*
- *l* for *pull*
- *r* for *rebase*
    - *a* for *--abort*
    - *c* for *--continue*
    - *i* for *-i | --interactive*
- *s* for *push*
    - *u* for *-u | --set-upstream*
- *t* for *status*

### Docker and Docker Compose conventions
Docker names MUST start with **d** followed by

- *l* for *logs*
    - *f* for *-f | --follow*
    
Note that 'c' is reserved for dock-compose.

Docker-compose names MUST start with **dc**

- *e* for *exec*
- *l* for *logs*
    - *f* for *-f | --follow*
- *r* for *run*
- *s* for *stop*
- *u* for *up*
    - *d* for *-d | --detach*

Same subcommands for docker and docker-compose MUST have same letters.

### Vagrant conventions
Vagrant names MUST start with **v** followed by

- *h* for *halt*
- *in* for *in*<br>
Using only 'i' will conflict with 'vi'
- *u* for *up*
