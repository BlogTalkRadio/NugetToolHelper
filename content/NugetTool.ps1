param(
    [string]$Package = "",
    [string]$Tool = "" # Using "" or "_" will find an exe or ps1 named as the package
)

Function FindToolInFolder([string]$folder, [string]$packageName, [string]$tool) {
    if (!(Test-Path $folder)) {
        return
    }
    if ($tool) {
        $toolPath = Join-Path $folder $tool -resolve -ErrorAction SilentlyContinue
        if ($toolPath -and (Test-Path $toolPath -PathType Leaf)) {
            return $toolPath
        }
    } else {
        # find using packageName
        $toolPath = Join-Path $folder $packageName".ps1" -resolve -ErrorAction SilentlyContinue
        if ($toolPath -and (Test-Path $toolPath -PathType Leaf)) {
            return $toolPath
        }
        $toolPath = Join-Path $folder $packageName".exe" -resolve -ErrorAction SilentlyContinue
        if ($toolPath -and (Test-Path $toolPath -PathType Leaf)) {
            return $toolPath
        }
    }
}

Function FindPackageTool([string]$packageName, [string]$tool) {
    $container = Resolve-Path "."
    
    $toolPath = FindToolInFolder $container $packageName $tool
    if ($toolPath) {
        return $toolPath
    }
    $toolPath = FindToolInFolder (Join-Path $container bin -ErrorAction SilentlyContinue) $packageName $tool
    if ($toolPath) {
        # tool found on bin folder (works for websites)
        return $toolPath
    }
    $toolPath = FindToolInFolder (Join-Path $container tools -ErrorAction SilentlyContinue) $packageName $tool
    if ($toolPath) {
        return $toolPath
    }
    
    # find in packages folder
    while (!(Test-Path(Join-Path $container "packages"))) {
        $containerParent = Join-Path $container ".." -resolve
        if ($container -eq $containerParent) {
            Throw "packages folder not found"
        }
        $container = $containerParent
    }
    $container = Join-Path $container "packages"
    $packagePath = (Get-ChildItem -Path $container -Filter "$packageName.*" | Select-Object -First 1).FullName
    if (!$packagePath) {
        Throw "Package not found: $packageName"
    }
    $packageToolsPath = Join-Path $packagePath "tools"
    $toolPath = FindToolInFolder $packageToolsPath $packageName $tool
    if ($toolPath) {
        return $toolPath
    }
    Throw "Unable to find tool: $tool, package: $packageName"
}

if (!$Package) {
    Throw "Package name is required"
}
if ($Tool -eq "_") {
    $Tool = ""
}

$arguments = $args | %{ @($_) -join ", " }

$command = (FindPackageTool $Package $Tool) + " " + $arguments
"$command"

Invoke-Expression $command