test -x /opt/homebrew/bin/brew && eval (/opt/homebrew/bin/brew shellenv)
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.config/git/bin
fish_add_path -g ~/.local/bin

set -x ALTERNATE_EDITOR nano
test (uname) = Darwin && set -x BROWSER open
if command -q nvim
    abbr -g --add nv nvim
    set -x EDITOR (command -s nvim)
    set -x VISUAL $EDITOR
else
    set -x EDITOR vim
    set -x VISUAL vim
end

if not set -q SSH_AUTH_SOCK
    and set -q XDG_RUNTIME_DIR
    and test -S $XDG_RUNTIME_DIR/openssh_agent
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/openssh_agent
end

if status is-interactive
    set -g fish_greeting ''
    set -x GPG_TTY (tty)
    command -q starship && starship init fish | source
    command -q zoxide && zoxide init fish | source
    command -q fzf && fzf --fish | source
end
