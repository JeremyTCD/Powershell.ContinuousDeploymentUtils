# all required function are being written here first
# later on these can be decomposed into smaller projects
# for greater flexibility

<# Abstraction layer for mocking #>
function Invoke-Git{
	git $args
}

# Create tag from changelog
function Push-TagAndChangelog{
	[CmdletBinding()]
	param([Parameter(Mandatory=$false)][string] $path = 'Changelog.md')
	
	$changelog = Get-Content $path

	Foreach ($line in $changelog){
		if($line -match '^##[ \t]+(\d*\.\d*\.\d*)$'){
			$version = $Matches[1]
			break
		}
	}

	#retreive all tags, see if a tag with same version exists, give it build number = last
	#build number + 1. Otherwise build number = 1
			
	# push changelog commit
	# create tag and push it
}

function Get-Message{
	if($version -eq $null){
		Foreach ($line in $changelog){
			if($line -match '^##[ \t]+(\d*\.\d*\.\d*)$'){
				$version = $Matches[1]
				$message = 'todo'
				break
			}
		}
	}else{
		Foreach ($line in $changelog){
			if($line -match "^##[ \t]+$version$"){
				$message = 'todo'
				break
			}
		}
	}
}

function Create-GithubRelease{
	[CmdletBinding()]
	param([Parameter(Mandatory=$true)][string] $token,
		[Parameter(Mandatory=$true)][string] $tag,
		[Parameter(Mandatory=$true)][string] $name,
		[Parameter(Mandatory=$true)][string] $body,
		[Parameter(Mandatory=$false)][string] $branch = 'master',
		[Parameter(Mandatory=$false)][bool] $draft = $false,
		[Parameter(Mandatory=$false)][string] $prerelase = $tag.Contains('-'))
	
	$input = @{
	  tag_name = $tag
	  target_commitish = $branch
	  name = $name
	  body = $body
	  draft = $draft
	  prerelease = $prerelase
	}
	$inputAsJson = $input | ConvertTo-Json

	$url = "https://api.github.com/repos/$owner/$repo/releases"

	$headers = New-Object 'System.Collections.Generic.Dictionary[[String],[String]]'
	$headers.Add('Authorization', "token $token")

	Invoke-RestMethod $url -Headers $headers -Method Post -Body $inputAsJson -ContentType 'application/json'
}

function Get-VersionNotes{
	[CmdletBinding()]
	[OutputType([String[]])]
	param([Parameter(Mandatory=$true)][string] $version,
		[Parameter(Mandatory=$false)][string] $path = 'changelog.md')
	$changelog = Get-Content $path
	if($changelog -is [string]){
		return ''
	}
	$escapedVersion = $version -replace '\.', '\.'

	for($i=0; $i -lt $changelog.Length; $i++){
		if($changelog[$i] -match "^##[ \t]+$escapedVersion$")
		{		
			$startIndex = $i + 1
		}		
		elseif($startIndex -and ($changelog[$i] -match '^##[ \t]+\d+\.\d+\.\d+$'))	
		{
			$endIndex = $i - 1
			break;
		}
		elseif($i -eq $changelog.Length - 1)
		{
			if(!$startIndex){
				throw "Version `"$version`" does not exist"
			}

			$endIndex = $i
		}
	}

	# No notes
	if(!$endIndex -or $endIndex -le $startIndex){
		return ''
	}

	return $changelog[$startIndex..$endIndex] | where {$_.Trim() -ne ''}
}

function Compare-TextFileLines{
	[CmdletBinding()]
	[OutputType([int[][]])]
	param([Parameter(Mandatory=$true)][string] $newPath,
		[Parameter(Mandatory=$true)][string] $oldPath)	

	$newFile = $newPath | Split-Path -Leaf
	$oldFile = $oldPath | Split-Path -Leaf
	$newText = Get-Content $newPath
	$oldText = Get-Content $oldPath

	$compareObjectResult = Compare-Object $newText $oldText 

	$linesAddedToNewText = $compareObjectResult | Where {$_.SideIndicator -eq '=>'} `
		| Select -ExpandProperty InputObject `
		| Select -ExpandProperty ReadCount
	$linesRemovedFromOldText = $compareObjectResult | Where {$_.SideIndicator -eq '<='} `
		| Select -ExpandProperty InputObject `
		| Select -ExpandProperty ReadCount	

	return $linesAddedToNewText, $linesRemovedFromOldText
}