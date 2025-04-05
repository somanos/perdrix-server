#!/bin/bash

set -e

base="$(dirname "$(readlink -f "$0")")"
target=$base/procedures
echo Entering $target
cd $target
if [ "$1" == "" ]; then
  db=8_4fad48fd4fad4903
fi
echo $atching db $db
for i in $(ls *.sql); do
  echo $i
  mariadb $db < $i;
done
