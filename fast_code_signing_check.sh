#!/bin/bash
set -euo pipefail

# define your keychains here that should be unlocked, separated by spaces
KEYCHAINS="login.keychain"

# keychain(s) passwords need to be set via KEYCHAIN_PASSWORD env variable
# (currently this script assumes you have the same password for all keychains, which might be different for you)



echo "These are all keychains in the keychain search list"
security list-keychains

echo "Your default keychain is:"
security default-keychain

echo "Keychain files on your machine (there could be more files than in the keychain search list):"
ls -l ~/Library/Keychains/

echo "Valid certs for code signing (in all keychains):"
security find-identity -vp codesigning

for KEYCHAIN in $KEYCHAINS; do
    echo "Valid certs in $KEYCHAIN:"
    security find-identity -vp codesigning $KEYCHAIN
done

echo "Some of them can be duplicated, so here are the unique ones:"
security find-identity -vp codesigning | sed -nE "s/^( +[0-9]+\)) ([0-9A-F]{40}) (.*)$/\2 \3/p" | sort --unique

# gets SHA1 certificate identifiers
CERTIFICATE_IDS=$(security find-identity -vp codesigning | sed -nE "s/^( +[0-9]+\)) ([0-9A-F]{40}) (.*)$/\2/p" | sort --unique)

for KEYCHAIN in $KEYCHAINS; do
    echo "Unlocking $KEYCHAIN"
    security unlock-keychain -p $KEYCHAIN_PASSWORD $KEYCHAIN
done

for CERTIFICATE_ID in $CERTIFICATE_IDS; do
    echo "Trying to sign test file with $CERTIFICATE_ID:"
    rm -Rf test && touch test
    codesign --sign $CERTIFICATE_ID test
    if [ $? -eq 0 ]; then
        echo "Signing with $CERTIFICATE_ID worked!";
    fi

    # this can show you if the file is signed - the signature info is stored in special attributes on the file system
    ls -al test # this will show an '@' for the special attributes
    xattr test # this shows the special attribute list
done
