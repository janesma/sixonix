GFXB31_BASE=$BENCHDIR/gfxbench_gl-src-3.1.1+corporate/
GFXB31_PATH=$GFXB31_BASE/out/build/linux/testfw_Release/tfw-dev/
GFXB40_BASE=$BENCHDIR/gfxbench_gl-src-4.0.13-candidate+corporate/
GFXB40_PATH=$GFXB40_BASE/out/build/linux/testfw_Release/tfw-dev/

function gfxbench31() {
# anecdotal evidence suggests that if you set a -w, or -h, the benchmark won't
# actually run in fullscreen mode. However, you must set the offscreen width +
# height correctly.
	if [ -z ${DEBUGGER+x} ]; then
		${2}/testfw_app \
			--ei -fullscreen=1 \
			--ei -offscreen_width=$RES_X --ei -offscreen_height=$RES_Y \
			-b ${2} -t ${1} \
			--ei -play_time=30000 \
			--gfx glfw | \
			grep fps | awk -F"[ ,]" "{printf \"%.3f\\n\", \$6}"
	else
		${DEBUGGER} ${2}/testfw_app \
			--ei -fullscreen=1 \
			--ei -offscreen_width=$RES_X --ei -offscreen_height=$RES_Y \
			-b ${2} -t ${1} \
			--ei -play_time=30000 \
			--gfx glfw
	fi
}


function gfxbench40() {
# anecdotal evidence suggests that if you set a -w, or -h, the benchmark won't
# actually run in fullscreen mode. However, you must set the offscreen width +
# height correctly.
	if [ -z ${DEBUGGER+x} ]; then
		${2}/testfw_app \
			--ei -fullscreen=1 \
			--ei -offscreen_width=$RES_X --ei -offscreen_height=$RES_Y \
			-b ${2} -t ${1} \
			--ei -play_time=30000 \
			--gfx glfw | \
			grep fps | awk -F"[ ,]" "{printf \"%.3f\\n\", \$6}"
	else
		${DEBUGGER} ${2}/testfw_app \
			--ei -fullscreen=1 \
			--ei -offscreen_width=$RES_X --ei -offscreen_height=$RES_Y \
			-b ${2} -t ${1} \
			--ei -play_time=30000 \
			--gfx glfw
	fi
}
TESTS[CAR_CHASE]='gfxbench40 gl_4 $GFXB40_PATH'
TESTS[CAR_CHASE_O]='gfxbench40 gl_4_off $GFXB40_PATH'
TESTS[FILL]='gfxbench40 gl_fill2 $GFXB40_PATH'
TESTS[FILL_O]='gfxbench40 gl_fill2_off $GFXB40_PATH'
TESTS[TREX]='gfxbench40 gl_trex $GFXB40_PATH'
TESTS[TREX_O]='gfxbench40 gl_trex_off $GFXB40_PATH'
TESTS[MANHATTAN]='gfxbench40 gl_manhattan31 $GFXB40_PATH'
TESTS[MANHATTAN_O]='gfxbench40 gl_manhattan31_off $GFXB40_PATH'
