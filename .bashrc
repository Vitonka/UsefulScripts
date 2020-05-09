alias python=python2

#see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

export TERM="xterm-256color"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=200000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more aliases
alias ll='ls -alFog --group-directories-first'
alias la='ls -A'
alias l='ls -CF'
alias cdf='cd ~/mapscore/poi/factors'
alias cdr='cd ~/mapscore/poi/renames'
alias subl='/home/rudovichenko/rmate'
PD='/home/rudovichenko/poi/data'
alias colout='/home/rudovichenko/colout/colout/colout.py'
alias colorgcc='colout "error.*?(?=‘)" red | colout ".* instantiated from here" green | colout "^\S*:\d+:\d+:" blue | colout "instantiated from(?= ‘)" white | colout "instantiated from here" green'
alias build='make -j 2>&1 | colorgcc'

alias ta='tmux -S ~/tmux-session -u attach'
alias reformat_json='/home/rudovichenko/reformat_json/reformat_json.sh'

export MTDATA='/usr/share/yandex/maps/masstransit'

function view_json
{
    json --format $1 | python /home/rudovichenko/reformat_json/collapse_lists_in_json.py | less
}

function avior_copy
{
    path=$(realpath $*)
    echo "Will copy $path to avior"
    scp -r $path avior.dev.maps.yandex.net:$path
}

function was_long
{
    if [ $1 -lt 5 ]; then
        exit
    fi
    cmd=$(history 1)
    read -a array <<< $cmd
    edit=false
    keywords=(vim less git top htop ncdu dstat)
    for element in "${array[@]}"; do
        for keyword in "${keywords[@]}"; do
            if [ "$keyword" == "$element" ]; then
                edit=true
            fi
        done
    done

    if ! $edit; then
        # stripped=$(echo $cmd | sed 's/^[0-9]*\s*//')
        # window=$(tmux display-message -p '#I:#W')
        # echo "'${stripped}' has been finished" > ~/tmp-history
        # echo "Window: ${window}" >> ~/tmp-history
        # echo "Time elapsed: $*" >> ~/tmp-history
        # subl ~/tmp-history
        echo " _LONG_ALERT_"
    fi
}

# git diff with line numbers alias
function gitdiff
{
    echo "Colored git diff by Romka"
    git diff "$*" | /home/rudovichenko/work/git_diff_line_numbers/linenum.py
}

export DEBFULLNAME="Victor Otliga"
export EMAIL="vitonka@yandex-team.ru"

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

function mkcd
{
    dir="$*"
    mkdir -p "$dir" && cd "$dir"
}

function cv {
    cd $*
    ll
}

function policy {
    pkg=$(apt-cache search $1 | awk "BEGIN { shortest = \"\"; } \
                                    \$1 ~ /$1/ { \
                                    if (shortest == \"\" || length(\$1) < length(shortest)) \
                                        shortest = \$1; \
                                    } \
                                    END { print shortest; }")
    if [ -z $pkg ]; then
        echo "No packages matching '$1' found."
    else
        apt-cache policy $pkg | head -n 20
    fi
}

set show-all-if-ambiguous on

