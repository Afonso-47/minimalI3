set fish_greeting ""
set -x GNOME_KEYRING_CONTROL (gnome-keyring-daemon --start --components=secrets | sed 's/.*=//')
export OLLAMA_MODELS=/home/afonso/ollama-models

alias speedtest='speedtest-cli --secure'
alias speedrate='speedtest-cli --secure | qwen-ai "Rate this internet speed test result and provide a brief assessment (good, average, poor):"'

if status is-interactive
# Commands to run in interactive sessions can go here
end
