# Komga startup script (invoked by scheduled task as SYSTEM)
# java.exe uses full path: SYSTEM account does not inherit user PATH
$java = "C:\Program Files\Eclipse Adoptium\jre-21.0.12.101-hotspot\bin\java.exe"
$jar  = "D:\komga\komga-1.28.1.jar"

# Stop existing instance if running (task restart scenario)
Get-CimInstance Win32_Process -Filter "Name='java.exe'" |
    Where-Object { $_.CommandLine -like "*komga-1.28.1.jar*" } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Start-Process -FilePath $java -ArgumentList @(
    "-Xmx2g",
    "-jar", $jar,
    "--komga.config-dir=D:\komga\config",
    "--server.tomcat.accesslog.enabled=true",
    "--server.tomcat.basedir=D:\komga\config\tomcat",
    "--logging.file.name=D:\komga\config\logs\komga-console.log"
) -WindowStyle Hidden
