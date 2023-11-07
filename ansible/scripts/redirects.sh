#!/bin/bash
 echo
 for yourdomain in $@; do
 echo --------------------
 echo $yourdomain
 echo --------------------
 curl -sILk $yourdomain | egrep 'HTTP|Loc' | sed 's/Loc/ -> Loc/g'
 echo
 done