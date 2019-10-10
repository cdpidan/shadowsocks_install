yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum install docker-ce -y
systemctl start docker

mkdir -p /etc/shadowsocks-libev
cat > /etc/shadowsocks-libev/config.json<<-EOF
{
	"server": "0.0.0.0",
	"server_port": $1,
	"password": "$2",
	"timeout": 300,
	"user": "nobody",
	"method": "chacha20-ietf-poly1305",
	"fast_open": true,
	"nameserver": "8.8.8.8",
	"mode": "tcp_and_udp"
}
EOF

docker run -d -p $1:$1 -p $1:$1/udp --restart=always --name ss-libev -v /etc/shadowsocks-libev:/etc/shadowsocks-libev teddysun/shadowsocks-libev
