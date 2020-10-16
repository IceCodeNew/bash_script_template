#!/bin/bash

# IMPORTANT!
# `apt` does not have a stable CLI interface. Use with caution in scripts.
## Refer: https://askubuntu.com/a/990838
export DEBIAN_FRONTEND=noninteractive

## Refer: https://unix.stackexchange.com/a/356759
export PAGER='cat'
export SYSTEMD_PAGER=cat

# Consider adding the following aliases to `~/.bash_aliases` for daily use.
: << 'ALIASES'
```shell
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias crontab='crontab -i'
```
ALIASES

# Shell functions are only known to the shell. External commands like `find`, `xargs`, `su` and `sudo` do not recognize shell functions.
# Instead, the function contents can be executed in a shell, either through sh -c or by creating a separate shell script as an executable file.
## Refer: https://github.com/koalaman/shellcheck/wiki/SC2033

cd() {
  cd "$@" || exit 1
}
rm() {
  $(type -P rm) "$@"
}
cp() {
  $(type -P cp) "$@"
}
mv() {
  $(type -P mv) "$@"
}
mkdir() {
  $(type -P mkdir) -p "$@"
}
# Personally I would recommend using `install` rather than `cp`
## Refer: https://unix.stackexchange.com/a/441251 , https://superuser.com/a/229980
mkdir_and_install_644() {
  # $(type -P install) --preserve-context -pvDm 644 "$@"
  $(type -P install) -pvDm 644 "$@"
}

curl() {
  $(type -P curl) -LRq --retry 5 --retry-delay 10 --retry-max-time 60 "$@"
}
# The following version will not work on non-interactive environment
: << 'CURL_2_DEST'
```shell
curl_to_dest() {
  (
    tmp_dir=$(mktemp -d)
    cd "$tmp_dir" || exit 1
    read -rp "(Download URL is): " -a download_url
    if $(type -P curl) -LROJq --retry 5 --retry-delay 10 --retry-max-time 60 "${download_url[@]}"; then
      read -rp "(The dest for file copying): " dest_path
      find . -maxdepth 1 -type f -print0 | xargs -0 -i -r -s 2000 "$(type -P install)" -pvDm 644 "{}" "$dest_path"
    fi
    /bin/rm -rf "$tmp_dir"
  )
}
```
CURL_2_DEST
curl_to_dest() {
  if [[ $# -eq 2 ]]; then
    (
      tmp_dir=$(mktemp -d)
      cd "$tmp_dir" || exit 1
      if $(type -P curl) -LROJq --retry 5 --retry-delay 10 --retry-max-time 60 "$1"; then
        find . -maxdepth 1 -type f -print0 | xargs -0 -i -r -s 2000 "$(type -P install)" -pvDm 644 "{}" "$2"
      fi
      /bin/rm -rf "$tmp_dir"
    )
  fi
}

git_clone() {
  if [[ -z "$GIT_PROXY" ]]; then
    $(type -P git) clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch "$@"
  else
    $(type -P git) -c "$GIT_PROXY" clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch "$@"
  fi
}
