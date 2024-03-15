#!/usr/bin/env bash

CLOCK_CHAR_THEME_PROMPT_PREFIX=''
CLOCK_CHAR_THEME_PROMPT_SUFFIX=''
CLOCK_THEME_PROMPT_PREFIX=''
CLOCK_THEME_PROMPT_SUFFIX=''

THEME_PROMPT_HOST='\H'

SCM=''

SCM_CHECK=${SCM_CHECK:=true}

SCM_THEME_PROMPT_DIRTY=' '
SCM_THEME_PROMPT_CLEAN=' '
SCM_THEME_PROMPT_PREFIX=' |'
SCM_THEME_PROMPT_SUFFIX='|'
SCM_THEME_BRANCH_PREFIX=''
SCM_THEME_TAG_PREFIX='tag:'
SCM_THEME_DETACHED_PREFIX='detached:'
SCM_THEME_BRANCH_TRACK_PREFIX=' → '
SCM_THEME_BRANCH_GONE_PREFIX=' ⇢ '
SCM_THEME_CURRENT_USER_PREFFIX=' ☺︎ '
SCM_THEME_CURRENT_USER_SUFFIX=''
SCM_THEME_CHAR_PREFIX=''
SCM_THEME_CHAR_SUFFIX=''

THEME_BATTERY_PERCENTAGE_CHECK=${THEME_BATTERY_PERCENTAGE_CHECK:=true}

SCM_HG='hg'
SCM_HG_CHAR='☿'

SCM_SVN='svn'
SCM_SVN_CHAR='⑆'

SCM_NONE='NONE'
SCM_NONE_CHAR='○'

NVM_THEME_PROMPT_PREFIX=' |'
NVM_THEME_PROMPT_SUFFIX='|'

RVM_THEME_PROMPT_PREFIX=' |'
RVM_THEME_PROMPT_SUFFIX='|'

THEME_SHOW_USER_HOST=${THEME_SHOW_USER_HOST:=false}
USER_HOST_THEME_PROMPT_PREFIX=''
USER_HOST_THEME_PROMPT_SUFFIX=''

VIRTUAL_ENV=

VIRTUALENV_THEME_PROMPT_PREFIX=' |'
VIRTUALENV_THEME_PROMPT_SUFFIX='|'

RBENV_THEME_PROMPT_PREFIX=' |'
RBENV_THEME_PROMPT_SUFFIX='|'

RBFU_THEME_PROMPT_PREFIX=' |'
RBFU_THEME_PROMPT_SUFFIX='|'

HG_EXE=`which hg  2> /dev/null || true`
SVN_EXE=`which svn  2> /dev/null || true`

function scm {
  if [[ "$SCM_CHECK" = false ]]; then SCM=$SCM_NONE
  elif [[ -d .hg ]] && [[ -x "$HG_EXE" ]]; then SCM=$SCM_HG
  elif [[ -x "$HG_EXE" ]] && [[ -n "$(hg root 2> /dev/null)" ]]; then SCM=$SCM_HG
  elif [[ -d .svn ]] && [[ -x "$SVN_EXE" ]]; then SCM=$SCM_SVN
  elif [[ -x "$SVN_EXE" ]] && [[ -n "$(svn info --show-item wc-root 2>/dev/null)" ]]; then SCM=$SCM_SVN
  else SCM=$SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $SCM_HG ]]; then SCM_CHAR=$SCM_HG_CHAR
  elif [[ $SCM == $SCM_SVN ]]; then SCM_CHAR=$SCM_SVN_CHAR
  else SCM_CHAR=$SCM_NONE_CHAR
  fi
}

function scm_prompt_vars {
  scm
  scm_prompt_char
  SCM_DIRTY=0
  SCM_STATE=''
  [[ $SCM == $SCM_HG ]] && hg_prompt_vars && return
  [[ $SCM == $SCM_SVN ]] && svn_prompt_vars && return
}

function scm_prompt_info {
  scm
  scm_prompt_char
  scm_prompt_info_common
}

function scm_prompt_char_info {
  scm_prompt_char
  echo -ne "${SCM_THEME_CHAR_PREFIX}${SCM_CHAR}${SCM_THEME_CHAR_SUFFIX}"
  scm_prompt_info_common
}

function scm_prompt_info_common {
  SCM_DIRTY=0
  SCM_STATE=''

  { [[ ${SCM} == ${SCM_HG} ]] && hg_prompt_info && return; } || true
  { [[ ${SCM} == ${SCM_SVN} ]] && svn_prompt_info && return; } || true
}

function terraform_workspace_prompt {
    if _command_exists terraform ; then
        if [ -d .terraform ]; then
            echo -e "$(terraform workspace show 2>/dev/null)"
        fi
    fi
}

