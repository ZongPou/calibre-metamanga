# One-shot admin script: fix scheduled task settings + add firewall rule
$log = @()

# 1. Fix scheduled task settings
try {
    $t = Get-ScheduledTask -TaskName "Komga Server" -ErrorAction Stop
    $t.Settings.ExecutionTimeLimit = "PT0S"
    $t.Settings.DisallowStartIfOnBatteries = $false
    $t.Settings.StopIfGoingOnBatteries = $false
    $t.Settings.RestartCount = 3
    $t.Settings.RestartInterval = "PT1M"
    Set-ScheduledTask -InputObject $t -ErrorAction Stop | Out-Null
    $log += "[OK] Task settings fixed (no time limit / battery OK / restart x3)"
} catch {
    $log += "[FAIL] Task fix: $($_.Exception.Message)"
}

# 2. Firewall rule
try {
    if (Get-NetFirewallRule -DisplayName "Komga" -ErrorAction SilentlyContinue) {
        $log += "[SKIP] Firewall rule Komga already exists"
    } else {
        New-NetFirewallRule -DisplayName "Komga" -Direction Inbound -Protocol TCP -LocalPort 25600 -Action Allow -ErrorAction Stop | Out-Null
        $log += "[OK] Firewall rule added (TCP 25600 inbound allow)"
    }
} catch {
    $log += "[FAIL] Firewall: $($_.Exception.Message)"
}

# 3. Verify
try {
    $chk = Get-ScheduledTask -TaskName "Komga Server"
    $log += "[CHK] TimeLimit=$($chk.Settings.ExecutionTimeLimit) DisallowOnBattery=$($chk.Settings.DisallowStartIfOnBatteries) StopOnBattery=$($chk.Settings.StopIfGoingOnBatteries)"
    $fw = Get-NetFirewallRule -DisplayName "Komga" -ErrorAction SilentlyContinue
    $log += "[CHK] Firewall rule exists=$([bool]$fw) status=$($fw.Status)"
} catch {
    $log += "[CHK-FAIL] $($_.Exception.Message)"
}

$log | Out-File -Encoding utf8 D:\komga\setup-admin-result.txt
Write-Host "DONE - see D:\komga\setup-admin-result.txt"
