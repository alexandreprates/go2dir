#!/usr/local/bin/bash

echo Preparing environment to run tesht

# Create directory for configs
mkdir -p $HOME/.local/share/go2dir

# Create empty locations.txt
touch $HOME/.local/share/go2dir/locations.txt

# Load go2dir source
source /go2dir/go2dir.sh
