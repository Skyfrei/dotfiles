# My minimal tmux config


Use the shell command below to have tmux start or attach 
upong terminal client instanciation.
```
if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi
```
