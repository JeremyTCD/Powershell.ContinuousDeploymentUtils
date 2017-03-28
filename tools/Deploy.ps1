git config --global credential.helper store
Add-Content "$($env:USERPROFILE)\.git-credentials" "https://$($env:git_key):x-oauth-basic@github.com`n"

git config --global user.email $env:build_user_email
git config --global user.name $env:build_user

Write-Host "Checking if deployment is required"
if($env:APPVEYOR_REPO_TAG){
	Write-Host "Tag $($env:APPVEYOR_REPO_TAG_NAME) pushed ... deployment starting"
}
else
{
	# check if changelog has changed
	$commit = $env:APPVEYOR_REPO_COMMIT
	$versionHeaderPattern = '^\+##[ \t]*(\d+\.\d+\.\d+)'
	$changedFiles = git diff-tree --no-commit-id --name-only -r $commit
	if($changedFiles -contains 'changelog.md'){
		Write-Host "Changelog changed ... deployment starting"

		$addedLines = git diff $commit^ $commit -- 'changelog.md' 
		$newVersionLines = $addedLines -match $versionHeaderPattern
		if($newVersionLines.length -eq 1){
			$newVersionLines[0] -match $versionHeaderPattern
			Write-Host "New version $($matches[1]) detected ... creating tag"

			$tag = "$($matches[1])+1"
			git tag $tag
			# use gitinvoke
			# git push origin $tag

			Write-Host "Tag $tag created and pushed to origin"
		}
		elseif($newVersionLines.Length -gt 1)
		{
			Write-Error "More than one versions added"
		}
		else
		{
			# something else was changed
		}
	}
	else
	{
		Write-Host "Deployment not required"
	}
}