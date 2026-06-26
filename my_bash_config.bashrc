# Prompt: user@host dir branch time
parse_git_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
parse_rel_path() {
  local p=$(pwd -P)
  if [[ "$p" == "$HOME" ]]; then
    echo ""
  elif [[ "$p" == $HOME/* ]]; then
    echo "${p/#$HOME\//}"
  else
    echo "$p"
  fi
}

PS1='\[\e[1;36m\]\u@\h\[\e[0m\]$(r=$(parse_rel_path); [ -n "$r" ] && echo " \e[0;37m$r")\[\e[33m\]$(b=$(parse_git_branch); [ -n "$b" ] && echo " ($b)")\[\e[0m\]\[\e[35m\] $(date +%H:%M)\[\e[0m\]\$ '

# Aliases (ls always colored)
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias editbash='nano ~/.bashrc && source ~/.bashrc && echo -e "\e[32mbashrc reloaded\e[0m"'
alias c='clear'
alias ga='git add .'

# MPV music control
alias play='mpv ~/Media/Music/Phonks --shuffle --no-video \
--input-ipc-server=/tmp/mpv-socket \
>/dev/null 2>&1 & disown'
alias next='echo "playlist-next" | socat - /tmp/mpv-socket'
alias prev='echo "playlist-prev" | socat - /tmp/mpv-socket'
alias pause='echo "cycle pause" | socat - /tmp/mpv-socket'
alias mstop='killall mpv'

# History
HISTSIZE=50000
HISTFILESIZE=500000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend 2>/dev/null
add_to_prompt_command() {
  case ";$PROMPT_COMMAND;" in *";$1;"*) : ;; *) PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }$1" ;; esac
}
__pc_hist_sync() { history -a; history -c; history -r; }
add_to_prompt_command __pc_hist_sync

# Arch package management
alias orphans='pacman -Qtdq'
alias search='pacman -Ss'
alias remove='sudo pacman -Rns'
alias clean='sudo pacman -Rns $(pacman -Qtdq 2>/dev/null) 2>/dev/null || true'
alias up='update'
alias download='sudo pacman -S'

# Docker alias
alias docon='sudo systemctl start docker.socket docker.service && docker info --format "{{.ServerVersion}}" && echo "docker: up"'
alias docoff='sudo systemctl stop docker.service docker.socket && echo "docker: down"'
alias docclean='containers=$(docker ps -aq); [ -n "$containers" ] && docker stop $containers && docker rm -f $containers; images=$(docker images -aq); [ -n "$images" ] && docker rmi -f $images; docker system prune -a --volumes -f'
alias docrun='docclean && docker compose build --no-cache && docker compose up -d'

# Open Russian VPN
alias rus_vpn='sudo openvpn --config /home/alan/Documents/servers/vpn696556713.opengw.net_ddns_udp.ovpn'

# Status alias
alias vpnstatus='systemctl --user status protonvpn-autoconnect.service'

# Shut down
alias stop='sudo systemctl poweroff'

update() {
  local NO_AUR=0 CLEAN=0 FORCE=0
  while (( "$#" )); do
    case "$1" in
      --no-aur) NO_AUR=1 ;;
      --clean) CLEAN=1 ;;
      --force-refresh) FORCE=1 ;;
      *) echo -e "\e[31munknown option:\e[0m $1"; return 2 ;;
    esac
    shift
  done

  local pac_flags="-Syu --noconfirm"
  [[ $FORCE -eq 1 ]] && pac_flags="-Syyu --noconfirm"

  echo -e "\e[36m==> pacman update\e[0m"
  sudo pacman $pac_flags || { echo -e "\e[31mpacman failed\e[0m"; return 1; }

  if [ $NO_AUR -eq 0 ]; then
    if command -v paru >/dev/null 2>&1; then
      echo -e "\e[36m==> AUR update (paru)\e[0m"
      paru -Syu --noconfirm || echo -e "\e[31mAUR update failed\e[0m"
    elif command -v yay >/dev/null 2>&1; then
      echo -e "\e[36m==> AUR update (yay)\e[0m"
      yay -Syu --noconfirm || echo -e "\e[31mAUR update failed\e[0m"
    else
      echo -e "\e[33mAUR helper not found\e[0m"
    fi
  else
    echo -e "\e[33mAUR skipped\e[0m"
  fi

  if [ $CLEAN -eq 1 ]; then
    echo -e "\e[36m==> Cleaning orphans\e[0m"
    local orph
    orph=$(pacman -Qtdq 2>/dev/null || true)
    if [ -n "$orph" ]; then
      sudo pacman -Rns $orph --noconfirm
      echo -e "\e[32morphan packages removed\e[0m"
    else
      echo -e "\e[32mno orphans found\e[0m"
    fi
  fi
 if command -v flatpak >/dev/null 2>&1; then
    echo -e "\e[36m==> flatpak update\e[0m"
    flatpak update -y || echo -e "\e[31mflatpak update failed\e[0m"
  else
    echo -e "\e[33mflatpak not installed\e[0m"
  fi

  echo -e "\e[32mupdate done\e[0m"
}

# Enable color for ls
eval "$(dircolors -b)"
export PATH="$PATH:$HOME/.dotnet/tools"
export PATH="$PATH:$HOME/flutter/bin"

export PATH=$PATH:/usr/local/go/bin
export ARDUINO_DIRECTORIES_DATA=/data/.arduino15

# Android SDK paths
export ANDROID_HOME=/data/Android/Sdk
export ANDROID_SDK_ROOT=/data/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools

# Go paths
export GOPATH=/data/go
export PATH=$PATH:$GOPATH/bin

# Dev tools paths (moved to /data)
export ARDUINO_DIRECTORIES_DATA=/data/.arduino15
export ANDROID_HOME=/data/Android/Sdk
export ANDROID_SDK_ROOT=/data/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
export PATH="$PATH:/data/flutter/bin"
export GOPATH=/data/go
export PATH=$PATH:$GOPATH/bin
export CHROME_EXECUTABLE=/usr/bin/chromium

. "$HOME/.local/bin/env"
alias interpreter="source ~/oi-venv/bin/activate 2>/dev/null && interpreter -y"
alias interpreter="source ~/oi-venv/bin/activate 2>/dev/null && interpreter -y"
alias interpreter="source ~/oi-venv/bin/activate 2>/dev/null && interpreter -y"

# OpenClaw Completion
source "/home/alan/.openclaw/completions/openclaw.bash"
export PATH="$HOME:$PATH"
export PATH="$HOME:$PATH"
export OPENCLAW_AUTH_TOKEN=""

# NPM global bin (added by Qwen Code installer)
export PATH="$HOME/.npm-global/bin:$PATH"
