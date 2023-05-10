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

add_to_shellrc () {
    read -p "would you like to add TEXTGEN_DIR to your login shell? [Y/n]" user_input

    if [[ $user_input='Y' || $user_input='' || $user_input='y' ]];
        then echo "checking and/or adding to shell rc scripts and /etc/profile.d/textgen.sh"

        if [ -z "$(cat $HOME/.bashrc | grep .textgenrc )" ];
            then echo "source $HOME/.textgenrc" | tee -a $HOME/.bashrc
            echo "added to bash";
        fi

        if [ -z "$(cat $HOME/.zshrc | grep .textgenrc)" ];
            then echo "source $HOME/.textgenrc" | tee -a $HOME/.zshrc
            echo "added to zsh";
        fi

        if [ ! -f /etc/profile.d/textgen.sh ];
            then echo "source $HOME/.textgenrc" | sudo tee -a /etc/profile.d/textgen.sh
            echo "added to /etc/profile.d/ i.e. any login shell"
        fi
        else echo "TEXTGEN_DIR not set"
    fi
}

run () {
    if [ -z $TEXTGEN_DIR ];
        then echo "environment variable TEXTGEN_DIR not set, setting now.";
        add_to_shellrc
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



