#!/bin/bash

ACE_ROOT=`pwd`/ACE
TAO_ROOT=`pwd`/TAO
MPC_ROOT=`pwd`/MPC
LD_LIBRARY_PATH=$ACE_ROOT/lib:$LD_LIBRARY_PATH

export QTDIR=/usr
export ACE_ROOT=$ACE_ROOT
export TAO_ROOT=$TAO_ROOT
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH

cd $ACE_ROOT

# configure ACE/TAO build
echo '#include "ace/config-linux.h"' > ace/config.h
echo include $ACE_ROOT/include/makeinclude/platform_linux.GNU > \
	include/makeinclude/platform_macros.GNU
echo 'qt4 = 1' >> include/makeinclude/platform_macros.GNU
echo 'ace_qt4reactor = 1' >> include/makeinclude/platform_macros.GNU
echo "INSTALL_PREFIX = /usr" >> include/makeinclude/platform_macros.GNU
echo "LDFLAGS += -fPIC" >> include/makeinclude/platform_macros.GNU
echo "CFLAGS += -fPIC" >> include/makeinclude/platform_macros.GNU
echo "CXXFLAGS += -fPIC" >> include/makeinclude/platform_macros.GNU

# setup tree as expected by Makefiles
unlink MPC
ln -s $MPC_ROOT MPC
unlink TAO
ln -s $TAO_ROOT TAO

#configure ACE
cp $ACE_ROOT/bin/MakeProjectCreator/modules/* $MPC_ROOT/modules/
$ACE_ROOT/bin/mwc.pl -type gnuace ACE.mwc

# configure TAO for use with ACE
cd TAO
$ACE_ROOT/bin/mwc.pl -type gnuace TAO_ACE.mwc
cd -

# build ACE
make -j9

# build/install TAO
cd TAO
make -j9
sudo ACE_ROOT=$ACE_ROOT TAO_ROOT=$TAO_ROOT make install
cd -
# install ACE
sudo ACE_ROOT=$ACE_ROOT TAO_ROOT=$TAO_ROOT make install
