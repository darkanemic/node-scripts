#!/bin/bash
set -e
echo "🔐 [1/6] Обновляем sshd_config..."
cat > /etc/ssh/sshd_config <<'EOF'
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

echo "🧯 [2/6] Отключаем systemd socket-активацию SSH..."
systemctl stop ssh.socket || true
systemctl disable ssh.socket || true

echo "🔁 [3/6] Перезапускаем SSH на порту 1717..."
systemctl restart ssh

echo "🔑 [4/6] Добавляем SSH-ключ..."
bash <(curl -s https://raw.githubusercontent.com/darkanemic/node-scripts/main/tools/add-dark-key.sh)

echo "🛡 [5/6] Устанавливаем и настраиваем fail2ban..."
apt update -y
apt install -y fail2ban ufw -y

cat > /etc/fail2ban/jail.local <<'EOF'
[sshd]
enabled = true
port = 1717
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

systemctl enable fail2ban
systemctl restart fail2ban

echo "🌐 [6/6] Настраиваем UFW и открываем порты..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 1717/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp
ufw allow 5000:5010/tcp
ufw --force enable

echo ""
echo "📜 Текущий статус UFW:"
ufw status numbered
echo ""
echo "✅ Установка завершена. Проверь подключение: ssh -p 1717 root@<ip>"
