# 更新日志

## [Unreleased] - 2025-11-13

### Added

### Changed

- 优化安装过程，实现即装即用，无需手动source ~/.ak/env.sh
- 优化docker tags命令，支持分页查询，支持搜索关键词

### Fixed

## [0.0.4] - 2025-11-13

### Changed

- 文档修复
- 更新README.md中ssl命令描述，增加通配符证书支持说明
- 优化Makefile注释，移除无用的check目标
- 改进ssl.sh脚本的输出目录逻辑，支持根据common_name自动创建目录
- 增强jq依赖检查功能，支持自动检测操作系统并安装jq工具 #1

### Fixed

- 修复ssl.sh脚本中示例命令格式，统一使用引号包围SAN参数
- 修复ssl.sh脚本输出目录处理逻辑，当未指定output时根据common_name自动设置

## [0.0.3] - 2025-08-05

### Fixed

- 修复DEBUG环境变量判断逻辑
- 修复容器环境无法安装golang的问题，使用try_sudo替代sudo

## [0.0.2] - 2025-06-03

### Added

- DeepSeek终端智能助手: 通过Ctrl+G快捷键获取AI建议，直接将命令行中的描述转换成命令并输出到终端
- ak docker tags 支持带斜杠的非docker官方镜像
- 新增ak ps fdcount命令：查看进程打开的文件描述符数量

### Fixed

- 修复ak update `<branch>` 无法覆盖更新的问题
- 修复清除--debug参数时未重置$#导致子命令参数数量读取异常问题

## [0.0.1] - 2025-05-20

### Added

- 一键式极简安装，引入单行命令部署方案，一行命令快速安装
- 集成交互式Shell补全功能，支持bash/zsh等主流shell环境
- 新增ssl命令：ssl证书工具集，支持自建私有CA认证中心、一键生成SSL自签名证书、证书链配置与验证工具
- 新增docker命令：docker辅助命令，支持镜像仓库tag版本检索、进入容器文件系统交互式终端
- 新增go命令：go语言开发套件，支持多版本运行时环境管理、查看go历史版本
