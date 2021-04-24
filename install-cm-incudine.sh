#!/bin/bash

# This should be a setup script to go from 0 to hero with everything needed for cm-incudine, including slime and quicklisp

# This is assuming arch-linux and arch-linux-based distros

# Change this to what your package manager's install command is.
# Like, if on debian, change to apt install
INSTALL_CMD="sudo pacman --needed -S"
# Set this to where you would like to put emacs configurations
EMACS_CONFIG=~/.emacs
# Where the quicklisp directory will be
QUICKLISP_DIR=~/quicklisp/local-projects
# Where the .sbclrc file is.
SBCLRC_LOCATION=~/.sbclrc

NOTIFY () {
    echo "Running script function $1"
}

SCRIPT_DEPENDENCIES () {
    NOTIFY SCRIPT_DEPENDENCIES
    $INSTALL_CMD git
}

EMACS () {
    NOTIFY EMACS
    $INSTALL_CMD emacs
}

SBCL () {
    # This is specifically for arch-based distros.
    # I need to figure out how to detect os and then use an appropriate command
    NOTIFY SBCL
    $INSTALL_CMD sbcl
}

JACK () {
    NOTIFY JACK
    $INSTALL_CMD jack2 realtime-privileges
    echo "Setting your user to the realtime group for pro-audio."
    echo "Make sure to restart in order for it to take effect."
    sudo usermod -a -G realtime $USER
}
    
# Pro-audio on Arch can optionally be installed. It can make installing cm-incudine easier, and it's full
# of great software.
PRO-AUDIO () {
    NOTIFY PRO-AUDIO
    read -p "Do you want to install the pro-audio group? This package contains lots of great audio packages and can enhance your cm-incudine experience. [y]es, [n]o: " PRO_AUDIO_QUESTION
    if [[ $PRO_AUDIO_QUESTION == 'y' || $PRO_AUDIO_QUESTION == 'Y' || $PRO_AUDIO_QUESTION == "yes" ]]
    then
       $INSTALL_CMD pro-audio
    else
	echo "Not installing the pro-audio group."
    fi
}
    
QUICKLISP () {
    NOTIFY QUICKLISP
    curl -O https://beta.quicklisp.org/quicklisp.lisp
    sbcl --script install-quicklisp.lisp
    echo '(setq inferior-lisp-program "/usr/bin/sbcl")' >> $EMACS_CONFIG
}

SLIME () {
    NOTIFY SLIME
    sbcl --eval --quit '(ql:quickload "quicklisp-slime-helper")'
    echo '  (load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
  (setq inferior-lisp-program "sbcl")' >> $EMACS_CONFIG
}

INCUDINE () {
    NOTIFY INCUDINE
    echo "Installing INCUDINE dependencies."
    JACK
    $INSTALL_CMD portaudio portmidi libsndfile fftw gsl clthreads
    echo "To have incudine work, make sure you have installed:"
    echo "pthread, portaudio, jack, portmidi, libsndfile, fftw"
    echo "gnu scientific library (gsl)"
    echo
    echo "Pause the installation if needed by doing Cntrl+z (C-z) and installing the packages needed."
    echo "Then, resume with fg."
    echo "If you are unsure and are on an arch-based distro, just continue with yes."
    read -p "Type y to continue. [y]es, [n]o: " QUESTION_RESPONSE
    if [[ $QUESTION_RESPONSE == 'y' || $QUESTION_RESPONSE == 'Y' || $QUESTION_RESPONSE == "yes" ]]
    then
	# -i to make sure not to overwrite anyone's .incudinerc
	cp -i incudinerc ~/.incudinerc
	git clone git://git.code.sf.net/p/incudine/incudine $QUICKLISP_DIR/incudine
	sbcl --eval --quit '(ql:quickload "incudine")'
    else
	echo "Skipping the INCUDINE installation and going to next function"
    fi
}

CM-INCUDINE () {
    NOTIFY CM-INCUDINE
    $INSTALL_CMD pd
    git clone https://github.com/ormf/fudi-incudine.git $QUICKLISP_DIR/fudi-incudine
    git clone https://github.com/ormf/cm.git $QUICKLISP_DIR/cm
    git clone https://github.com/ormf/cm-incudine.git $QUICKLISP_DIR/cm-incudine
    git clone https://github.com/ormf/cm-fomus.git $QUICKLISP_DIR/cm-fomus
    git clone https://github.com/ormf/fomus.git $QUICKLISP_DIR/fomus
    git clone https://github.com/ormf/cm-utils.git $QUICKLISP_DIR/cm-utils
    sbcl --eval --quit '(ql:quickload "cm-incudine")'
    echo "When ready to use cm-incudine, run "
    echo "(ql:quickload "cm-incudine")"
    echo "(cm:rts)"
    echo "And you will be all set."
    echo
    read -p "Do you want to put this in .sbclrc to autostart cm-incudine when launching sbcl?: [y]es, [n]o" SBCL_QUESTION
    if [[ $SBCL_QUESTION == 'y' || $SBCL_QUESTION == 'Y' || $SBCL_QUESTION == "yes" ]]
    then
	echo "(ql:quickload "cm-incudine")" >> ~/.sbclrc
	echo "(cm:rts)" >> ~/.sbclrc
    else
	echo "Not installing to .sbclrc."
    fi
}

ENDING-MESSAGE () {
    NOTIFY ENDING-MESSAGE
    # Put source code page for this script
    echo "For help with the installation script, go to:"
    echo "INSTALLATION_SCRIPT URL"
    echo
    echo "For help with cm-incudine, go to:"
    echo "https://github.com/ormf/cm-incudine"
}

# The main function calls are below
# JACK is used inside of INCUDINE
# Uncomment PRO-AUDIO to install the pro-audio package

EMACS
SBCL
PRO-AUDIO
QUICKLISP
SLIME
INCUDINE
CM-INCUDINE
ENDING-MESSAGE
