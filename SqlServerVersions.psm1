function Get-SqlServerVersionApiRootUri {
    return "http://sqlserverversions.azurewebsites.net/api/version"
}
function Test-SqlServerVersionApiRootUri {
    # to do this test we are just going to make a quick request 
    # and interpret our HTTP response status code
    #
    try {
        return (
            (Invoke-WebRequest -Uri (Get-SqlServerVersionApiRootUri) -ErrorAction Stop |
                Select-Object -ExpandProperty StatusCode) -eq 200
        )
    }
    catch {
        # on error return false
        #
        return $false
    }
}
function Parse-SqlServerVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VersionString
    )

    $RegexPattern = "^(\d+)\.(\d+)\.(\d+)\.(\d+)$"

    if ([regex]::IsMatch($VersionString, $RegexPattern)) {
        return (
            [regex]::Match($VersionString, $RegexPattern) |
                Select-Object @{Name = "Major"; Expression = { [int]$_.Groups[1].Value }},
                    @{Name = "Minor"; Expression = { [int]$_.Groups[2].Value }},
                    @{Name = "Build"; Expression = { [int]$_.Groups[3].Value }},
                    @{Name = "Revision"; Expression = { [int]$_.Groups[4].Value }})
    }
    else {
        Write-Error "Version string is in the incorrect format"
    }
}

function Get-SqlServerVersion {
    param (
        [Parameter(Mandatory = $false)]
        [string]$VersionString,

        [Parameter(Mandatory = $false)]
        [int]$Major = -1,

        [Parameter(Mandatory = $false)]
        [int]$Minor = -1,

        [Parameter(Mandatory = $false)]
        [int]$Build = -1,

        [Parameter(Mandatory = $false)]
        [int]$Revision = -1
    )

    # do a test to first see if we can hit the API
    #
    if (!(Test-SqlServerVersionApiRootUri)) {
        Write-Error "SQL Server Version API Uri not available"
    }

    # if a version string is passed, it will trump other 
    # version parameters
    #
    if ($VersionString) {
        $ParsedVersion = Parse-SqlServerVersion -VersionString $VersionString -ErrorAction Stop
        $Major = $ParsedVersion.Major
        $Minor = $ParsedVersion.Minor
        $Build = $ParsedVersion.Build
        $Revision = $ParsedVersion.Revision
    }

    # start constructing the request URI
    #
    $RequestUri = (Get-SqlServerVersionApiRootUri)
    # have a waterfall condition statement to append version information
    #
    if ($Major -ge 0) {
        $RequestUri += "/" + $Major
        if ($Minor -ge 0) {
            $RequestUri += "/" + $Minor
            if ($Build -ge 0) {
                if ($Revision -ge 0) {
                    $RequestUri += "/" + "$Build/$Revision"
                }
                # this is a kind act here, as if the user specifies only 
                # a revision with an assumed zero for build but doens't 
                # specify, then we will assume that and put it there 
                # instead of just ignoring the build search altogether 
                #
                else {
                    $RequestUri += "/" + "$Build/0"
                }
            }
        }
    }
    Write-Verbose "RequestUri :: $RequestUri"

    # make the request
    #
    Invoke-RestMethod -Method Get -Uri $RequestUri |
        Select-Object Major, Minor, Build, Revision,
            FriendlyNameShort, FriendlyNameLong,
            ReleaseDate, IsSupported, ReferenceLinks
}