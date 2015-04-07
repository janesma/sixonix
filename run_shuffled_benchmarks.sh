#!/usr/bin/env bash

# Version history:
# 1.0 (1/11/15): Things seem to work.

TEE="tee -a"
set -u #undeclared variables are not okay

# This runner is built on top of the core runner provided by base.sh. That
# runner has some variables to set for the paths of various benchmark data.

# In order to use this runner, place a symlink named glx.sh which links to
# base.sh. That glx.sh must reside:
GLX_RUNNER="$HOME/scripts/sixonix/glx.sh"

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

# Empty will use the default config, we never want this when run from here, so
# the -u saves us.
#synmark_cfg=""

function populate_full_test_list() {
	local mesa=$1
	local output=$2

	if [[ "$GLBENCH" = "true" ]] ; then
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib EGYPT | $TEE bench_egypt_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib EGYPT_O | $TEE bench_egyptoff_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TREX | $TEE bench_trex_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TREX_O | $TEE bench_trexoff_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib MANHATTAN | $TEE bench_manhattan_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib MANHATTAN_O | $TEE bench_manhattanoff_${output}"
	fi

	if [[ "$COMMUNITY" = "true" ]] ; then
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib WARSOW | $TEE bench_warsow_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib XONOTIC | $TEE bench_xonotic_${output}"
	fi

	if [[ "$GPUTEST" = "true" ]] ; then
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib FUR | $TEE bench_fur_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib PLOT3D | $TEE bench_plot3d_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TRIANGLE | $TEE bench_triangle_${output}"
	fi

	if [[ "$SYNMARK" = "true" ]] ; then
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillPixel ${synmark_cfg} | $TEE bench_OglFillPixel_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillTexMulti ${synmark_cfg} | $TEE bench_OglFillTexMulti_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillTexSingle ${synmark_cfg} | $TEE bench_OglFillTexSingle_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexFilterAniso ${synmark_cfg} | $TEE bench_OglTexFilterAniso_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexFilterTri ${synmark_cfg} | $TEE bench_OglTexFilterTri_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexMem128 ${synmark_cfg} | $TEE bench_OglTexMem128_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexMem512 ${synmark_cfg} | $TEE bench_OglTexMem512_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomPoint ${synmark_cfg} | $TEE bench_OglGeomPoint_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomTriList ${synmark_cfg} | $TEE bench_OglGeomTriList_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomTriStrip ${synmark_cfg} | $TEE bench_OglGeomTriStrip_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglZBuffer ${synmark_cfg} | $TEE bench_OglZBuffer_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch0 ${synmark_cfg} | $TEE bench_OglBatch0_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch1 ${synmark_cfg} | $TEE bench_OglBatch1_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch2 ${synmark_cfg} | $TEE bench_OglBatch2_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch3 ${synmark_cfg} | $TEE bench_OglBatch3_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch4 ${synmark_cfg} | $TEE bench_OglBatch4_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch5 ${synmark_cfg} | $TEE bench_OglBatch5_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch6 ${synmark_cfg} | $TEE bench_OglBatch6_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch7 ${synmark_cfg} | $TEE bench_OglBatch7_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSDiffuse1 ${synmark_cfg} | $TEE bench_OglVSDiffuse1_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSDiffuse8 ${synmark_cfg} | $TEE bench_OglVSDiffuse8_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSTangent ${synmark_cfg} | $TEE bench_OglVSTangent_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSInstancing ${synmark_cfg} | $TEE bench_OglVSInstancing_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSPhong ${synmark_cfg} | $TEE bench_OglPSPhong_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSBump2 ${synmark_cfg} | $TEE bench_OglPSBump2_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSBump8 ${synmark_cfg} | $TEE bench_OglPSBump8_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSPom ${synmark_cfg} | $TEE bench_OglPSPom_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglShMapPcf ${synmark_cfg} | $TEE bench_OglShMapPcf_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglShMapVsm ${synmark_cfg} | $TEE bench_OglShMapVsm_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglCSCloth ${synmark_cfg} | $TEE bench_OglCSCloth_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglOclCloth ${synmark_cfg} | $TEE bench_OglOclCloth_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglCSDof ${synmark_cfg} | $TEE bench_OglCSDof_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglOclDof ${synmark_cfg} | $TEE bench_OglOclDof_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDeferred ${synmark_cfg} | $TEE bench_OglDeferred_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDeferredAA ${synmark_cfg} | $TEE bench_OglDeferredAA_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglHdrBloom ${synmark_cfg} | $TEE bench_OglHdrBloom_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglMultithread ${synmark_cfg} | $TEE bench_OglMultithread_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainPanInst ${synmark_cfg} | $TEE bench_OglTerrainPanInst_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainFlyInst ${synmark_cfg} | $TEE bench_OglTerrainFlyInst_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainPanTess ${synmark_cfg} | $TEE bench_OglTerrainPanTess_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainFlyTess ${synmark_cfg} | $TEE bench_OglTerrainFlyTess_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvState ${synmark_cfg} | $TEE bench_OglDrvState_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvShComp ${synmark_cfg} | $TEE bench_OglDrvShComp_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvRes ${synmark_cfg} | $TEE bench_OglDrvRes_${output}"
#		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDrvCtx ${synmark_cfg} | $TEE bench_OglDrvCtx_${output}"
	fi

	if [[ "$UNIGINE" = "true" ]] ; then
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib VALLEY | $TEE bench_valley_${output}"
		TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib HEAVEN | $TEE bench_heaven_${output}"
	fi
}

