#!/bin/bash

module_dir="$1/components";
echo $module_dir;

for c in $module_dir/**/*.html
do
    c=$(echo $c | rev | cut -d. -f2- | rev)
    ./scripts/flex-layout.pl $c
done

