set -ev

ANT_ROOT="$TRAVIS_BUILD_DIR"

cd $ANT_ROOT
ant retrieve
