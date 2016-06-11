# Deploys installation scripts to the
#  gh-pages branch.
# Hopefully once a Cheddar website exists
#  this will have ssh stuff and push to it

set -e # error if anything errors

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "$SOURCE_BRANCH" ]; then
    echo "Not a deploy enviornment. Exiting..."
    exit 0
fi

REMOTE_REPO="git@github.com:cheddar-lang/cheddar-lang.github.io.git"

git clone $REMOTE_REPO && cd $REMOTE_REPO

git config user.name "Travis CI"
git config user.email $COMMIT_AUTHOR_EMAIL

if [ -z `git diff  --exit-code nix/ windows/ ]; then
    echo "No changes. Exiting..."
    exit 0
fi
