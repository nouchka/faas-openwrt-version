#!/bin/bash

set -- "${1:-$(</dev/stdin)}" "${@:2}"

main() {
  check_args "$@"
  local openwrt_url=$1
  local filename=/tmp/`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 32`
  curl \
    --silent \
    --location \
    "$openwrt_url" > $filename
  FILE=`cat $filename| grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*"|sort|uniq|grep "http://downloads.openwrt.org/releases/"|grep targets|grep -v factory`
  VERSION=`echo $FILE|egrep -o '[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}'|head -n1`
  SHA=`curl -s $FILE|sha256sum|awk '{print $1}'`
  echo '{ "sysupgrade":"'$FILE'", "version":"'$VERSION'", "sha256":"'$SHA'" }'
}

check_args() {
  if (($# != 1)); then
    echo "Error:
    1 url must be provide - $# provided.
  
    Usage:
      $0 https://openwrt.org/toh/hwdata/d-link/d-link_dir-860l_b1
      
Aborting."
    exit 1
  fi
}

main $1
