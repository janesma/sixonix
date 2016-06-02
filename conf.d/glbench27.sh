GLB27_BASE=$BENCHDIR/_deprecated_/GLB27/
GL27_DATA_PATH=$GLB27_BASE/data
GL27_PATH=$GLB27_BASE/buildES/binaries/GLBenchmark

function gfxbench27() {
	if [ -z ${DEBUGGER+x} ]; then
		$GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
			-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
			-t ${1} | \
			grep fps | awk -F "[()]" "{print \$2}" | awk "{print \$1}"
	else
		${DEBUGGER} $GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
			-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
			-t ${1}
	fi
}

#TESTS[TREX_2.7]='gfxbench27 GLB27_TRex_C24Z16_FixedTimeStep'
#TESTS[TREX_O_2.7]='gfxbench27 GLB27_TRex_C24Z16_FixedTimeStep_Offscreen'
TESTS[EGYPT]='gfxbench27 GLB27_EgyptHD_inherited_C24Z16_FixedTime'
TESTS[EGYPT_O]='gfxbench27 GLB27_EgyptHD_inherited_C24Z16_FixedTime_Offscreen'
