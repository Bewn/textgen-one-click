#!/usr/bin/env sh
#
# this script will let you run the environment created with init.sh
# then henceforth run the server etc.
# I'm coding in bash for generic shell, with a functional style!

_cwd=$PWD
choose_textgen_dir () {
    read -p "
             Installing textgen to directory containing run.sh
             if you would like to install elsewhere, please enter here,
             otherewise leave blank.
             enter intall directory now: " input
    if [ -z $input ];
      then export TEXTGEN_DIR=$PWD;
      else export TEXTGEN_DIR=$input
    fi
}


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
        then echo "checking and/or adding to /etc/profile.d/textgen.sh"
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
        choose_textgen_dir
        add_to_shellrc
    fi
    
: '
    if [ -f $HOME/.textgenrc ];
        then init_env;
        else create_textgenrc && init_env;
    fi
    
    # load in header now that TEXTGEN_DIR is ensured
    source $TEXTGEN_DIR/init.header.sh && echo "init header loaded"

    ## we now have free access to the functions defined in the header
    prepare_mamba

    #create env_textgen (passes if already created)
    make_env

    # check mamba
    echo "micromamba v. $($MAMBA_EXE --version) active" # we can now run micromamba in the correct env and shell!
    
    if [ ! -d $TEXTGEN_DIR/textgen-portable ];
        then build;
    fi

    read -n1 -p "do you want to check for updates? [y/N]" user_input
    case $user_input in
        y|Y) check_up_to_date ;;
        n|N|*) echo "continuing..." ;;
    esac

    cd $TEXTGEN_DIR/textgen-portable
    micromamba activate $TEXTGEN_DIR/env_textgen && echo env_textgen activated
    python server.py --share
    '
} 
run
#micromamba --version

# run main as defined in init.header.sh
#echo "running main"
#main
#echo "testing hook"
#hook_mamba
#micromamba activate $TEXTGEN_DIR/env_textgen



