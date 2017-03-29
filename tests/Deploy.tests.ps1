$projectRoot = $PSScriptRoot | Split-Path -Parent
$projectName = 'ContinuousDeploymentUtils'
Invoke-Expression -Command "`"$projectRoot\src\$projectName\$projectName.pre.ps1`""
Remove-Module $projectName
Import-Module "$projectRoot\src\$projectName\$projectName.psd1"

Describe "Deploy" {
	AfterAll{
		# So test drive can be deleted
		cd $projectRoot
	}

	BeforeEach{
		cd $projectRoot
		Remove-Item $TestDrive\* -Recurse -Force
		cd $TestDrive

		$env:APPVEYOR_REPO_COMMIT = 'head'
		$env:GITHUB_TOKEN = 'test token'
		git init 
	}

	It "Creates and pushes a tag if a version has been added to changelog" {
		# Arrange
		$version1 = '0.1.0'
		$version2 = '0.2.1'
		$version3 = '1.0.1'
		$version4 = '1.2.1'
		$expectedTag = "$version4+1"

		for($i=1; $i -le 4; $i++)
		{
			$version = Get-Variable -Name "version$i" -ValueOnly
			[System.IO.File]::AppendAllText("$TestDrive\changelog.md", "`n## {0}`nBody" -f $version)
			git add .
			git commit -m 'dummy'
		}

		$env:APPVEYOR_REPO_COMMIT = git rev-list head -1

		Mock Invoke-Git -Verifiable -ParameterFilter{
			$args[0] -eq 'push' -and `
		    $args[1] -eq 'origin' -and `
			$args[2] -eq $expectedTag
		} 

		# Act
		. "$projectRoot\tools\Deploy.ps1"

		# Assert
		git tag -l | Should Be $expectedTag
		Assert-VerifiableMocks
	}

	It "Creates release if new version has been added" {
		[System.IO.File]::AppendAllText("$TestDrive\changelog.md", "`n## 0.1.1`nBody")
		git add .
		git commit -m 'dummy'

		Mock Invoke-Git -Verifiable -ParameterFilter{
			$args[0] -eq 'push' -and `
			$args[1] -eq 'origin' -and `
			$args[2] -eq '0.1.1+1'
		}

		Mock Create-GithubRelease -Verifiable -ParameterFilter{
			$args[0] -eq $env:GITHUB_TOKEN -and `
			$args[1] -eq '0.1.1+1' -and `
			$args[2] -eq '0.1.1' -and `
			$args[3] -eq "## 0.1.1`nBody" 
		}

		# Act
		. "$projectRoot\tools\Deploy.ps1"
	} 
}

	#It "Updates releases if version notes were changed" {

	#}
