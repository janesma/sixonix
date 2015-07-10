#!/usr/bin/env bash

set -u #undeclared variables are not okay

GBM_RUNNER="$HOME/scripts/sixonix/gbm.sh"
MESA_LIBS="$HOME/mesa-test-dir/*"

source ${GBM_RUNNER}

dump_system_info "$MESA_LIBS" execution.log

for mesa in $MESA_LIBS; do
	output=$(basename $mesa)
	${GBM_RUNNER} ${mesa}/usr/local/lib PIGLIT ${PWD}/piglit_${output}
done
