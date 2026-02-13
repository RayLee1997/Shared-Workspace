# CentOS 9 配置 Cloudflare Tunnel 远程访问家庭主机服务

## 概述

本教程指导你在 CentOS 9 家庭主机上配置 Cloudflare Tunnel，实现：
- 无需公网 IP，通过域名访问家庭主机上的本地服务（4096 端口）
- 配置邮箱验证码登录的安全访问策略
- 7x24 小时稳定服务

## 前置条件

- CentOS 9 系统的家庭主机
- 一个已托管到 Cloudflare 的域名
- Cloudflare 账号（免费账号即可）
- 本地服务运行在 4096 端口

## 架构说明

```
用户手机(5G) --> Cloudflare 边缘节点 --> Cloudflare Tunnel --> 家庭主机:4096
                     |
              Cloudflare Access
              (邮箱OTP验证)
```

---

## 第一部分：Cloudflare 账号准备

### 步骤 1.1：注册 Cloudflare 账号

1. 访问 https://dash.cloudflare.com/sign-up
2. 使用邮箱注册账号
3. 验证邮箱

**验证方法**：登录 Cloudflare Dashboard 能正常访问

### 步骤 1.2：添加域名到 Cloudflare

1. 登录 Cloudflare Dashboard
2. 点击 "Add a Site"
3. 输入你的域名
4. 选择 Free 计划
5. Cloudflare 会提供两个 Nameserver 地址，如：
   - `xxx.ns.cloudflare.com`
   - `yyy.ns.cloudflare.com`
6. 到你的域名注册商（阿里云、腾讯云等）修改 DNS 服务器为 Cloudflare 提供的地址

**验证方法**：
```bash
# 在任意机器上执行，检查 NS 记录是否已变更
nslookup -type=NS yourdomain.com
```
等待 DNS 生效（通常 24-72 小时，部分情况几分钟内生效）

### 步骤 1.3：启用 Zero Trust（免费版）

1. 在 Cloudflare Dashboard 左侧菜单点击 "Zero Trust"
2. 如果是首次使用，需要创建一个 team name（如：`myteam`）
3. 选择 Free 计划（需要绑定支付方式但不会扣费）

**验证方法**：能够进入 Zero Trust Dashboard（https://one.dash.cloudflare.com）

---

## 第二部分：CentOS 9 安装 cloudflared

### 步骤 2.1：添加 Cloudflare 官方仓库

```bash
# 安装 dnf-plugins-core（如果没有）
sudo dnf install -y dnf-plugins-core

# 添加 Cloudflare 官方仓库
sudo dnf config-manager --add-repo https://pkg.cloudflare.com/cloudflared.repo
```

**验证方法**：
```bash
cat /etc/yum.repos.d/cloudflared.repo
# 应该能看到仓库配置内容
```

### 步骤 2.2：安装 cloudflared

```bash
sudo dnf install -y cloudflared
```

**验证方法**：
```bash
cloudflared --version
# 应该输出类似：cloudflared version 2024.x.x
```

### 备选方案：手动下载安装

如果仓库方式失败，可以手动下载：

```bash
# 下载最新版本
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-x86_64.rpm

# 安装
sudo dnf install -y ./cloudflared-linux-x86_64.rpm

# 验证
cloudflared --version
```

---

## 第三部分：创建 Cloudflare Tunnel（推荐 Dashboard 方式）

### 步骤 3.1：在 Dashboard 创建 Tunnel

1. 登录 Zero Trust Dashboard：https://one.dash.cloudflare.com
2. 左侧菜单选择 **Networks** > **Tunnels**
3. 点击 **Create a tunnel**
4. 选择 **Cloudflared** 作为 connector
5. 输入 Tunnel 名称，如：`home-server`
6. 点击 **Save tunnel**

### 步骤 3.2：获取安装命令和 Token

创建 Tunnel 后，Dashboard 会显示安装命令，格式如下：

```bash
sudo cloudflared service install <YOUR_TUNNEL_TOKEN>
```

**重要**：复制这个完整命令，包含 Token

### 步骤 3.3：在 CentOS 9 上执行安装命令

```bash
# 执行从 Dashboard 复制的命令
sudo cloudflared service install eyJhIjoixxx...（你的 Token）
```

这个命令会：
- 创建 systemd 服务文件 `/etc/systemd/system/cloudflared.service`
- 自动启动 cloudflared 服务
- 设置开机自启

**验证方法**：
```bash
# 检查服务状态
sudo systemctl status cloudflared

# 应该显示 Active: active (running)
```

### 步骤 3.4：配置 Public Hostname（映射本地服务）

