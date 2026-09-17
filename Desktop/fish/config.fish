set fish_greeting ""
set -x GNOME_KEYRING_CONTROL (gnome-keyring-daemon --start --components=secrets | sed 's/.*=//')
export OLLAMA_MODELS=/home/afonso/ollama-models

alias speedtest='speedtest-cli --secure'
alias speedrate='speedtest-cli --secure | qwen-ai "Rate this internet speed test result and provide a brief assessment (good, average, poor):"'

# Gruvbox dark theme for Fish shell
set -g fish_color_normal ebdbb2
set -g fish_color_command 83a598
set -g fish_color_param fabd2f
set -g fish_color_error fb4934
set -g fish_color_operator d3869b
set -g fish_color_escape 8ec07c
set -g fish_color_quote b8bb26
set -g fish_color_redirection d79921
set -g fish_color_end 98971a
set -g fish_color_selection --background=504945
set -g fish_color_autosuggestion 928374
set -g fish_color_valid_path --underline
set -g fish_color_cwd d79921
set -g fish_color_status cc241d

if status is-interactive
    # Commands to run in interactive sessions can go here
end
