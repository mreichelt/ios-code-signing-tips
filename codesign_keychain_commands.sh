#!/bin/bash

# useful tool with lots of options: show help
security help
# also on individual commands:
security help list-keychains

# list all keychains currently in search list
security list-keychains

# set keychain search list for current user (order is important!)
security list-keychains -d user -s chain1 chain2 chain3 login.keychain

# view actual keychain files
ls -al ~/Library/Keychains/

# create an empty keychain (caution: defaults to 300s timeout!)
security create-keychain chain1

# show settings of a keychain
security show-keychain-info chain1

# show settings of all keychains currently in path
security list-keychains -d user | xargs -n 1 security show-keychain-info
# prints:
# Keychain "/Users/marc/Library/Keychains/chain1-db" lock-on-sleep timeout=300s
# Keychain "/Users/marc/Library/Keychains/chain2-db" lock-on-sleep timeout=300s
# Keychain "/Users/marc/Library/Keychains/chain3-db" lock-on-sleep timeout=300s
# Keychain "/Users/marc/Library/Keychains/login.keychain-db" no-timeout

# change settings for a keychain
security set-keychain-settings <options> chain1
# by omitting all options, we remove the timeout and lock-on-sleep!
security set-keychain-settings chain1




# unlocking a keychain (be careful: this has a different effect on each)
security unlock-keychain -p password chain1

# locking a keychain
security lock-keychain chain1



# codesign completely ignores --keychain parameter :-(
# codesign --keychain conflict_2 --sign conflict test