#! /bin/bash

echo "Setup GoogleService-Info.plist BEGIN"
echo "Configuration = ${CONFIGURATION}"
if [[ "${CONFIGURATION}" == *"dev"* ]]; then
    cp "${PRODUCT_NAME}/Firebase/GoogleService-Info-dev.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
    echo "Copy GoogleService-Info-dev.plist to GoogleService-Info.plist"
elif [[ "${CONFIGURATION}" == *"prod"* ]]; then
    cp "${PRODUCT_NAME}/Firebase/GoogleService-Info-prod.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
    echo "Copy GoogleService-Info-prod.plist to GoogleService-Info.plist"
else
    echo "configuration didn't match to dev or prod"
    exit 1
fi
echo "Setup GoogleService-Info.plist END"
