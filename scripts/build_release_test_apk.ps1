$ErrorActionPreference = 'Stop'
$taskRoot = (Get-Location).Path
$taskToolDir = Join-Path $taskRoot '.release-tools'
$taskVerified = Get-Content -LiteralPath (Join-Path $taskRoot 'release/bundle-verificado.json') | ConvertFrom-Json
if ($taskVerified.versionName -notmatch '^\d+\.\d+\.\d+$') { throw 'Versión de bundle inválida.' }
$taskBundlePath = Join-Path $taskRoot "release/Equilibra-v$($taskVerified.versionName).aab"
if ((Get-FileHash -LiteralPath $taskBundlePath -Algorithm SHA256).Hash -ne $taskVerified.sha256) {
    throw 'El bundle difiere del archivo verificado.'
}
$taskPasswordFile = Join-Path $taskToolDir 'upload-password.tmp'
$taskProperties = @{}
foreach ($taskLine in Get-Content -LiteralPath (Join-Path $taskRoot 'android/key.properties')) {
    if ($taskLine -match '^([^=]+)=(.*)$') { $taskProperties[$Matches[1]] = $Matches[2] }
}
try {
    [System.IO.File]::WriteAllText($taskPasswordFile, $taskProperties['storePassword'])
    Set-Acl -LiteralPath $taskPasswordFile -AclObject (Get-Acl -LiteralPath (Join-Path $taskRoot 'android/key.properties'))
    & 'C:\Program Files\Android\Android Studio\jbr\bin\java.exe' -jar (Join-Path $taskToolDir 'bundletool-all-1.18.1.jar') build-apks `
        "--bundle=$taskBundlePath" `
        "--output=$(Join-Path $taskToolDir 'equilibra-release.apks')" --mode=universal `
        "--ks=$(Join-Path $taskRoot ('android/' + $taskProperties['storeFile']))" `
        --ks-key-alias=$($taskProperties['keyAlias']) --ks-pass=file:$taskPasswordFile `
        --key-pass=file:$taskPasswordFile --overwrite
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar el APK de prueba desde el bundle.' }
    $taskArchive = [System.IO.Compression.ZipFile]::OpenRead((Join-Path $taskToolDir 'equilibra-release.apks'))
    try {
        [System.IO.Compression.ZipFileExtensions]::ExtractToFile($taskArchive.GetEntry('universal.apk'),
            (Join-Path $taskToolDir 'equilibra-release.apk'), $true)
    } finally { $taskArchive.Dispose() }
    Write-Output 'APK de prueba generado directamente desde el AAB firmado.'
} finally {
    if (Test-Path -LiteralPath $taskPasswordFile) { Remove-Item -LiteralPath $taskPasswordFile }
}
