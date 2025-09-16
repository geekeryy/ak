.PHONY: sync check clean log

# 同步文件到 /usr/local/bin/ 进行本地测试
sync:
	sudo cp ak.bash /usr/local/bin/ak
	sudo cp -r _ak-script /usr/local/bin/

# 卸载
clean:
	sudo rm -rf /usr/local/bin/_ak-script
	sudo rm -rf /usr/local/bin/ak
	sudo rm -rf ~/.cache/ak

# 查看git日志
log:
	git log --pretty=format:%s