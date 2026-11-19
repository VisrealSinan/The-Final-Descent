param(
    [Parameter(Mandatory = $true)]
    [string]$GodotPath
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$enginePath = (Resolve-Path -LiteralPath $GodotPath).Path
$outputPath = Join-Path $projectRoot 'builds/visreal-prototype'
$archivePath = Join-Path $projectRoot 'deliverables/visreal-combat-prototype-windows.zip'

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $archivePath) -Force | Out-Null
& $enginePath --headless --path $projectRoot --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
& $enginePath --headless --path $projectRoot --script tools/pack_combat.gd
if ($LASTEXITCODE -ne 0) { throw 'Godot packaging failed.' }

# The GUI Godot executable supports running an adjacent same-name PCK.
# Use the installed runtime to avoid requiring export templates on this machine.
$guiEngine = $enginePath -replace '_console\.exe$', '.exe'
Copy-Item -LiteralPath $guiEngine -Destination (Join-Path $outputPath 'TheFinalDescent.exe') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/PLAY-PROTOTYPE.txt') -Destination (Join-Path $outputPath 'READ-ME-FIRST.txt') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'docs/GODOT-LICENSE.txt') -Destination (Join-Path $outputPath 'GODOT-LICENSE.txt') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'Hackathon-Official-Rules.md') -Destination $outputPath -Force
Compress-Archive -LiteralPath @(
    (Join-Path $outputPath 'TheFinalDescent.exe'),
    (Join-Path $outputPath 'TheFinalDescent.pck'),
    (Join-Path $outputPath 'READ-ME-FIRST.txt'),
    (Join-Path $outputPath 'GODOT-LICENSE.txt'),
    (Join-Path $outputPath 'Hackathon-Official-Rules.md')
) -DestinationPath $archivePath -Force
Write-Output "Built $archivePath"
