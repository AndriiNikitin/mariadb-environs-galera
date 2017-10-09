#!/bin/bash
set -e

. common.sh

# extract worker prefix, e.g. m12
wwid=${1%%-*}
# extract number, e.g. 12
wid=${wwid:1:100}

port=$((3506+$wid))

workdir=$(find . -maxdepth 1 -type d -name "$wwid*" | head -1)

# if folder exists - it must be empty or have only two empry directories
if [[ -d $workdir ]]; then
  ( [[ -d $workdir/dt && "$(ls -A $workdir/dt)" ]] \
  || [[ -d $workdir/bkup && "$(ls -A $workdir/bkup)" ]] \
  || [[ "$(ls -A $workdir | grep -E -v '(^dt$|^bkup$)')" ]] \
  ) &&  { (>&2 echo "Non-empty $workdir aready exists, expected unassigned worker id") ; exit 1; }

  [[ $workdir =~ ($wwid-)([5-9]?)(\.)([0-9])((\.)([1-9]?[0-9]))?(-[1-9][0-9]\.[1-9][0-9]?)? ]] || ((>&2 echo "Couldn't parse format of $workdir, expected $wwid-version") ; exit 1)
  version=${BASH_REMATCH[2]}.${BASH_REMATCH[4]}
  [ -z "${BASH_REMATCH[6]}" ] || version=$major_m5_version.${BASH_REMATCH[6]}
#  galera_version=${BASH_REMATCH[7]}
fi

workdir=$(pwd)/$wwid-${version}
[[ -d $workdir ]] || mkdir $workdir
[[ -d $workdir/dt ]] || mkdir $workdir/dt
[[ -d $workdir/bkup ]] || mkdir $workdir/bkup

# detect windows like this for now
if [[ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]]; then
  dll=dll
  bldtype=Debug
else
  dll=so
fi


# reuse mariadb templates and just replace m-tar to w-tar 
for filename in _template/m-{version,all}/* ; do
  m4 -D__wid=$wid -D__workdir=$workdir -D__srcdir=$src -D__blddir=$bld -D__port=$port -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename \
  | sed s/m-tar/w-tar/g \
  > $workdir/$(basename $filename)
done

for filename in _template/m-{version,all}/*.sh ; do
  chmod +x $workdir/$(basename $filename)
done

# reuse mariadb templates and just replace m-tar to w-tar 
for plugin in $ERN_PLUGINS ; do
  [ -d ./_plugin/$plugin/m-version/ ] && for filename in ./_plugin/$plugin/m-version/* ; do
    MSYS2_ARG_CONV_EXCL="*" m4 -D__wid=$wid -D__workdir=$workdir -D__port=$port -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename \
    | sed s/m-tar/w-tar/g \
    > $workdir/$(basename $filename)

    chmod +x $workdir/$(basename $filename)
  done

  [ -d ./_plugin/$plugin/m-all/ ] && for filename in ./_plugin/$plugin/m-all/* ; do
    MSYS2_ARG_CONV_EXCL="*" m4 -D__wid=$wid -D__workdir=$workdir -D__srcdir=$src -D__blddir=$bld -D__port=$port -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename \
    | sed s/m-tar/w-tar/g \
    > $workdir/$(basename $filename)
    chmod +x $workdir/$(basename $filename)
  done
done

# now we generate scripts from w- templates
for plugin in $ERN_PLUGINS ; do
  [ -d ./_plugin/$plugin/w-version/ ] && for filename in ./_plugin/$plugin/w-version/* ; do
    MSYS2_ARG_CONV_EXCL="*" m4 -D__wid=$wid -D__workdir=$workdir -D__port=$port -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename > $workdir/$(basename $filename)
    chmod +x $workdir/$(basename $filename)
  done

  [ -d ./_plugin/$plugin/w-all/ ] && for filename in ./_plugin/$plugin/w-all/* ; do
    MSYS2_ARG_CONV_EXCL="*" m4 -D__wid=$wid -D__workdir=$workdir -D__srcdir=$src -D__blddir=$bld -D__port=$port -D__bldtype=$bldtype -D__dll=$dll -D__version=$version -D__wwid=$wwid -D__datadir=$workdir/dt $filename > $workdir/$(basename $filename)
    chmod +x $workdir/$(basename $filename)
  done

done

:
