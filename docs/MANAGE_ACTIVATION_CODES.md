# 激活码管理脚本

脚本路径：`backend/scripts/manage_activation_codes.py`

用于生成、导入、查询、删除 Vloglish 会员激活码（一次性永久会员）。

**生成规则：** 自动生成的激活码为 **4 位**大写字母 + 数字（已去掉 `0/O`、`1/I/L` 等易混淆字符）。

## 使用前

在 `backend` 目录下执行，并确保虚拟环境已安装依赖、数据库已初始化：

```powershell
cd d:\code\teco-lab\backend
.\.venv\Scripts\python scripts\manage_activation_codes.py stats
```

## 命令说明

### 统计

```powershell
python scripts/manage_activation_codes.py stats
```

输出激活码总数、未使用数、已使用数。

### 批量生成

```powershell
# 生成 5 个 4 位激活码（如 AB3K、P7XN）
python scripts/manage_activation_codes.py generate --count 5

# 生成并写入文件
python scripts/manage_activation_codes.py generate -n 10 -o codes.txt
```

| 参数 | 说明 |
|------|------|
| `--count` / `-n` | 生成数量，默认 `1` |
| `--output` / `-o` | 可选，同时写入文本文件（每行一个码） |

### 列表

```powershell
python scripts/manage_activation_codes.py list
python scripts/manage_activation_codes.py list --status available
python scripts/manage_activation_codes.py list --status used
```

| 参数 | 说明 |
|------|------|
| `--status` | `all`（默认）、`available`（未使用）、`used`（已使用） |

列表字段：激活码、状态、使用者邮箱、使用时间、创建时间。

### 查看单个

```powershell
python scripts/manage_activation_codes.py show AB3K
```

### 删除未使用的码

```powershell
python scripts/manage_activation_codes.py delete AB3K
```

> 已绑定用户的激活码不能删除。

### 从文件导入

```powershell
python scripts/manage_activation_codes.py import codes.txt
```

文本格式：每行一个激活码；以 `#` 开头的行视为注释；已存在的码会自动跳过。

导入支持任意长度的自定义码（不限于 4 位）。

示例 `codes.txt`：

```text
# 2026-06 批次
AB3K
P7XN
```

## 激活码规则

- 脚本 `generate` 生成的码固定为 **4 位**
- 每个激活码只能使用一次
- 用户在前端 `/activate` 页面输入后，永久成为会员
- 开发环境启动时会自动 seed 测试码 `DEV1`（见 `app/main.py`）

## 用户激活流程

1. 用户注册 / 登录
2. 打开 `/activate`，输入激活码
3. 激活成功后，`/english` 目录显示全量内容