function populate_quick_test_list() {
	local mesa=$1
	local output=$2

	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib TREX | $TEE bench_trex_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib MANHATTAN_O | $TEE bench_manhattanoff_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib PLOT3D | $TEE bench_plot3d_${output}"

	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglFillPixel ${synmark_cfg} | $TEE bench_OglFillPixel_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTexMem512 ${synmark_cfg} | $TEE bench_OglTexMem512_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomPoint ${synmark_cfg} | $TEE bench_OglGeomPoint_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglGeomTriList ${synmark_cfg} | $TEE bench_OglGeomTriList_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglZBuffer ${synmark_cfg} | $TEE bench_OglZBuffer_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglBatch7 ${synmark_cfg} | $TEE bench_OglBatch7_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSDiffuse8 ${synmark_cfg} | $TEE bench_OglVSDiffuse8_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglVSInstancing ${synmark_cfg} | $TEE bench_OglVSInstancing_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSPhong ${synmark_cfg} | $TEE bench_OglPSPhong_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSBump2 ${synmark_cfg} | $TEE bench_OglPSBump2_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglPSPom ${synmark_cfg} | $TEE bench_OglPSPom_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglShMapPcf ${synmark_cfg} | $TEE bench_OglShMapPcf_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglDeferred ${synmark_cfg} | $TEE bench_OglDeferred_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglHdrBloom ${synmark_cfg} | $TEE bench_OglHdrBloom_${output}"
	TEST_LIST[((ndx++))]="${GLX_RUNNER} ${mesa}/usr/local/lib SYNMARK OglTerrainFlyInst ${synmark_cfg} | $TEE bench_OglTerrainFlyInst_${output}"
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
	echo -e "\t-Q: Run a quick set of tests"
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

while getopts "AQgsucGdlhni:v" opt; do
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
		Q) ITERATIONS=2
		   SYNMARK="true" # This is a lie
		   QUICK="true"
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
[[ "$DRY_RUN" = "true" ]] && POST_DELETE=false

# Initialize our environment now so we have all the variables set for building
# the tests. This means we can skip it in the future.
source ${GLX_RUNNER}

for mesa in $MESA_LIBS; do
	if is_debug_build ${mesa}/usr/local/lib ; then
		echo "Trying to benchmark a debug build ($mesa). Abort!"
		exit 1
	fi
done

# The runner will later set up the real paths, but we want the display setup
# done now.
glx_env FAKE_PATH

init
export SKIP_RUNNER_INIT=1

if [[ "$SYNMARK" = "true" ]] ; then
	synmark_cfg=$(init_synmark)
	[[ "$VERBOSE" = "true" ]] && cat $synmark_cfg
fi

ndx=0
for ((i=1;i<=ITERATIONS;i++)); do
	for mesa in $MESA_LIBS; do
		output=$(basename $mesa)
		if [[ -z $QUICK ]] ; then
			populate_full_test_list $mesa $output
		else
			populate_quick_test_list $mesa $output
		fi
	done
done

shuffle

for (( i = 0 ; i < ${#TEST_LIST[*]} ; i++ )) do
	before=$(date)
	test_name=$(echo ${TEST_LIST[i]} | awk '{print $NF}')

	if [[ "$VERBOSE" = "true" ]] ; then
		echo -n "Starting $test_name $(date +'%c') ..."
	else
		echo -ne "[$(($i+1)) / ${#TEST_LIST[*]}] ($test_name) \033[0K\r"
	fi

	if [[ "$DRY_RUN" = "true" ]] ; then
		echo "${TEST_LIST[i]} 2> /dev/null"
	else
		oldX=$RES_X
		oldY=$RES_Y
		fps=$(eval ${TEST_LIST[i]} 2> /dev/null)
		echo "$test_name $fps $(date +'%T')" >> execution.log
		last_test=${TEST_LIST[i]##* }

		get_dimensions
		if [ $oldX -ne $RES_X ] || [ $oldY -ne $RES_Y ] ; then
			sed -i '$s/.*/!!!MODE_CHANGED!!!/' $last_test
			set_dimensions $RES_X $RES_Y
		fi
	fi

	elapsed=$(date -d @$(( $(date -d "now" +%s) - $(date -d "$before" +%s))) -u +'%M:%S')
	[[ "$VERBOSE" = "true" ]] && echo "elapsed: $elapsed"
done

echo

#remove empty files
[[ "$POST_DELETE" = "true" ]] && rm -f $(find . -empty)

[[ "$SYNMARK" = "true" ]] && rm $synmark_cfg
