#!/usr/bin/env bash

# Version history:
# 1.0 (1/11/15): Things seem to work.


set -u #undeclared variables are not okay

# This runner is built on top of the core runner provided by base.sh. That
# runner has some variables to set for the paths of various benchmark data.

# In order to use this runner, place a symlink named glx.sh which links to
# base.sh. That glx.sh must reside:
GLX_RUNNER="~/benchmarks/sixonix/glx.sh"

# Next, the script expects the results of `make DESTDIR=foo install` for all mesa
# builds that are to be tested here:
MESA_LIBS="$HOME/mesa-test-dir/*"

#http://mywiki.wooledge.org/BashFAQ/026
# Returns random number from 0 to ($1-1) in global var 'r'.
# Bash syntax.
function rand() {
	local max=$((32768 / $1 * $1))
	while (( (r=$RANDOM) >= max )); do :; done
	r=$(( r % $1 ))
}

function shuffle() {
   local i tmp size max

   # $RANDOM % (i+1) is biased because of the limited range of $RANDOM
   # Compensate by using a range which is a multiple of the array size.
   size=${#TEST_LIST[*]}
   max=$(( 32768 / size * size ))

   for ((i=size-1; i>0; i--)); do
      rand $size
      tmp=${TEST_LIST[i]} TEST_LIST[i]=${TEST_LIST[r]} TEST_LIST[r]=$tmp
   done
}

function populate_test_list() {
	local RUNS=$1
	local ndx=0
	for ((i=1;i<=RUNS;i++)); do
		for mesa in $MESA_LIBS; do
			output=$(basename $mesa)

			if [[ "$GLBENCH" = "true" ]] ; then
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib EGYPT >> bench_egypt_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib EGYPT_O >> bench_egyptoff_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TREX >> bench_trex_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TREX_O >> bench_trexoff_${output}"
			fi

			if [[ "$COMMUNITY" = "true" ]] ; then
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib WARSOW >> bench_warsow_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib XONOTIC >> bench_xonotic_${output}"
			fi

			if [[ "$GPUTEST" = "true" ]] ; then
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib FUR >> bench_fur_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib PLOT3D >> bench_plot3d_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TRIANGLE >> bench_triangle_${output}"
			fi

			if [[ "$SYNMARK" = "true" ]] ; then
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillPixel >> bench_OglFillPixel_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillTexMulti >> bench_OglFillTexMulti_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillTexSingle >> bench_OglFillTexSingle_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexFilterAniso >> bench_OglTexFilterAniso_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexFilterTri >> bench_OglTexFilterTri_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexMem128 >> bench_OglTexMem128_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexMem512 >> bench_OglTexMem512_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomPoint >> bench_OglGeomPoint_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomTriList >> bench_OglGeomTriList_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomTriStrip >> bench_OglGeomTriStrip_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglZBuffer >> bench_OglZBuffer_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch0 >> bench_OglBatch0_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch1 >> bench_OglBatch1_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch2 >> bench_OglBatch2_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch3 >> bench_OglBatch3_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch4 >> bench_OglBatch4_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch5 >> bench_OglBatch5_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch6 >> bench_OglBatch6_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch7 >> bench_OglBatch7_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSDiffuse1 >> bench_OglVSDiffuse1_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSDiffuse8 >> bench_OglVSDiffuse8_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSTangent >> bench_OglVSTangent_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSInstancing >> bench_OglVSInstancing_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSPhong >> bench_OglPSPhong_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSBump2 >> bench_OglPSBump2_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSBump8 >> bench_OglPSBump8_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSPom >> bench_OglPSPom_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglShMapPcf >> bench_OglShMapPcf_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglShMapVsm >> bench_OglShMapVsm_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglCSCloth >> bench_OglCSCloth_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglOclCloth >> bench_OglOclCloth_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglCSDof >> bench_OglCSDof_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglOclDof >> bench_OglOclDof_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDeferred >> bench_OglDeferred_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDeferredAA >> bench_OglDeferredAA_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglHdrBloom >> bench_OglHdrBloom_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglMultithread >> bench_OglMultithread_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainPanInst >> bench_OglTerrainPanInst_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainFlyInst >> bench_OglTerrainFlyInst_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainPanTess >> bench_OglTerrainPanTess_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainFlyTess >> bench_OglTerrainFlyTess_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvState >> bench_OglDrvState_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvShComp >> bench_OglDrvShComp_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvRes >> bench_OglDrvRes_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvCtx >> bench_OglDrvCtx_${output}"
			fi

			if [[ "$UNIGINE" = "true" ]] ; then
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib VALLEY >> bench_valley_${output}"
				TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib HEAVEN >> bench_heaven_${output}"
			fi

#			if [[ "$LONG" = "true" ]] ; then

#			fi
		done
	done
}

if [[ $# -ne 0 ]] ; then
	# If the user specified any arguments, set everything to false
	GLBENCH="false"
	SYNMARK="false"
	UNIGINE="false"
	COMMUNITY="false"
	LONG="false"
	GPUTEST="false"
	ITERATIONS=0
	POST_DELETE="false"
else
	# Otherwise, use all the defaults
	GLBENCH="true"
	SYNMARK="true"
	UNIGINE="false"
	COMMUNITY="false"
	LONG="false"
	GPUTEST="true"
	ITERATIONS=5
	POST_DELETE="true"
fi

DRY_RUN="false"
VERBOSE="false"

function usage() {
	local script_name=$1
	echo Usage: $script_name [-AgsucGdlhnv] [-i iterations] 1>&2
	echo -e "\t-A: Run all tests"
	echo -e "\t-g: Run glbench tests"
	echo -e "\t-s: Run synmark tests"
	echo -e "\t-c: Run community tests"
	echo -e "\t-G: Run gputest tests"
	echo -e "\t-l: Run long (temporally) tests"
	echo -e "\t-d: Delete empty files (failures)"
	echo -e "\t-i iter: Number of iterations to run tests"
	echo -e "\t-h: this message"
	echo -e "\t-v: verbose"
	echo -e "\tn: Dry run"
	echo -e "\tno args: $script_name -gsGcd -i 5"
	echo "Specifying any arguments will set all things to false"
}

while getopts "AgsucGdlhni:v" opt; do
	case "$opt" in
		A)
			GLBENCH="true"
			SYNMARK="true"
			UNIGINE="true"
			COMMUNITY="true"
			LONG="true"
			GPUTEST="true"
			# The user probably wants defaults also
			ITERATIONS=5
			POST_DELETE="true"
			;;
		g) GLBENCH="true" ;;
		s) SYNMARK="true" ;;
		G) GPUTEST="true" ;;
		u) UNIGINE="true" ;;
		c) COMMUNITY="true" ;;
		l) LONG="true" ;;
		d) POST_DELETE="true" ;;
		i) ITERATIONS=$OPTARG ;;
		n) DRY_RUN="true" ; POST_DELETE="false" ;;
		v) VERBOSE="true" ;;
		h|\?|*)
			usage $(basename $0) >&2
			exit 0
			;;
	esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

