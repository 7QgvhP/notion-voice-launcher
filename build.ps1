# Notion 音声入力ランチャー ビルドスクリプト
#
# Gradle を使わず、Android SDK の素のツール（aapt2 / javac / d8 / zipalign / apksigner）
# だけで APK を生成する。
#
# バージョンと SDK レベルは本ファイルの変数が唯一の出典で、AndroidManifest.xml には
# 記述せず aapt2 link で注入する。バージョンを上げるときは下の $versionCode /
# $versionName だけを書き換える。
$ErrorActionPreference = "Stop"

# ==== ここだけを更新する ====
$versionCode = 8
$versionName = "1.1.4"

# ==== ビルド設定 ====
$minSdk    = 26
$targetSdk = 35

# ツールチェーンの設置場所。個別のバージョン番号は下で自動検出する。
# 環境変数 NVL_TOOL_ROOT を設定するとそちらを優先し、未設定ならユーザープロファイル直下を使う。
$toolRoot = if ($env:NVL_TOOL_ROOT) { $env:NVL_TOOL_ROOT } else { "$env:USERPROFILE\android-build-tools" }

$proj = $PSScriptRoot
$out  = "$proj\build"

# native コマンドの終了コードを確認する
function Assert-Ok($label) {
    if ($LASTEXITCODE -ne 0) { throw "$label に失敗しました (exit=$LASTEXITCODE)" }
}

# パターンに一致するディレクトリのうち最も新しいものを1つ返す。
# ツールを更新してもビルドが壊れないよう、バージョン番号を固定しない。
function Resolve-ToolDir($pattern, $label) {
    $found = @(Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending)
    if ($found.Count -eq 0) {
        throw "$label が見つかりません: $pattern`nセットアップ手順は README.md を参照してください。"
    }
    return $found[0].FullName
}

$jdkHome    = Resolve-ToolDir "$toolRoot\jdk\jdk-*"               "JDK"
$buildTools = Resolve-ToolDir "$toolRoot\sdk\build-tools\*"       "Android build-tools"
$platform   = Resolve-ToolDir "$toolRoot\sdk\platforms\android-*" "Android platform"

$env:JAVA_HOME = $jdkHome
$jdkBin        = "$jdkHome\bin"
$androidJar    = "$platform\android.jar"
if (-not (Test-Path $androidJar)) { throw "android.jar が見つかりません: $androidJar" }

Write-Host "JDK        : $jdkHome"
Write-Host "build-tools: $buildTools"
Write-Host "platform   : $platform"
Write-Host "version    : $versionName ($versionCode)"
Write-Host ""

# アイコンが未生成なら先に生成する（初回ビルドでも1コマンドで完結させるため）
$iconFiles = @(
    "$proj\res\mipmap-xxhdpi\ic_launcher.png",
    "$proj\res\mipmap-xxhdpi\ic_launcher_foreground.png"
)
if (@($iconFiles | Where-Object { -not (Test-Path $_) }).Count -gt 0) {
    Write-Host "[0/6] アイコンが未生成のため make-icon.ps1 を実行"
    & "$proj\make-icon.ps1"
}

# 出力ディレクトリを作り直す
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null

Write-Host "[1/6] リソースをコンパイル"
& "$buildTools\aapt2.exe" compile --dir "$proj\res" -o "$out\res.zip"
Assert-Ok "aapt2 compile"

Write-Host "[2/6] リソースをリンクし R.java を生成"
& "$buildTools\aapt2.exe" link -o "$out\app-base.apk" -I $androidJar `
    --manifest "$proj\AndroidManifest.xml" "$out\res.zip" `
    --java "$out\gen" `
    --min-sdk-version $minSdk --target-sdk-version $targetSdk `
    --version-code $versionCode --version-name $versionName
Assert-Ok "aapt2 link"

Write-Host "[3/6] Java をコンパイル"
$sources = @(Get-ChildItem "$proj\src" -Recurse -Filter *.java | ForEach-Object { $_.FullName })
$sources += @(Get-ChildItem "$out\gen" -Recurse -Filter R.java | ForEach-Object { $_.FullName })
New-Item -ItemType Directory -Force "$out\classes" | Out-Null
& "$jdkBin\javac.exe" -source 8 -target 8 -nowarn -encoding UTF-8 `
    -classpath $androidJar -d "$out\classes" $sources
Assert-Ok "javac"

Write-Host "[4/6] dex に変換"
$classes = @(Get-ChildItem "$out\classes" -Recurse -Filter *.class | ForEach-Object { $_.FullName })
New-Item -ItemType Directory -Force "$out\dex" | Out-Null
& "$buildTools\d8.bat" --min-api $minSdk --lib $androidJar --output "$out\dex" $classes
Assert-Ok "d8"

Write-Host "[5/6] classes.dex を APK に格納し zipalign"
Copy-Item "$out\app-base.apk" "$out\app-unaligned.apk" -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open("$out\app-unaligned.apk", "Update")
[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, "$out\dex\classes.dex", "classes.dex") | Out-Null
$zip.Dispose()
& "$buildTools\zipalign.exe" -f 4 "$out\app-unaligned.apk" "$out\app-aligned.apk"
Assert-Ok "zipalign"

Write-Host "[6/6] 署名"
# 個人利用のためのローカル署名鍵。無ければ生成する（リポジトリには含めない）
$keystore = "$proj\debug.keystore"
# 署名鍵のパスワード。Android のデバッグ署名で使われる慣例値を既定とする。
# 変更したい場合は環境変数 NVL_KEYSTORE_PASSWORD で上書きする。
$keystorePassword = if ($env:NVL_KEYSTORE_PASSWORD) { $env:NVL_KEYSTORE_PASSWORD } else { "android" }
if (-not (Test-Path $keystore)) {
    & "$jdkBin\keytool.exe" -genkeypair -keystore $keystore `
        -storepass $keystorePassword -keypass $keystorePassword `
        -alias androiddebugkey -dname "CN=Notion Voice Launcher,O=local,C=JP" `
        -keyalg RSA -keysize 2048 -validity 10000
    Assert-Ok "keytool"
}
& "$buildTools\apksigner.bat" sign --ks $keystore `
    --ks-pass "pass:$keystorePassword" --key-pass "pass:$keystorePassword" `
    --out "$out\notion-voice-launcher.apk" "$out\app-aligned.apk"
Assert-Ok "apksigner"

Write-Host ""
Write-Host "ビルド完了: $out\notion-voice-launcher.apk"
Write-Host ("サイズ: {0} KB" -f [math]::Round((Get-Item "$out\notion-voice-launcher.apk").Length / 1KB, 1))
