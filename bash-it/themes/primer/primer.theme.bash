#!/usr/bin/env bash

# based of the candy theme, but minimized by odbol
function prompt_command() {
    PS1="$(clock_prompt) ${reset_color}${bold_yellow}\w${reset_color}$(scm_prompt_info)${bold_green} →${bold_white} ${reset_color} ";
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$bold_green"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%I:%M:%S"}

safe_append_prompt_command prompt_command
