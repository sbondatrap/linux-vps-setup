#!/bin/bash

# --- Конфигурация ---
USERNAME="admin"  # заменить на нужного пользователя либо  оставить как есть
USER_HOME="/home/$USERNAME"
SSH_PATH="$USER_HOME/.ssh"
KEY_FILE="$USER_HOME/.ssh/id_ed25519"
UFW_CONFIG="/etc/ufw/user.conf"

echo "=========================================="
echo "  Linux VPS Automated Setup Script v1.0"
echo "  (Real Server Deployment)"
echo "=========================================="


#-------------------------------------------------------------------------

# Проверяем, я ли root
if [ "$(id -u)" != "0" ]; then
    echo "Error: This script must be run as root!"
    exit 1
fi

# --------------------------------------------------------------------

# --- Шаг 1: Создание пользователя ---
# Если пользователь уже существует — пропускаем
if id "$USERNAME" &> /dev/null; then
    echo "[1/4] User '$USERNAME' already exists. Skipping creation."
else
    echo "[1/4] Creating admin user..."
    useradd --disabled-password --gecos "" "$USERNAME"
fi

# --------------------------------------------------------------------------

# --- Шаг 2: Настройка SSH ключей ---
# Генерация SSH ключа
ssh-keygen -t ed25519 -f "$KEY_FILE" -q -N '' 

if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key generation failed."
    exit 1
fi


# -------------------------------------------------------------------------

# --- Шаг 3: Настройка прав доступа (SSH) ---
chmod 700 "$SSH_PATH"
chmod 600 "$KEY_FILE"
chown -R $USERNAME:$USERNAME "$SSH_PATH"

echo "[2/4] SSH Keys generated for '$USERNAME'"

# --------------------------------------------------------------------------

# --- Шаг 4: Настройка UFW (Firewall) ---
if ! command -v ufw &> /dev/null; then
    echo "Error: UFW not found."
else
    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    # Разрешаем SSH и HTTP/HTTPS (стандартные правила для VPS)
    sudo ufw allow OpenSSH
    sudo ufw allow 'Nginx Full'

    echo "[3/4] UFW Rules configured"
fi

# -------------------------------------------------------------------------

# --- Шаг 5: Чистка root доступа по SSH (опционально, но важно для безопасности) ---
if [ -f "$UFW_CONFIG" ]; then
    sudo chmod 600 "$UFW_CONFIG"
fi

echo "=========================================="
echo "  Setup Complete!"
echo "  User: $USERNAME"
echo "  SSH Key location: $KEY_FILE"
echo "  VPS Status: Ready for secure access"
echo "=========================================="
```


