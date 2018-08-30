set -ev

SRC_ROOT="$TRAVIS_BUILD_DIR/src"
ANT_ROOT="$TRAVIS_BUILD_DIR"

cd $SRC_ROOT
git fetch
git checkout master
git pull

cd $ANT_ROOT
ant retrieve

cd $SRC_ROOT
git status
git add .
git commit -m "prodSync [ci skip]"
git push

cd $ANT_ROOT
ant validate
