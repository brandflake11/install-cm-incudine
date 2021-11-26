#!/bin/bash

# install-cm-incudine; A helper script to go from zero to hero with cm-incudine. Includes everything from emacs, to quicklisp, to incudine, to cm-incudine.
    # Copyright (C) 2021  Brandon Hale

    # This program is free software: you can redistribute it and/or modify
    # it under the terms of the GNU General Public License as published by
    # the Free Software Foundation, either version 3 of the License, or
    # (at your option) any later version.

    # This program is distributed in the hope that it will be useful,
    # but WITHOUT ANY WARRANTY; without even the implied warranty of
    # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    # GNU General Public License for more details.

    # You should have received a copy of the GNU General Public License
    # along with this program.  If not, see <https://www.gnu.org/licenses/>.

# This should be a setup script to go from 0 to hero with everything needed for cm-incudine, including emacs, slime, and quicklisp

# This is assuming void-linux and void-linux-based distros

# Change this to what your package manager's install command is.
# Like, if on debian, change to apt install
INSTALL_CMD="sudo xbps-install"
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
    $INSTALL_CMD emacs-gtk3
}

SBCL () {
    # This is specifically for arch-based distros.
    # I need to figure out how to detect os and then use an appropriate command
    NOTIFY SBCL
    $INSTALL_CMD sbcl
}

JACK () {
    NOTIFY JACK
    $INSTALL_CMD jack jack-devel rtaudio rtaudio-devel
    echo "Setting your user to the realtime group for pro-audio."
    echo "Make sure to restart in order for it to take effect."
    # Setting user to realtime doesn't seem necessary on void
    # sudo usermod -a -G realtime $USER
}
    
# Pro-audio doesn't exist on void linux :(
# 
# PRO-AUDIO () {
#     NOTIFY PRO-AUDIO
#     read -p "Do you want to install the pro-audio group? This package contains lots of great audio packages and can enhance your cm-incudine experience. [y]es, [n]o: " PRO_AUDIO_QUESTION
#     if [[ $PRO_AUDIO_QUESTION == 'y' || $PRO_AUDIO_QUESTION == 'Y' || $PRO_AUDIO_QUESTION == "yes" ]]
#     then
#        $INSTALL_CMD pro-audio
#     else
# 	echo "Not installing the pro-audio group."
#     fi
# }
    
QUICKLISP () {
    NOTIFY QUICKLISP
    sudo xbps-install curl
    curl -O https://beta.quicklisp.org/quicklisp.lisp
    sbcl --script install-quicklisp.lisp
}

SLIME () {
    NOTIFY SLIME
    sbcl --quit --eval '(ql:quickload "quicklisp-slime-helper")'
    echo '  (load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
  (setq inferior-lisp-program "/usr/bin/sbcl")' >> $EMACS_CONFIG
}

INCUDINE () {
    NOTIFY INCUDINE
    echo "Installing INCUDINE dependencies."
    JACK
    $INSTALL_CMD portaudio portmidi libsndfile libsndfile-devel libfftw fftw fftw-devel gsl gsl-devel clthreads
    echo "To have incudine work, make sure you have installed:"
    echo "pthread, portaudio, jack, portmidi, libsndfile, fftw"
    echo "gnu scientific library (gsl)"
    echo
    echo "Pause the installation if needed by doing Cntrl+z (C-z) and installing the packages needed."
    echo "Then, resume with fg."
    echo "If you are unsure and on a void-based distro, just continue with yes."
    read -p "Type y to continue. [y]es, [n]o: " QUESTION_RESPONSE
    if [[ $QUESTION_RESPONSE == 'y' || $QUESTION_RESPONSE == 'Y' || $QUESTION_RESPONSE == "yes" ]]
    then
	# -i to make sure not to overwrite anyone's .incudinerc
	cp -i incudinerc ~/.incudinerc
	git clone git://git.code.sf.net/p/incudine/incudine $QUICKLISP_DIR/incudine
	sbcl --quit --eval '(ql:quickload "cffi")'
	sbcl --quit --eval '(ql:quickload "incudine")'
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
    git clone https://github.com/ormf/orm-utils.git $QUICKLISP_DIR/orm-utils
    sbcl --quit --eval '(ql:quickload "cm-incudine")'
    echo "When ready to use cm-incudine, run "
    echo '(ql:quickload "cm-incudine")'
    echo '(ql:quickload "asdf")'
    echo '(ql:quickload "fudi")'
    echo '(ql:quickload "cl-coroutine")'
    echo '(ql:quickload "orm-utils")'
    echo "(require 'orm-utils)"
    echo '(ql:quickload "fomus")'
    echo "(require 'cm-fomus)"
    echo '(cm:rts)'
    echo "And you will be all set."
    echo
    read -p "Do you want to put this in .sbclrc to autostart cm-incudine when launching sbcl?: [y]es, [n]o: " SBCL_QUESTION
    if [[ $SBCL_QUESTION == 'y' || $SBCL_QUESTION == 'Y' || $SBCL_QUESTION == "yes" ]]
    then
	echo '(ql:quickload "cm-incudine")' >> $SBCLRC_LOCATION
	echo '(ql:quickload "asdf")' >> $SBCLRC_LOCATION
	echo '(ql:quickload "fudi")' >> $SBCLRC_LOCATION
	echo '(ql:quickload "cl-coroutine")' >> $SBCLRC_LOCATION
	echo '(ql:quickload "orm-utils")' >> $SBCLRC_LOCATION
	echo "(require 'orm-utils)" >> $SBCLRC_LOCATION
	echo '(ql:quickload "fomus")' >> $SBCLRC_LOCATION
	echo "(require 'cm-fomus)" >> $SBCLRC_LOCATION
	echo '(cm:rts)' >> $SBCLRC_LOCATION
    else
	echo "Not installing to .sbclrc."
    fi
}

FOMUS-SETUP () {
    NOTIFY FOMUS-SETUP
    $INSTALL_CMD lilypond
    read -p "Insert the terminal command for your preferred pdf viewer: " PDF_VIEWER
    PDF_VIEWER_LOCATION=$(which $PDF_VIEWER)
    echo "Putting $PDF_VIEWER_LOCATION in fomus file for you as preferred editor."
    read -p "Is this correct? [y]es, [n]o: " FOMUS_QUESTION
    if [[ $FOMUS_QUESTION == 'y' || $FOMUS_QUESTION == 'Y' || $FOMUS_QUESTION == "yes" ]]
    then
	sed -i "s|\/usr\/bin\/evince|$PDF_VIEWER_LOCATION|" fomus
	echo "The fomus file looks like:"
	cat fomus
	cp -i fomus ~/.fomus
    else
	echo "Stopping FOMUS-SETUP. Re-run script with only FOMUS-SETUP uncommented to try again."
    fi
}

ENDING-MESSAGE () {
    NOTIFY ENDING-MESSAGE
    # Put source code page for this script
    echo "For help with the installation script, go to:"
    echo "https://github.com/brandflake11/install-cm-incudine"
    echo
    echo "For help with cm-incudine, go to:"
    echo "https://github.com/ormf/cm-incudine"
    echo "Double check your $EMACS_CONFIG and $SBCLRC_LOCATION to make sure there isn't duplicate lisp code in the files."
}

# The main function calls are below
# JACK is used inside of INCUDINE
# Comment out anything you don't need.

EMACS
SBCL
QUICKLISP
SLIME
INCUDINE
CM-INCUDINE
FOMUS-SETUP
ENDING-MESSAGE
