#!/usr/bin/env sh
# this code is based on the arch PKGBUILD in the build directory, but should be 
# accessible to generic x86_64 distros
#
# this is a shell scipt to simplifiy installing the oobabooga text generation webui
# it's self contained so the only dependencies are git and wget
# you don't even need python! this downloads micromamba and creates a fast and small conda env.
# this will install "textgen-portable" in your current directory


# Maintainer: Ben Rosebery <benrosebery@gmail.com>

pkgname=textgen-ben
pkgver=0.5
pkgrel=1
arch=('x86_64')

##quick and sly dependency check
#if [ ! -z [ $(git --version && wget --version) | grep "No" ]  ]; then exit; fi
url="https://github.com/Bewn/textgen-ben"

_cwd=$PWD
cd $_cwd
curl ftp://ftp.gnu.org/gnu/wget/wget2-latest.tar.gz && tar xzf wget2-*.tar.gz

############################ function definitions ###############################################

prepare () {
	cd $_cwd
	if [ ! -d "$_cwd/textgen-portable" ]; then mkdir $_cwd/textgen-portable; fi
	cd $_cwd/textgen-portable
	_cwd=$_cwd/textgen-portable

	#download latest micromamba
	if [ ! -d $_cwd/micromamba ]; then mkdir $_cwd/micromamba && cd $_cwd/micromamba
		wget https://micro.mamba.pm/api/micromamba/linux-64/latest && tar xf latest;
	fi
	export MAMBA_EXE=$_cwd/micromamba/bin/micromamba #micromamba now runnable from this script
	
	#make  environment
	$MAMBA_EXE create --prefix=$_cwd/env_textgen
	export _mamba_env=$_cwd/env_textgen
}

hook_mamba () {
	eval "$($MAMBA_EXE shell hook --shell=bash)"
	micromamba activate $_mamba_env
}

build () {
	hook_mamba
    cd $_cwd
    micromamba install python=3.10 gradio pytorch pip accelerate colorama pandas datasets markdown numpy pillow pyyaml requests safetensors sentencepiece tqdm peft transformers
    
    pip install rwkv flexgen gradio_client rwkvstic bitsandbytes llama-cpp-python

	git init && git remote add original https://github.com/oobabooga/text-generation-webui && git fetch original
	git checkout original/main -- server.py download-model.py settings-template.json characters css docs extensions loras models modules presets prompts softprompts training
	git remote add benver $url && git fetch benver 
	git checkout benver/main -- bendir 

	pip install cython
}

package () {
    #install to local root/opt
    pkgdir=$HOME/../../
	cd $_cwd && if [ ! -d $_cwd/textgen-portable ]; then prepare; fi
	_cwd=$_cwd/textgen-portable && cd $_cwd
	
	sudo mkdir $pkgdir/opt
	sudo mv $_cwd $pkgdir/opt
}

cd_to_new_portable_install () {
    cd $_cwd/textgen-portable
}

################## main #############################
#####################################################
#main () {
    continue
    #pythonic bash with functional flair
    #prepare
    #build
    #cd_to_new_portable_install
    #hook_mamba
    #python $_cwd/server.py --share
#}

#main