#!/bin/bash

for ny in {10..110..10}; do
  echo "Running mesh with ny = $ny"

  # Replace all instances of ${ny} with the current value and save to temp file
  sed "s/\${ny}/$ny/g" refinement.i > refinement_tmp.i

  # Run MOOSE with the temp input file
  ./part2-opt -i refinement_tmp.i
done
