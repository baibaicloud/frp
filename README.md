# 重要声明，本开源基于https://github.com/fatedier/frp，在原本基础功能上添加认证相关功能
# 基于v0.30.0 进行修改，git url https://github.com/fatedier/frp/tree/v0.30.0
# build windown
```
cd frp根路径
gmake

在64位下编译32位
set GOARCH=386
gmake
```

# 扩展功能说明
# 1. 客户端token认证
**功能场景说明**
客户端预先配置一个token，在客户端启动连接到服务端时，服务端会验证客户端的token是否合法，如果不合法则无法连接成功，跟官方的token、OIDC认证一样，只不过这里是基于简单http认证，方便自家系统进行对接认证。

**客户端配置**
```
[common]
server_addr = 192.168.0.100
server_port = 8100
pritoken = 2b33386cb6d14ab7b5f6738f7fc1704c
```

**服务端配置**
```
[common]
bind_addr = 0.0.0.0
bind_port = 7000
token_auth_url = http://127.0.0.1:8080/tunnel/token/check?token=
# port_check_url 后续会用到
port_check_url = http://127.0.0.1:8080/tunnel/port/check
```

**验证流程**
1. 客户端预先写入[pritoken]值
2. 启动客户端，让客户端连接到服务端
3. 服务端收到客户端的连接，此时服务端会调用[token_auth_url]的url进行验证,是get请求，验证的完整url是http://127.0.0.1:8080/tunnel/token/check?token=2b33386cb6d14ab7b5f6738f7fc1704c
4. http://127.0.0.1:8080/tunnel/token/check?token=2b33386cb6d14ab7b5f6738f7fc1704c 的返回内容是字符串 ok 表示通过，非 ok 字符串都认证失败，认证失败客户端无法连接成功。

**认证方式优点**
token_auth_url 的url随意修改,方便接入自家系统.

# 2. 客户端远程端口映射验证
**功能场景说明**
不希望客户端随意指定远程端口，比如客户端配置了[remote_port = 9999]，frps服务器会开启9999端口监听。这个机制是比较危险的，如果有客户端恶意指定远程端口，frps根本无法控制，而且frps做不到指定客户端只能指定映射指定的远程端口。
比如：A客户端只能配置[remote_port = 9999]，配置[remote_port = 8888]无效。
这里frps就要就要验证A客户端有没有权限配置9999、8888等远程端口。

**客户端配置**
```
# 此名字很重要，后续会传到服务端，代表1256252144558809089代理映射了remote_port=9999的远程端口
[1256252144558809089]
type = tcp
local_ip = 192.168.0.100
local_port = 80
remote_port = 9999
```

**服务端配置**
```
[common]
bind_port = 8100
token_auth_url = http://127.0.0.1:8080/tunnel/token/check?token=

# 此url用来验证客户端[1256252144558809089]的代理信息是否合法
port_check_url = http://127.0.0.1:8080/tunnel/port/check
```

**验证流程**
1. 客户端预先写入[1256252144558809089]代理名称和[remote_port]远程端口信息
2. 启动客户端，让客户端连接到服务端
3. 服务端收到客户端的连接，此时服务端会调用[port_check_url]的url进行验证,是get请求，验证的完整url是http://127.0.0.1:8080/tunnel/port/check?proxyname=1256252144558809089&remoteport=9999
4. http://127.0.0.1:8080/tunnel/port/check?proxyname=1256252144558809089&remoteport=9999 的返回内容是字符串 ok 表示通过，非 ok 字符串都认证失败，认证失败端口无法代理成功。

**认证方式优点**
1. port_check_url 的url随意修改,方便接入自家系统.
2. 客户端的代理名称可自行修改，比如会加一些认证信息，再配合调用http协议进行验证，很容易进行控制指定的客户端只能指定对应的远程端口。

# frp的详细配置请参照官方 README_zh.md

# docker build images
```
docker build -t registry.cn-hangzhou.aliyuncs.com/baibaicloud/baibai-frp:1.0.0 .
```
