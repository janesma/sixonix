GLB27_BASE=$BENCHDIR/_deprecated_/GLB27/
GL27_DATA_PATH=$GLB27_BASE/data
GL27_PATH=$GLB27_BASE/buildES/binaries/GLBenchmark

TESTS[TREX_2.7]='
$GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
	-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
	-t GLB27_TRex_C24Z16_FixedTimeStep | \
	grep fps | awk -F "[()]" "{print \$2}" | awk "{print \$1}"'

TESTS[TREX_O_2.7]='
$GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
	-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
	-t GLB27_TRex_C24Z16_FixedTimeStep_Offscreen | \
	grep fps | awk -F "[()]" "{print \$2}" | awk "{print \$1}"'

TESTS[EGYPT]='
$GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
	-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
	-t GLB27_EgyptHD_inherited_C24Z16_FixedTime | \
	grep fps | awk -F "[()]" "{print \$2}" | awk "{print \$1}"'

TESTS[EGYPT_O]='
$GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
	-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
	-t GLB27_EgyptHD_inherited_C24Z16_FixedTime_Offscreen | \
	grep fps | awk -F "[()]" "{print \$2}" | awk "{print \$1}"'
