## SQL Server Versions PowerShell Module

***Description***

This PowerShell module is used to abstract API calls to the SQL Server Versions API.  It can be used to retrieve version information.

***Usage***

Pass in the build as a string.

`Get-SqlServerVersion -VersionString "10.0.1600.0"`

*Or* specify each part of the build individually.

`Get-SqlServerVersion -Major 10 -Minor 0 -Build 1600 -Revision 1600`

If you want to change a SQL Server version, then specify the major.minor.build and then any combination of version data that you want changed.

`Modify-SqlServerVersion -Major 10 -Minor 0 -Build 1600` *<modifiable parameters>*

The list of parameters and properties of version data you can modify is following:

- `Revision` (int) - the revision number of the build number.  This is the last number in the version build of major.minor.build.REVISION
- `FriendlyNameLong` (string) - the long and proper friendly name for the build
- `FriendlyNameShort` (string) - the short friendly name
- `ReleaseDate` (datetime) - when the build was released
- `IsSupported` (bool) - TRUE if the build is supported, FALSE if the build is not currently supported

If you want to change a build from supported to unsupported, you can just specify the IsSupported parameter.

`Modify-SqlServerVersion -Major 10 -Minor 0 -Build 1600 -IsSupported $false`
