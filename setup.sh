#!/usr/bin/sh

sudo apt-get install git gcc make

cd bin
git clone https://github.com/cc65/cc65.git
cd cc65
make clean
make
