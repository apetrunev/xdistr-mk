#!/bin/bash -x

. /usr/gtm/.iks_environment

jnl_mtime=$(stat -c %Y $gtm_journals/iks.mjl)
count=6

while [ $cout -ne 0 ]; do
	sleep 10
	jnl_mtime_old=$jnl_mtime
	jnl_mtime=$(stat -c %Y $gtm_journals/iks.mjl)
	if test $jnl_mtime_old -eq $jnl_mtime; then
		mupip set -journal="on,before_images,filename=$gtm_journals/iks.mjl" -region IKS
		break
	fi
	$cout=$(expr $count - 1)
done

if test $count -eq 0; then echo "Journal $gtm_journals/iks.mjl is still updated"; fi
