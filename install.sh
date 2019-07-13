#!/usr/bin/env bash

set -e
set -u
[ -n "${DEBUG:-}" ] && set -x || true

CKB_PKG="ckb_${CKB_VERSION}_x86_64-unknown-linux-gnu.tar.gz"
curl -LO "https://github.com/nervosnetwork/ckb/releases/download/${CKB_VERSION}/${CKB_PKG}"
tar -xzf "${CKB_PKG}"
rm -f "${CKB_PKG}"

cd "${CKB_PKG%.tar.gz}"

sudo mv ckb /usr/local/bin
sudo mv ckb-cli /usr/local/bin
sudo chown root:root /usr/local/bin/ckb /usr/local/bin/ckb-cli
sudo chmod 755 /usr/local/bin/ckb /usr/local/bin/ckb-cli

sudo mkdir /var/lib/ckb
sudo /usr/local/bin/ckb init -C /var/lib/ckb --chain testnet --log-to stdout --ba-arg "${BA_ARG}"

sudo groupadd ckb
sudo useradd \
  -g ckb --no-user-group \
  --home-dir /var/lib/ckb --no-create-home \
  --shell /usr/sbin/nologin \
  --system ckb

sudo chown -R ckb:ckb /var/lib/ckb
sudo chmod 755 /var/lib/ckb
sudo chmod 644 /var/lib/ckb/ckb.toml /var/lib/ckb/ckb-miner.toml

sudo sed -i'' "s/threads\\s*=.*/threads = ${MINER_THREADS}/" /var/lib/ckb/ckb-miner.toml

sudo mv init/linux-systemd/ckb.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/ckb.service
sudo chmod 644 /etc/systemd/system/ckb.service
sudo systemctl daemon-reload
sudo systemctl enable ckb.service

sudo mv init/linux-systemd/ckb-miner.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/ckb-miner.service
sudo chmod 644 /etc/systemd/system/ckb-miner.service
sudo systemctl daemon-reload
sudo systemctl enable ckb-miner.service

cd ..
rm -rf "${CKB_PKG%.tar.gz}"
