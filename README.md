# AK

```plain

         _____________/\\\\\\\\\__________/\\\________/\\\_________       
          ___________/\\\\\\\\\\\\\_______\/\\\_____/\\\//__________       
           __________/\\\/////////\\\______\/\\\__/\\\//_____________      
            _________\/\\\_______\/\\\______\/\\\\\\//\\\_____________     
             _________\/\\\\\\\\\\\\\\\______\/\\\//_\//\\\____________    
              _________\/\\\/////////\\\______\/\\\____\//\\\___________   
               _________\/\\\_______\/\\\______\/\\\_____\//\\\__________  
                _________\/\\\_______\/\\\______\/\\\______\//\\\_________ 
                 _________\///________\///_______\///________\///__________
                                                      
```

[![Website](https://img.shields.io/website?url=https%3A%2F%2Fwww.jiangyang.me)](https://blog.jiangyang.online)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/geekeryy/ak)
![GitHub](https://img.shields.io/github/license/geekeryy/ak)
![GitHub issues](https://img.shields.io/github/issues/geekeryy/ak)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/geekeryy/ak)
![GitHub pull requests](https://img.shields.io/github/issues-pr/geekeryy/ak)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/geekeryy/ak)
![GitHub last commit](https://img.shields.io/github/last-commit/geekeryy/ak)
![GitHub repo size](https://img.shields.io/github/repo-size/geekeryy/ak)
![GitHub language count](https://img.shields.io/github/languages/count/geekeryy/ak)
![Lines of code](https://img.shields.io/tokei/lines/github/geekeryy/ak)
![GitHub commit activity](https://img.shields.io/github/commit-activity/y/geekeryy/ak)
![GitHub contributors](https://img.shields.io/github/contributors-anon/geekeryy/ak)
![Sourcegraph for Repo Reference Count](https://img.shields.io/sourcegraph/rrc/github.com/geekeryy/ak)
![GitHub top language](https://img.shields.io/github/languages/top/geekeryy/ak)

AK 是一款专为重度终端用户设计的轻量级 Bash 工具集，具备以下核心优势：

- DeepSeek终端智能助手 - 通过Ctrl+G快捷键获取AI建议，直接将命令行中的描述转换成命令并输出到终端
- 独立运行 - 无外部依赖，脚本即装即用
- 零配置体验 - 开箱即用，一键式极简安装，无需复杂初始化设置
- 效率倍增 - 通过模块化设计封装高频操作，灵性的自动补全，显著提升开发运维工作流效率

## 子命令

- ssl：ssl证书工具集，支持自建私有CA认证中心、支持通配符证书、一键生成SSL自签名证书、证书链配置与验证工具
- docker：docker辅助命令，支持镜像仓库tag版本检索、进入容器文件系统交互式终端
- go：go语言开发套件，支持多版本运行时环境管理、查看go历史版本
- ps：进程信息查看，支持Linux和MacOS

## 安装

安装稳定版本

```sh
curl https://ak.jiangyang.online | bash
```

安装开发版本（使用--version参数指定分支名称 例如： main）

```sh
curl https://ak.jiangyang.online | bash -s -- --version main
```

## 说明

- 主要支持环境：MacOS、Centos、Ubuntu、Docker

## 代码提交规范

推荐遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/v1.0.0/)约定，保持提交历史清晰易读。

### 基础格式

`<type>(<scope>): <summary> [issue]`

- `type`：必填，表示此次提交的类别。
- `scope`：可选，用于标识受影响的模块或子命令，例如 `go`、`ssl`、`docs`。
- `summary`：使用祈使句（如“修复”、“添加”），建议不超过 72 个字符。
- `issue`：可选，用于关联问题，例如 `close #123`、`fix #123`、`resolve #123`。

### 关联问题

- 自动关闭：`close|closes|closed #<issue_number>`
- 修复缺陷：`fix|fixes|fixed #<issue_number>`
- 解决任务：`resolve|resolves|resolved #<issue_number>`

### 常用提交类型

| type      | 适用场景             |
|-----------|----------------------|
| feat      | 引入新功能或模块       |
| fix       | 修复缺陷或异常行为     |
| docs      | 更新文档、注释或指南    |
| refactor  | 重构，不改变对外行为    |
| test      | 新增或更新测试         |
| perf      | 优化性能或资源占用     |
| style     | 风格调整，不影响逻辑    |
| chore     | 杂项维护、依赖升级等    |

### 最佳实践

- 一次提交聚焦单一主题，避免引入不相关改动。
- 提交前确保本地测试通过，例如执行 `make test` 或相关脚本。
- 若提交影响用户文档或脚本行为，请同步更新文档并在提交信息中说明。

## 更新日志

请查看 [CHANGELOG.md](CHANGELOG.md)
