#!/bin/bash

# 检查Docker是否已安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo "正在安装Docker..."
        curl -fsSL https://get.docker.com | sh
        systemctl start docker
        systemctl enable docker
    fi
}

# 安装redis_sentinel
function install_redis_sentinel() {
    check_docker
    echo "开始安装Redis Sentinel..."
    chmod +x sentinel.sh
    ./sentinel.sh
    echo "Redis Sentinel安装完成"
    show_menu
}

# 安装PPP_mangage
function install_PPP_mangage() {
    echo "开始安装PPP_mangage..."
    # 安装MySQL
    if ! command -v mysql &> /dev/null; then
        apt-get update
        apt-get install -y mysql-server
        systemctl start mysql
        systemctl enable mysql
    fi
    
    # 导入数据库
    mysql < ppp.sql
    
    # 编译程序
    go build -o ppp_mangage
    
    echo "PPP_mangage安装完成"
    show_menu
}

# 卸载redis_sentinel
function uninstall_redis_sentinel() {
    echo "开始卸载Redis Sentinel..."
    chmod +x remove_sentinel.sh
    ./remove_sentinel.sh
    rm -rf runtime/
    echo "Redis Sentinel卸载完成"
    show_menu
}

# 卸载PPP_mangage
function uninstall_PPP_mangage() {
    echo "开始卸载PPP_mangage..."
    sudo pkill -9 -f ppp_mangage
    rm -f ppp_mangage
    echo "PPP_mangage卸载完成"
    show_menu
}

# 启动PPP_mangage
function start_PPP_mangage() {
    echo "正在启动PPP_mangage..."
    ./ppp_mangage &
    echo "PPP_mangage已启动"
    show_menu
}

# 编译PPP_mangage
function build_PPP_mangage() {
    echo "正在编译PPP_mangage..."
    uninstall_PPP_mangage
    go build -o ppp_mangage
    echo "编译完成"
    show_menu
}

# 显示主菜单
function show_menu() {
    PS3='请选择一个操作: '
    options=("安装redis_sentinel" "卸载redis_sentinel" "安装PPP_mangage" "卸载PPP_mangage" "启动PPP_mangage" "编译PPP_mangage" "返回菜单" "退出")
    select opt in "${options[@]}"; do
        case $opt in
            "安装redis_sentinel")
                install_redis_sentinel
                ;;
            "卸载redis_sentinel")
                uninstall_redis_sentinel
                ;;                
            "安装PPP_mangage")
                install_PPP_mangage
                ;;
            "卸载PPP_mangage")
                uninstall_PPP_mangage
                ;;
            "启动PPP_mangage")
                start_PPP_mangage
                ;;
            "编译PPP_mangage")
                build_PPP_mangage
                ;;
            "返回菜单")
                show_menu
                ;;                      
            "退出")
                exit 0                
                ;;
            *) echo "无效选项 $REPLY";;
        esac
    done
}

# 脚本入口
show_menu