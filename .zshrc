# If not running interactively, don't do anything
if [[ $- = *i* ]]; then
    # Configure antigen
    source /usr/share/zsh/share/antigen.zsh

    antigen use oh-my-zsh
    antigen bundle git
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-completions
    antigen bundle zsh-users/zsh-autosuggestions    

    antigen theme robbyrussell
    antigen apply

fi

source /etc/profile.d/android-ndk.sh
source ${HOME}/.env

if ! (systemctl -q is-active docker.service) then
    alias docker="echo 'Docker is starting... ' && sudo systemctl start docker && unalias docker && docker"
    alias docker-compose="echo 'Docker is starting... ' && sudo systemctl start docker && unalias docker-compose && docker-compose"
fi

# Copies the piped input onto the clipboard 
alias copy="xclip -selection c"
# Pastes the clipboards contents into the terminal
alias paste="xclip -selection clipboard -o"

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

composer () {
    tty=
    tty -s && tty=--tty
    docker run \
        $tty \
        --interactive \
        --rm \
        --user $(id -u):$(id -g) \
        --volume /etc/passwd:/etc/passwd:ro \
        --volume /etc/group:/etc/group:ro \
        --volume $(pwd):/app \
        composer "$@"
}

# Configure grep
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn} --exclude="*.pyc"'

# Output code with highlight
highlight () vimcat -c "set syntax=$1" -- $2
alias ccat="vimcat"

# Create mini webserver
alias webserver="python -m http.server"

# Get my external ip
alias myIp="curl -sSL 'https://api.ipify.org?format=json'"

# Check if you is a tor client
alias isTor="curl -sSL 'https://check.torproject.org/api/ip'"

# Check location of a ip
trackIp () { curl -sSL "http://ip-api.com/json/$1" }

# Send text to termbin (like pastebin)
alias tb="nc termbin.com 9999"

# Unshorten url
unshorten () { curl -sSL "https://unshorten.me/json/$1" }

# Updating system
update-system () { sudo mount -o remount,size=16G,noatime /tmp/trizen-$(whoami); sudo prlimit --pid $$ --nofile=10000:10000 &&
trizen -Syyu --noconfirm && while :; do sudo pacman -R --noconfirm $(pacman -Qdtq) || break; sleep 10; done &&
sudo rm -Rf /var/cache/pacman/pkg/* && sudo rm -Rf /tmp/trizen-$(whoami)/* }

# Scan file with virus total
scanFileWithVirusTotal () {
    curl -sSL -F "file=@$1" -F \
    apikey=$VIRUS_TOTAL_KEY \
    https://www.virustotal.com/vtapi/v2/file/scan
}

scanUrlWithVirusTotal () {
    curl -sSL --request POST \
    --url 'https://www.virustotal.com/vtapi/v2/url/scan' \
    -d apikey=$VIRUS_TOTAL_KEY \
    -d "url=$1"
}
