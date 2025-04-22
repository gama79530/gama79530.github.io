# Git 指令自動補齊

讓 `command line` 在輸入 `git command` 時可以只需要輸入幾個簡短的字之後按 `Tab` 把命令自動補完。
參考 [ProGit - 提示和技巧](https://iissnan.com/progit/html/zh-tw/ch2_7.html)

```bash
# debian 提供的補齊腳本位置，先確定是否存在。
ls /usr/share/bash-completion/completions/git

# 不存在的話就下載，這裡使用 debian 提供的。
sudo apt update
sudo apt install bash-completion

# 下載完成後在 `~/.bashrc` 末尾加上
if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi
```
