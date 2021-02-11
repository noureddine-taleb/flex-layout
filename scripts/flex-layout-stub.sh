#!/bin/bash

# assuming modules have there own separate floders
# with the current structure <module-path>/components :
# Ex:
# src/app/module
# └── components
#    ├── component-1
#    │   ├── component-1.component.html
#    │   ├── component-1.component.scss
#    │   ├── component-1.component.spec.ts
#    │   └── component-1.component.ts
#    └── component-2
#       ├── component-2.component.html
#       ├── component-2.component.scss
#       ├── component-2.component.spec.ts
#       └── component-2.component.ts
# components can have subcomponents as well

if [ "$1" = "" ]
then
    echo "err: you must supply module path" >&2
cat <<EOF
Example:
./scripts/flex-layout-stub.sh src/app/module
EOF
exit 1
fi

module_dir="$1/components";
if [ ! -e $module_dir ]
then
    echo "err: $module_dir folder not found" >&2
    exit 1
fi

echo "scan: $module_dir";

for c in `find ${module_dir} -type f -name "*html"`
do
    c=$(echo $c | rev | cut -d. -f2- | rev)
    ./scripts/flex-layout.pl $c
    grep fx $c.html >/dev/null && echo $(tput setaf 3)warning: $(tput sgr 0)unresolved directives found in $c
done

