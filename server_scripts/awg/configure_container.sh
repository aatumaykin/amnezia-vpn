#!/bin/bash

mkdir -p /opt/amnezia/awg
cd /opt/amnezia/awg

PRIVATE_KEY_PATH="/opt/amnezia/awg/wireguard_server_private_key.key"

if [[ -f "$PRIVATE_KEY_PATH" ]]; then
    # Если файл существует, читаем его содержимое в переменную
    WIREGUARD_SERVER_PRIVATE_KEY=$(cat "$PRIVATE_KEY_PATH")
else
    # Если файла нет, генерируем новый ключ
    WIREGUARD_SERVER_PRIVATE_KEY=$(wg genkey)
    # Сохраняем ключ в файл
    echo "$WIREGUARD_SERVER_PRIVATE_KEY" > "$PRIVATE_KEY_PATH"
fi


PUBLIC_KEY_PATH="/opt/amnezia/awg/wireguard_server_public_key.key"

if [[ -f "$PUBLIC_KEY_PATH" ]]; then
    # Если файл существует, читаем его содержимое в переменную
    WIREGUARD_SERVER_PUBLIC_KEY=$(cat "$PUBLIC_KEY_PATH")
else
    WIREGUARD_SERVER_PUBLIC_KEY=$(echo $WIREGUARD_SERVER_PRIVATE_KEY | wg pubkey)
    echo $WIREGUARD_SERVER_PUBLIC_KEY > /opt/amnezia/awg/wireguard_server_public_key.key
fi


PSK_PATH="/opt/amnezia/awg/wireguard_psk.key"

if [[ -f "$PSK_PATH" ]]; then
    # Если файл существует, читаем его содержимое в переменную
    WIREGUARD_PSK=$(cat "$PSK_PATH")
else
    WIREGUARD_PSK=$(wg genpsk)
    echo $WIREGUARD_PSK > /opt/amnezia/awg/wireguard_psk.key
fi

WG_CONF="/opt/amnezia/awg/wg0.conf"

cat > $WG_CONF <<EOF
[Interface]
PrivateKey = $WIREGUARD_SERVER_PRIVATE_KEY
Address = $AWG_SUBNET_IP/$WIREGUARD_SUBNET_CIDR
ListenPort = $AWG_SERVER_PORT
Jc = $JUNK_PACKET_COUNT
Jmin = $JUNK_PACKET_MIN_SIZE
Jmax = $JUNK_PACKET_MAX_SIZE
S1 = $INIT_PACKET_JUNK_SIZE
S2 = $RESPONSE_PACKET_JUNK_SIZE
H1 = $INIT_PACKET_MAGIC_HEADER
H2 = $RESPONSE_PACKET_MAGIC_HEADER
H3 = $UNDERLOAD_PACKET_MAGIC_HEADER
H4 = $TRANSPORT_PACKET_MAGIC_HEADER
EOF
