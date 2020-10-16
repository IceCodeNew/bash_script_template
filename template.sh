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
curl() {
  $(type -P curl) -LRq --retry 5 --retry-delay 10 --retry-max-time 60 "$@"
}
git_clone() {
  if [[ -z "$GIT_PROXY" ]]; then
    $(type -P git) clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch "$@"
  else
    $(type -P git) -c "$GIT_PROXY" clone -j "$(nproc)" --no-tags --shallow-submodules --recurse-submodules --depth 1 --single-branch "$@"
  fi
}
