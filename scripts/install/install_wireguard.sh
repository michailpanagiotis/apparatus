#!/usr/bin/env bash
set -e

read -p "Enter peer number: " PEER_NUMBER
read -p "Enter wireguard endpoint: " WIREGUARD_ENDPOINT

if ! test -f /etc/wireguard/private.key; then
  wg genkey | tee /etc/wireguard/private.key
  chmod go= /etc/wireguard/private.key
  echo "Created wireguard private key"
else
  echo "Wireguard private key exists"
fi

if ! test -f /etc/wireguard/public.key; then
  cat /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key
  echo "Created wireguard public key"
else
  echo "Wireguard public key exists"
fi

public_key=$(cat /etc/wireguard/public.key)
echo "Add the following to your Wireguard server configuration:"
echo "  [Peer]"
echo "  PublicKey = ${public_key} # ${PEER_NUMBER}"
echo "  AllowedIPs = fda7:bcf9:b71c::${PEER_NUMBER}/128"

if ! test -f /etc/wireguard/wg0.conf; then
  private_key=$(cat /etc/wireguard/private.key)
  cat > /etc/wireguard/wg0.conf <<- EOM
[Interface]
Address = fda7:bcf9:b71c::${PEER_NUMBER}/64
ListenPort = 51820
PrivateKey = ${private_key}

[Peer]
PublicKey = EMoxRoV0nQldMzAFjcFa7Rkuk2fMO+83YX3R7ppOMXQ=
AllowedIPs = fda7:bcf9:b71c::/64
Endpoint = ${WIREGUARD_ENDPOINT}
PersistentKeepalive = 25
EOM
  echo "Created wireguard configuration"
else
  echo "Wireguard configuration exists"
fi

is_up=$(wg show)

if [ -z "$is_up" ]; then
  wg-quick up wg0
  echo 'Wireguard is up'
else
  echo 'Wireguard is up'
fi
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
