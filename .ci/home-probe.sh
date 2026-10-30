printf '\n=== %s (MSYS2 Bash) ===\n' "$1"
printf 'HOME=%s\nUSERPROFILE=%s\nHOMEDRIVE=%s\nHOMEPATH=%s\nMSYSTEM=%s\n' \
  "${HOME-<unset>}" "${USERPROFILE-<unset>}" "${HOMEDRIVE-<unset>}" \
  "${HOMEPATH-<unset>}" "${MSYSTEM-<unset>}"
printf 'UID=%s; login_shell=' "$UID"
if shopt -q login_shell; then printf 'yes\n'; else printf 'no\n'; fi
if [[ -d $HOME ]]; then
  printf 'HOME directory exists=yes; profile would set MAYBE_FIRST_START=false\n'
else
  printf 'HOME directory exists=no; profile would set MAYBE_FIRST_START=true\n'
fi
/usr/bin/id
printf '%s\n' '--- HOME as a Windows path ---'
/usr/bin/cygpath -w "$HOME"
printf '%s\n' '--- account database entry ---'
if [[ -x /usr/bin/getent.exe ]]; then
  /usr/bin/getent passwd "$UID"
elif [[ -x /usr/bin/mkpasswd.exe ]]; then
  /usr/bin/mkpasswd -c
fi
printf '%s\n' '--- HOME configuration ---'
/usr/bin/grep -n '^[[:space:]]*db_home:' /etc/nsswitch.conf
printf '%s\n' '--- initialization state ---'
for path in "$HOME" /home /etc/mtab /etc/hosts /etc/pacman.d/gnupg /etc/pacman.d/gnupg/pubring.gpg; do
  if [[ -e $path || -L $path ]]; then
    /usr/bin/ls -ld -- "$path"
  else
    printf 'missing: %s\n' "$path"
  fi
done
printf '%s\n' '--- installed profile gate ---'
/usr/bin/grep -n -A 4 -B 1 -E 'MAYBE_FIRST_START=|for postinst|if .*MAYBE_FIRST_START' /etc/profile
true
