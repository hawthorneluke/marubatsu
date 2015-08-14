#!/bin/bash

dir=$1
tiles=
is_my_turn=0
oforkmap=
xforkmap=

win_msg="こ、このオレ様が、負けるなんて・・？！"

think()
{
ret=`try_win_block x`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_win_block o`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_fork`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_block_fork`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_center`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_opposite_or_empty_corner 1`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_opposite_or_empty_corner`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi

ret=`try_empty_side`
if [ "$ret" != "" ] ; then echo $ret ; return ; fi
}

check_cheat()
{
o=0
x=0
str=$1
f=${dir}/${str}

for i in {1..9}
do
 if [ "${tiles[$i]}" == "o" ] ; then
  o=$((o+1))
 elif [ "${tiles[$i]}" == "x" ] ; then
  x=$((x+1))
 fi
done

if [ $o -gt $((x+1)) ] ; then
 touch $f
 chmod 000 $f
 echo $f
fi
}

check_win()
{
mark=$1
str=$2
f=${dir}/${str}

if [[ ! -e $f ]] ; then
 #rows
 for i in {1..3}
 do
  ret=`check_row $i`
  if [ "`check_count "$mark" "$ret"`" == "3" ] ; then
   touch $f
   chmod 000 $f
   echo $f
  fi

  ret=`check_col $i`
  if [ "`check_count "$mark" "$ret"`" == "3" ] ; then
   touch $f
   chmod 000 $f
   echo $f
  fi

  if [ $i -lt 3 ] ; then
   ret=`check_diag $i`
   if [ "`check_count "$mark" "$ret"`" == "3" ] ; then
    touch $f
    chmod 000 $f
    echo $f
   fi  
  fi
 done 
fi
}

check_draw()
{
str=$1
f=${dir}/${str}

ret=`check_tiles 1 2 3 4 5 6 7 8 9`
if [ "`check_count "\." "$ret"`" == "0" ] ; then
 touch $f
 chmod 777 $f
 echo $f
fi
}

reset_fork_maps()
{
for i in {1..9}
do
 xforkmap[$i]=0
 oforkmap[$i]=0
done
}

try_fork()
{
reset_fork_maps
try_fork_block_check x

for i in {1..9}
do
 if [[ ${xforkmap[$i]} -ge 2 ]] ; then
  echo $i
  return
 fi
done
}

try_block_fork()
{
reset_fork_maps
try_fork_block_check o
try_fork_block_check x

#don't let opponent fork
for i in {1..9}
do
 if [[ ${oforkmap[$i]} -ge 2 ]] ; then
  echo $i
  return
 fi
done

for i in {1..9}
do
 if [[ ${xforkmap[$i]} -ge 1 ]] ; then
  echo $i
  return
 fi
done

#if xforkmap is empty, block opponents fork
for i in {1..9}
do
 if [[ ${oforkmap[$i]} -ge 2 ]] ; then
  echo $i
  return
 fi
done
}

try_fork_block_check()
{
mark=$1

#rows
for i in {1..3}
do
 ret=`check_row $i`
 if [ "`check_count "$mark" "$ret"`" == "1" ] && [ "`check_count "\." "$ret"`" == "2" ] ; then
  for j in {1..3}
  do
   a=$(( j-1 ))
   if [[ "${ret:$a:1}" == "." ]] ; then
    k=$(( ((i-1)*3)+j ))
    case $mark in
     x)
      xforkmap[$k]=$((xforkmap[$k]+1))
     ;;
     o)
      oforkmap[$k]=$((oforkmap[$k]+1))
     ;;
    esac 
   fi
  done
 fi
done

#cols
for i in {1..3}
do
 ret=`check_col $i` 
 if [ "`check_count "$mark" "$ret"`" == "1" ] && [ "`check_count "\." "$ret"`" == "2" ] ; then
  for j in {1..3}
  do
   a=$(( j-1 ))
   if [[ "${ret:$a:1}" == "." ]] ; then
    k=$(( ((j-1)*3)+i ))
    case $mark in
     x)
      xforkmap[$k]=$((xforkmap[$k]+1))
     ;;
     o)
      oforkmap[$k]=$((oforkmap[$k]+1))
     ;;
    esac 
   fi
  done
 fi
done

#diags
for i in {1..2}
do
 ret=`check_diag $i` 
 if [ "`check_count "$mark" "$ret"`" == "1" ] && [ "`check_count "\." "$ret"`" == "2" ] ; then
  for j in {1..3}
  do
   a=$(( j-1 ))
   if [[ "${ret:$a:1}" == "." ]] ; then
    case $i in
     1)
      case $j in
       1)
        k=1
       ;;
       2)
        k=5
       ;;
       3)
        k=9
       ;;
      esac
     ;;
     2)
      case $j in
       1)
        k=3
       ;;
       2)
        k=5
       ;;
      3)
       k=7
      ;;
      esac
     ;;
    esac
    
    case $mark in
     x)
      xforkmap[$k]=$((xforkmap[$k]+1))
     ;;
     o)
      oforkmap[$k]=$((oforkmap[$k]+1))
     ;;
    esac
   fi
  done
 fi
done
}

try_center()
{
if [[ "`check_tiles 5`" == "." ]] ; then
 echo 5
fi
}

