$projectRoot = $containingDir | Split-Path -Parent
$projectName = 'ContinuousDeploymentUtils'
Remove-Module $projectName
Import-Module "$projectRoot\src\$projectName\$projectName.psd1"
Invoke-Expression -Command "`"$projectRoot\src\$projectName\$projectName.pre.ps1`""

Describe "Push-TagAndChangelog" {
	BeforeAll{
		cd $TestDrive
	}
	AfterAll{
		cd $location
	}

	It "test" {
		"# Changelog`n## 0.1.0`nInitial release" | Out-File 'Changelog.md'

		Push-TagAndChangelog
	}
} 