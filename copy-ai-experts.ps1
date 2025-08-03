# Script để copy .ai-experts và cập nhật .gitignore tự động
param(
    [string]$TargetPath = "."
)

$sourcePath = "D:\pcloud\code\ai\Prompt AI NguyenX"
$aiExpertsSource = Join-Path $sourcePath ".ai-experts"
$gitignoreRules = "# AI Experts configuration - keep local only`n.ai-experts/`n"

# Copy thư mục .ai-experts
Write-Host "Copying .ai-experts directory..." -ForegroundColor Green
Copy-Item $aiExpertsSource (Join-Path $TargetPath ".ai-experts") -Recurse -Force

# Kiểm tra và cập nhật .gitignore
$gitignorePath = Join-Path $TargetPath ".gitignore"
if (Test-Path $gitignorePath) {
    # Kiểm tra xem rule đã tồn tại chưa
    $content = Get-Content $gitignorePath -Raw
    if ($content -notmatch "\.ai-experts/") {
        Write-Host "Adding .ai-experts rule to existing .gitignore..." -ForegroundColor Yellow
        $gitignoreRules + "`n" + $content | Set-Content $gitignorePath
    } else {
        Write-Host ".gitignore already contains .ai-experts rule" -ForegroundColor Cyan
    }
} else {
    # Tạo .gitignore mới
    Write-Host "Creating new .gitignore with .ai-experts rule..." -ForegroundColor Yellow
    $gitignoreRules | Set-Content $gitignorePath
}

Write-Host "Done! .ai-experts has been copied and .gitignore updated." -ForegroundColor Green