tmux_pane() {
    zz=${PWD##*/}
    printf "\033k$zz\033\\"
}

# xterm-256 color control sequences
SET_BG="\e[48;5;"
SET_FG="\e[38;5;"
END="m"

# Nice xterm-256color colors
PROMPT_COLOR=40
BG_COLOR=0
OUTPUT_COLOR=230
TIME_COLOR=140
USERHOST_COLOR=111
CMD_COLOR=250

# \n - newline
# \$ - variable
# \[ \] surround characters not to be included in the length calculation
# \` \` surround command to be executed
# export PS1="\[$SET_BG$BG_COLOR$END$SET_FG$TIME_COLOR$END\]\$LAST_LAUNCH_TIME\[$SET_FG$PROMPT_COLOR$END\]$PWD>\[$SET_FG$COMMAND_COLOR$END\] "
export PS1="[\t]\n\[$SET_FG$TIME_COLOR$END\]\$LAST_LAUNCH_TIME\[$SET_FG$USERHOST_COLOR$END\]\u@\h:\[$SET_FG$PROMPT_COLOR$END\]\W (\$(git rev-parse --abbrev-ref HEAD 2>/dev/null))>\[$SET_FG$CMD_COLOR$END\] "
export PROMPT_COMMAND='on_prompt'

LAST_LAUNCH_TIME=
function on_prompt() {
    # Do not trigger on completion
    tmux_pane
    [ -n "${COMP_LINE-}" ] && return
    # Save last launch time frame
    if [ -n "$LAST_LAUNCH_TIME" -a "$LAST_LAUNCH_TIME" != "$(date +'%T')" ]; then
        local newline=$'\n'
        local cur_time=$(date +'%s')
        local secs=$(($cur_time - $LAST_LAUNCH_UNIXTIME))
        sec="$(($secs % 60)) sec"
        local mins=$(($secs / 60))
        if [ $mins -gt 0 ]; then
            min="$(($mins % 60)) min "
        else
            min=""
        fi
        local hours=$(($mins / 60))
        if [ $hours -gt 0 ]; then
            hr="$hours h "
        else
            hr=""
        fi
        LAST_LAUNCH_TIME="[$LAST_LAUNCH_TIME - $(date +'%T') ($hr$min$sec)$(was_long $secs)]$newline"
    else
        LAST_LAUNCH_TIME=""
    fi
    # For time tracking, we need to catch the first DEBUG trap
    __interactive__=yes
}
function before_command_execution() {
    if [ -n "$__interactive__" ]; then
        LAST_LAUNCH_TIME=$(date +'%T')
        LAST_LAUNCH_UNIXTIME=$(date +'%s')
        __interactive__=
    fi

    echo -ne "$SET_FG$OUTPUT_COLOR$END"
}
trap 'before_command_execution' DEBUG

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE="" # unlimited bash history
HISTFILESIZE="" # unlimited bash history
export HISTTIMEFORMAT='%F %T '


lib_deps()
{
    local executable="$1"
    ldd $executable | cut -d ' ' -f 3 | egrep -v '^[\ ]*$' | gawk '{ ORS=" "; print "-file", $0 }'
}

yt_run()
{
    local operation="$1"
    local executable="$2"
    [ -x "$executable" ] || log_error "second argument is not executable (reducer or mapper expected)"
    [ "$operation" = "-map" ] || [ "$operation" = "-reduce" ] || log_error "-reduce or -map expected as first argument"
    shift 2
    mapreduce-yt -server marx.yt.yandex.net "$operation" "env LD_LIBRARY_PATH=. $executable" \
        -file "$executable" `lib_deps $executable` -subkey "$@"
}

yt_sort()
{
    yt --proxy marx.yt.yandex.net sort --src $1 --dst $1 $(printf $2 | sed -r 's/(,|^)/ --sort-by /g') 
}

# Predictable SSH authentication socket location.
SOCK="$HOME/.ssh/ssh_auth_sock"
if [ "$SSH_AUTH_SOCK" ] && [ "$SOCK" != "$SSH_AUTH_SOCK" ]; then
ln -sf "$SSH_AUTH_SOCK" "$SOCK" 
export SSH_AUTH_SOCK="$SOCK"
fi

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# added by Anaconda3 2018.12 installer
# >>> conda init >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$(CONDA_REPORT_ERRORS=false '/home/vitonka/anaconda3/bin/conda' shell.bash hook 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     \eval "$__conda_setup"
# else
#     if [ -f "/home/vitonka/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/vitonka/anaconda3/etc/profile.d/conda.sh"
#        CONDA_CHANGEPS1=false conda activate base
#    else
#         \export PATH="/home/vitonka/anaconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
# <<< conda init <<<

function snotebook ()
{
#Spark path (based on your computer)
SPARK_PATH=~/spark-2.4.0-bin-hadoop2.7

export PYSPARK_DRIVER_PYTHON="jupyter"
export PYSPARK_DRIVER_PYTHON_OPTS="notebook"

# For python 3 users, you have to add the line below or you will get an error
export PYSPARK_PYTHON=python3

$SPARK_PATH/bin/pyspark --packages graphframes:graphframes:0.7.0-spark2.4-s_2.11 --master local[2]
}
