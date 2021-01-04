#!/bin/sh
find "${BUILT_PRODUCTS_DIR}" -d 1 -name "*.framework" | while read framework     
    do    
        find -L "${framework}" -name "*.bundle" -d 1 | while read source
        do
            destination="${TARGET_BUILD_DIR}/${EXECUTABLE_FOLDER_PATH}"
            rsync -auv "${source}" "${destination}" || exit 1
        done
    done  
exit 0
