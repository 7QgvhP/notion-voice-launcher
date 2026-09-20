# アプリアイコン生成スクリプト
#
# マイク形状のグリフを一度だけ描き、それを縮小合成して各用途の画像を出力する。
# 出力先は res 配下（アダプティブアイコンの前景・旧形式用）とプロジェクト直下（確認用）。
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$proj = $PSScriptRoot
$res  = "$proj\res"

# ==== 調整用パラメータ ====
# グリフを描く基準キャンバスの一辺。マイクの座標は全てこの値を基準に定義する。
$glyphCanvas = 256
# グリフの色（濃いグレー）
$glyphColor = [System.Drawing.Color]::FromArgb(255, 74, 74, 74)
# 各出力キャンバスに対するグリフの占有率。
# アダプティブアイコンのセーフゾーン（中央約61%）に収まるよう、やや小さめにしている。
$glyphRatio = 0.53

# ==== マイク形状の寸法（$glyphCanvas = 256 基準）====
# 本体（上下が半円のカプセル形）
$bodyX = 88; $bodyY = 8; $bodyWidth = 80; $bodyHeight = 152
# 本体を囲む U 字のアーク（外接矩形と線幅）
$arcX = 58; $arcY = 60; $arcSize = 140; $arcWidth = 20
# 支柱
$stemX = 118; $stemY = 193; $stemWidth = 20; $stemHeight = 55

<#
.SYNOPSIS
マイク形状を描いた透過ビットマップを返す。
#>
function New-MicGlyph {
    param([int]$Size, [System.Drawing.Color]$Color)

    # 256 基準で定義した座標を実サイズへ換算する係数
    $k = $Size / 256.0

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = "AntiAlias"
    $g.Clear([System.Drawing.Color]::Transparent)

    $brush = New-Object System.Drawing.SolidBrush $Color
    $pen = New-Object System.Drawing.Pen $Color, ([float]($arcWidth * $k))
    $pen.StartCap = "Flat"
    $pen.EndCap = "Flat"

    # 本体：上下の半円を繋いでカプセル形にする
    $body = New-Object System.Drawing.Drawing2D.GraphicsPath
    $body.AddArc([float]($bodyX * $k), [float]($bodyY * $k),
                 [float]($bodyWidth * $k), [float]($bodyWidth * $k), 180, 180)
    $body.AddArc([float]($bodyX * $k), [float](($bodyY + $bodyHeight - $bodyWidth) * $k),
                 [float]($bodyWidth * $k), [float]($bodyWidth * $k), 0, 180)
    $body.CloseFigure()
    $g.FillPath($brush, $body)
    $body.Dispose()

    # U 字のアーク
    $g.DrawArc($pen, [float]($arcX * $k), [float]($arcY * $k),
               [float]($arcSize * $k), [float]($arcSize * $k), 0, 180)

    # 支柱
    $g.FillRectangle($brush, [float]($stemX * $k), [float]($stemY * $k),
                     [float]($stemWidth * $k), [float]($stemHeight * $k))

    $g.Dispose()
    $brush.Dispose()
    $pen.Dispose()
    return $bmp
}

<#
.SYNOPSIS
グリフを指定の比率で中央配置したアイコン画像を生成し、ファイルへ保存する。

.PARAMETER Background
none = 透過 / circle = 白い円 / fill = 白一色
#>
function Save-Icon {
    param(
        [System.Drawing.Image]$Glyph,
        [int]$Size,
        [double]$Ratio,
        [ValidateSet("none", "circle", "fill")][string]$Background,
        [string]$Path
    )

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = "AntiAlias"
    $g.InterpolationMode = "HighQualityBicubic"
    $g.Clear([System.Drawing.Color]::Transparent)

    switch ($Background) {
        "circle" { $g.FillEllipse([System.Drawing.Brushes]::White, 0, 0, $Size, $Size) }
        "fill"   { $g.Clear([System.Drawing.Color]::White) }
    }

    # 中央に比率どおりの大きさで載せる
    $drawSize = [int]($Size * $Ratio)
    $offset = [int](($Size - $drawSize) / 2)
    $g.DrawImage($Glyph, $offset, $offset, $drawSize, $drawSize)
    $g.Dispose()

    New-Item -ItemType Directory -Force (Split-Path $Path -Parent) | Out-Null
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host ("  {0} ({1}x{1})" -f (Split-Path $Path -Leaf), $Size)
}

$glyph = New-MicGlyph -Size $glyphCanvas -Color $glyphColor

# アダプティブアイコンの前景（背景は colors.xml の ic_launcher_background）
Save-Icon $glyph 288 $glyphRatio "none" "$res\mipmap-xxhdpi\ic_launcher_foreground.png"
# 旧形式（API 25 以下）用のアイコン
Save-Icon $glyph 144 $glyphRatio "circle" "$res\mipmap-xxhdpi\ic_launcher.png"
# 見た目確認用のプレビュー（ビルドには含まれない）
Save-Icon $glyph 256 $glyphRatio "fill" "$proj\icon-preview.png"

$glyph.Dispose()

Write-Host "アイコンを生成しました"
