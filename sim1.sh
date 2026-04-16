#!/bin/bash

# Source setup
source /home/iakovos-qpix/Programs/Library/marley/setup_marley.sh || exit 1
cd /home/iakovos-qpix/Programs/Library/MarleyTest/macros || exit 1

TEMPLATE=Radiogenic_Ar42_background.mac

# Define the isotopes and their specific A values (Z is always 86)
ISOTOPES=("219" "220" "222")

for ISO in "${ISOTOPES[@]}"; do
    
    LABEL="Rn${ISO}"
    WORK_MACRO="run_${LABEL}.mac"
    cp "$TEMPLATE" "$WORK_MACRO"

    # 1. Update the output ROOT file path
    sed -i "s|/inputs/output_file .*|/inputs/output_file ../output/radiogenic_${LABEL}.root|" "$WORK_MACRO"
    
    # 2. Correctly set the nucleusLimits: AMin AMax ZMin ZMax
    # This finds the line starting with the command and replaces the whole line
    sed -i "s|/process/had/rdm/nucleusLimits .*|/process/had/rdm/nucleusLimits ${ISO} ${ISO} 86 86|" "$WORK_MACRO"

    sed -i "s|/supernova/N_Ar42_Decays|/supernova/N_Rn${ISO}_Decays|" "$WORK_MACRO"

    echo "=== Running Isotope: $LABEL ==="
    ../build/app/G4_QPIX "$WORK_MACRO"

    if [ $? -ne 0 ]; then
        echo "ERROR: Run failed for $LABEL — stopping."
        exit 1
    fi

    echo "=== Done: ../output/radiogenic_${LABEL}.root ==="
done

echo "All Radon runs complete."
