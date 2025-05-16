.PHONY: sync check clean

# 同步文件到 /usr/local/bin/
sync:
	sudo cp ak.bash /usr/local/bin/ak
	sudo cp -r _ak-script /usr/local/bin/

clean:
	sudo rm -rf /usr/local/bin/_ak-script
	rm -rf /usr/local/bin/ak

# 检查所有脚本是否可执行
check:
	find ./ak-script/*.sh -exec chmod +x {} \;