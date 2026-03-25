# Fly-Rules
远程规则集

## GitHub 规则自动更新

- `GitHub.yaml`: Clash `payload` 规则格式
- `GitHub.list`: iOS 使用的纯列表格式

手动更新一次：

```bash
bash scripts/update_github_rules.sh
```

仓库已包含定时任务：`.github/workflows/update-github-rules.yml`，每天自动刷新。
