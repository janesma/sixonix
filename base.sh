#!/bin/bash

# Version history
# 1.0 (1/11/15)
# 1.1 (4/5/15): Add the debug build checker.
# 1.2 (4/6/15): Add the mode change checker and hang checker

VERSION="1.2"

# Example ways to use this script:
# Run GBM piglit with custom mesa:
#	gbm.sh /foo/bar/mesa/lib PIGLIT [extra piglit args] results/dir
# Run GBM piglit with system mesa:
#	gbm.sh /usr/lib PIGLIT results/dir
# Run GLX egypt benchmark with custom mesa:
#	glx.sh /foo/bar/mesa/lib EGYPT
# Run GLX with menu and custom mesa:
#	glx.sh /foo/bar/mesa/lib
# Run GLX with menu and system mesa:
#	base.sh

# By default the script will try to use the native resolution. However in
# failure cases, it will warn and fall back to this resolution.
DEFAULT_RES_X=1920
DEFAULT_RES_Y=1080

# Customize this to your own environments.
BENCHDIR=$HOME/benchmarks/
GLB27_BASE=$BENCHDIR/GLB27/
GL27_DATA_PATH=$GLB27_BASE/data
GL27_PATH=$GLB27_BASE/buildES/binaries/GLBenchmark
GLB30_BASE=$BENCHDIR/GLB30/
GLB30_PATH=$GLB30_BASE/gfxbench-source-corporate/out/build/linux/gfxbench_Release/mainapp
VALLEY_PATH=$BENCHDIR/Valley-1.1-rc1/
SYNMARK_PATH=$BENCHDIR/Synmark2-6.00/
HEAVEN_PATH=$BENCHDIR/Heaven-4.1-rc1/
GPUTEST_PATH=$BENCHDIR/GpuTest_Linux_x64_0.7.0
XONOTIC_PATH=$BENCHDIR/Xonotic
WARSOW_PATH=$BENCHDIR/warsow_15

PIGLIT_PATH=$HOME/intel-gfx/piglit

function heaven() {
	heaven_cfg=$(mktemp -p $HEAVEN_PATH --suffix=.cfg)
	sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${SCRIPT_PATH}/configs/heaven_4.0.cfg > $heaven_cfg
	set -o nounset
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./bin
	./bin/heaven_x64 -engine_config ../$(basename $heaven_cfg)
	set +o nounset
	rm $heaven_cfg
}

function valley() {
	valley_cfg=$(mktemp -p $VALLEY_PATH --suffix=.cfg)
	sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${SCRIPT_PATH}/configs/valley_1.1.cfg > $valley_cfg
	set -o nounset
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./bin
	./bin/valley_x64 -engine_config ../$(basename $valley_cfg)
	set +o nounset
}

function jordanatic() {
	set -- ./xonotic-linux-sdl.sh
	rm -f data/jordanatic.log
	rm -f data/benchmark.log
	rm -f data/engine.log

	# for next version of benchmark: remove +cl_playerdetailreduction 0 and add +showfps 1
	p="+vid_width $RES_X +vid_height $RES_Y +vid_desktopfullscreen 0 \
		+cl_curl_enabled 0 +r_texture_dds_load 1 \
		+cl_playerdetailreduction 0 +developer 1 \
		-nosound -nohome -benchmarkruns 2 \
		-benchmarkruns_skipfirst \
		-benchmark demos/jordanatic.dem"

	for e in ${1}; do
		echo "Benchmarking on $e"
		rm -f data/benchmark.log
		echo + "$@" +exec effects-$e.cfg $p > data/engine.log
		"$@" +exec effects-$e.cfg $p >>data/engine.log 2>&1 || true
		grep "^MED: " data/engine.log # print results to the terminal
		if grep '\]quit' data/engine.log >/dev/null; then
			break
		fi
		cat data/engine.log >> data/jordanatic.log
		cat data/benchmark.log >> data/jordanatic.log
	done

	rm -f data/benchmark.log
	rm -f data/engine.log
	if ! [ -f data/jordanatic.log ]; then
		echo
		echo "The benchmark has been aborted. No log file has been written."
	fi
	popd
}

function get_hang_count() {
	return $(dmesg | grep "GPU HANG" | wc -l)
}

