#!/bin/bash
# Script from https://forums.truenas.com/t/update-powertop-from-2-14-to-2-15/11741 to compile the latest version of powertop to use in TrueNAS
# Powertop 2.15 required to get HW C-states
# This script is best run in a bookworm container and will generate a /powertop/src/powertop binary that you need to transfer back to the TrueNAS host
apt install -y build-essential autoconf-archive ncurses-dev libnl-3-dev libpci-dev pkg-config libtool-bin autopoint gettext libnl-genl-3-dev
git clone https://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git
cd libtraceevent || exit; make; make install; cd ..
git clone https://git.kernel.org/pub/scm/libs/libtrace/libtracefs.git
cd libtracefs || exit; make; make install; cd ..
git clone https://github.com/fenrus75/powertop.git
cd powertop || exit

# Append "--force" to the end of the last line in autogen.sh because otherwise it says that files were "manually edited" and not able to proceed
sed -i '$ s/$/ --force/' autogen.sh

./autogen.sh
./configure
make