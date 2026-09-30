$gitExe = "C:\Program Files\Git\cmd\git.exe"
if (-not (Test-Path $gitExe)) {
    $gitExe = "git"
}

Clear-Host
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Chekushkagram -> GitHub Auto-Deploy                    " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$currentRemote = & $gitExe remote get-url origin 2>$null
Write-Host "Current remote origin: $currentRemote" -ForegroundColor Gray
Write-Host ""
Write-Host "Esli repozitoriya esche net:" -ForegroundColor Yellow
Write-Host "1. Otkroy https://github.com/new" -ForegroundColor Yellow
Write-Host "2. Ukazhi imya: chekyshkagram" -ForegroundColor Yellow
Write-Host "3. NE stav' galochku 'Add README'" -ForegroundColor Yellow
Write-Host "4. Nazhmi 'Create repository'" -ForegroundColor Yellow
Write-Host ""

$repoUrl = Read-Host "Vstavit' ssylku na repozitoriy (naprimer https://github.com/USERNAME/chekyshkagram.git)"

if ([string]::IsNullOrWhiteSpace($repoUrl)) {
    Write-Host "Ssylka ne vvedena. Otmena." -ForegroundColor Red
    exit 1
}

$repoUrl = $repoUrl.Trim()

Write-Host "Nastraivayu remote origin na: $repoUrl" -ForegroundColor Green
& $gitExe remote set-url origin $repoUrl

Write-Host "Dobavlyayu i commitiruem izmeneniya..." -ForegroundColor Green
& $gitExe add .
& $gitExe commit -m "Chekushkagram: Anti-Delete, Edit History, Ghost Mode, Troll Panel, 12 Custom Icons" 2>$null

Write-Host "Zagruzhayu vetku master na GitHub..." -ForegroundColor Cyan
& $gitExe branch -M master
& $gitExe push -u origin master --force

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "   USPEH! Proekt uspeshno zagruzhen na GitHub!            " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host ""
    $actionsUrl = $repoUrl.Replace(".git", "") + "/actions"
    Write-Host "Sborka IPA nachnetsya avtomaticheski na macOS runner." -ForegroundColor Yellow
    Write-Host "Otkryvayu Actions: $actionsUrl" -ForegroundColor Cyan
    try {
        Start-Process $actionsUrl
    } catch {}
} else {
    Write-Host ""
    Write-Host "Oshibka pri zagruzke. Prover' prava dostupa i login v GitHub." -ForegroundColor Red
}
