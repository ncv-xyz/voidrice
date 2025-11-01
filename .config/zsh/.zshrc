# Luke's config for the Zoomer Shell

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
[ "$(uname -o)" = "Android" ] &&
	PS1="%B%{$fg[red]%}[%{$fg[yellow]%}${USER:-$USERNAME}%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b " ||
	PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b " \
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
setopt inc_append_history

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^ulfcd\n'

bindkey -s '^a' '^ubc -lq\n'

bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# LARBS dwm binds in tty.
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	bindkey -s '^[`' '^udmenuunicode\n'
	bindkey -s '^[-' '^uwpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\n'
	bindkey -s '^[_' '^uwpctl set-volume @DEFAULT_AUDIO_SINK@ 15%-\n'
	bindkey -s '^[=' '^uwpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\n'
	bindkey -s '^[+' '^uwpctl set-volume @DEFAULT_AUDIO_SINK@ 15%+\n'
	#bindkey -s '^[^?' '^usysact\n'
	bindkey -s '^[q' '^uexit\n'
	#bindkey -s '^[Q' '^usysact\n'
	#bindkey -s '^[w' '^u$BROWSER\n'
	#bindkey -s '^[W' '^unmtui\n'
	bindkey -s '^[e' '^uneomutt; rmdir ~/.abook 2>/dev/null\n'
	bindkey -s '^[E' '^uabook -C ~/.config/abook/abookrc --datafile ~/.config/abook/addressbook\n'
	bindkey -s '^[r' '^ulfub\n'
	bindkey -s '^[R' '^uhtop\n'
	bindkey -s '^[p' '^umpc toggle\n'
	bindkey -s '^[P' '^umpc pause; pauseallmpv\n'
	bindkey -s '^[[' '^umpc seek -10\n'
	bindkey -s '^[{' '^umpc seek -60\n'
	bindkey -s '^[]' '^umpc seek +10\n'
	bindkey -s '^[}' '^umpc seek +60\n'
	bindkey -s '^[D' '^upassmenu\n'
	bindkey -s '^[c' '^uprofanity\n'
	bindkey -s '^[n' '^unvim -c VimwikiIndex\n'
	bindkey -s '^[N' '^unewsboat\n'
	bindkey -s '^[m' '^uncmpcpp\n'
	bindkey -s '^[M' '^uwpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\n'
	bindkey -s '^[,' '^umpc prev\n'
	bindkey -s '^[<' '^umpc seek 0%\n'
	bindkey -s '^[.' '^umpc next\n'
	bindkey -s '^[>' '^umpc repeat\n'
	bindkey -s '^[[2;3~' "^uxdotool type \$(grep -v '\^#' ~/.local/share/larbs/snippets | dmenu -i -l 50 | cut -d' ' -f1)\\n"
	#bindkey -s '^[1' '^ugroff -mom /usr/local/share/dwm/larbs.mom -Tpdf | zathura -\n'
	#bindkey -s '^[2' '^ututorialvids\n'
	#bindkey -s '^[3' '^udisplayselect\n'
	bindkey -s '^[4' '^upulsemixer\n'
	#bindkey -s '^[5' '^uxrdb\n'
	bindkey -s '^[6' '^utorwrap\n'
	bindkey -s '^[7' '^utd-toggle\n'
	bindkey -s '^[8' '^umailsync\n'
	#bindkey -s '^[9' '^umounter\n'
	#bindkey -s '^[0' '^uunmounter\n'
fi

# Disable Termux's command-not-found handler.
[ "$(uname -o)" = "Android" ] && unset -f command_not_found_handler

# Load syntax highlighting; should be last.
[ "$(uname -o)" = "Android" ] &&
	source "$HOME"/.local/src/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null ||
	source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
