# PPP Manage

PPP管理系统安装和运维工具。

## 目录结构

```
.
├── README.md           # 项目说明文档
├── run.sh             # 主控制脚本
├── sh/                # 子脚本目录
│   ├── install_sentinel.sh
│   ├── install_mysql_docker.sh
│   ├── uninstall_sentinel.sh
│   └── uninstall_mysql_docker.sh
├── runtime/           # Redis Sentinel运行目录
├── mysql/            # MySQL数据目录
└── logs/             # 应用日志目录
```

## 使用说明

### 安装和运行

1. 一键安装所有组件:
```bash
./run.sh              # 选择"一键完整安装"选项
```

2. 分步安装:
- 安装Redis Sentinel
- 安装MySQL Docker 
- 安装并启动PPP Manage

### 基本操作

1. 启动服务:
```bash
./run.sh              # 选择"启动PPP_mangage"
```

2. 停止服务:
```bash
./run.sh              # 选择"停止PPP_mangage"
```

3. 重启服务:
```bash
./run.sh              # 选择"重启PPP_mangage"
```

4. 查看日志:
```bash
./run.sh              # 选择"查看PPP_mangage日志"
```

### 卸载

1. 一键完全卸载:
```bash
./run.sh              # 选择"一键完全卸载"
```

2. 分步卸载:
- 卸载PPP Manage
- 卸载MySQL Docker
- 卸载Redis Sentinel

## 注意事项

1. 需要root权限执行脚本
2. 确保系统已安装Docker
3. 建议在全新环境中安装