function init() {
	[[ -z $DISPLAY ]] && echo "Inappropriate call to init" && exit 1
	if hash xset 2>/dev/null; then
		xset -dpms; xset s off
	fi
	if hash xscreensaver-command 2>/dev/null; then
		xscreensaver-command -deactivate >/dev/null 2>&1
	fi

	# Get a count of number of GPU hangs at the start of the run
	get_hang_count
	export HANG_COUNT=$?
}

function env_sanitize() {
	unset LD_LIBRARY_PATH
	unset LIBGL_DRIVERS_PATH
	unset LD_LIBRARY_PATH
	unset PIGLIT_PLATFORM
	unset vblank_mode
	unset EGL_PLATFORM
	unset EGL_DRIVERS_PATH
	unset DISPLAY
	unset RES_X
	unset RES_Y
	unset HANG_COUNT
}

function get_dimensions() {
	if hash xdpyinfo 2>/dev/null; then
		read RES_X RES_Y <<< $(xdpyinfo | grep dimensions | \
			awk '{print $2}' | awk -Fx '{print $1, $2}')
	else
		echo "WARNING: COULDN'T GET DIMENSIONS"
		RES_X=$DEFAULT_RES_X
		RES_Y=$DEFAULT_RES_Y
	fi
	export RES_X
	export RES_Y
}

