#!/bin/bash
# Restores file permissions for all files on a debian system for which .deb
# packages exist.
#
# Author: Larry Kagan <me at larrykagan dot com>

ARCHIVE_DIR=/var/cache/apt/archives/
cd $ARCHIVE_DIR
PACKAGES=`ls *.deb`

function changePerms()
{
CHOWN="/bin/chown"
CHMOD="/bin/chmod"

string="$1"
let perms=0
let symli=0

  [[ "${string}" = l????????? ]] && symli=$(( symli +    1 ))
  [[ "${string}" = ?r???????? ]] && perms=$(( perms +  400 ))
  [[ "${string}" = ??w??????? ]] && perms=$(( perms +  200 ))
  [[ "${string}" = ???x?????? ]] && perms=$(( perms +  100 ))
  [[ "${string}" = ???s?????? ]] && perms=$(( perms + 4100 ))
  [[ "${string}" = ???S?????? ]] && perms=$(( perms + 4000 ))
  [[ "${string}" = ????r????? ]] && perms=$(( perms +   40 ))
  [[ "${string}" = ?????w???? ]] && perms=$(( perms +   20 ))
  [[ "${string}" = ??????x??? ]] && perms=$(( perms +   10 ))
  [[ "${string}" = ??????s??? ]] && perms=$(( perms + 2010 ))
  [[ "${string}" = ??????S??? ]] && perms=$(( perms + 2000 ))
  [[ "${string}" = ???????r?? ]] && perms=$(( perms +    4 ))
  [[ "${string}" = ????????w? ]] && perms=$(( perms +    2 ))
  [[ "${string}" = ?????????x ]] && perms=$(( perms +    1 ))
  [[ "${string}" = ?????????t ]] && perms=$(( perms + 1001 ))
  [[ "${string}" = ?????????T ]] && perms=$(( perms + 1000 ))

PERMS=`echo ${perms}`
OWN=`echo $2 | /usr/bin/tr '/' '.'`
PATHNAME="${3#?} $4 $5 $6"
PATHNAME2=$(echo $PATHNAME | sed 's/ /\\ /g')
# echo "DONE:" $PATHNAME2
# echo -e "CHOWN: $CHOWN $OWN $PATHNAME2"
# result=`$CHOWN $OWN $PATHNAME2`
if [ $? -ne 0 ]; then
$CHOWN $OWN $PATHNAME2
fi
# echo -e "CHMOD: $CHMOD $PERMS $PATHNAME2"
# result=`$CHMOD $PERMS $PATHNAME2`
if [ $? -ne 0 ]; then
$CHMOD $PERMS $PATHNAME2
fi
}
for PACKAGE in $PACKAGES;
do
if [ -d $PACKAGE ]; then
continue;
fi
echo -e "Getting information for $PACKAGE\n"
FILES=`/usr/bin/dpkg -c "${ARCHIVE_DIR}${PACKAGE}"`
for FILE in "$FILES";
do
echo "$FILE" | awk '{print $1"\t"$2"\t"$6"\t"$7"\t"$8"\t"$9}' | while read permstring ownergroup file1 file2 file3 file4; do
if [ "$symli" != "1" ]; then changePerms $permstring $ownergroup $file1 $file2 $file3 $file4;
else echo $PACKAGE $permstring $ownergroup $file1 $file2 $file3 $file4 >> /tmp/symlink.txt; fi
done
done
done
