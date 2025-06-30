#!/bin/bash

# Скрипт: build_idevicerestore_stack.sh
# Назначение: Сборка полного стека libimobiledevice из исходников на Linux
# Поддержка M1/M2/Apple Silicon Mac'ов
# Зависимости: git, cmake, make, gcc, pkg-config, libtool, autoconf, automake, libusb-1.0-0-dev, libreadline-dev, libzip-dev

set -e

echo "[INFO] Обновление системы и установка зависимостей..."
sudo apt update && sudo apt install -y       git cmake make gcc pkg-config libtool autoconf automake       libusb-1.0-0-dev libreadline-dev libzip-dev libssl-dev       libcurl4-openssl-dev libplist-dev

echo "[INFO] Создание рабочего каталога..."
mkdir -p ~/libimobile-stack && cd ~/libimobile-stack

clone_and_build() {
  local repo=$1
  local folder=$(basename "$repo" .git)

  echo "[INFO] Клонирование $repo..."
  git clone --depth=1 "https://github.com/libimobiledevice/$repo"

  echo "[INFO] Сборка $folder..."
  cd "$folder"
  ./autogen.sh --prefix=/usr/local
  make -j$(nproc)
  sudo make install
  cd ..
}

# Сборка всех библиотек
clone_and_build libplist.git
clone_and_build libusbmuxd.git
clone_and_build libimobiledevice-glue.git
clone_and_build libirecovery.git
clone_and_build libimobiledevice.git
clone_and_build idevicerestore.git

echo "[DONE] Всё собрано! Теперь можно запускать:"
echo "       sudo usbmuxd -f -U root -v"
echo "       sudo idevicerestore --erase /path/to/YourFirmware.ipsw"
