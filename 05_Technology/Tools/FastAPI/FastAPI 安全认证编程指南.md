# FastAPI 安全认证编程指南

> **面向 AI Agent 的自动化编程参考手册**
> 基于 FastAPI 官方文档深度调研 · 2026-02

---

## 目录

1. [安全架构总览](#1-安全架构总览)
2. [依赖注入安全体系](#2-依赖注入安全体系)
3. [方案一：OAuth2 Password Bearer（推荐）](#3-方案一oauth2-password-bearer推荐)
4. [方案二：OAuth2 + JWT 令牌（生产级）](#4-方案二oauth2--jwt-令牌生产级)
5. [方案三：OAuth2 Scopes 细粒度权限控制](#5-方案三oauth2-scopes-细粒度权限控制)
6. [方案四：HTTP Basic Auth](#6-方案四http-basic-auth)
7. [方案五：API Key 认证](#7-方案五api-key-认证)
8. [CORS 跨域安全配置](#8-cors-跨域安全配置)
9. [安全方案选型决策树](#9-安全方案选型决策树)
10. [AI Agent 编程清单](#10-ai-agent-编程清单)

---

## 1. 安全架构总览

FastAPI 的安全体系基于 **OpenAPI 标准**，通过依赖注入（Dependency Injection）实现认证与授权的解耦。所有安全工具类均继承自 `SecurityBase`，自动集成到 OpenAPI 文档 (`/docs`) 中。

### 1.1 OpenAPI 支持的安全方案

| 方案类型 | FastAPI 类 | 传输方式 | 适用场景 |
|---------|-----------|---------|---------|
| OAuth2 Password | `OAuth2PasswordBearer` | `Authorization: Bearer <token>` | 用户名密码登录 → Token |
| HTTP Bearer | `HTTPBearer` | `Authorization: Bearer <token>` | 纯 Token 验证 |
| HTTP Basic | `HTTPBasic` | `Authorization: Basic <base64>` | 简单管理后台 |
| API Key (Header) | `APIKeyHeader` | 自定义 Header | 服务间调用 |
| API Key (Query) | `APIKeyQuery` | URL 查询参数 | 简单 API 调用 |
| API Key (Cookie) | `APIKeyCookie` | Cookie | 浏览器会话 |

### 1.2 核心依赖包

```bash
# 基础安装
pip install fastapi uvicorn

# JWT 令牌支持
pip install pyjwt

# 密码哈希（官方推荐）
pip install "pwdlib[argon2]"

# 完整安装
pip install fastapi uvicorn pyjwt "pwdlib[argon2]"
```

### 1.3 关键导入一览

```python
# 安全方案类
from fastapi.security import (
    OAuth2PasswordBearer,       # OAuth2 密码承载令牌
    OAuth2PasswordRequestForm,  # 登录表单
    HTTPBasic,                  # HTTP 基础认证
    HTTPBasicCredentials,       # 基础认证凭据
    HTTPBearer,                 # HTTP Bearer 令牌
    SecurityScopes,             # OAuth2 作用域
    APIKeyHeader,               # API Key (Header)
    APIKeyQuery,                # API Key (Query)
    APIKeyCookie,               # API Key (Cookie)
)

# 依赖注入
from fastapi import Depends, Security

# JWT 相关
import jwt
from jwt.exceptions import InvalidTokenError

# 密码哈希
from pwdlib import PasswordHash
```

---

## 2. 依赖注入安全体系

FastAPI 安全的核心机制是 **依赖注入**。理解 `Depends()` 和 `Security()` 是掌握所有安全方案的前提。

### 2.1 `Depends()` vs `Security()`

| 特性 | `Depends()` | `Security()` |
|-----|------------|-------------|
| 用途 | 通用依赖注入 | 安全专用依赖注入 |
| Scopes 支持 | ❌ 不支持 | ✅ 支持 `scopes` 参数 |
| OpenAPI 集成 | 基础集成 | 完整安全方案集成 |
| 使用场景 | 获取当前用户 | 需要权限检查的端点 |

```python
# Depends() — 不传递 scopes
@app.get("/users/me")
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)]
):
    return current_user

# Security() — 传递 scopes 进行权限控制
@app.get("/users/me/items/")
async def read_own_items(
    current_user: Annotated[User, Security(get_current_active_user, scopes=["items"])]
):
    return [{"item_id": "Foo", "owner": current_user.username}]
```

### 2.2 依赖链模式

FastAPI 安全依赖通常形成 **链式结构**：

```
路由端点
  └─ get_current_active_user (检查用户是否活跃)
       └─ get_current_user (解码 Token，查找用户)
            └─ oauth2_scheme (提取 Authorization Header 中的 Token)
```

---

## 3. 方案一：OAuth2 Password Bearer（推荐）

> **官方文档**: <https://fastapi.tiangolo.com/tutorial/security/simple-oauth2/>

这是 FastAPI 安全教程的入门方案，适合快速原型开发。

### 3.1 完整代码

```python
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel

# ============================================================
# 1. 模拟数据库
# ============================================================
fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "fakehashedsecret",
        "disabled": False,
    },
    "alice": {
        "username": "alice",
        "full_name": "Alice Wonderson",
        "email": "alice@example.com",
        "hashed_password": "fakehashedsecret2",
        "disabled": True,
    },
}

# ============================================================
# 2. Pydantic 模型
# ============================================================
class User(BaseModel):
    username: str
    email: str | None = None
    full_name: str | None = None
    disabled: bool | None = None

class UserInDB(User):
    hashed_password: str

# ============================================================
# 3. 安全方案实例化
# ============================================================
#   tokenUrl: 客户端发送凭据以获取 Token 的端点路径
#   该实例会自动在 OpenAPI 文档中注册安全方案
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI()

# ============================================================
# 4. 工具函数
# ============================================================
def fake_hash_password(password: str):
    """模拟密码哈希（仅用于演示，生产环境请用 pwdlib）"""
    return "fakehashed" + password

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)

def fake_decode_token(token):
    """模拟 Token 解码（仅用于演示，生产环境请用 JWT）"""
    user = get_user(fake_users_db, token)
    return user

# ============================================================
# 5. 安全依赖函数
# ============================================================
async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)]
):
    """从 Token 中提取并验证用户"""
    user = fake_decode_token(token)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user

async def get_current_active_user(
    current_user: Annotated[User, Depends(get_current_user)]
):
    """检查用户是否激活"""
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# ============================================================
# 6. 路由端点
# ============================================================
@app.post("/token")
async def login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    """登录端点：验证凭据，返回 Token"""
    user_dict = fake_users_db.get(form_data.username)
    if not user_dict:
        raise HTTPException(
            status_code=400, detail="Incorrect username or password"
        )
    user = UserInDB(**user_dict)
    hashed_password = fake_hash_password(form_data.password)
    if not hashed_password == user.hashed_password:
        raise HTTPException(
            status_code=400, detail="Incorrect username or password"
        )
    return {"access_token": user.username, "token_type": "bearer"}

@app.get("/users/me")
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)]
):
    """获取当前用户信息（受保护端点）"""
    return current_user
```

### 3.2 关键要点

| 组件 | 说明 |
|------|------|
| `OAuth2PasswordBearer(tokenUrl="token")` | 声明 Token 获取端点，自动注册到 OpenAPI |
| `OAuth2PasswordRequestForm` | 标准表单字段：`username`、`password`、`scope`、`grant_type` |
| `Depends(oauth2_scheme)` | 自动从 `Authorization: Bearer <token>` 提取 Token |
| HTTP 401 响应 | 必须包含 `headers={"WWW-Authenticate": "Bearer"}` |

> [!WARNING]
> 此方案中 Token 就是用户名本身，**没有真正的安全性**。仅用于理解流程，生产环境必须使用 JWT。

---

## 4. 方案二：OAuth2 + JWT 令牌（生产级）

> **官方文档**: <https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/>

这是 FastAPI 官方推荐的 **生产级认证方案**，使用 JWT 令牌和安全密码哈希。

### 4.1 完整代码

```python
from datetime import datetime, timedelta, timezone
from typing import Annotated

import jwt
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jwt.exceptions import InvalidTokenError
from pwdlib import PasswordHash
from pydantic import BaseModel

# ============================================================
# 1. 安全配置常量
# ============================================================
# 生成方法: openssl rand -hex 32
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# ============================================================
# 2. 模拟数据库
# ============================================================
fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "$argon2id$v=19$m=65536,t=3,p=4$wagCPXjifgvUFBzq4hqe3w$CYaIb8sB+wtD+Vu/P4uod1+Qof8h+1g7bbDlBID48Rc",
        "disabled": False,
    }
}

# ============================================================
# 3. Pydantic 模型
# ============================================================
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None

class User(BaseModel):
    username: str
    email: str | None = None
    full_name: str | None = None
    disabled: bool | None = None

class UserInDB(User):
    hashed_password: str

# ============================================================
# 4. 密码哈希与安全方案
# ============================================================
# Argon2id: 抗 GPU/ASIC 攻击，推荐参数 (m=65536, t=3, p=4)
password_hash = PasswordHash.recommended()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

app = FastAPI()

# ============================================================
# 5. 密码工具函数
# ============================================================
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """验证明文密码与哈希是否匹配"""
    return password_hash.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """对明文密码进行哈希"""
    return password_hash.hash(password)

# ============================================================
# 6. 用户查询与认证
# ============================================================
def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)

def authenticate_user(fake_db, username: str, password: str):
    """认证用户：查找用户 → 验证密码"""
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

# ============================================================
# 7. JWT 令牌操作
# ============================================================
def create_access_token(
    data: dict, expires_delta: timedelta | None = None
) -> str:
    """
    创建 JWT 访问令牌
    - data: 载荷数据（必须包含 "sub" 字段存放用户标识）
    - expires_delta: 过期时间增量，默认 15 分钟
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# ============================================================
# 8. 安全依赖函数
# ============================================================
async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)]
):
    """
    解码 JWT Token → 验证 → 返回用户对象
    Token 验证流程:
      1. 从 Authorization Header 提取 Token
      2. 用 SECRET_KEY + HS256 解码 JWT
      3. 验证 Token 未过期
      4. 从 "sub" claim 提取 username
      5. 查找用户是否存在
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        token_data = TokenData(username=username)
    except InvalidTokenError:
        raise credentials_exception

    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception
    return user

async def get_current_active_user(
    current_user: Annotated[User, Depends(get_current_user)]
):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# ============================================================
# 9. 路由端点
# ============================================================
@app.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
) -> Token:
    """登录端点：验证凭据 → 生成 JWT → 返回 Token"""
    user = authenticate_user(
        fake_users_db, form_data.username, form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=access_token_expires,
    )
    return Token(access_token=access_token, token_type="bearer")

@app.get("/users/me/")
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)]
) -> User:
    return current_user

@app.get("/users/me/items/")
async def read_own_items(
    current_user: Annotated[User, Depends(get_current_active_user)]
):
    return [{"item_id": "Foo", "owner": current_user.username}]
```

### 4.2 JWT 令牌结构

```
Header.Payload.Signature
```

| 部分 | 内容 | 示例 |
|------|------|------|
| Header | `{"alg": "HS256", "typ": "JWT"}` | Base64 编码 |
| Payload | `{"sub": "johndoe", "exp": 1700000000}` | 包含 claims |
| Signature | HMAC-SHA256 签名 | 防篡改 |

**JWT Payload 标准 Claims：**

| Claim | 含义 | FastAPI 用法 |
|-------|------|-------------|
| `sub` | Subject（主题） | 存放 username 或 user_id |
| `exp` | Expiration（过期时间） | UTC 时间戳 |
| `scope` | 作用域 | 空格分隔的权限字符串 |

### 4.3 密码哈希对比

| 哈希算法 | 包 | 安全等级 | FastAPI 官方推荐 |
|---------|---|---------|----------------|
| **Argon2id** | `pwdlib[argon2]` | ⭐⭐⭐⭐⭐ | ✅ 当前推荐 |
| bcrypt | `pwdlib[bcrypt]` | ⭐⭐⭐⭐ | ✅ 可选 |
| ~~passlib~~ | ~~`passlib[bcrypt]`~~ | ⭐⭐⭐⭐ | ❌ 已弃用 |

> [!IMPORTANT]
> FastAPI 官方已从 `passlib` 迁移到 `pwdlib`。新项目请直接使用 `pwdlib`。
> 安装命令：`pip install "pwdlib[argon2]"`

---

## 5. 方案三：OAuth2 Scopes 细粒度权限控制

> **官方文档**: <https://fastapi.tiangolo.com/advanced/security/oauth2-scopes/>

OAuth2 Scopes 在标准 JWT 认证基础上增加了 **细粒度权限控制**，适用于复杂的 RBAC 场景。

### 5.1 完整代码

```python
from datetime import datetime, timedelta, timezone
from typing import Annotated

import jwt
from fastapi import Depends, FastAPI, HTTPException, Security, status
from fastapi.security import (
    OAuth2PasswordBearer,
    OAuth2PasswordRequestForm,
    SecurityScopes,
)
from jwt.exceptions import InvalidTokenError
from pwdlib import PasswordHash
from pydantic import BaseModel, ValidationError

# ============================================================
# 安全配置
# ============================================================
SECRET_KEY = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "$argon2id$v=19$m=65536,t=3,p=4$wagCPXjifgvUFBzq4hqe3w$CYaIb8sB+wtD+Vu/P4uod1+Qof8h+1g7bbDlBID48Rc",
        "disabled": False,
    },
    "alice": {
        "username": "alice",
        "full_name": "Alice Chains",
        "email": "alicechains@example.com",
        "hashed_password": "$argon2id$v=19$m=65536,t=3,p=4$g2/AV1zwopqUntPKJavBFw$BwpRGDCyUHLvHICnwijyX8ROGoiUPwNKZ7915MeYfCE",
        "disabled": True,
    },
}

# ============================================================
# Pydantic 模型（扩展 scopes 字段）
# ============================================================
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None
    scopes: list[str] = []       # ← 新增：存储 Token 中的权限列表

class User(BaseModel):
    username: str
    email: str | None = None
    full_name: str | None = None
    disabled: bool | None = None

class UserInDB(User):
    hashed_password: str

# ============================================================
# 安全方案：在 OAuth2PasswordBearer 中声明可用 Scopes
# ============================================================
password_hash = PasswordHash.recommended()

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="token",
    scopes={                              # ← 声明系统支持的所有 Scopes
        "me": "Read information about the current user.",
        "items": "Read items.",
    },
)

app = FastAPI()

# ============================================================
# 工具函数（与方案二相同）
# ============================================================
def verify_password(plain_password, hashed_password):
    return password_hash.verify(plain_password, hashed_password)

def get_password_hash(password):
    return password_hash.hash(password)

def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)

def authenticate_user(fake_db, username: str, password: str):
    user = get_user(fake_db, username)
    if not user:
        return False
    if not verify_password(password, user.hashed_password):
        return False
    return user

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# ============================================================
# 核心：带 Scopes 验证的用户获取依赖
# ============================================================
async def get_current_user(
    security_scopes: SecurityScopes,     # ← 注入当前端点要求的 Scopes
    token: Annotated[str, Depends(oauth2_scheme)]
):
    """
    Token 验证 + Scopes 权限检查
    SecurityScopes 通过依赖链自动收集所有层级要求的 scopes
    """
    # 构建 WWW-Authenticate 响应头
    if security_scopes.scopes:
        authenticate_value = f'Bearer scope="{security_scopes.scope_str}"'
    else:
        authenticate_value = "Bearer"

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": authenticate_value},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        # 从 Token 中解析 scopes
        token_scopes = payload.get("scope", "").split()
        token_data = TokenData(scopes=token_scopes, username=username)
    except (InvalidTokenError, ValidationError):
        raise credentials_exception

    user = get_user(fake_users_db, username=token_data.username)
    if user is None:
        raise credentials_exception

    # 检查 Token 中的 scopes 是否覆盖端点要求的 scopes
    for scope in security_scopes.scopes:
        if scope not in token_data.scopes:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Not enough permissions",
                headers={"WWW-Authenticate": authenticate_value},
            )
    return user

# ============================================================
# 带 "me" scope 要求的活跃用户检查
# ============================================================
async def get_current_active_user(
    current_user: Annotated[
        User, Security(get_current_user, scopes=["me"])  # ← 要求 "me" scope
    ],
):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

# ============================================================
# 路由端点
# ============================================================
@app.post("/token")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
) -> Token:
    user = authenticate_user(
        fake_users_db, form_data.username, form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=400, detail="Incorrect username or password"
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={
            "sub": user.username,
            "scope": " ".join(form_data.scopes),  # ← 将请求的 scopes 写入 Token
        },
        expires_delta=access_token_expires,
    )
    return Token(access_token=access_token, token_type="bearer")

@app.get("/users/me/")
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)]
) -> User:
    """需要 "me" scope（通过 get_current_active_user 继承）"""
    return current_user

@app.get("/users/me/items/")
async def read_own_items(
    current_user: Annotated[
        User, Security(get_current_active_user, scopes=["items"])  # ← 额外要求 "items" scope
    ],
):
    """需要 "me" + "items" 两个 scopes"""
    return [{"item_id": "Foo", "owner": current_user.username}]

@app.get("/status/")
async def read_system_status(
    current_user: Annotated[User, Depends(get_current_user)]
):
    """仅需认证，不要求任何特定 scope"""
    return {"status": "ok"}
```

### 5.2 Scopes 依赖链传播机制

```
/users/me/items/ 端点
  └─ Security(get_current_active_user, scopes=["items"])   → 要求: items
       └─ Security(get_current_user, scopes=["me"])         → 要求: me
            └─ Depends(oauth2_scheme)                       → 提取 Token

SecurityScopes.scopes = ["items", "me"]  ← 自动合并所有层级的 scopes
SecurityScopes.scope_str = "items me"    ← 空格分隔的字符串形式
```

### 5.3 Scopes 关键概念速查

| 概念 | 说明 |
|------|------|
| `Security(dependency, scopes=[...])` | 替代 `Depends()`，声明端点所需的 scopes |
| `SecurityScopes` | 注入参数，包含当前依赖链中所有累积的 scopes |
| `SecurityScopes.scopes` | `list[str]`，所有要求的 scope 列表 |
| `SecurityScopes.scope_str` | `str`，空格分隔的 scope 字符串 |
| Token 中的 `scope` claim | 空格分隔的字符串，记录该 Token 被授予的权限 |

---

## 6. 方案四：HTTP Basic Auth

> **官方文档**: <https://fastapi.tiangolo.com/advanced/security/http-basic-auth/>

适用于简单的管理后台或内部工具，浏览器会自动弹出登录对话框。

### 6.1 完整代码

```python
import secrets
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import HTTPBasic, HTTPBasicCredentials

app = FastAPI()

security = HTTPBasic()

def get_current_username(
    credentials: Annotated[HTTPBasicCredentials, Depends(security)],
):
    """
    验证 HTTP Basic Auth 凭据
    使用 secrets.compare_digest() 防止时序攻击
    """
    current_username_bytes = credentials.username.encode("utf8")
    correct_username_bytes = b"stanleyjobson"
    is_correct_username = secrets.compare_digest(
        current_username_bytes, correct_username_bytes
    )

    current_password_bytes = credentials.password.encode("utf8")
    correct_password_bytes = b"swordfish"
    is_correct_password = secrets.compare_digest(
        current_password_bytes, correct_password_bytes
    )

    if not (is_correct_username and is_correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Basic"},  # ← 触发浏览器登录弹窗
        )
    return credentials.username

@app.get("/users/me")
def read_current_user(
    username: Annotated[str, Depends(get_current_username)]
):
    return {"username": username}
```

### 6.2 安全要点

> [!CAUTION]
> **时序攻击防护**：必须使用 `secrets.compare_digest()` 而非 `==`。
> 普通字符串比较 (`==`) 会在第一个不匹配的字符处停止，攻击者可以通过测量响应时间来逐字符猜测密码。
> `secrets.compare_digest()` 进行 **常数时间比较**，无论哪个位置不匹配，耗时都相同。

**另外注意**：即使用户名或密码错误，仍然需要对两者 **都** 进行 `compare_digest` 比较。这是为了确保无论输入是什么，函数的执行时间都是恒定的，避免攻击者通过时间差异推断出用户名是否正确。

---

## 7. 方案五：API Key 认证

FastAPI 提供三种 API Key 传输方式，适用于服务间通信或第三方 API 集成。

### 7.1 Header 方式（推荐）

```python
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import APIKeyHeader

app = FastAPI()

# 声明 API Key 从哪个 Header 中提取
api_key_header = APIKeyHeader(name="X-API-Key", auto_error=True)

API_KEYS = {
    "sk-live-abc123": "service-a",
    "sk-live-def456": "service-b",
}

async def verify_api_key(
    api_key: Annotated[str, Depends(api_key_header)]
) -> str:
    """验证 API Key 并返回服务名称"""
    if api_key not in API_KEYS:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid API Key",
        )
    return API_KEYS[api_key]

@app.get("/data")
async def get_data(
    service_name: Annotated[str, Depends(verify_api_key)]
):
    return {"message": f"Hello {service_name}", "data": [1, 2, 3]}
```

### 7.2 Query 参数方式

```python
from fastapi.security import APIKeyQuery

api_key_query = APIKeyQuery(name="api_key", auto_error=True)

# 使用方式与 Header 完全相同，只是 Key 从 URL 查询参数中提取
# 请求示例: GET /data?api_key=sk-live-abc123
```

### 7.3 Cookie 方式

```python
from fastapi.security import APIKeyCookie

api_key_cookie = APIKeyCookie(name="session_token", auto_error=True)

# 使用方式与 Header 完全相同，只是 Key 从 Cookie 中提取
```

### 7.4 多认证方式组合

```python
from fastapi.security import APIKeyHeader, APIKeyQuery

api_key_header = APIKeyHeader(name="X-API-Key", auto_error=False)  # ← auto_error=False
api_key_query = APIKeyQuery(name="api_key", auto_error=False)       # ← auto_error=False

async def verify_api_key(
    header_key: Annotated[str | None, Depends(api_key_header)],
    query_key: Annotated[str | None, Depends(api_key_query)],
) -> str:
    """支持从 Header 或 Query 参数中提取 API Key"""
    api_key = header_key or query_key
    if not api_key or api_key not in API_KEYS:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid or missing API Key",
        )
    return API_KEYS[api_key]
```

> [!TIP]
> 设置 `auto_error=False` 后，当 Key 不存在时依赖函数返回 `None` 而非自动抛出异常。
> 这允许你在业务逻辑中实现 **可选认证** 或 **多种认证方式回退**。

---

## 8. CORS 跨域安全配置

当前端和后端部署在不同域时，需要配置 CORS 中间件。

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# 允许的源列表
origins = [
    "http://localhost:3000",      # 本地前端开发
    "https://myapp.example.com",  # 生产前端域名
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,           # 允许跨域的源列表
    allow_credentials=True,          # 允许携带 Cookie
    allow_methods=["*"],             # 允许所有 HTTP 方法
    allow_headers=["*"],             # 允许所有请求头
)
```

### CORS 参数说明

| 参数 | 类型 | 说明 |
|------|------|------|
| `allow_origins` | `list[str]` | 允许跨域的源 URL 列表，`["*"]` 表示所有 |
| `allow_credentials` | `bool` | 是否允许携带 Cookie/Authorization |
| `allow_methods` | `list[str]` | 允许的 HTTP 方法 |
| `allow_headers` | `list[str]` | 允许的请求头 |
| `expose_headers` | `list[str]` | 浏览器可访问的响应头 |
| `max_age` | `int` | 预检请求缓存时间（秒） |

> [!CAUTION]
> 当 `allow_credentials=True` 时，`allow_origins` **不能**设置为 `["*"]`。
> 必须明确列出允许的源地址。

---

## 9. 安全方案选型决策树

```
需要用户登录认证？
├── 是 → 需要细粒度权限控制？
│   ├── 是 → 方案三: OAuth2 Scopes + JWT
│   └── 否 → 方案二: OAuth2 + JWT（生产级推荐）
│
├── 仅服务间调用？
│   └── 方案五: API Key (Header)
│
├── 简单内部管理后台？
│   └── 方案四: HTTP Basic Auth
│
└── 快速原型/Demo？
    └── 方案一: OAuth2 Password Bearer（简化版）
```

### 方案对比矩阵

| 特性 | OAuth2+JWT | Scopes | HTTP Basic | API Key |
|------|-----------|--------|-----------|---------|
| 无状态 | ✅ | ✅ | ✅ | ✅ |
| Token 过期 | ✅ | ✅ | ❌ | ❌ |
| 细粒度权限 | ❌ | ✅ | ❌ | ❌ |
| 浏览器原生支持 | ❌ | ❌ | ✅ | ❌ |
| OpenAPI 文档集成 | ✅ | ✅ | ✅ | ✅ |
| 适合前后端分离 | ✅ | ✅ | ❌ | ❌ |
| 适合服务间调用 | ⚠️ | ⚠️ | ❌ | ✅ |
| 实现复杂度 | 中 | 高 | 低 | 低 |

---

## 10. AI Agent 编程清单

以下是 AI Agent 在自动化生成 FastAPI 安全代码时的 **标准化检查清单**：

### 10.1 通用检查项

- [ ] 所有密码存储为 **哈希值**（使用 `pwdlib` + Argon2id）
- [ ] SECRET_KEY 使用 `openssl rand -hex 32` 生成，**不硬编码**在源码中
- [ ] Token 过期时间合理设置（推荐 15-60 分钟）
- [ ] 错误响应不泄露系统信息（统一 "Could not validate credentials"）
- [ ] 401 响应包含 `WWW-Authenticate` header
- [ ] 使用 `Annotated` 类型注解（Python 3.9+推荐写法）

### 10.2 OAuth2 + JWT 检查项

- [ ] `OAuth2PasswordBearer(tokenUrl="...")` 指向正确的登录端点
- [ ] JWT Payload 使用 `sub` claim 存放用户标识
- [ ] `jwt.decode()` 的 `algorithms` 参数为 **列表** `[ALGORITHM]`
- [ ] Token 解码失败统一抛出 `credentials_exception`
- [ ] `InvalidTokenError` 被捕获处理

### 10.3 Scopes 检查项

- [ ] `OAuth2PasswordBearer` 的 `scopes` 参数声明所有可用权限
- [ ] 登录端点将 `form_data.scopes` 写入 Token 的 `scope` claim
- [ ] `get_current_user` 接收 `SecurityScopes` 参数
- [ ] 端点使用 `Security()` 而非 `Depends()` 并传递必需 scopes
- [ ] Token scope 覆盖检查遍历所有 `security_scopes.scopes`

### 10.4 代码生成模板命令

```python
# AI Agent 快速初始化命令
"""
生成文件结构:
  app/
  ├── main.py           # FastAPI 应用入口
  ├── auth/
  │   ├── __init__.py
  │   ├── schemas.py    # Token、User、TokenData 模型
  │   ├── security.py   # oauth2_scheme、password_hash 实例
  │   ├── utils.py      # verify_password、create_access_token
  │   └── deps.py       # get_current_user、get_current_active_user
  ├── config.py         # SECRET_KEY、ALGORITHM、过期时间
  └── routers/
      └── auth.py       # /token 登录端点
"""
```

### 10.5 可复用代码片段

#### 片段 A：标准安全配置

```python
# config.py
import os

SECRET_KEY = os.environ.get("SECRET_KEY", "fallback-dev-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
```

#### 片段 B：标准认证依赖

```python
# auth/deps.py
from typing import Annotated
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
import jwt
from jwt.exceptions import InvalidTokenError

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)]
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except InvalidTokenError:
        raise credentials_exception

    user = await get_user_from_db(username)
    if user is None:
        raise credentials_exception
    return user
```

#### 片段 C：标准登录端点

```python
# routers/auth.py
from typing import Annotated
from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter()

@router.post("/token", response_model=Token)
async def login(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token = create_access_token(
        data={"sub": user.username},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    return Token(access_token=access_token, token_type="bearer")
```

---

## 参考资料

| 来源 | 链接 |
|------|------|
| Security 总览 | <https://fastapi.tiangolo.com/tutorial/security/> |
| Security 入门 | <https://fastapi.tiangolo.com/tutorial/security/first-steps/> |
| Simple OAuth2 | <https://fastapi.tiangolo.com/tutorial/security/simple-oauth2/> |
| OAuth2 + JWT | <https://fastapi.tiangolo.com/tutorial/security/oauth2-jwt/> |
| OAuth2 Scopes | <https://fastapi.tiangolo.com/advanced/security/oauth2-scopes/> |
| HTTP Basic Auth | <https://fastapi.tiangolo.com/advanced/security/http-basic-auth/> |
| Security 工具类 API | <https://fastapi.tiangolo.com/reference/security/> |
| CORS 中间件 | <https://fastapi.tiangolo.com/tutorial/cors/> |
| PyJWT 文档 | <https://pyjwt.readthedocs.io/> |
| pwdlib 文档 | <https://frankie567.github.io/pwdlib/> |
