#!/bin/bash

. /usr/gtm/.iks_environment

export DISPLAY=:1

WDIR=$gtm_dist/xm/print/PF_Client

# EXAMPLE:
# wine $gtm_dist/xm/print/PF_Client/XMagicPFCl.exe \	$1
#      pfm2295888498.pfi \				$2	$pfi
#      pfm2295888498.pfs \				$3	$pfs
#      pfm2295888498 \					$4
#      1 \						$5
#      0 \						$6
#      9.2.3 \						$7
#      1 \						$8
#      pfm2295888498.ini \				$9	$ini
#      PDF \						$10
#      $gtm_dist/xm/print/tmp/test.pdf			$11	$pdf

pfi=$2
pfs=$3
ini=$9
pdf=${11}

exec 2>&1
exec > /dev/null

# Create pdf file
cd $WDIR && wine $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} && pdf=${11}
pdftops -level3 $pdf ${pdf%.*}.ps &