1. 回到 Zero Trust Dashboard > Networks > Tunnels
2. 点击刚创建的 Tunnel 名称
3. 选择 **Public Hostname** 标签
4. 点击 **Add a public hostname**
5. 填写配置：

| 字段 | 值 | 说明 |
|------|-----|------|
| Subdomain | `app`（或你喜欢的名称） | 子域名 |
| Domain | 选择你的域名 | 如 `yourdomain.com` |
| Path | 留空 | - |
| Type | HTTP | 选择 HTTP（Cloudflare 会自动提供 HTTPS） |
| URL | `localhost:4096` | 本地服务地址和端口 |

6. 点击 **Save hostname**

**验证方法**：
```bash
# 检查 DNS 记录是否已创建
nslookup app.yourdomain.com

# 从外网访问测试（可以用手机 5G 网络）
curl -I https://app.yourdomain.com
```

---

## 第四部分：配置 Cloudflare Access 安全策略（邮箱验证码）

### 步骤 4.1：启用 One-time PIN 登录方式

1. 登录 Zero Trust Dashboard
2. 左侧菜单选择 **Settings** > **Authentication**
3. 在 **Login methods** 部分，点击 **Add new**
4. 选择 **One-time PIN**
5. 点击 **Save**

**验证方法**：在 Login methods 列表中能看到 "One-time PIN"

### 步骤 4.2：创建 Access Application

1. 左侧菜单选择 **Access** > **Applications**
2. 点击 **Add an application**
3. 选择 **Self-hosted**
4. 填写配置：

**Application Configuration**:
| 字段 | 值 |
|------|-----|
| Application name | `Home Service`（或你喜欢的名称） |
| Session Duration | `24 hours`（可根据需要调整） |
| Application domain | `app.yourdomain.com`（你配置的域名） |

5. 点击 **Next**

### 步骤 4.3：配置 Access Policy（访问策略）

**Policy Configuration**:
| 字段 | 值 |
|------|-----|
| Policy name | `Email Access Policy` |
| Action | Allow |

**Configure rules** (Include 规则):

选择 **Emails**，然后添加允许访问的邮箱地址：
- `your-email@example.com`
- 可以添加多个邮箱

或者选择 **Emails ending in** 允许整个域的邮箱：
- `@yourdomain.com`

6. 点击 **Next**
7. 在 Setup 页面保持默认设置
8. 点击 **Add application**

**验证方法**：
1. 打开无痕浏览器窗口
2. 访问 `https://app.yourdomain.com`
3. 应该看到 Cloudflare Access 登录页面
4. 输入授权邮箱
5. 检查邮箱收到验证码
6. 输入验证码后能正常访问服务

---

## 第五部分：配置服务稳定性（7x24 运行）

### 步骤 5.1：确认 systemd 服务配置

```bash
# 查看服务文件内容
sudo cat /etc/systemd/system/cloudflared.service
```

应该包含类似内容：
```ini
[Unit]
Description=cloudflared
After=network.target

[Service]
TimeoutStartSec=0
Type=notify
ExecStart=/usr/bin/cloudflared --no-autoupdate tunnel run --token <TOKEN>
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 步骤 5.2：优化 systemd 配置（可选）

如果需要更强的重启策略，可以编辑服务文件：

```bash
sudo systemctl edit cloudflared
```

添加以下内容：
```ini
[Service]
Restart=always
RestartSec=10
StartLimitIntervalSec=0
```

保存后重载配置：
```bash
sudo systemctl daemon-reload
sudo systemctl restart cloudflared
```

### 步骤 5.3：设置开机自启

```bash
sudo systemctl enable cloudflared
```

**验证方法**：
```bash
# 检查是否设置为开机启动
sudo systemctl is-enabled cloudflared
# 应该输出：enabled

