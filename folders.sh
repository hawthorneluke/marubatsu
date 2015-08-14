#!/bin/bash

dir=$1

check_files()
{
d=$1
for i in {1..9}
do
 f=${d}/${i}
 if [[ ! -e $f ]] && [[ ! -e "${f}o" ]] && [[ ! -e "${f}x" ]] ; then
  touch $f
  chmod 777 $f
 fi
done
}

while true
do
 for d in ${dir}/*/
 do
  if [[ -d $d ]] ; then
   echo $d
   check_files $d
   ./nac.sh $d
  fi
 done
 sleep 1
done

