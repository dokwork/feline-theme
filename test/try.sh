#!/bin/bash

# This script creates a temp directory to use it as XDG_DATA_HOME
# and then runs neovim with configuration described in the test/init.lua

# got to the directory with this script (./test/):
cd $(dirname ${BASH_SOURCE[0]})

export XDG_DATA_HOME='/tmp/feline-components/'
mkdir -p $XDG_DATA_HOME
nvim -u init.lua --cmd 'set rtp='$XDG_DATA_HOME',$VIMRUNTIME'
