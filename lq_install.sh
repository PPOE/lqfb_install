#!/bin/bash -e
# Disclaimer and stuff
###############################################################################


set -e

###############################################################################
# Configuration
###############################################################################

# which user should run the LQFB code
LQFB_USER=lqfb

# the group to run LQFB code as
LQFB_GROUP=nogroup

# the root directory in which to install the LQFB code
LQFB_HOME=/home/$LQFB_USER

LQFB_OWNER=lqfb

# the domain that you will connect to your LQFB install with.
# MUST contain a . in it somewhere as browsers won't do cookies for dotless
# domains. an IP address will suffice if nothing else is available.
LQFB_DOMAIN=${LQFB_DOMAIN:-LQFB.local}

###############################################################################
# Sanity Checks
###############################################################################
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Must be run with root privileges."
    exit 1
fi

# Here was a check if the correct version of dubuntu/debian is running


###############################################################################
# Install prerequisites
###############################################################################
set -x

# create the user if non-existent
if ! id $LQFB_USER &> /dev/null; then
    adduser --system $LQFB_USER
fi

# aptitude configuration
APTITUDE_OPTIONS="-y" # limit bandwidth: -o Acquire::http::Dl-Limit=100"
export DEBIAN_FRONTEND=noninteractive

# run an aptitude update to make sure python-software-properties
# dependencies are found
aptitude update
aptitude upgrade

# install prerequisites
cat <<PACKAGES | xargs apt-get install $APTITUDE_OPTIONS
git-core

lua5.1
postgresql 
build-essential 
libpq-dev 
liblua5.1-0-dev 
lighttpd 
ghc 
libghc6-parsec3-dev 
imagemagick 
exim4

PACKAGES

# create lqfb psql user
echo "CREATE ROLE lqfb WITH CREATEDB PASSWORD '123';" | su postgres -c "psql"


# get LQFB data --- repÃ¼to github repo
git clone https://github.com/PPOE/liquid_ppat_core.git $LQFB_HOME/core
git clone https://github.com/PPOE/liquid_ppat_frontend.git $LQFB_HOME/frontend

