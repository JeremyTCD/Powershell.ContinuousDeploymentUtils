<# Abstraction layer for mocking #>
function Invoke-Git{
	git $args
}

# Create tag from changelog
function Push-TagAndChangelog{
	[CmdletBinding()]
	param([Parameter(Mandatory=$false)][string] $file = 'Changelog.md')
	
	$changelog = Get-Content $file

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

function get-message{
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