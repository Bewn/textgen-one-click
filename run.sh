#!/usr/bin/env sh
#
# this script will let you run the environment created with init.sh
# then henceforth run the server etc.
# I'm coding in bash for generic shell, with a functional style!

_cwd=$PWD
choose_textgen_dir () {
    read -p "
            where would you like to install textgen?
            leave blank to install in $HOME without needing any privileges
            or enter a directory to install to system with sudo privileges

            ~*~***~***~*~*~***~*~*
            leave blank if unsure
            ~*~*~*~***~*~*~**~*~*~

                enter e.g. /opt/ or /usr/local/ or /home/someone-else
                enter intall directory now: " input
    if [ -z $input ];
      then mkdir -p $HOME/textgen
        export TEXTGEN_DIR=$HOME/textgen;
      else 
        if [ -z $input/textgen ]; 
            then mkdir $input/textgen
        fi
        export TEXTGEN_DIR=$input/textgen
    fi
}


_add_env_var () {
	$(echo "export TEXTGEN_DIR=$TEXTGEN_DIR" >> $HOME/.textgenrc)
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
    read -p "
            would you like to add TEXTGEN_DIR to your login shell? 
            This will add to your /etc/profile.d/ folder and needs sudo privileges
            it is easily reversible by deleting textgen.sh in profile.d [Y/n]" user_input
    case $user_input in
        'Y'|'y'|'') echo "checking and/or adding /etc/profile.d/textgen.sh" 
                    if [ ! -f /etc/profile.d/textgen.sh ]; 
                        then echo "if [ -f $HOME/.textgenrc ] then source $HOME/.textgenrc fi" | sudo tee -a /etc/profile.d/textgen.sh
                        echo "      added to login shell" ;
                    fi ;;
        'N'|'n') echo "not added to login shell" ;;
    esac
}


run () {

    echo "*~*~*~*~*~*~ beginning run of textgen, will proceed with install... *~*~*~*~*~*~

                   please enjoy this software and report any issues at
                       github.com/Bewn/textgen-one-click

~*~*~*~*~*~* thank you, support free and open source projects ~*~*~*~*~~*~*~*~*~*~*
      "

    if [ -z $TEXTGEN_DIR ];
        then echo "     environment variable TEXTGEN_DIR not set, setting now.";
        choose_textgen_dir
        create_textgenrc
        add_to_shellrc
    fi

    if [ ! -f $HOME/.textgenrc ];
        then create_textgenrc
    fi

    #load environment via now-ensured rc file 
    init_env

    #load in header now that TEXTGEN_DIR is ensured
    cp $_cwd/init.header.sh $TEXTGEN_DIR
    source $TEXTGEN_DIR/init.header.sh && echo "init header loaded"

: '
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



