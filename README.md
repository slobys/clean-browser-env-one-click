# Clean Browser Env One-Click

一键创建“干净、可丢弃、不污染主浏览器资料”的临时浏览器环境。

这个项目适合账号注册、网页测试、客服排障前的浏览器环境隔离。它不会伪造设备指纹，不会绕过平台风控，不会批量注册账号，也不能保证 IP 信誉“干净”。

## 一键使用

macOS / Linux：

```sh
curl -fsSL https://raw.githubusercontent.com/slobys/clean-browser-env-one-click/main/bootstrap.sh -o /tmp/clean-browser-env.sh && sh /tmp/clean-browser-env.sh
```

国内 Gitee：

```sh
curl -fsSL https://gitee.com/naiyou88/clean-browser-env-one-click/raw/main/bootstrap.sh -o /tmp/clean-browser-env.sh && sh /tmp/clean-browser-env.sh
```

Windows PowerShell：

```powershell
iwr -UseBasicParsing https://raw.githubusercontent.com/slobys/clean-browser-env-one-click/main/scripts/windows/Start-CleanBrowserEnv.ps1 -OutFile $env:TEMP\Start-CleanBrowserEnv.ps1; powershell -ExecutionPolicy Bypass -File $env:TEMP\Start-CleanBrowserEnv.ps1
```

完整项目方式：

```sh
git clone https://github.com/slobys/clean-browser-env-one-click.git
cd clean-browser-env-one-click
sh bootstrap.sh
```

## 它做什么

- 创建独立浏览器 Profile：默认路径为 `~/CleanBrowserEnv/profiles/session-*`
- 自动寻找 Chrome / Edge / Firefox
- 启动浏览器时禁用同步和扩展，避免污染你的真实浏览器资料
- 支持列出和清理本工具创建的临时 Profile
- 不会删除你的桌面、文档、下载、照片、微信、浏览器真实数据

## 它不做什么

- 不保证注册成功
- 不判断或美化 IP 信誉
- 不伪造硬件、系统、浏览器指纹
- 不自动填写验证码、手机号、邮箱
- 不做批量注册、养号或平台风控绕过

## 命令

macOS / Linux：

```sh
sh scripts/unix/clean-browser-env.sh start
sh scripts/unix/clean-browser-env.sh start --browser chrome --url https://web.telegram.org/
sh scripts/unix/clean-browser-env.sh doctor
sh scripts/unix/clean-browser-env.sh list
sh scripts/unix/clean-browser-env.sh cleanup
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Browser Chrome -Url https://web.telegram.org/
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Doctor
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action List
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Cleanup
```

## 推荐流程

1. 确认网络来源合法、稳定、可信。
2. 运行本工具启动一次性浏览器 Profile。
3. 手动打开注册页面并正常完成注册。
4. 注册完成后按需保留或清理这个临时 Profile。

## 安全说明

本工具默认只写入 `~/CleanBrowserEnv`。清理命令也只删除 `~/CleanBrowserEnv/profiles/session-*`，不会主动清理系统浏览器缓存或用户文件。

如果你需要更强隔离，建议使用全新虚拟机或系统自带的新用户账户。本工具的定位是轻量隔离，不是完整虚拟化。

