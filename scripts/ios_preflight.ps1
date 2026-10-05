param()
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$failures = [System.Collections.Generic.List[string]]::new()
function Read-PlistValue([xml]$plist, [string]$key) {
  $node = $plist.SelectSingleNode("/plist/dict/key[text()='$key']")
  if ($null -eq $node) { return $null }
  return $node.NextSibling.InnerText
}
$projectText = Get-Content -LiteralPath (Join-Path $projectRoot 'ios/Runner.xcodeproj/project.pbxproj') -Raw
$bundleIds = [regex]::Matches($projectText, 'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);')
if ($bundleIds.Count -ne 3 -or @($bundleIds | Where-Object { $_.Groups[1].Value -ne 'pe.com.equilibra.app' }).Count -gt 0) {
  $failures.Add('Bundle ID incorrecto en una configuracion Xcode.')
}
$config = [xml](Get-Content -LiteralPath (Join-Path $projectRoot 'ios/Runner/GoogleService-Info.plist') -Raw)
if ((Read-PlistValue $config 'BUNDLE_ID') -ne 'pe.com.equilibra.app') {
  $failures.Add('Registrar pe.com.equilibra.app en Firebase y descargar su GoogleService-Info.plist real. No editar el plist antiguo a mano.')
}
if ((Read-PlistValue $config 'PROJECT_ID') -ne 'equilibra-w5rl2h') {
  $failures.Add('Firebase apunta a otro proyecto.')
}
$manifest = [xml](Get-Content -LiteralPath (Join-Path $projectRoot 'ios/Runner/PrivacyInfo.xcprivacy') -Raw)
if ($null -eq $manifest.SelectSingleNode('/plist/dict/key[text()="NSPrivacyCollectedDataTypes"]/following-sibling::array[1]/dict')) {
  $failures.Add('Faltan las declaraciones de datos propios en PrivacyInfo.xcprivacy.')
}
$info = [xml](Get-Content -LiteralPath (Join-Path $projectRoot 'ios/Runner/Info.plist') -Raw)
$permissionKeys = @($info.plist.dict.key | Where-Object { $_ -match 'UsageDescription$' })
Write-Output "Permisos declarados: $($permissionKeys -join ', ')"
if (@($permissionKeys | Where-Object { $_ -ne 'NSPhotoLibraryUsageDescription' }).Count -gt 0) {
  $failures.Add('Se agregaron permisos que requieren revisar su uso real.')
}
if ($projectText -notmatch 'PrivacyInfo.xcprivacy in Resources' -or $projectText -notmatch 'Crashlytics Symbols') {
  $failures.Add('Faltan recursos de privacidad o la fase de simbolos de Crashlytics.')
}
Write-Output 'La comprobacion estatica no sustituye un Archive de Xcode, sus SDK manifests, firma ni pruebas reales.'
if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Output "PENDIENTE: $_" }
  exit 1
}
Write-Output 'Configuracion estatica de iOS correcta.'
