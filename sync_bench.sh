#!/bin/bash

# This script synchronizes the benchmarks directory. It should be run on the
# "master" or most up to date machine, and it will push the changes to the
# slave.
#
# It has a couple of external dependencies
# - bc for version comparison
# - pssh for parallel rsync


BENCHMARK_DIR=/opt/benchmarks/
PARALLEL_JOBS=4 # Might want to increase for many slaves.

read -d '' possible_hosts << EOF
norris2.jf.intel.com
norris.jf.intel.com
EOF

local_version=$(cat ${BENCHMARK_DIR}/VERSION | head -n 1)
for i in "${possible_hosts}" ; do
	ver=$(ssh $i "cat ${BENCHMARK_DIR}/VERSION" | head -n 1)
	if [ $(echo " $local_version > $ver" | bc) -eq 1 ] ; then
		targets+="-H $i"
	fi
done

[[ -z "${targets// }" ]] || prsync ${targets} -e /tmp -a -p ${PARALLEL_JOBS} -x "--delete" ${BENCHMARK_DIR}/ ${BENCHMARK_DIR}/
