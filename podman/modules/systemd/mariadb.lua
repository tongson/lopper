return {
ports = { "3306" },
volumes = {
	["mariadb-data"] = {
		"chown -R 999:999 __MOUNTPOINT__",
	},
	["mariadb-secret"] = {
		"test -f __MOUNTPOINT__/password || tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 > __MOUNTPOINT__/password",
	      "chmod 0600 __MOUNTPOINT__/password",
	},
},
unit = [==[
[Unit]
Description=MariaDB Container
Wants=network.target
After=network-online.target

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
RestartSec=5
Type=notify
NotifyAccess=all
KillMode=mixed
SystemCallArchitectures=native
MemoryDenyWriteExecute=yes
LockPersonality=yes
NoNewPrivileges=yes
RemoveIPC=yes
DevicePolicy=closed
PrivateTmp=yes
PrivateNetwork=false
ProtectKernelModules=yes
ProtectSystem=full
ProtectHome=yes
ProtectKernelLogs=yes
ProtectClock=yes
RestrictRealtime=yes
#RestrictSUIDSGID=yes
ProtectKernelTunables=yes
RestrictAddressFamilies=AF_INET AF_UNIX
LimitMEMLOCK=infinity
LimitNOFILE=65536
LimitNPROC=infinity
ExecStart=/usr/bin/podman run --name mariadb \
--security-opt apparmor=unconfined \
--security-opt seccomp=/etc/podman.seccomp/mariadb.json \
--rm \
--replace \
--sdnotify conmon \
--network host \
--hostname mariadb  \
--dns 127.255.255.53 \
--cap-drop all \
--cap-add setgid \
--cap-add setuid \
--cap-add dac_read_search \
-e "MYSQL_ROOT_PASSWORD_FILE=/etc/mysql/secret/password" \
-e "MALLOC_ARENA_MAX=2" \
-e "TZ=UTC" \
--ulimit nofile=65536:65536 \
--ulimit nproc=65536:65536 \
--cpu-shares __SHARES__ \
--cpuset-cpus __CPUS__ \
--memory __MEM__ \
-v mariadb-data:/var/lib/mysql:rw \
-v mariadb-secret:/etc/mysql/secret \
__ID__ --character-set-server=utf8mb4, --collation-server=utf8mb4_unicode_ci --wait_timeout=28800 --log-warnings=0 --bind-address=__IP__ --port=3306

[Install]
WantedBy=multi-user.target
]==],
}
