set -ev

SRC_ROOT="$TRAVIS_BUILD_DIR/src"

cd $SRC_ROOT
git add .
git commit -m "prodSync [ci skip]"
git push
