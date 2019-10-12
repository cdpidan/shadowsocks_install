# Firewall set
firewall_set(){
    echo -e "[${green}Info${plain}] firewall set start..."
    systemctl status firewalld > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        default_zone=$(firewall-cmd --get-default-zone)
        firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/tcp
        firewall-cmd --permanent --zone=${default_zone} --add-port=${shadowsocksport}/udp
        firewall-cmd --reload
    else
        echo -e "[${yellow}Warning${plain}] firewalld looks like not running or not installed, please enable port ${shadowsocksport} manually if necessary."
    fi
    echo -e "[${green}Info${plain}] firewall set completed..."
}

install_docker(){
    docker version > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Docker-ce exists ..."
    else
        yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        yum makecache fast
        yum install --nobest docker-ce -y
        systemctl enable docker
        systemctl start docker
    fi
}

run_docker(){
    mkdir -p /etc/shadowsocks-libev
	cat > /etc/shadowsocks-libev/config.json<<-EOF
{
	"server": "0.0.0.0",
	"server_port": ${shadowsocksport},
	"password": "${shadowsockspwd}",
	"timeout": 300,
	"user": "nobody",
	"method": "chacha20-ietf-poly1305",
	"fast_open": true,
	"nameserver": "8.8.8.8",
	"mode": "tcp_and_udp"
}
EOF
    
	docker rm -f ss-libev > /dev/null 2>&1
    docker run -d -p ${shadowsocksport}:${shadowsocksport} -p ${shadowsocksport}:${shadowsocksport}/udp --restart=always --name ss-libev -v /etc/shadowsocks-libev:/etc/shadowsocks-libev teddysun/shadowsocks-libev
}

format_parameters(){
    [ -z $shadowsocksport ] && shadowsocksport=21321
    [ -z $shadowsockspwd ] && shadowsockspwd="helloworld123"
}

install_shadowsocks_libev(){
    install_docker
    format_parameters
    run_docker
    firewall_set
}

# Initialization step

shadowsocksport=$1
shadowsockspwd=$2

install_shadowsocks_libev