# 模拟重启测试
sudo systemctl restart cloudflared
sudo systemctl status cloudflared
```

### 步骤 5.4：配置日志（可选）

查看 cloudflared 日志：
```bash
sudo journalctl -u cloudflared -f
```

配置日志文件：
```bash
# 编辑服务配置
sudo systemctl edit cloudflared
```

添加：
```ini
[Service]
ExecStart=
ExecStart=/usr/bin/cloudflared --no-autoupdate --loglevel info --logfile /var/log/cloudflared/cloudflared.log tunnel run --token <TOKEN>
```

创建日志目录：
```bash
sudo mkdir -p /var/log/cloudflared
sudo systemctl daemon-reload
sudo systemctl restart cloudflared
```

---

## 第六部分：防火墙配置

### 步骤 6.1：Cloudflared 出站连接

Cloudflared 只需要出站连接，不需要开放入站端口。

确保以下出站端口可用：
- **TCP 443** (HTTPS)
- **UDP 7844** (QUIC 协议，可选但推荐)

```bash
# CentOS 9 使用 firewalld，默认允许出站连接
# 如果有限制，执行以下命令
sudo firewall-cmd --permanent --add-port=7844/udp
sudo firewall-cmd --reload
```

### 步骤 6.2：验证网络连通性

```bash
# 测试 cloudflared 连接
cloudflared tunnel --edge-ip-version auto --post-quantum --protocol auto connectivity-check
```

---

## 第七部分：完整验证流程

### 验证清单

| 检查项 | 命令/方法 | 预期结果 |
|--------|-----------|----------|
| cloudflared 版本 | `cloudflared --version` | 显示版本号 |
| 服务状态 | `sudo systemctl status cloudflared` | Active: active (running) |
| 开机自启 | `sudo systemctl is-enabled cloudflared` | enabled |
| DNS 解析 | `nslookup app.yourdomain.com` | 返回 Cloudflare IP |
| Dashboard 状态 | Zero Trust > Tunnels | 显示 HEALTHY |
| Access 登录 | 访问 https://app.yourdomain.com | 显示邮箱登录页面 |
| 邮件收发 | 输入授权邮箱 | 收到 6 位验证码 |
| 服务访问 | 输入验证码后 | 正常访问本地服务 |

### 从手机测试

1. 关闭手机 WiFi，使用 5G 移动网络
2. 在浏览器访问 `https://app.yourdomain.com`
3. 输入授权的邮箱地址
4. 查收验证码邮件
5. 输入验证码完成登录
6. 应该能正常访问家庭主机上的服务

---

## 故障排除

### 问题 1：cloudflared 服务启动失败

```bash
# 查看详细日志
sudo journalctl -u cloudflared -n 50 --no-pager

# 常见原因：
# 1. Token 无效 - 重新从 Dashboard 获取
# 2. 网络问题 - 检查出站连接
# 3. 权限问题 - 确保以 root 运行
```

### 问题 2：Tunnel 状态显示 DEGRADED

```bash
# 可能原因：部分连接失败
# 解决方法：等待几分钟自动恢复，或重启服务
sudo systemctl restart cloudflared
```

### 问题 3：收不到验证码邮件

1. 检查垃圾邮件文件夹
2. 确认邮箱地址在 Access Policy 的 Include 规则中
3. 将 `noreply@notify.cloudflare.com` 添加到邮箱白名单

### 问题 4：国内访问慢或不稳定

这是 Cloudflare 免费版的已知限制，因为节点在海外。
- 预期延迟：100-200ms
- 可能偶尔断流
- 对于轻量级使用（每天 1000 次请求）可以接受

优化建议：
- 考虑使用 Cloudflare Argo（付费）减少延迟
- 避免传输大文件

---

## 常用命令速查

```bash
# 服务管理
sudo systemctl start cloudflared    # 启动
sudo systemctl stop cloudflared     # 停止
sudo systemctl restart cloudflared  # 重启
sudo systemctl status cloudflared   # 状态

# 日志查看
sudo journalctl -u cloudflared -f   # 实时日志
sudo journalctl -u cloudflared -n 100  # 最近 100 行

# 版本更新
sudo dnf update cloudflared

# 连接测试
cloudflared tunnel --edge-ip-version auto connectivity-check
```

---

## 安全建议

1. **定期更新 cloudflared**：`sudo dnf update cloudflared`
2. **限制授权邮箱**：只添加必要的邮箱地址
3. **监控访问日志**：在 Zero Trust Dashboard > Logs 查看访问记录
4. **设置合理的 Session Duration**：避免过长的会话有效期
5. **考虑添加额外的 Access 规则**：如地理位置限制

---

## 附录：配置文件位置

| 文件 | 路径 |
|------|------|
| systemd 服务文件 | `/etc/systemd/system/cloudflared.service` |
| cloudflared 二进制 | `/usr/bin/cloudflared` |
| 日志（如配置） | `/var/log/cloudflared/cloudflared.log` |

---

## 参考资料

- [Cloudflare Tunnel 官方文档](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/)
- [Cloudflare Access 官方文档](https://developers.cloudflare.com/cloudflare-one/applications/)
- [One-time PIN 配置](https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/one-time-pin/)
- [cloudflared GitHub](https://github.com/cloudflare/cloudflared)

---

*文档创建日期：2026-01-26*
*适用环境：CentOS 9 Stream*
