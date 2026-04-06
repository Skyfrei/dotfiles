set -gx VIMRUNTIME "$HOME/code/neovim/runtime"
set fish_greeting
set -gx SSLKEYLOGFILE "/home/sky/code/granblue-fantasy-tool/gbf_keys.log"

fish_add_path "$HOME/code/neovim/build/bin"

if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec start-hyprland
    end
end

if status is-interactive
    if test -z "$TMUX" -a -n "$WAYLAND_DISPLAY"
        if type -q tmux
            exec tmux new-session -A -s $USER
        end
    end
end

alias ls="ls --color=auto"
alias grep="grep --color=auto"

function fish_prompt
    set -l user_color (set_color green)
    set -l normal (set_color normal)
    echo -n "["$user_color$USER$normal"@(hostname) "(prompt_pwd)"]\$ "
end