function set_dimensions() {
	local newX=$1
	local newY=$2
	output=$(xrandr | grep -E " connected (primary )?[1-9]+" | \
		sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
	xrandr --output $output --mode ${newX}x${newY}

	get_dimensions
}

function glx_env() {
	env_sanitize
	export vblank_mode=0
	export LD_LIBRARY_PATH=${1}
	export LIBGL_DRIVERS_PATH=${1}/dri
	export DISPLAY=:0
	set +o nounset
	[[ -z $RES_X ]] && get_dimensions
}

function gbm_env() {
	env_sanitize
	export vblank_mode=0
	export LD_LIBRARY_PATH=${1}
	export LIBGL_DRIVERS_PATH=${1}/dri
	export EGL_DRIVERS_PATH=${LIBGL_DRIVERS_PATH}
	export EGL_PLATFORM=drm
	export PIGLIT_PLATFORM=gbm
}

function is_debug_build() {
	local mesa_dir=$1
	readelf -S ${mesa_dir}/dri/i965_dri.so | grep -q debug
	return $?
}

function check_gpu_hang() {
	get_hang_count
	local count=$?
	if [[ $count -gt $HANG_COUNT ]] ; then
		export HANG_COUNT=$count
		return 0
	else
		return 1
	fi
}

synmark_cfg=""

function init_synmark() {
	# Create a synmark config file with the proper resolutions
	[[ -n $synmark_cfg ]] && echo "Synmark init can only be called once" && exit -1
	get_dimensions
	#synmark requires configs to be specified as "-name" without .cfg, but
	#the file must actually be named.cfg
	synmark_cfg=$(mktemp -p $SYNMARK_PATH --suffix=.cfg)
	echo "FullScreen = 1;" >> $synmark_cfg
	echo "ScreenWidth = ${RES_X};" >> $synmark_cfg
	echo "ScreenHeight = ${RES_Y};" >> $synmark_cfg
	echo "RenderingTime = 5.0;" >> $synmark_cfg
	echo "ValidateImage = 0;" >> $synmark_cfg

	echo $synmark_cfg #return to caller
}

SCRIPT_PATH=$(realpath $(dirname $BASH_SOURCE))
declare -A TESTS
TESTS[XONOTIC_BIGKEY]='$XONOTIC_PATH/misc/tools/the-big-benchmark/sixonix.sh "normal" 2>/dev/null | egrep -e "[0-9]+ frames" | awk "{print \$6}"'
TESTS[XONOTIC]='cd $XONOTIC_PATH ; jordanatic "normal" 2>/dev/null | egrep -e "[0-9]+ frames" | awk "{print \$6}"'

TESTS[WARSOW]='
$WARSOW_PATH/warsow -nosound +set fs_basepath "$WARSOW_PATH" +set fs_usehomedir 0 \
	+set timedemo 1 +exec sixonix.cfg +demo benchsow.wdz20 \
	+next "quit" 2> /dev/null 2>&1 | grep frames | awk "{print \$5}"'

TESTS[TREX]='
$GL27_PATH -data $GL27_DATA_PATH -skip_load_frames \
	-w $RES_X -h $RES_Y -ow $RES_X -oh $RES_Y \
	-t GLB27_TRex_C24Z16_FixedTimeStep | \
	grep fps | awk -F "[()]" "{print \$2}" | awk "{print \$1}"'

TESTS[TREX_O]='
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

TESTS[MANHATTAN]='
cd $GLB30_PATH ; \
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:. ; \
	MESA_GLSL_VERSION_OVERRIDE=400 \
	MESA_GL_VERSION_OVERRIDE=4.1 \
	./mainapp -t gl_manhattan -w $RES_X -h $RES_Y | \
	grep score | awk -F"[ ,]" "{printf \"%.3f\\n\", \$5}"'

TESTS[MANHATTAN_O]='
cd $GLB30_PATH ; \
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:. ; \
	MESA_GLSL_VERSION_OVERRIDE=400 \
	MESA_GL_VERSION_OVERRIDE=4.1 \
	./mainapp -t gl_manhattan_off -w $RES_X -h $RES_Y | \
	grep score | awk -F"[ ,]" "{printf \"%.3f\\n\", \$5}"'

TESTS[VALLEY]='cd $VALLEY_PATH ; valley | grep -i fps | awk "{print \$2}"'
TESTS[HEAVEN]='cd $HEAVEN_PATH ; heaven | grep -i fps | awk "{print \$2}"'

#Be careful. I sed this, so newlines don't work easily
TESTS[SYNMARK]='
cd $SYNMARK_PATH ; ./synmark2 TESTCONFIGHERE TESTNAMEHERE | grep FPS | awk "{print \$2}"'

TESTS[FUR]='
cd $GPUTEST_PATH ; \
./GpuTest /fullscreen /width=$RES_X /height=$RES_Y \
	/benchmark /benchmark_duration_ms=10000 \
	/print_score /no_scorebox \
	/test=fur | \
	grep Score | awk "{print \$2}"'

TESTS[PLOT3D]='
cd $GPUTEST_PATH ; \
./GpuTest /fullscreen /width=$RES_X /height=$RES_Y \
	/benchmark /benchmark_duration_ms=10000 \
	/print_score /no_scorebox \
	/test=plot3d | \
	grep Score | awk "{print \$2}"'

TESTS[TRIANGLE]='
cd $GPUTEST_PATH ; \
./GpuTest /fullscreen /width=$RES_X /height=$RES_Y \
	/benchmark /benchmark_duration_ms=10000 \
	/print_score /no_scorebox \
	/test=triangle |
	grep Score | awk "{print \$2}"'

TESTS[PIGLIT]='cd $PIGLIT_PATH ; ./piglit-run.py -x glean -x glx gpu'
TESTS[NOP]='echo 10' #Sanity check

# If sourced from another script, just leave
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return

if [[ $# && "$1" = "-v" ]] ; then
	echo version: $VERSION
	exit 0
fi

# IF our script name was gbm.sh, setup the GBM environment. If it was named
# glx, then do the usual thing. Default to local mesa install
script_name=`basename $0`
if [[ $script_name = "gbm.sh" ]] ; then
	gbm_env $1
	shift
elif [[ $script_name = "glx.sh" ]] ; then
	glx_env $1
	shift
fi

[[ -n $SKIP_RUNNER_INIT ]] && init

if [[ $# -eq 0 ]]; then
	prompt="Pick an option:"

	PS3="Select test (just hit ctrl+c to exit)"
	select test in ${!TESTS[*]} "Exit"; do
	    case "$REPLY" in
	    *) eval "${TESTS[$test]}";;
	    esac
	done
else
	if [[ "$1" = "SYNMARK" ]] ; then
		syn_test=$2
		if [[ $# -eq 3 ]] ; then
			synmark_cfg="-$(basename -s .cfg $3)"
		else
			#FIXME: leaves a tmp file
			synmark_cfg="-$(basename -s .cfg $(init_synmark))"
		fi
		set -o nounset
		cmd=${TESTS[$1]/TESTNAMEHERE/$syn_test}
		cmd=${cmd/TESTCONFIGHERE/$synmark_cfg}
		set +o nounset
		shift
		shift
		eval $cmd
	else
		index=$1
		shift
		set -o nounset
		eval "${TESTS[$index]} $*"
		set +o nounset
	fi
fi
