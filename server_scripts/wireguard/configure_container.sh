mkdir -p /opt/amnezia/wireguard
cd /opt/amnezia/wireguard

PRIVATE_KEY_PATH="/opt/amnezia/wireguard/wireguard_server_private_key.key"

if [[ -f "$PRIVATE_KEY_PATH" ]]; then
    # Если файл существует, читаем его содержимое в переменную
    WIREGUARD_SERVER_PRIVATE_KEY=$(cat "$PRIVATE_KEY_PATH")
else
    # Если файла нет, генерируем новый ключ
    WIREGUARD_SERVER_PRIVATE_KEY=$(wg genkey)
    # Сохраняем ключ в файл
    echo "$WIREGUARD_SERVER_PRIVATE_KEY" > "$PRIVATE_KEY_PATH"
fi


PUBLIC_KEY_PATH="/opt/amnezia/wireguard/wireguard_server_public_key.key"

if [[ -f "$PUBLIC_KEY_PATH" ]]; then
    # Если файл существует, читаем его содержимое в переменную
    WIREGUARD_SERVER_PUBLIC_KEY=$(cat "$PUBLIC_KEY_PATH")
else
    WIREGUARD_SERVER_PUBLIC_KEY=$(echo $WIREGUARD_SERVER_PRIVATE_KEY | wg pubkey)
    echo $WIREGUARD_SERVER_PUBLIC_KEY > /opt/amnezia/wireguard/wireguard_server_public_key.key
fi


PSK_PATH="/opt/amnezia/wireguard/wireguard_psk.key"

if [[ -f "$PSK_PATH" ]]; then
    # Если файл существует, читаем его содержимое в переменную
    WIREGUARD_PSK=$(cat "$PSK_PATH")
else
    WIREGUARD_PSK=$(wg genpsk)
    echo $WIREGUARD_PSK > /opt/amnezia/wireguard/wireguard_psk.key
fi

WG_CONF="/opt/amnezia/wireguard/wg0.conf"

cat > $WG_CONF <<EOF
[Interface]
PrivateKey = $WIREGUARD_SERVER_PRIVATE_KEY
Address = $WIREGUARD_SUBNET_IP/$WIREGUARD_SUBNET_CIDR
ListenPort = $WIREGUARD_SERVER_PORT
EOF

CLIENTS_TABLE="clientsTable"

if [[ ! -f "$CLIENTS_TABLE" ]]; then
    echo "Файл $CLIENTS_TABLE не найден."
    exit 0
fi

if ! command -v jq &> /dev/null; then
    echo "Утилита jq не установлена. Установите её с помощью 'sudo apt install jq' или аналогичной команды."
    exit 0
fi

# Читаем JSON и генерируем секции [Peer]
NEW_PEERS=$(jq -r '
    .[] |
    "[Peer]\nPublicKey = \(.clientId)\nPresharedKey = '$WIREGUARD_PSK'\nAllowedIPs = \(.userData.allowedIps)\n"
' "$CLIENTS_TABLE")

# Добавляем новые секции [Peer] в конец файла wg0.conf
echo "$NEW_PEERS" >> "$WG_CONF"

echo "Секции [Peer] успешно добавлены в $WG_CONF."