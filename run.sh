#!/usr/bin/env sh
#
# this script will let you run the environment created with init.sh
#

if [ -f $HOME/.textgenrc ];
    then source $HOME/.textgenrc;
    echo ".textgenrc loaded"
fi

if [ -z ${TEXTGEN_DIR} ];
    then echo "TEXTGEN_DIR not set"
    exit 0;
fi

#micromamba --version

# run main as defined in init.header.sh
#echo "running main"
#main
#echo "testing hook"
#hook_mamba
#micromamba activate $TEXTGEN_DIR/env_textgen
    x   




