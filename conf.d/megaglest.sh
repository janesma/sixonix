GLEST_BASE=$BENCHDIR/megaglest-source/
GLEST_PATH=$GLEST_BASE/mk/linux/build/source/glest_game

function megaglest() {
	sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${CONFIGS_PATH}/glest.ini > $GLEST_PATH/glest.ini;
	cd $GLEST_BASE
	timeout 70s \
		./mk/linux/build/source/glest_game/megaglest \
		--data-path=data/glest_game/ \
		--disable-sound \
		--load-scenario=gfx-benchmark | \
		grep RenderFps | awk '{print $6}' | cut -c -2
}


TESTS[MEGAGLEST]='megaglest'
