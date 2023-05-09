#!/usr/bin/env sh
#
# this script will let you run the environment created with init.sh
#

# read in the header/init code
source $TEXTGEN_DIR/init.header.sh

# enter main directory
cd $TEXTGEN_DIR

micromamba --version

# run main as defined in init.header.sh
echo "running main"
main
echo "testing hook"
hook_mamba
#micromamba activate $TEXTGEN_DIR/env_textgen





