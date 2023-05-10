#!/usr/bin/env sh
# this code is based on the arch PKGBUILD in the build directory, but should be 
# accessible to generic x86_64 distros
#
# this is a shell scipt to simplifiy installing the oobabooga text generation webui
# it's self contained so the only dependency is git and a shell
# you don't even need python! this downloads micromamba and creates a fast and small conda env.
# this will install "textgen-portable" in your current directory

# run `source init.header.sh` to import these functions in your current shell 

# Maintainer: Ben Rosebery <benrosebery@gmail.com>

pkgname=textgen-one-click
pkgver=0.5
pkgrel=1
arch=('x86_64')

##quick and sly dependency check
if [ ! -z  $(git --version | grep "No")  ]; then exit; fi

url="https://github.com/Bewn/textgen-one-click"


# work in directory init.sh was run in
_cwd=$PWD
############################ function definitions ###############################################




prepare () {
	cd $_cwd
	init_env
	cd $TEXTGEN_DIR
	
	#get wget to later get micromamba
	if [ ! -f wget ]; 
		then git init && git remote add self $url && git fetch self && git checkout self/main -- wget;
	fi

	# get latest micromamba
	if [ ! -d $_cwd/micromamba ]; 
		then mkdir $_cwd/micromamba && cd $_cwd/micromamba
		wget https://micro.mamba.pm/api/micromamba/linux-64/latest  && tar xf latest;
	fi
	export MAMBA_EXE=$_cwd/micromamba/bin/micromamba #micromamba now runnable from this script
}

hook_mamba () {
	eval $($MAMBA_EXE shell hook $_mamba_env --shell=bash)
}

make_env () {
	hook_mamba
	if [ ! -d $TEXTGEN_DIR/env_textgen ];
		then micromamba create --prefix $TEXTGEN_DIR/env_textgen;
		export mamba_env_dir=$TEXTGEN_DIR/env_textgen
	fi
}

build () {
	hook_mamba
    if [ ! -d $_cwd/textgen-portable ]; then mkdir $_cwd/textgen-portable; fi 
	cd $_cwd/textgen-portable

	# install python and depends with mamba/conda
    micromamba install python
	# \ gradio pytorch pip accelerate colorama pandas datasets markdown numpy pillow pyyaml requests safetensors sentencepiece tqdm peft transformers
    
	#install the rest with pip
    #pip install rwkv flexgen gradio_client rwkvstic bitsandbytes llama-cpp-python

	#get the latest git version of oobabooga textgen
	git init && git remote add original https://github.com/oobabooga/text-generation-webui && git fetch original
	git checkout original/main -- server.py download-model.py settings-template.json characters css docs extensions loras models modules presets prompts softprompts training

	# cython for compiling 
	#pip install cython
}

package () {
    #install to local root/opt
    pkgdir=$HOME/../../
	cd $_cwd && if [ ! -d $_cwd/textgen-portable ]; then prepare; fi
	_cwd=$_cwd/textgen-portable && cd $_cwd
	
	sudo mkdir $pkgdir/opt
	sudo mv $_cwd $pkgdir/opt
}

cd_to_portable_install () {
    cd $_cwd/textgen-portable
}

first_init () {
	prepare
	make_env
	build
}
################## main #############################
#####################################################
main () { #pythonic bash with functional flair
    prepare
	if [ ! -d $TEXTGEN_DIR/textgen-portable ]; 
		then first_init;
	fi
    #python $_cwd/server.py --share
}