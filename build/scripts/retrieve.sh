set -ev

ANT_ROOT="$TRAVIS_BUILD_DIR"

cd $ANT_ROOT
ant retrieve


ANT_ROOT="$TRAVIS_BUILD_DIR/src"
git add .
git commit -m "prodSync [ci skip]"
git push
