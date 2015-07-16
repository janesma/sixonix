GFXB31_BASE=$BENCHDIR/gfxbench_gl-src-3.1.1+corporate/
GFXB31_PATH=$GFXB31_BASE/out/build/linux/testfw_Release/tfw-dev/

function gfxbench31() {
# anecdotal evidence suggests that if you set a -w, or -h, the benchmark won't
# actually run in fullscreen mode. However, you must set the offscreen width +
# height correctly.
	${2}/testfw_app \
		--ei -fullscreen=1 \
		--ei -offscreen_width=$RES_X --ei -offscreen_height=$RES_Y \
		-b ${2} -t ${1} \
		--ei -play_time=30000 \
		--gfx glfw | \
		grep fps | awk -F"[ ,]" "{printf \"%.3f\\n\", \$6}"
}

TESTS[FILL]='MESA_GLSL_VERSION_OVERRIDE=400 MESA_GL_VERSION_OVERRIDE=4.1 gfxbench31 gl_fill2 $GFXB31_PATH'
TESTS[FILL_O]='MESA_GLSL_VERSION_OVERRIDE=400 MESA_GL_VERSION_OVERRIDE=4.1 gfxbench31 gl_fill2_off $GFXB31_PATH'
TESTS[TREX]='gfxbench31 gl_trex $GFXB31_PATH'
TESTS[TREX_O]='gfxbench31 gl_trex_off $GFXB31_PATH'
TESTS[MANHATTAH]='MESA_GLSL_VERSION_OVERRIDE=400 MESA_GL_VERSION_OVERRIDE=4.1 gfxbench31 gl_manhattan $GFXB31_PATH'
TESTS[MANHATTAH_O]='MESA_GLSL_VERSION_OVERRIDE=400 MESA_GL_VERSION_OVERRIDE=4.1 gfxbench31 gl_manhattan_off $GFXB31_PATH'
