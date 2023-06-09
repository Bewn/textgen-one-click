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
pkgver=0.6
pkgrel=1
arch=('x86_64')

##quick and sly dependency check
if [ ! -z  $(git --version | grep "No")  ]; then exit; fi

url="https://github.com/Bewn/textgen-one-click"


# work in textgen directory
_cwd=$TEXTGEN_DIR

############################ function definitions ###############################################
prepare_mamba () {
	cd $_cwd
	#get wget to later get micromamba
	if [ ! -f wget ]; 
		then git init && git remote add self $url && git fetch self && git checkout self/main -- wget;
	fi

	# get latest micromamba
	if [ ! -d $_cwd/micromamba ]; 
		then mkdir $_cwd/micromamba && cd $_cwd/micromamba
		wget https://micro.mamba.pm/api/micromamba/linux-64/latest  && tar xf latest;
		echo "micromamba is installed"
	fi
	make_env
}


make_env () {
	if [ ! -d $TEXTGEN_DIR/env_textgen ];
		then $MAMBA_EXE create --prefix $TEXTGEN_DIR/env_textgen;
		export mamba_env_dir=$TEXTGEN_DIR/env_textgen
		echo "mamba environment is created"
	fi
}

check_up_to_date () {
	$MAMBA_EXE update --all -p $TEXTGEN_DIR/env_textgen
	cd $TEXTGEN_DIR/textgen-portable && git pull original main
	git_checkout
}

git_checkout () {
	git checkout original/main -- server.py download-model.py settings-template.json characters css docs extensions loras models modules presets prompts softprompts training
}

build () {
    mkdir $_cwd/textgen-portable
	cd $_cwd/textgen-portable

	# install python and depends with mamba/conda
	$MAMBA_EXE install python -p $TEXTGEN_DIR/env_textgen
	$MAMBA_EXE install gradio pip accelerate colorama pandas datasets markdown numpy pillow pyyaml requests safetensors sentencepiece tqdm peft transformers -p $TEXTGEN_DIR/env_textgen -c conda-forge
    
	if [ ! -z $(lsmod | grep nvidia) ];
		then $MAMBA_EXE install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
	fi

	if [ ! -z $(lsmod | grep rocm) ];
		then pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.4.2
	fi
	#install the rest with pip
    pip install rwkv flexgen gradio_client rwkvstic bitsandbytes llama-cpp-python

	#get the latest git version of oobabooga textgen
	git init && git remote add original https://github.com/oobabooga/text-generation-webui && git fetch original
	git_checkout
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
