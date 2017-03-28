if ((Get-Command "git" -ErrorAction SilentlyContinue) -eq $null) 
{ 
   throw "Error: Git not available. Please install git and add it to your path."
}