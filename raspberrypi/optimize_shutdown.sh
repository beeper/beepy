#!/bin/sh

modify_conf() {
  modify_conf_conf_file="$1"

  if echo "${2}" | grep -q '='; then
    modify_conf_key=$(echo "${2}" | cut -d'=' -f1)
    modify_conf_value=$(echo "${2}" | cut -d'=' -f2-)
  else
    modify_conf_key="${2}"
    modify_conf_value="${3}"
  fi

  modify_conf_new_content=""
  modify_conf_found=0

  if [ -f "${modify_conf_conf_file}" ]; then
    while IFS= read -r modify_conf_line; do
      if echo "${modify_conf_line}" | grep -q "^${modify_conf_key}"; then
        modify_conf_line="${modify_conf_key}=${modify_conf_value}"
        modify_conf_found=1
      fi
      modify_conf_new_content="${modify_conf_new_content}$(printf "%s\n" "${modify_conf_line}")"
    done < "${modify_conf_conf_file}"
  fi

  [ "${modify_conf_found}" -eq 0 ] && modify_conf_new_content="${modify_conf_new_content}$(printf '%s=%s\n' "${modify_conf_key}" "${modify_conf_value}")"

  modify_conf_new_content=$(printf "%s" "${modify_conf_new_content}" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')

  printf "%s" "${modify_conf_new_content}" > "${modify_conf_conf_file}"
}

modify_conf "/etc/sysctl.d/20-quiet-printk.conf" "kernel.printk" "-1 -1 -1 -1"
