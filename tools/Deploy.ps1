git config --global credential.helper store
Add-Content "$($env:USERPROFILE)\.git-credentials" "https://$($env:git_key):x-oauth-basic@github.com`n"

git config --global user.email $env:build_user_email
git config --global user.name $env:build_user
