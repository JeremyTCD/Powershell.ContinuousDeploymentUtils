$projectRoot = $PSScriptRoot | Split-Path -Parent
$projectName = 'ContinuousDeploymentUtils'
Invoke-Expression -Command "`"$projectRoot\src\$projectName\$projectName.pre.ps1`""

Describe "Deploy" {
	BeforeAll{
		cd $TestDrive
	}
	AfterAll{
		cd $projectRoot
	}

	It "Creates and pushes a tag if a version has been added to changelog" {
		# Arrange
		$version1 = '0.1.0'
		$version2 = '0.2.1'
		$version3 = '1.0.1'
		$version4 = '1.2.1'

		git init 
		for($i=1; $i -le 4; $i++)
		{
			$version = Get-Variable -Name "version$i" -ValueOnly
			[System.IO.File]::AppendAllText("$TestDrive\changelog.md", "`n## {0}`nBody" -f $version)
			git add .
			git commit -m 'dummy'
		}

		#set env vars
		$env:APPVEYOR_REPO_COMMIT = git rev-list head -1

		# Act
		. "$projectRoot\tools\Deploy.ps1"

		# Assert
		git tag -l | Should Be '1.2.1+1'
	}

	#It "Updates release if change was made to existing version's release notes" {

	#}

	#It "Creates release and publishes package if tag was pushed" {

	#}
} 