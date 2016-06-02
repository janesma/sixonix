VALLEY_PATH=$BENCHDIR/Valley-1.1-rc1/
HEAVEN_PATH=$BENCHDIR/Heaven-4.1-rc1/

function unigine() {
	local path=$1
	local bench=$2
	cfg=$(mktemp -p $path --suffix=.cfg)
	sed "s/RES_X/${RES_X}/; s/RES_Y/${RES_Y}/" ${CONFIGS_PATH}/${bench}.cfg > $cfg
	set -o nounset
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./bin
	./bin/${bench}_x64 -engine_config ../$(basename $cfg)  | grep -i fps | awk "{print \$2}"
	set +o nounset
}

TESTS[VALLEY]='cd $VALLEY_PATH ; unigine $VALLEY_PATH valley'
TESTS[HEAVEN]='cd $HEAVEN_PATH ; unigine $HEAVEN_PATH heaven'

