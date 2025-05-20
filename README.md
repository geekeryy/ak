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

[![Website](https://img.shields.io/website?url=https%3A%2F%2Fwww.jiangyang.me)](https://blog.jiangyang.me)
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

- 独立运行 - 无外部依赖，脚本即装即用
- 零配置体验 - 开箱即用，一键式极简安装，无需复杂初始化设置
- 效率倍增 - 通过模块化设计封装高频操作，灵性的自动补全，显著提升开发运维工作流效率

## 子命令

- ssl：ssl证书工具集，支持自建私有CA认证中心、一键生成SSL自签名证书、证书链配置与验证工具
- docker：docker辅助命令，支持镜像仓库tag版本检索、进入容器文件系统交互式终端
- go：go语言开发套件，支持多版本运行时环境管理、查看go历史版本

## 安装

安装稳定版本

```sh
curl https://ak.jiangyang.online | bash
```

安装开发版本（使用--version参数指定分支名称 例如： main）

```sh
curl https://ak.jiangyang.online | bash -s -- --version main
```

## 代码规范

| Commit      | 描述          |
|-------------|--------------|
| fix       | 修复BUG         |
| feat      | 引入新功能       |
| docs      | 添加或更新文档    |
| refactor  | 重构            |
| test      | 测试            |
