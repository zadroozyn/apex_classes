set -ev
#just a comment
ANT_ROOT="$TRAVIS_BUILD_DIR"
SRC_ROOT="$TRAVIS_BUILD_DIR/src"

cd $ANT_ROOT
ant retrieve

cd $SRC_ROOT
git add .
git commit -m "prodSync [ci skip]"
git push origin HEAD:master
