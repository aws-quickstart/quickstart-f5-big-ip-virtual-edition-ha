#!/usr/bin/env bash


######################
echo "*** Configuring SSH"
eval $(ssh-agent -s)
test "$GIT_SSH_USER_PRIVATE_KEY" && (echo "$GIT_SSH_USER_PRIVATE_KEY" | tr -d '\r' | ssh-add -)
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$GIT_SSH_USER_PUBLIC_KEY" >> ~/.ssh/id_rsa.pub
echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
git config user.name $GITLAB_USER_LOGIN
git config user.email $GITLAB_USER_EMAIL
######################

ALLOWED_DIRS=(declarations submodules templates)
ALLOWED_FILES=(.cfnlintrc .gitignore .gitmodules .metadata LICENSE.txt README.md .taskcat.yml CODEOWNERS)

echo "*** Setting git origin"
git fetch --unshallow origin
git remote rm origin && git remote add origin git@github.com:F5Networks/quickstart-f5-big-ip-virtual-edition.git
echo "*** Removing everything from local git"
git rm -rf .

echo "*** Adding allowed directories"
for dir in "${ALLOWED_DIRS[@]}"; do
    git checkout HEAD ${dir}
    git add ${dir}
done

echo "*** Adding allowed files"
for file in "${ALLOWED_FILES[@]}"; do
    git checkout HEAD ${file}
    git add ${file}
done

echo "*** Committing source code"
git status
git commit -m "Updating develop..." || echo "No changes, nothing to commit!"
git push -u origin HEAD:develop -f

######################
# Reserved for creating pull request via Github API
######################

echo "*** Publishing to github is completed."
