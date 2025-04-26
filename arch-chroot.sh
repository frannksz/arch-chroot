#!/usr/bin/env bash

# ======================================================
#  Pós-instalação do Arch Linux - Franklin Souza (@frannksz)
# ======================================================

set -euo pipefail

# === Cores ===
RED="\e[31m"
GREEN="\e[32m"
CYAN="\e[36m"
RESET="\e[0m"

msg() {
  echo -e "${CYAN}[INFO]${RESET} $1"
}

erro() {
  echo -e "${RED}[ERRO]${RESET} $1" >&2
  exit 1
}

# === Habilitar rede ===
dhcpcd_enable() {
  clear
  msg "Habilitando dhcpcd..."
  systemctl enable dhcpcd
}

# === Fuso horário ===
timezone_config() {
  msg "Configurando fuso horário para America/Sao_Paulo"
  ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
  hwclock --systohc
}

# === Idioma ===
language_system() {
  clear
  echo -e "${CYAN}Escolha o idioma do sistema:${RESET}"
  echo "[1] Inglês (en_US.UTF-8)"
  echo "[2] Português Brasileiro (pt_BR.UTF-8)"
  read -p "Opção [1 ou 2]: " LANGUAGE_CHOICE

  case "$LANGUAGE_CHOICE" in
    1)
      sed -i '171s/^#//' /etc/locale.gen
      ;;
    2)
      sed -i '391s/^#//' /etc/locale.gen
      ;;
    *)
      echo "Opção inválida!"
      return language_system
      ;;
  esac

  locale-gen

  LANG_CODE=$( [ "$LANGUAGE_CHOICE" = "1" ] && echo "en_US.UTF-8" || echo "pt_BR.UTF-8" )
  echo "LANG=$LANG_CODE" > /etc/locale.conf
  export LANG="$LANG_CODE"
  read -rp "Idioma configurado para $LANG_CODE. Pressione ENTER para continuar..."
}

# === Teclado ===
keymap_config() {
  echo "KEYMAP=br-abnt2" > /etc/vconsole.conf
}

# === Hostname ===
hostname_config() {
  clear
  read -rp "Digite o nome da máquina (hostname): " HOST_NAME
  echo "$HOST_NAME" > /etc/hostname
}

# === Btrfs-progs ===
btrfs_progs_config() {
  msg "Instalando btrfs-progs..."
  pacman -S btrfs-progs --noconfirm
}

# === Kernel ===
kernels_download() {
  clear
  echo -e "${CYAN}Escolha o kernel:${RESET}"
  echo "[1] linux (padrão)"
  echo "[2] linux-hardened (segurança)"
  echo "[3] linux-lts (estável)"
  echo "[4] linux-zen (performance)"
  read -p "Opção: " KERNEL_CHOICE

  case "$KERNEL_CHOICE" in
    1|01) pacman -S linux --noconfirm ;;
    2|02) pacman -S linux-hardened --noconfirm ;;
    3|03) pacman -S linux-lts --noconfirm ;;
    4|04) pacman -S linux-zen --noconfirm ;;
    *) read -p "Opção inválida. Pressione ENTER para tentar novamente..." && kernels_download ;;
  esac
}

# === Configurar Pacman ===
pacman_config() {
  msg "Otimizando configurações do pacman"
  sed -i -r 's/^#(UseSyslog|Color|CheckSpace|VerbosePkgLists|ParallelDownloads)/\1/' /etc/pacman.conf
  sed -i '/^ParallelDownloads/s/=[[:space:]]*[0-9]*/= 100/' /etc/pacman.conf
  sed -i '40s/$/ILoveCandy/' /etc/pacman.conf
  sed -i '92,93s/^#//' /etc/pacman.conf
}

# === Atualizar repositórios ===
repo_update() {
  clear && pacman -Syy --noconfirm
}

# === Senha root ===
password_root() {
  clear
  msg "Digite a senha de root:"
  passwd
}

# === Criar usuário ===
user_create() {
  clear
  echo -e "${CYAN}Escolha o shell do usuário:${RESET}"
  echo "[1] bash"
  echo "[2] zsh"
  read -p "Opção: " SHELL_CHOICE

  case "$SHELL_CHOICE" in
    1|01)
      SHELL_PATH="/bin/bash"
      pacman -S bash --noconfirm
      ;;
    2|02)
      SHELL_PATH="/bin/zsh"
      pacman -S zsh --noconfirm
      ;;
    *)
      read -p "Opção inválida. Pressione ENTER para tentar novamente..." && user_create
      return
      ;;
  esac

  read -rp "Digite o nome de usuário (sem espaços ou acentos): " USERNAME
  useradd -m -g users -G wheel -s "$SHELL_PATH" "$USERNAME"
}

# === Senha do usuário ===
password_user() {
  clear
  read -rp "Digite o nome do usuário para definir a senha: " USERNAME1
  passwd "$USERNAME1"
}

# === Permitir sudo para grupo wheel ===
edit_sudoers() {
  sed -i '125s/^# //' /etc/sudoers
}

# === Instalar GRUB ===
grub_install() {
  clear
  msg "Instalando o GRUB..."
  pacman -S grub efibootmgr --noconfirm
  grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck
  grub-mkconfig -o /boot/grub/grub.cfg
}

# === Fim ===
finish_install() {
  clear
  echo -e "${GREEN}Instalação concluída com sucesso!${RESET}"
  read -p "Saia do chroot e reinicie o sistema. Pressione ENTER para sair..."
  exit 0
}

# === Execução sequencial ===
dhcpcd_enable
timezone_config
language_system
keymap_config
hostname_config
btrfs_progs_config
kernels_download
pacman_config
repo_update
password_root
user_create
password_user
edit_sudoers
grub_install
finish_install
