# Deploys installation scripts to the
#  gh-pages branch.
# Hopefully once a Cheddar website exists
#  this will have ssh stuff and push to it

set -e # error if anything errors

if [ "$TRAVIS_PULL_REQUEST" != "false" -o "$TRAVIS_BRANCH" != "master" ]; then
    echo "Not a deploy enviornment. Exiting..."
    exit 0
fi

# De-encrypt the deployment private key 
ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}
openssl aes-256-cbc -K $encrypted_c66588929ae5_key -iv $encrypted_c66588929ae5_iv -in deploykey.enc -out deploykey -d
chmod 600 deploykey
eval `ssh-agent -s`
ssh-add deploykey

REPO="cheddar-lang.github.io"
REMOTE_REPO="git@github.com:cheddar-lang/${REPO}.git"

git clone $REMOTE_REPO && cd $REPO

git config user.name "Travis CI"
git config user.email $COMMIT_AUTHOR_EMAIL

mkdir install 2>/dev/null||:;

cp -r ../nix ./install/
cp -r ../windows ./install/
git add -A
git commit -am "$(printf "Auto-deploy from @/install: SHA$(git log -1 --pretty=%B --oneline | sed 's/ /; /') " )"

# if [ -z `git diff  --exit-code nix/ windows/` ]; then
#     echo "No changes. Exiting..."
#     exit 0
# fi

git push origin master
