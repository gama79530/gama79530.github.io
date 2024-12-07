# Ubuntu 22.04 工具安裝

## 總整理
1. [Softwares](#softwares)
2. [google chrome](#google-chrome)
3. [Visual Studio Code](#visual-studio-code)
4. [Build Essential Package](#build-essential-package)
5. [GNU GRUB](#gnu-grub)
6. [Window 10 / ubuntu system time synchronization](#window-10--ubuntu-system-time-synchronization)

## Softwares
```bash
sudo apt update
sudo apt upgrade
# vim
sudo apt install vim
# git
sudo apt install git
# python3
sudo apt install python3-pip
sudo apt install python3-venv
# VLC
sudo apt install vlc
# LibreOffice
sudo apt install libreoffice
# Gnome clocks
sudo apt-get -y install gnome-clocks
# gdb
sudo apt install gdb-multiarch
# cross compiler
sudo apt install gcc-aarch64-linux-gnu
# qemu
sudo apt install qemu-system-aarch64
```

## google chrome
```bash
mkdir /etc/apt/keyrings
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/keyrings/google.asc >/dev/null
sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google.asc] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
sudo apt-get update 
sudo apt install google-chrome-stable
```
### Reference
1. [How to install Google Chrome](https://askubuntu.com/questions/510056/how-to-install-google-chrome)
2. [3rd Party Repository: Google Chrome](https://www.ubuntuupdates.org/ppa/google_chrome?dist=stable)

## Visual Studio Code
```bash
sudo apt-get install wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https
sudo apt update
sudo apt install code # or code-insiders
```

### Reference
1. [Visual Studio Code on Linux](https://code.visualstudio.com/docs/setup/linux#_debian-and-ubuntu-based-distributions)

## Build Essential Package
```bash
sudo apt-get install build-essential
```

### Reference
1. [What is Build Essential Package in Ubuntu? How to Install it?](https://itsfoss.com/build-essential-ubuntu/)

## GNU GRUB
```bash
sudo apt install grub-customizer
```

### 當 GRUB 找不到 Windows 的解決辦法
1. 將 `GRUB_DISABLE_OS_PROBER=false` 加入 `/etc/default/grub`
2. 執行 
```bash
    sudo grub-mkconfig
```

## Window 10 / ubuntu system time synchronization
```bash
sudo timedatectl set-local-rtc 1
timedatectl | grep local
```

### Reference
1. [Ubuntu 與 Windows 雙系統時間不同步修正](https://hackmd.io/@Z5feOdXLT-eld5sA3Shfbg/SJUFkZv22#Ubuntu-%E8%88%87-Windows-%E9%9B%99%E7%B3%BB%E7%B5%B1%E6%99%82%E9%96%93%E4%B8%8D%E5%90%8C%E6%AD%A5%E4%BF%AE%E6%AD%A3)