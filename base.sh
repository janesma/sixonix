#!/bin/bash

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
#	glx.sh

# By default the script will try to use the native resolution. However in
# failure cases, it will warn and fall back to this resolution.
DEFAULT_RES_X=1920
DEFAULT_RES_Y=1080

# Customize this to your own environments.
BENCHDIR=$HOME/benchmarks/
SYNMARK_PATH=$BENCHDIR/Synmark2-6.00/
DEFAULT_LIBS=/usr/lib/xorg/modules/

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

	local path=${1:-$DEFAULT_LIBS}

	export vblank_mode=0
	export LD_LIBRARY_PATH=$path
	export LIBGL_DRIVERS_PATH=$path/dri
	export DISPLAY=:0
	set +o nounset
	[[ -z $RES_X ]] && get_dimensions
}

function gbm_env() {
	env_sanitize

	local path=${1:-$DEFAULT_LIBS}

	export vblank_mode=0
	export LD_LIBRARY_PATH=$path
	export LIBGL_DRIVERS_PATH=$path/dri
	export EGL_DRIVERS_PATH=${LIBGL_DRIVERS_PATH}
	export EGL_PLATFORM=drm
	export PIGLIT_PLATFORM=gbm
}

function dump_system_info() {
	echo $(uname -rvmp) >> $2
	for mesa in $1; do
		mesa_ver=$(strings $mesa/usr/local/lib/dri/i965_dri.so  | grep 'git-' | \
			awk '{print $3 " " $4}')
		echo "$mesa = $mesa_ver" >> $2
	done
}

function is_debug_build() {
	local mesa_dir=$1
	readelf -s ${mesa_dir}/dri/i965_dri.so | grep -q nir_validate_shader
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
CONFIGS_PATH=${SCRIPT_PATH}/conf.d/
declare -A TESTS

for conf_file in ${CONFIGS_PATH}/*.sh; do
	source "$conf_file"
done

# Synmark
TESTS[SYNMARK]='cd $SYNMARK_PATH ; ./synmark2 TESTCONFIGHERE TESTNAMEHERE | grep FPS | awk "{print \$2}"'


# If sourced from another script, just leave
[[ "${BASH_SOURCE[0]}" != "${0}" ]] && return

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
