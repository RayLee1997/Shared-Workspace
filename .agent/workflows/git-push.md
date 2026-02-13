---
description: Git 快速提交并推送 - 一键 commit & push
---

# Git Commit & Push 工作流

// turbo-all

## 1. 查看变更状态

```bash
git status
```

## 2. 暂存所有变更

```bash
git add -A
```

## 3. 提交变更

根据变更内容生成有意义的 commit message，格式：

- `feat: 新功能描述`
- `fix: 修复问题描述`
- `docs: 文档更新描述`
- `refactor: 重构描述`
- `chore: 杂项更新`

```bash
git commit -m "[自动生成的 commit message]"
```

## 4. 推送到远程

```bash
git push
```

## 5. 完成通知

告知用户提交和推送已完成，显示本次提交的摘要信息。
