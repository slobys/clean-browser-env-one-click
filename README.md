# Clean Browser Env One-Click

一键创建“干净、可丢弃、不污染主浏览器资料”的临时浏览器环境。

这个项目适合电脑环境测试、网页测试、客服排障前的浏览器环境隔离。它不会伪造设备指纹，不会绕过平台风控，不会批量注册账号，也不能保证 IP 信誉“干净”。

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
- 支持打开本地指纹测试页，查看当前电脑和浏览器暴露的常见环境信号
- 不会删除你的桌面、文档、下载、照片、微信、浏览器真实数据

## 它不做什么

- 不保证注册成功
- 不判断或美化 IP 信誉
- 不伪造硬件、系统、浏览器指纹
- 不向真实网站注入指纹修改或伪装代码
- 不自动填写验证码、手机号、邮箱
- 不做批量注册、养号或平台风控绕过

## 命令

macOS / Linux：

```sh
sh scripts/unix/clean-browser-env.sh start
sh scripts/unix/clean-browser-env.sh start --browser chrome --url https://web.telegram.org/
sh scripts/unix/clean-browser-env.sh fingerprint
sh scripts/unix/clean-browser-env.sh fingerprint --simulate
sh scripts/unix/clean-browser-env.sh doctor
sh scripts/unix/clean-browser-env.sh list
sh scripts/unix/clean-browser-env.sh cleanup
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Browser Chrome -Url https://web.telegram.org/
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Fingerprint
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Fingerprint -Simulate
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Doctor
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action List
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Cleanup
```

## 指纹测试页

`fingerprint` 命令会用一次性浏览器 Profile 打开本地页面 `assets/fingerprint-test.html`。这个页面会显示：

- User-Agent、浏览器平台、语言、时区
- 屏幕尺寸、像素比、颜色深度
- CPU 线程数、内存提示、触摸点数量
- Cookie / LocalStorage / IndexedDB 可用性
- Canvas、Audio、WebGL 摘要
- 一个本地生成的摘要哈希，方便你对比不同电脑或不同 Profile

这个页面只在本地运行，不上传数据，也不修改真实网站看到的指纹。

打开模拟面板：

```sh
sh scripts/unix/clean-browser-env.sh fingerprint --simulate
```

Windows：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\windows\Start-CleanBrowserEnv.ps1 -Action Fingerprint -Simulate
```

模拟面板可以改 User-Agent、Platform、Language、Timezone、屏幕尺寸、CPU 线程、内存提示、触摸点、WebGL vendor/renderer。它只改变本地页面生成的“模拟报告”和摘要哈希，方便你对比参数变化后的报告形态；它不会改浏览器真实指纹，也不会影响真实网站。

## 推荐流程

1. 运行 `doctor` 确认本机浏览器状态。
2. 运行 `fingerprint` 记录当前电脑和浏览器暴露的环境信号。
3. 运行 `start` 启动一次性浏览器 Profile 做网页测试。
4. 测试完成后按需保留或清理这个临时 Profile。

## 安全说明

本工具默认只写入 `~/CleanBrowserEnv`。清理命令也只删除 `~/CleanBrowserEnv/profiles/session-*`，不会主动清理系统浏览器缓存或用户文件。

如果你需要更强隔离，建议使用全新虚拟机或系统自带的新用户账户。本工具的定位是轻量隔离，不是完整虚拟化。
