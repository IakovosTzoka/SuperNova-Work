!/bin/bash
#
#
source  /home/iakovos-qpix/Programs/Library/marley/setup_marley.sh || { echo "Failed to source MARLEY! Exiting..."; exit 1; }

# shellcheck disable=SC2164
cd /home/iakovos-qpix/Programs/Library/MarleyTest/macros

../build/app/G4_QPIX ./Template_Supernova_Neutrino.mac
