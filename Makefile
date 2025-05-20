.PHONY: sync check clean log

# 同步文件到 /usr/local/bin/
sync:
	sudo cp ak.bash /usr/local/bin/ak
	sudo cp -r _ak-script /usr/local/bin/

# 卸载
clean:
	sudo rm -rf /usr/local/bin/_ak-script
	sudo rm -rf /usr/local/bin/ak
	sudo rm -rf ~/.cache/ak

# 检查所有脚本是否可执行
check:
	find ./ak-script/*.sh -exec chmod +x {} \;

# 查看git日志
log:
	git log --pretty=format:%s