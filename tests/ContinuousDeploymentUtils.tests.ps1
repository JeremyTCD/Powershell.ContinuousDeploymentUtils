$projectRoot = $PSScriptRoot | Split-Path -Parent
$projectName = 'ContinuousDeploymentUtils'
Remove-Module $projectName
Import-Module "$projectRoot\src\$projectName\$projectName.psd1"
Invoke-Expression -Command "`"$projectRoot\src\$projectName\$projectName.pre.ps1`""

#Describe "Push-TagAndChangelog" {
#	BeforeAll{
#		cd $TestDrive
#	}
#	AfterAll{
#		cd $location
#	}

#	It "test" {
#		"# Changelog`n## 0.1.0`nInitial release" | Out-File 'Changelog.md'

#		Push-TagAndChangelog
#	}
#} 

Describe "Get-VersionNotes" {
	BeforeAll{
		cd $TestDrive
	}
	AfterAll{
		cd $projectRoot
	}

	$testCases = @(
		# Changelog with notes for only 1 version
        @{ content = "## 0.1.1`n
Test version notes`nTest version notes line 2`n";  
		   expectedResult = "Test version notes`nTest version notes line 2" }
		# Changelog with notes for multiple versions
		@{ content = "## 1.1.0`nBody`n
## 0.1.1`nTest version notes`nTest version notes line 2`n
## 0.1.0`nBody";  
		   expectedResult = "Test version notes`nTest version notes line 2" }
		# Changelog with no notes for its only version
		@{ content = "## 0.1.1";  
		   expectedResult = "" }
    )

	It "Gets version notes if version exists" -TestCases $testCases {
		param($content, $expectedResult)

		# Arrange
		$path = "$TestDrive/changelog.md"
		$version = '0.1.1'
		[System.IO.File]::WriteAllLines($path, $content)

		# Act
		$result = (Get-VersionNotes $path '0.1.1') -join "`n"

		# Assert
		$result | Should Be $expectedResult
	}

	It "Throws error if version does not exist" {
		# Arrange
		$path = "$TestDrive/changelog.md"
		$version = '0.1.1'
		$content = "## 1.1.0`nBody`n
## 0.1.2`nTest version notes`nTest version notes line 2`n
## 0.1.0`nBody";  
		[System.IO.File]::WriteAllLines($path, $content)

		# Act and Assert
		{Get-VersionNotes $path '0.1.1'} | Should Throw "Version `"$version`" does not exist"
	}
} 

Describe "Compare-TextFileLines" {
	BeforeAll{
		cd $TestDrive
	}
	AfterAll{
		cd $projectRoot
	}

	It "Returns added changed and removed lines"{
		# Arrange
		$oldText = 'This is line 1',
'This is line 2',
'This is line 3',
'This is line 4'
		$newText = 'This is the new line 1',
'This is line 3',
'This is line 4',
'This is line 5'
		$oldPath = "$TestDrive\old.md"
		$newPath = "$TestDrive\new.md"

		[System.IO.File]::WriteAllLines($oldPath, $oldText)
		[System.IO.File]::WriteAllLines($newPath, $newText)

		# Act
		$result = Compare-TextFileLines $oldPath $newPath

		# Assert
		$result[0] | Should Be 1,4
		$result[1] | Should Be 1,2
	}
} 