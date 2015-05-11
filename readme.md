## SQL Server Versions PowerShell Module

***Description***

This PowerShell module is used to abstract API calls to the SQL Server Versions API.  It can be used to retrieve version information.

***Usage***

Pass in the build as a string.

`Get-SqlServerVersion -VersionString "10.0.1600.0"`

*Or* specify each part of the build individually.

`Get-SqlServerVersion -Major 10 -Minor 0 -Build 1600 -Revision 1600`
