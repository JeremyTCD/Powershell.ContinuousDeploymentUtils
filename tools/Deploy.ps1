Invoke-Git config --global credential.helper store
Add-Content "$($env:USERPROFILE)\.git-credentials" "https://$($env:git_key):x-oauth-basic@github.com`n"

Invoke-Git config --global user.email $env:build_user_email
Invoke-Git config --global user.name $env:build_user

Write-Host "Checking if changelog has changed"

# check if changelog has changed
$commit = $env:APPVEYOR_REPO_COMMIT
$file = 'changelog.md'
$versionHeaderPattern = '^\+##[ \t]*(\d+\.\d+\.\d+)'

$changedFiles = Invoke-Git show --pretty="" --name-only $commit
if($changedFiles -contains $file){
	Write-Host "> Changelog changed"

	$addedLines = Invoke-Git diff --unified=0 $commit^ $commit -- $file 
	$newVersionLines = $addedLines -match $versionHeaderPattern
	if($newVersionLines.length -eq 1){
		$newVersionLines[0] -match $versionHeaderPattern
		$newVersion = $matches[1]

		Write-Host "> New version `"$newVersion`" detected"

		$tag = "$newVersion+1"
		Invoke-Git tag $tag
		Invoke-Git push origin $tag -q

		$env:APPVEYOR_REPO_TAG_NAME = $tag
		Write-Host "> Tag `"$tag`" created and pushed to origin"
	}
	elseif($newVersionLines.Length -gt 1)
	{
		throw "More than one new versions detected"
	}

	Write-Host "Checking if version notes changed"

	# can't run the following if commit is initial commit
	# just don't enter this bit if there is only one version
	# if(changelogMetadata.numVersions > 1){
		Invoke-Git show $commit^:$file > 'changelogOld.md'
		$addedAndRemovedFiles = Compare-TextFileLines $file 'changelogOld.md'
		#$versionsWithChangedNotes = Get-VersionsWithChangedNotes
	#}
}
else
{
	Write-Host "> Changelog unchanged..."
}

Write-Host "Checking if a new release is required"
if($newVersion){
	Write-Host "> New release `"$newVersion`" required"
	$body = Get-VersionNotes $newVersion
	Write-Host "> Release notes for `"#$newVersion`":`n$body"
	Create-GithubRelease $env:GITHUB_TOKEN $tag $newVersion $body
}
else{
	Write-Host "> New release not required"
}

#if($versionsWithChagnedNotes.length -gt 0){
#	foreach($release in $versionsWithChagnedNotes){
#		$body = Get-VersionNotes $release
#		Edit-GithubRelease $env:GITHUB_TOKEN $tag $newVersion $body
#	}
#}

# Possible that there might be a new tag without a new version if one of more
# builds fail for a new version
Write-Host "Checking if a tag has been added"
if($env:APPVEYOR_REPO_TAG){
	Write-Host "> New tag `"$($env:APPVEYOR_REPO_TAG_NAME)`" detected"

	#publish
}
else
{
	Write-Host "> No new tags"
}

