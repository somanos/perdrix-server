#!/bin/bash

set -e

base="$(dirname "$(readlink -f "$0")")"
target=$base/procedures
echo Entering $target
cd $target
if [ "$1" = "" ]; then
  echo rquire db name
  exit 1
fi
db=$1
echo db=$db
for i in $(ls *.sql); do
  echo $i
  mariadb $db < $i;
done
