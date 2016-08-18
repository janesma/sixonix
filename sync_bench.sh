#!/bin/bash

read -d '' possible_hosts << EOF
norris2.jf.intel.com
norris.jf.intel.com
EOF

local_version=$(cat /opt/benchmarks/VERSION | head -n 1)
for i in "${possible_hosts}" ; do
	ver=$(ssh $i "cat /opt/benchmarks/VERSION" | head -n 1)
	if [ $(echo " $local_version > $ver" | bc) -eq 1 ] ; then
		targets+="-H $i"
	fi
done

[[ -z "${targets// }" ]] || prsync ${targets} -e /tmp -a -p 4 -x "--delete" /opt/benchmarks/ /opt/benchmarks/
