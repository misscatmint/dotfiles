test -x /opt/homebrew/bin/brew && eval (/opt/homebrew/bin/brew shellenv)
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.local/bin

if status is-interactive
    set -g fish_greeting ''
    set -x ALTERNATE_EDITOR nano
    set -x GPG_TTY (tty)
    test (uname) = Darwin && set -x BROWSER open

    if command -q nvim
        abbr -g --add nv nvim
        set -x EDITOR nvim
        set -x VISUAL nvim
    else
        set -x EDITOR vim
        set -x VISUAL vim
    end

    command -q starship && starship init fish | source
    command -q zoxide && zoxide init fish | source
    command -q fzf && fzf --fish | source
end