function svn_prompt_vars {
  if [[ -n $(svn status |head -c1 2> /dev/null) ]]; then
    SCM_DIRTY=1
    SCM_STATE=${SVN_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
  else
    SCM_DIRTY=0
    SCM_STATE=${SVN_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
  fi
  SCM_PREFIX=${SVN_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
  SCM_SUFFIX=${SVN_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
  SCM_BRANCH=$(svn info --show-item=url 2> /dev/null | awk -F/ '{ for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
  SCM_CHANGE=$(svn info --show-item=revision 2> /dev/null)
}

function get_hg_root {
    local CURRENT_DIR=$(pwd)

    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -d "$CURRENT_DIR/.hg" ]; then
            echo "$CURRENT_DIR/.hg"
            return
        fi

        CURRENT_DIR=$(dirname $CURRENT_DIR)
    done
}

function hg_prompt_vars {
    if [[ -n $(hg status 2> /dev/null) ]]; then
      SCM_DIRTY=1
        SCM_STATE=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      SCM_DIRTY=0
        SCM_STATE=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    SCM_PREFIX=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    SCM_SUFFIX=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}

    HG_ROOT=$(get_hg_root)

    if [ -f "$HG_ROOT/branch" ]; then
        # Mercurial holds it's current branch in .hg/branch file
        SCM_BRANCH=$(cat "$HG_ROOT/branch")
    else
        SCM_BRANCH=$(hg summary 2> /dev/null | grep branch: | awk '{print $2}')
    fi

    if [ -f "$HG_ROOT/dirstate" ]; then
        SCM_CHANGE=$(hexdump -n 10 -e '1/1 "%02x"' "$HG_ROOT/dirstate" | cut -c-12)
    else
        SCM_CHANGE=$(hg summary 2> /dev/null | grep parent: | awk '{print $2}')
    fi
}

function nvm_version_prompt {
  local node
  if declare -f -F nvm &> /dev/null; then
    node=$(nvm current 2> /dev/null)
    [[ "${node}" == "system" ]] && return
    echo -e "${NVM_THEME_PROMPT_PREFIX}${node}${NVM_THEME_PROMPT_SUFFIX}"
  fi
}

function node_version_prompt {
  echo -e "$(nvm_version_prompt)"
}

function rvm_version_prompt {
  if which rvm &> /dev/null; then
    rvm=$(rvm-prompt) || return
    if [ -n "$rvm" ]; then
      echo -e "$RVM_THEME_PROMPT_PREFIX$rvm$RVM_THEME_PROMPT_SUFFIX"
    fi
  fi
}

function rbenv_version_prompt {
  if which rbenv &> /dev/null; then
    rbenv=$(rbenv version-name) || return
    $(rbenv commands | grep -q gemset) && gemset=$(rbenv gemset active 2> /dev/null) && rbenv="$rbenv@${gemset%% *}"
    if [ $rbenv != "system" ]; then
      echo -e "$RBENV_THEME_PROMPT_PREFIX$rbenv$RBENV_THEME_PROMPT_SUFFIX"
    fi
  fi
}

function rbfu_version_prompt {
  if [[ $RBFU_RUBY_VERSION ]]; then
    echo -e "${RBFU_THEME_PROMPT_PREFIX}${RBFU_RUBY_VERSION}${RBFU_THEME_PROMPT_SUFFIX}"
  fi
}

function chruby_version_prompt {
  if declare -f -F chruby &> /dev/null; then
    if declare -f -F chruby_auto &> /dev/null; then
      chruby_auto
    fi

    ruby_version=$(ruby --version | awk '{print $1, $2;}') || return

    if [[ ! $(chruby | grep '\*') ]]; then
      ruby_version="${ruby_version} (system)"
    fi
    echo -e "${CHRUBY_THEME_PROMPT_PREFIX}${ruby_version}${CHRUBY_THEME_PROMPT_SUFFIX}"
  fi
}

function ruby_version_prompt {
  echo -e "$(rbfu_version_prompt)$(rbenv_version_prompt)$(rvm_version_prompt)$(chruby_version_prompt)"
}

function k8s_context_prompt {
  echo -e "$(kubectl config current-context 2> /dev/null)"
}

function virtualenv_prompt {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    virtualenv=`basename "$VIRTUAL_ENV"`
    echo -e "$VIRTUALENV_THEME_PROMPT_PREFIX$virtualenv$VIRTUALENV_THEME_PROMPT_SUFFIX"
  fi
}

function condaenv_prompt {
  if [[ $CONDA_DEFAULT_ENV ]]; then
    echo -e "${CONDAENV_THEME_PROMPT_PREFIX}${CONDA_DEFAULT_ENV}${CONDAENV_THEME_PROMPT_SUFFIX}"
  fi
}

function py_interp_prompt {
  py_version=$(python --version 2>&1 | awk 'NR==1{print "py-"$2;}') || return
  echo -e "${PYTHON_THEME_PROMPT_PREFIX}${py_version}${PYTHON_THEME_PROMPT_SUFFIX}"
}

function python_version_prompt {
  echo -e "$(virtualenv_prompt)$(condaenv_prompt)$(py_interp_prompt)"
}

function clock_char {
  CLOCK_CHAR=${THEME_CLOCK_CHAR:-"⌚"}
  CLOCK_CHAR_COLOR=${THEME_CLOCK_CHAR_COLOR:-"$normal"}
  SHOW_CLOCK_CHAR=${THEME_SHOW_CLOCK_CHAR:-"true"}

  if [[ "${SHOW_CLOCK_CHAR}" = "true" ]]; then
    echo -e "${CLOCK_CHAR_COLOR}${CLOCK_CHAR_THEME_PROMPT_PREFIX}${CLOCK_CHAR}${CLOCK_CHAR_THEME_PROMPT_SUFFIX}"
  fi
}

function clock_prompt {
  CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$normal"}
  CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%H:%M:%S"}
  [ -z $THEME_SHOW_CLOCK ] && THEME_SHOW_CLOCK=${THEME_CLOCK_CHECK:-"true"}
  SHOW_CLOCK=$THEME_SHOW_CLOCK

  if [[ "${SHOW_CLOCK}" = "true" ]]; then
    CLOCK_STRING=$(date +"${CLOCK_FORMAT}")
    echo -e "${CLOCK_COLOR}${CLOCK_THEME_PROMPT_PREFIX}${CLOCK_STRING}${CLOCK_THEME_PROMPT_SUFFIX}"
  fi
}

function user_host_prompt {
  if [[ "${THEME_SHOW_USER_HOST}" = "true" ]]; then
      echo -e "${USER_HOST_THEME_PROMPT_PREFIX}\u@\h${USER_HOST_THEME_PROMPT_SUFFIX}"
  fi
}

function svn_prompt_info {
  svn_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}${SCM_STATE}${SCM_SUFFIX}"
}

function hg_prompt_info() {
  hg_prompt_vars
  echo -e "${SCM_PREFIX}${SCM_BRANCH}:${SCM_CHANGE#*:}${SCM_STATE}${SCM_SUFFIX}"
}

function scm_char {
  scm_prompt_char
  echo -e "${SCM_THEME_CHAR_PREFIX}${SCM_CHAR}${SCM_THEME_CHAR_SUFFIX}"
}

function prompt_char {
    scm_char
}

function battery_char {
    if [[ "${THEME_BATTERY_PERCENTAGE_CHECK}" = true ]]; then
        echo -e "${bold_red}$(battery_percentage)%"
    fi
}

if ! _command_exists battery_charge ; then
    # if user has installed battery plugin, skip this...
    function battery_charge (){
	# no op
	echo -n
    }
fi

if ! _command_exists battery_percentage ; then
    function battery_char (){
	# no op
	echo -n
    }
fi

function aws_profile {
  if [[ $AWS_DEFAULT_PROFILE ]]; then
    echo -e "${AWS_DEFAULT_PROFILE}"
  else
    echo -e "default"
  fi
}

function __check_precmd_conflict() {
    local f
    for f in "${precmd_functions[@]}"; do
        if [[ "${f}" == "${1}" ]]; then
            return 0
        fi
    done
    return 1
}

function safe_append_prompt_command {
    local prompt_re

    if [ "${__bp_imported}" == "defined" ]; then
        # We are using bash-preexec
        if ! __check_precmd_conflict "${1}" ; then
            precmd_functions+=("${1}")
        fi
    else
        # Set OS dependent exact match regular expression
        if [[ ${OSTYPE} == darwin* ]]; then
          # macOS
          prompt_re="[[:<:]]${1}[[:>:]]"
        else
          # Linux, FreeBSD, etc.
          prompt_re="\<${1}\>"
        fi

        if [[ ${PROMPT_COMMAND} =~ ${prompt_re} ]]; then
          return
        elif [[ -z ${PROMPT_COMMAND} ]]; then
          PROMPT_COMMAND="${1}"
        else
          PROMPT_COMMAND="${1};${PROMPT_COMMAND}"
        fi
    fi
}

function _save-and-reload-history() {
  local autosave=${1:-0}
  [[ $autosave -eq 1 ]] && history -a && history -c && history -r
}
