# If not running interactively, don't do anything
if [[ $- = *i* ]]; then
    # Configure antigen
    [[ ! -d "$HOME/.antigen" ]] && git clone https://github.com/zsh-users/antigen.git "$HOME/.antigen"
    source "$HOME/.antigen/antigen.zsh"

    antigen use oh-my-zsh

    antigen bundle git
    antigen bundle docker
    antigen bundle kubernetes
    
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-completions
    antigen bundle zsh-users/zsh-autosuggestions
    
    antigen theme robbyrussell
    antigen apply

fi

[[ -f "$HOME/.env" ]] && source ${HOME}/.env

# Pretty print formt
alias json="python -m json.tool"
alias xml="xmllint --format -"

# Output text cases
alias lcase="tr '[:upper:]' '[:lower:]'"
alias ucase="tr '[:lower:]' '[:upper:]'"

# Slugify commad
alias slugify="iconv -t ascii//TRANSLIT | sed -r 's/[~\\^]+//g' | sed -r 's/[^a-zA-Z0-9]+/-/g' | sed -r 's/^-+\\|-+$//g' | lcase"

# Backup commad 
backup() {
    [ -z "$1" ] && {echo "ERROR: Empty input"; return 1}

    local input=$1
    [ -e $input ] || {echo "ERROR: File not found"; return 1}

    if [ -z "$2" ]; then
        local output="$HOME/.backup$(realpath -- $input 2> /dev/null | sed -r 's/(.+)\/.+/\1/')"
        [ -d $output ] || mkdir -p $output
    else
        local output=$(realpath -- "$2" 2> /dev/null)
        [ -d $output ] || {echo "ERROR: Invalid output"; return 1}
    fi 

    local output="$output/$(echo $input | sed 's/.*\///' | slugify).$(date '+%Y-%m-%d').bpk.tgz"
    
    tar -cpzf $output \
        --exclude=$output \
        --exclude=/proc \
        --exclude=/lost+found \
        --exclude=/mnt \
        --exclude=/sys \
        --exclude=/media \
        $input

    echo "Backup ${output} make with success"; return 0
}

# Extract commad
extract () {
    [ -z "$1" ] && {echo 'ERROR: Empty input'; return 1}
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1    ;;
            *.tar.gz)  tar xzf $1    ;;
            *.bz2)     bunzip2 $1    ;;
            *.rar)     unrar e $1    ;;
            *.gz)      gunzip $1     ;;
            *.tar)     tar xf $1     ;;
            *.tbz2)    tar xjf $1    ;;
            *.tgz)     tar xzf $1    ;;
            *.zip)     unzip $1      ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1       ;;
            *)         echo "ERROR: '$1' cannot be extracted via extract commad"; return 1
        esac
        echo "Files extracted with success"; return 0
    else
        echo "ERROR: '$1' is not a valid file"; return 1
    fi
}

# Send text to termbin (like pastebin)
alias tb="nc termbin.com 9999"

# Unshorten url
unshorten () { curl -sSL "https://unshorten.me/json/$1" }
