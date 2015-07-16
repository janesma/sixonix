GLB30_BASE=$BENCHDIR/GLB30/
GLB30_PATH=$GLB30_BASE/gfxbench-source-corporate/out/build/linux/gfxbench_Release/mainapp

function gfxbench30() {
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
	./mainapp -w $RES_X -h $RES_Y \
		-offscreen_width $RES_X -offscreen_height $RES_Y \
		-t ${1} -fullscreen 1 | \
		grep score | awk -F"[ ,]" "{printf \"%.3f\\n\", \$5}"
}

#TESTS[TREX_O]='cd $GLB30_PATH; gfxbench30 gl_trex_off'
