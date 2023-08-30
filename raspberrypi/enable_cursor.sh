#!/bin/sh

# note: this currently only works for key=value cmdline args
modify_cmdline() {
  if echo "${1}" | grep -q '='; then
    modify_cmdline_key=$(echo "${1}" | cut -d'=' -f1)
    modify_cmdline_value=$(echo "${1}" | cut -d'=' -f2-)
  else
    modify_cmdline_key="${1}"
    modify_cmdline_value="${2}"
  fi

  modify_cmdline_cmdline="$(cat /boot/cmdline.txt)"

  if echo "${modify_cmdline_cmdline}" | grep -q -E "\b${modify_cmdline_key}=[^ ]*"; then
    modify_cmdline_cmdline=$(echo "${modify_cmdline_cmdline}" | sed "s/\b${modify_cmdline_key}=[^ ]*/${modify_cmdline_key}=${modify_cmdline_value}/g")
  else
    modify_cmdline_cmdline="${modify_cmdline_cmdline} ${modify_cmdline_key}=${modify_cmdline_value}"
  fi

  echo "${modify_cmdline_cmdline}" > /boot/cmdline.txt
}

modify_cmdline "vt.global_cursor_default=1"
