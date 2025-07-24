function zathura() {
  nohup zathura "$1" >/dev/null &
  exit
}

zmv() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: zmv <source> <z pattern>"
    return 1
  fi

  local target_dir
  target_dir=$(z -e "$2")

  if [ -z "$target_dir" ]; then
    echo "Error: No match found for '$2' using 'z'."
    return 1
  fi

  mv "$1" "$target_dir"
}

_zmv_complete_source() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=($(compgen -f -- "$cur")) # File and directory completion
}
complete -F _zmv_complete_source zmv
