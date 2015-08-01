SYNMARK_PATH=$BENCHDIR/Synmark2-6.00/

function init_synmark_cfg() {
	# Create a synmark config file with the proper resolutions
	#synmark requires configs to be specified as "-name" without .cfg, but
	#the file must actually be named.cfg
	synmark_cfg="$(mktemp -p $SYNMARK_PATH --suffix=.cfg)"
	echo "FullScreen = 1;" >> $synmark_cfg
	echo "ScreenWidth = ${RES_X};" >> $synmark_cfg
	echo "ScreenHeight = ${RES_Y};" >> $synmark_cfg
	echo "RenderingTime = 5.0;" >> $synmark_cfg
	echo "ValidateImage = 0;" >> $synmark_cfg
}

function synmark()
{
	set -eux
	syn_test=$1
	init_synmark_cfg
	cat $synmark_cfg
	./synmark2 "-$(basename -s .cfg $synmark_cfg)" $syn_test | grep FPS | awk "{print \$2}"
	rm $synmark_cfg
	unset synmark_cfg
}

# Synmark
TESTS[SYNMARK]='cd $SYNMARK_PATH ; synmark $1'
