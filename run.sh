#!/usr/bin/env sh
#
# this script will let you run the environment created with init.sh
#

_cwd=$PWD
_add_env_var () {
	$(echo "export TEXTGEN_DIR=$_cwd" >> $HOME/.textgenrc)
}

create_textgenrc () {
	if [ ! -f $HOME/.textgenrc ]
		then touch $HOME/.textgenrc
		$(echo "# bashrc style environtment and function space" >> $HOME/.textgenrc)
		_add_env_var;
	fi
}

init_env () {
    source $HOME/.textgenrc
    echo ".textgenrc loaded"
}

run () {
    if [ -z $TEXTGEN_DIR ];
        then echo "environment variable TEXTGEN_DIR not set, setting now.";
    fi

     if [ -f $HOME/.textgenrc ];
        then init_env;
        else create_textgenrc && init_env;
    fi
    
    # load in header now that TEXTGEN_DIR is ensured
    source $TEXTGEN_DIR/init.header.sh
    echo "init header loaded"
} 
run
#micromamba --version

# run main as defined in init.header.sh
#echo "running main"
#main
#echo "testing hook"
#hook_mamba
#micromamba activate $TEXTGEN_DIR/env_textgen



