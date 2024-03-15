#!/usr/bin/env bash


# ===
# === Only set $BASH_IT if it's not already set
# ===
if [ -z "$BASH_IT" ];
then
  export BASH_IT=$BASH
  BASH="$(bash -c 'echo $BASH')"
  export BASH
fi


# ===
# === For backwards compatibility
# ===
if [ -z "$BASH_IT_THEME" ];
then
  export BASH_IT_THEME="$BASH_THEME";
  unset BASH_THEME;
fi


# ===
# === Load composure first, support function metadata
# ===
source "${BASH_IT}/lib/composure.bash"
cite _about _param _example _group _author _version


# ===
# === source libraries, but skip appearance for now
# ===
LIB="${BASH_IT}/lib/*.bash"
APPEARANCE_LIB="${BASH_IT}/lib/appearance.bash"
for _bash_it_config_file in $LIB
do
  if [ "$_bash_it_config_file" != "$APPEARANCE_LIB" ]; then
    source "$_bash_it_config_file"
  fi
done


# ===
# === Load the global "enabled" directory
# ===
source "${BASH_IT}/scripts/reloader.bash"


# ===
# === Load theme
# ===
if [[ ! -z "${BASH_IT_THEME}" ]]; then
  source "${BASH_IT}/themes/colors.theme.bash"
  source "${BASH_IT}/themes/base.theme.bash"
  source "$APPEARANCE_LIB"
fi


# ===
# === BASH_IT_RELOAD_LEGACY is set.
# ===
if ! command -v reload &>/dev/null && [ -n "$BASH_IT_RELOAD_LEGACY" ]; then
  case $OSTYPE in
    darwin*)
      alias reload='source ~/.bash_profile'
      ;;
    *)
      alias reload='source ~/.bashrc'
      ;;
  esac
fi

set +T
