param(
    [string]$BundlePath = 'build/app/outputs/bundle/release/app-release.aab'
)
$ErrorActionPreference = 'Stop'
$taskVersion = [regex]::Match([IO.File]::ReadAllText((Join-Path (Get-Location) 'pubspec.yaml')),
    '(?m)^version:\s*(?<name>\d+\.\d+\.\d+)\+(?<code>\d+)\s*$')
if (!$taskVersion.Success) { throw 'No se encontró una versión de publicación válida en pubspec.yaml.' }
$taskJava = 'C:\Program Files\Android\Android Studio\jbr\bin\java.exe'
$taskKeytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
$taskJarSigner = 'C:\Program Files\Android\Android Studio\jbr\bin\jarsigner.exe'
$taskToolDir = Join-Path (Get-Location) '.release-tools'
$taskBundletool = Join-Path $taskToolDir 'bundletool-all-1.18.1.jar'
New-Item -ItemType Directory -Force -Path $taskToolDir | Out-Null
if (!(Test-Path -LiteralPath $taskBundletool)) {
    Invoke-WebRequest -Uri 'https://github.com/google/bundletool/releases/download/1.18.1/bundletool-all-1.18.1.jar' -OutFile $taskBundletool
}
$taskBundle = (Resolve-Path -LiteralPath $BundlePath).Path
& $taskJava -jar $taskBundletool validate --bundle=$taskBundle *> (Join-Path $taskToolDir 'bundle-validation.txt')
if ($LASTEXITCODE -ne 0) { throw 'Bundle inválido.' }
$taskManifestText = (& $taskJava -jar $taskBundletool dump manifest --bundle=$taskBundle --module=base) -join "`n"
if ($LASTEXITCODE -ne 0) { throw 'No se pudo leer el manifiesto del bundle.' }
[xml]$taskManifest = $taskManifestText
$taskAndroidNamespace = 'http://schemas.android.com/apk/res/android'
$taskPackage = $taskManifest.manifest.GetAttribute('package')
$taskVersionName = $taskManifest.manifest.GetAttribute('versionName', $taskAndroidNamespace)
$taskVersionCode = $taskManifest.manifest.GetAttribute('versionCode', $taskAndroidNamespace)
$taskTarget = $taskManifest.manifest.'uses-sdk'.GetAttribute('targetSdkVersion', $taskAndroidNamespace)
$taskMin = $taskManifest.manifest.'uses-sdk'.GetAttribute('minSdkVersion', $taskAndroidNamespace)
if ($taskPackage -ne 'pe.com.equilibra.app' -or $taskTarget -ne '36' -or $taskMin -ne '23' -or
    $taskVersionName -ne $taskVersion.Groups['name'].Value -or
    $taskVersionCode -ne $taskVersion.Groups['code'].Value) { throw 'Metadatos de publicación incorrectos.' }
if ($taskManifestText.Contains('com.mycompany.equilibra')) { throw 'Referencia al package anterior en el manifiesto final.' }
& $taskJarSigner -verify $taskBundle *> (Join-Path $taskToolDir 'signature-validation.txt')
if ($LASTEXITCODE -ne 0) { throw 'La firma del bundle no se verifica.' }
$taskCertificate = (& $taskKeytool -printcert -jarfile $taskBundle) -join "`n"
if ($LASTEXITCODE -ne 0 -or $taskCertificate -match '(?i)CN=Android Debug' -or
    $taskCertificate -notmatch 'CN=Equilibra Upload') { throw 'Certificado de carga incorrecto.' }
$taskDelivery = Join-Path (Get-Location) 'release'
New-Item -ItemType Directory -Force -Path $taskDelivery | Out-Null
$taskOutput = Join-Path $taskDelivery "Equilibra-v$taskVersionName.aab"
Copy-Item -LiteralPath $taskBundle -Destination $taskOutput
[System.IO.File]::WriteAllText((Join-Path $taskDelivery 'AndroidManifest-verificado.xml'), $taskManifestText)
[System.IO.File]::WriteAllText((Join-Path $taskDelivery 'certificado-upload.txt'), $taskCertificate)
$taskMetadata = [ordered]@{ package = $taskPackage; versionName = $taskVersionName;
    versionCode = [int]$taskVersionCode; targetSdk = [int]$taskTarget; minSdk = [int]$taskMin;
    certificate = 'CN=Equilibra Upload, OU=Mobile, O=Equilibra, C=PE';
    sha256 = (Get-FileHash -LiteralPath $taskOutput -Algorithm SHA256).Hash }
$taskMetadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskDelivery 'bundle-verificado.json')
$taskMetadata | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskDelivery "bundle-v$taskVersionName-verificado.json")
$taskMetadata | ConvertTo-Json