# Skip any null cases
[[ $ITERATIONS < 1 ]] && echo "0 iterations specified" && exit 0
[[ "$GLBENCH" = "false" ]] && [[ "$SYNMARK" = "false" ]] &&
[[ "$UNIGINE" = "false" ]] && [[ "$COMMUNITY" = "false" ]] &&
[[ "$GPUTEST" = "false" ]] && echo "No tests specified" && exit 0

populate_test_list ${ITERATIONS}
shuffle

for (( i = 0 ; i < ${#TEST_LIST[*]} ; i++ )) do
	before=$(date)
	test_name=$(echo ${TEST_LIST[i]} | awk '{print $NF}')

	if [[ "$VERBOSE" = "true" ]] ; then
		echo -n "Starting $test_name $(date +'%b %d %T') ..."
	else
		echo -ne "[$(($i+1)) / ${#TEST_LIST[*]}] ($test_name) \033[0K\r"
	fi

	if [[ "$DRY_RUN" = "true" ]] ; then
		echo "${TEST_LIST[i]} > /dev/null 2>&1"
	else
		eval ${TEST_LIST[i]} > /dev/null 2>&1
	fi

	elapsed=$(date -d @$(( $(date -d "now" +%s) - $(date -d "$before" +%s))) -u +'%H:%M:%S')
	[[ "$VERBOSE" = "true" ]] && echo "elapsed: $elapsed"
done

echo

#remove empty files
[[ "$POST_DELETE" = "true" ]] && rm -f $(find . -empty)
