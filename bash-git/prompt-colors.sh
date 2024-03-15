#!/usr/bin/env bash
# prompt-colors.sh
#
# source this file to get color definitions

define_color_names() {

  ColorNames=( Black Red Green Yellow Blue Magenta Cyan White )
  FgColors=(    30   31   32    33     34   35      36   37  )
  BgColors=(    40   41   42    43     44   45      46   47  )

  local AttrNorm=0
  local AttrBright=1
  local AttrDim=2
  local AttrUnder=4
  local AttrBlink=5
  local AttrRev=7
  local AttrHide=8

  _map_colors() {
    local x=0
    local attrname="${1}"
    local attrcode="${2}"
    while (( x < 8 )) ; do
      local colorname="${ColorNames[x]}"
      local fgcolorcode="${FgColors[x]}"
      local bgcolorcode="${BgColors[x]}"
      longcolorname="${attrname}${colorname}"
      _def_color "${longcolorname}"   "${attrcode}" "${fgcolorcode}"
      _def_color "${longcolorname}Fg" "${attrcode}" "${fgcolorcode}"
      _def_color "${longcolorname}Bg" "${attrcode}" "${bgcolorcode}"
      (( x++ ))
    done
  }

  # _term_color [ N | N M ]
  _term_color() {
    local cv
    if [[ "${#}" -gt 1 ]]; then
      cv="${1};${2}"
    else
      cv="${1}"
    fi
    echo "\[\033[${cv}m\]"
  }

  # def_color NAME ATTRCODE COLORCODE
  _def_color() {
    local def="${1}=\"\`_term_color ${2} ${3}\`\""
    eval "${def}"
  }

  _map_colors Bold   ${AttrBright}
  _map_colors Bright ${AttrBright}
  _map_colors Dim    ${AttrDim}
  _map_colors ''     ${AttrNorm}

  _def_color IntenseBlack 0 90
  _def_color ResetColor   0 0

}

# do the color definitions only once
if [[ -z "${ColorNames+x}" || "${#ColorNames[*]}" = 0 || -z "${IntenseBlack:+x}" || -z "${ResetColor:+x}" ]]; then
  define_color_names
  Black="\e[1;49;30m"
  Red="\e[1;49;31m"
  Green="\e[1;49;32m"
  Yellow="\e[1;49;33m"
  Blue="\e[1;49;34m"
  Magenta="\e[1;49;35m"
  Cyan="\e[1;49;36m"
  White="\e[1;49;37m"
fi
