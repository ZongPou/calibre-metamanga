# Komga 部署配置备忘（Windows 本机）

## 部署参数（2026-10-09）

| 项目 | 值 |
|------|-----|
| JRE | Temurin 21.0.12.1（winget 全局安装） |
| java.exe | `C:\Program Files\Eclipse Adoptium\jre-21.0.12.101-hotspot\bin\java.exe` |
| Komga | 1.28.1，jar 位于 `D:\komga\komga-1.28.1.jar` |
| 配置目录 | `D:\komga\config` |
| 端口 | 25600（监听 0.0.0.0/::） |
| 书库路径 | `D:\Comic`（calibre 书库，Komga 只读扫描） |
| 本机静态 IP | 192.168.5.100 |

## 开机自启

计划任务 `Komga Server`：SYSTEM 账户、系统启动时触发、无运行时限、电池模式可运行、失败重启 x3（间隔 1 分钟）。

注册命令（管理员）：

```
schtasks /Create /TN "Komga Server" /TR "powershell.exe -ExecutionPolicy Bypass -File D:\komga\start-komga.ps1" /SC ONSTART /RU SYSTEM /RL HIGHEST /F
```

注册后需修正默认设置（schtasks 默认 72h 时限 + 电池停止），见 `setup-admin.ps1`。

## 防火墙

```
New-NetFirewallRule -DisplayName "Komga" -Direction Inbound -Protocol TCP -LocalPort 25600 -Action Allow
```

## OPDS 端点（重点：路径必须带 /catalog）

- OPDS v1.2：`http://192.168.5.100:25600/opds/v1.2/catalog` ← 可达阅读器使用此地址
- OPDS v2：`http://192.168.5.100:25600/opds/v2/catalog`
- **`/opds/v1` 不存在**（认证前统一 401，认证后 404，易误判为权限问题）

## 启动脚本

`start-komga.ps1`：java.exe 写死完整路径（SYSTEM 不继承用户 PATH）；含同名旧实例清理；开启 Tomcat 访问日志（`D:\komga\config\tomcat\logs\`）与日志落盘（`D:\komga\config\logs\komga-console.log`）。

## 注意事项

- `.ps1` 含中文时必须带 BOM 保存，否则 PowerShell 5.1 按 GBK 解析报语法错误（本目录脚本为纯英文规避）
- 排查连接问题先看访问日志，能区分"未到达"（无记录）/"认证失败"（401）/"路径错误"（404）
