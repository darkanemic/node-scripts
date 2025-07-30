#!/bin/bash
set -e

# Цвета
GREEN=$(tput setaf 2 2>/dev/null || echo "")
RED=$(tput setaf 1 2>/dev/null || echo "")
RESET=$(tput sgr0 2>/dev/null || echo "")

step() {
    echo -n "$1... "
}

ok() {
    echo "${GREEN}[✔]${RESET} $1"
}

fail() {
    echo "${RED}[✘]${RESET} $1"
    exit 1
}

# 1. Обновление sshd_config
step "Обновление sshd_config"
cat > /etc/ssh/sshd_config <<EOF
Port 1717
AddressFamily inet
ListenAddress 0.0.0.0

HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

PermitRootLogin prohibit-password
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
UsePAM no

AuthorizedKeysFile .ssh/authorized_keys

StrictModes yes
MaxAuthTries 3
MaxSessions 5
LoginGraceTime 30

X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no
GatewayPorts no
PermitUserEnvironment no

SyslogFacility AUTH
LogLevel INFO
PrintMotd no
PrintLastLog yes

AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server
EOF
ok "sshd_config обновлён"

# 2. Проверка конфигурации sshd
step "Проверка конфигурации sshd"
if ! sshd -t 2>/tmp/sshd_check_err; then
    echo
    fail "Ошибка в конфигурации SSH! $(cat /tmp/sshd_check_err)"
fi
ok "Конфигурация sshd валидна"

# 3. Убедимся, что /run/sshd существует
step "Проверка каталога /run/sshd"
mkdir -p /run/sshd
chmod 755 /run/sshd
ok "/run/sshd создан"

# 4. Отключение ssh.socket
step "Отключение ssh.socket"
systemctl stop ssh.socket >/dev/null 2>&1 || true
systemctl disable ssh.socket >/dev/null 2>&1 || true
ok "ssh.socket отключён"

# 5. Перезапуск SSH
step "Перезапуск ssh"
systemctl restart ssh && ok "SSH перезапущен" || fail "Ошибка при перезапуске SSH"

# 6. Добавление SSH-ключа
step "Добавление SSH-ключа"
bash <(curl -s https://raw.githubusercontent.com/darkanemic/node-scripts/main/tools/add-dark-key.sh) >/dev/null 2>&1 && ok "Ключ добавлен" || fail "Ошибка при добавлении ключа"

# 7. Установка fail2ban
step "Установка fail2ban"
apt-get update -qq >/dev/null
PYTHONWARNINGS=ignore apt-get install -y -qq fail2ban >/dev/null && ok "fail2ban установлен" || fail "Ошибка при установке fail2ban"

# 8. Настройка fail2ban
step "Настройка fail2ban"
cat > /etc/fail2ban/jail.local <<EOF
[sshd]
enabled = true
port = 1717
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

systemctl enable fail2ban >/dev/null
systemctl restart fail2ban >/dev/null && ok "fail2ban настроен и запущен" || fail "Ошибка запуска fail2ban"

# 9. UFW
step "Установка и настройка ufw"
apt-get install -y -qq ufw >/dev/null
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw allow 1717/tcp >/dev/null
ufw allow 80/tcp >/dev/null
ufw allow 443/tcp >/dev/null
ufw allow 3000/tcp >/dev/null
ufw allow 5000:5010/tcp >/dev/null
ufw --force enable >/dev/null && ok "ufw настроен и активирован" || fail "Ошибка настройки ufw"

# 10. Список портов
echo
echo "📜 Разрешённые порты:"
ufw status numbered | grep -E "ALLOW" || echo "(ничего не открыто)"

echo
ok "Готово. Проверь подключение: ssh -p 1717 root@<ip>"
