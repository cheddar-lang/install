# Deploys installation scripts to the
#  gh-pages branch.
# Hopefully once a Cheddar website exists
#  this will have ssh stuff and push to it

set -e # error if anything errors

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
    echo "Not a deploy enviornment. Exiting..."
    exit 0
fi

echo `ls`
echo `ls ..`

REMOTE_REPO="git@github.com:cheddar-lang/cheddar-lang.github.io.git"

git clone $REMOTE_REPO && cd $REMOTE_REPO

git config user.name "Travis CI"
git config user.email $COMMIT_AUTHOR_EMAIL

mkdir install 2> /dev/null || :

cp -r ../nix ./install/nix
cp -r ../windows ./install/windows
git add -A
git commit -am "Auto-deploy from @/install: $(git rev-parse --verify HEAD)"

if [ -z `git diff  --exit-code nix/ windows/` ]; then
    echo "No changes. Exiting..."
    exit 0
fi

ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $encrypted_c66588929ae5_key -iv $encrypted_c66588929ae5_iv -in deploykey.enc -out deploykey -d
chmod 600 deploykey
eval `ssh-agent -s`
ssh-add deploykey

git push $REMOTE_REPO master
