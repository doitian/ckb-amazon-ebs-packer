#!/usr/bin/env bash

set -e
set -u
[ -n "${DEBUG:-}" ] && set -x || true

CKB_PKG="ckb_opt.tar.gz"
curl -LO "https://github.com/rink1969/ckb/releases/download/v0.16_opt/${CKB_PKG}"
tar -xzf "${CKB_PKG}"
rm -f "${CKB_PKG}"

sudo mv ckb /usr/local/bin
sudo chown root:root /usr/local/bin/ckb
sudo chmod 755 /usr/local/bin/ckb

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

MINER_THREADS="${MINER_THREADS:-"$(nproc)"}"
sudo sed -i'' "s/threads\\s*=.*/threads = ${MINER_THREADS}/" /var/lib/ckb/ckb-miner.toml

curl -L -O https://raw.githubusercontent.com/nervosnetwork/ckb/master/devtools/init/linux-systemd/ckb.service
sudo cp ckb.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/ckb.service
sudo chmod 644 /etc/systemd/system/ckb.service
sudo systemctl daemon-reload
sudo systemctl enable ckb.service

curl -L -O https://raw.githubusercontent.com/nervosnetwork/ckb/master/devtools/init/linux-systemd/ckb-miner.service
sudo cp ckb-miner.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/ckb-miner.service
sudo chmod 644 /etc/systemd/system/ckb-miner.service
sudo systemctl daemon-reload
sudo systemctl enable ckb-miner.service
