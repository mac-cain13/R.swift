
requeststatus() { # $1: requestUUID
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun altool --notarization-info "$requestUUID" \
                              --username "$DEV_ACCOUNT" \
                              --password "$PASSWORD" 2>&1 \
                 | awk -F ': ' '/Status:/ { print $2; }' )
    echo "$req_status"
}


notarizefile() { # $1: path to file to notarize, $2: identifier
    filepath=${1:?"need a filepath"}
    identifier=${2:?"need an identifier"}
    
    # upload file
    echo "## uploading $filepath for notarization"
    requestUUID=$(xcrun altool --notarize-app \
                               --primary-bundle-id "$BUNDLE_ID" \
                               --username "$DEV_ACCOUNT" \
                               --password "$PASSWORD" \
                               --asc-provider "$DEV_TEAM" \
                               --file "$FILENAME" \
                  | awk '/RequestUUID/ { print $NF; }')
                               
    echo "Notarization RequestUUID: $requestUUID"
    
    if [[ $requestUUID == "" ]]; then 
        echo "could not upload for notarization"
        exit 1
    fi
        
    # wait for status to be not "in progress" any more
    request_status="in progress"
    while [[ "$request_status" == "in progress" ]]; do
        echo -n "waiting... "
        sleep 10
        request_status=$(requeststatus "$requestUUID")
        echo "$request_status"
    done
    
    # print status information
    xcrun altool --notarization-info "$requestUUID" \
                 --username "$DEV_ACCOUNT" \
                 --password "$PASSWORD"
    echo 
    
    if [[ $request_status != "success" ]]; then
        echo "## could not notarize $filepath"
        exit 1
    fi
}

notarizefile "$FILENAME" "$BUNDLE_ID"