try_opposite_or_empty_corner()
{
if [[ "`check_tiles 1`" == "o" ]] || [[ "$1" != "1" ]] ; then
 if [[ "`check_tiles 9`" == "." ]] ; then
  echo 9
  return
 fi
fi

if [[ "`check_tiles 3`" == "o" ]] || [[ "$1" != "1" ]] ; then
 if [[ "`check_tiles 7`" == "." ]] ; then
  echo 7
  return
 fi
fi

if [[ "`check_tiles 7`" == "o" ]] || [[ "$1" != "1" ]] ; then
 if [[ "`check_tiles 3`" == "." ]] ; then
  echo 3
  return
 fi
fi

if [[ "`check_tiles 9`" == "o" ]] || [[ "$1" != "1" ]] ; then
 if [[ "`check_tiles 1`" == "." ]] ; then
  echo 1
  return
 fi
fi
}

try_empty_side()
{
if [[ "`check_tiles 2`" == "." ]] ; then
 echo 2
 return
fi

if [[ "`check_tiles 4`" == "." ]] ; then
 echo 4
 return
fi

if [[ "`check_tiles 6`" == "." ]] ; then
 echo 6
 return
fi

if [[ "`check_tiles 8`" == "." ]] ; then
 echo 8
 return
fi
}

check_count() #char, string
{
echo `grep -o "$1" <<<"$2" | wc -l`
}

check_tiles()
{
str=""
while [[ $# -gt 0 ]]
do 
 t=${tiles[$1]}
 if [ "$t" == "" ] ; then t="." ; fi 
 str="${str}${t}"
shift
done
echo $str
}

check_row()
{
case $1 in
 1)
  echo `check_tiles 1 2 3` ;;
 2)
  echo `check_tiles 4 5 6` ;;
 3)
  echo `check_tiles 7 8 9` ;;
esac
}

check_col()
{
case $1 in
 1)
  echo `check_tiles 1 4 7` ;;
 2)
  echo `check_tiles 2 5 8` ;;
 3)
  echo `check_tiles 3 6 9` ;;
esac
}

check_diag()
{
case $1 in
 1)
  echo `check_tiles 1 5 9` ;;
 2)
  echo `check_tiles 3 5 7` ;;
esac
}

try_win_block()
{
mark=$1
for i in {1..3}
do
ret=`check_row $i`
win=`try_win_block_check $ret $mark`
if [[ "$win" != "" ]] ; then
 echo $(( ((i-1)*3)+win ))
fi
done

for i in {1..3}
do
ret=`check_col $i`
win=`try_win_block_check $ret $mark`
if [[ "$win" != "" ]] ; then
 echo $(( ((win-1)*3) + i  ))
fi
done

for i in {1..2}
do
ret=`check_diag $i`
win=`try_win_block_check $ret $mark`
if [[ "$win" != "" ]] ; then
 case $i in
   1)
    case $win in
     1)
      echo 1 ;;
     2)
      echo 5 ;;
     3)
      echo 9 ;;
    esac ;; 
   2)
    case $win in
     1)
      echo 3 ;;
     2)
      echo 5 ;;
     3)
      echo 7 ;;
    esac ;;
  esac
 fi
done
}

try_win_block_check()
{
if [ "`check_count "$2" $1`" == "2" ] && [ "`check_count "\." $1`" == "1" ] ; then
 echo `get_pos $1 "\."`
fi
}

get_pos() #string, char, char occurance num (starting from 1)
{
i=$3
if [[ "$i" == "" ]] ; then
 i=0
else
 i=$(((i-1)*4))
fi
posstr=`echo $1 | grep -aob "$2"`
pos=${posstr:$i:1}
if [[ "$pos" == "" ]] ; then
 return
fi
pos=$((pos+1))
echo $pos
}

play()
{
get_tiles

ret=`check_cheat "インチキしないと勝てないんだね"`
if [ "$ret" != "" ] ; then return ; fi

ret=`check_win x "お前の負けだ"`
if [ "$ret" != "" ] ; then return ; fi

ret=`check_win o "$win_msg"`
if [ "$ret" != "" ] ; then return ; fi

ret=`check_draw "引き分けだ。勝たないと意味がないぞ"`
if [ "$ret" != "" ] ; then return ; fi

if [ "$is_my_turn" == "1" ] ; then
 t=`think`
 if [[ "$t" != "" ]] ; then
  place_tile $t
 fi 
fi
}

place_tile()
{
index=$1
mv ${dir}/${index}* ${dir}/${index}x
}

get_tiles()
{
 ocount=0
 xcount=0
 for pass in "$dir"/*
 do
  file=`basename $pass`
  index=${file:0:1}
  case $index in
   1|2|3|4|5|6|7|8|9)
    b=0
   ;;
   *)
    b=1
   ;;
  esac

  if [[ $b -eq 1 ]] ; then
   continue
  fi

  if [ "`echo "$file" | grep -i o`" != "" ] ; then
   tiles[$index]="o"
   ocount=$((ocount+1))
  elif [ "`echo "$file" | grep -i x`" != "" ] ; then
   tiles[$index]="x"
   xcount=$((xcount+1))
  else
   tiles[$index]=""
  fi 
  #echo ${tiles[$index]}
 done
 if [ $ocount -gt $xcount ] ; then
  is_my_turn=1
 else
  is_my_turn=0 
 fi
}

play
