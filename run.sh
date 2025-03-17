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
    chmod +x sh/install_sentinel.sh
    ./sh/install_sentinel.sh
    echo "Redis Sentinel安装完成"
    show_menu
}

# 卸载redis_sentinel
function uninstall_redis_sentinel() {
    echo "开始卸载Redis Sentinel..."
    chmod +x sh/uninstall_sentinel.sh
    ./sh/uninstall_sentinel.sh
    rm -rf runtime/  # 正确的相对路径，因为run.sh在根目录
    echo "Redis Sentinel卸载完成"
    show_menu
}

# 安装mysql_docker
function install_mysql_docker() {
    check_docker
    echo "开始安装mysql_docker..."
    chmod +x sh/install_mysql_docker.sh
    ./sh/install_mysql_docker.sh
    
    # 检查安装结果
    if [ $? -eq 0 ]; then
        echo "MySQL Docker安装成功"
    else
        echo "MySQL Docker安装失败"
    fi
    show_menu
}

# 卸载mysql_docker
function uninstall_mysql_docker() {
    echo "开始卸载mysql_docker..."
    chmod +x sh/uninstall_mysql_docker.sh
    ./sh/uninstall_mysql_docker.sh
    rm -rf runtime/
    echo "mysql_docker卸载完成"
    show_menu
}


# 安装PPP_mangage
function install_PPP_mangage() {
    echo "开始安装PPP_mangage..."    
    # 编译程序
    go build -o ppp_mangage
    
    echo "PPP_mangage安装完成"
    show_menu
}



# 卸载PPP_mangage
function uninstall_PPP_mangage() {
    echo "开始卸载PPP_mangage..."
    
    # 获取进程PID
    PID=$(pgrep -f ppp_mangage)
    
    if [ ! -z "$PID" ]; then
        echo "正在停止 PPP_mangage 进程 (PID: $PID)..."
        # 先尝试优雅停止
        kill $PID
        sleep 2
        
        # 检查进程是否仍在运行
        if ps -p $PID > /dev/null; then
            echo "强制终止进程..."
            kill -9 $PID
        fi
    else
        echo "PPP_mangage 进程未运行"
    fi
    
    # 删除二进制文件
    rm -f ppp_mangage
    echo "PPP_mangage卸载完成"
    show_menu
}

# 安装screen
function install_screen() {
    if ! command -v screen &> /dev/null; then
        echo "正在安装screen..."
        apt-get update && apt-get install -y screen
    fi
}

# 启动PPP_mangage
function start_PPP_mangage() {
    install_screen
    echo "正在启动PPP_mangage..."
    
    # 检查程序是否存在
    if [ ! -f ./ppp_mangage ]; then
        echo "错误: ppp_mangage 程序不存在，请先编译"
        show_menu
        return
    fi
    
    # 创建logs目录(在项目根目录)
    mkdir -p $(dirname $0)/logs
    touch $(dirname $0)/logs/ppp_manage.log
    chmod 777 -R $(dirname $0)/logs
    
    # 检查是否已有screen会话
    if screen -ls | grep -q "ppp_manage"; then
        echo "检测到已存在的ppp_manage会话，先清理..."
        screen -S ppp_manage -X quit
        sleep 2
    fi
    
    # 使用screen启动程序并重定向日志
    cd $(dirname $0)  # 切换到脚本所在目录
    screen -dm -S ppp_manage bash -c './ppp_mangage 2>&1 | tee logs/ppp_manage.log'
    sleep 2
    
    # 验证启动状态
    if screen -ls | grep -q "ppp_manage"; then
        echo "PPP_mangage已在screen中启动成功"
        echo "使用 'cat logs/ppp_manage.log' 可以查看程序日志"
    else
        echo "PPP_mangage启动失败，请检查日志"
    fi
    show_menu
}

# 查看PPP_mangage会话
function view_PPP_mangage() {
    if [ ! -f $(dirname $0)/logs/ppp_manage.log ]; then
        echo "日志文件不存在，可能程序还未运行"
        return
    fi
    cat $(dirname $0)/logs/ppp_manage.log
}

# 编译PPP_mangage
function build_PPP_mangage() {
    echo "正在编译PPP_mangage..."
    
    # 检查文件是否存在
    if [ -f "./ppp_mangage" ]; then
        echo "检测到已存在的ppp_mangage，先卸载..."
        uninstall_PPP_mangage
    else
        echo "未检测到已存在的ppp_mangage，直接编译..."
    fi
    
    # 编译程序
    go build -o ppp_mangage
    
    if [ $? -eq 0 ]; then
        echo "编译完成"
    else
        echo "编译失败"
    fi
    show_menu
}

# 停止PPP_mangage
function stop_PPP_mangage() {
    echo "正在停止PPP_mangage..."
    
    # 停止screen会话
    if screen -ls | grep -q "ppp_manage"; then
        screen -S ppp_manage -X quit
    fi
    
    # 停止ppp_mangage进程
    PID=$(pgrep -f ppp_mangage)
    if [ ! -z "$PID" ]; then
        echo "正在停止进程 (PID: $PID)..."
        kill $PID
        sleep 2
        # 如果进程仍在运行，强制终止
        if ps -p $PID > /dev/null; then
            kill -9 $PID
        fi
    fi
    
    echo "PPP_mangage已停止"
}

# 重启PPP_mangage
function restart_PPP_mangage() {
    echo "正在重启PPP_mangage..."
    stop_PPP_mangage
    sleep 2
    start_PPP_mangage
    echo "PPP_mangage重启完成"
}

# 一键完全卸载
function uninstall_all() {
    echo "开始一键完全卸载..."
    
    # 停止并卸载PPP_mangage
    stop_PPP_mangage
    uninstall_PPP_mangage  
    # 卸载mysql_docker
    uninstall_mysql_docker
    
    # 卸载redis_sentinel
    uninstall_redis_sentinel
   
    # 清理日志
    rm -rf $(dirname $0)/logs/
    
    echo "所有组件已完全卸载"
    show_menu
}

# 一键完整安装
function install_all() {
    echo "开始一键安装所有组件..."
    
    # 1. 安装redis_sentinel
    check_docker
    echo "正在安装Redis Sentinel..."
    chmod +x sh/install_sentinel.sh
    ./sh/install_sentinel.sh
    
    if [ $? -ne 0 ]; then
        echo "Redis Sentinel安装失败"
        return
    fi
    
    # 2. 安装mysql_docker
    echo "正在安装MySQL..."
    chmod +x sh/install_mysql_docker.sh
    ./sh/install_mysql_docker.sh
    
    if [ $? -ne 0 ]; then
        echo "MySQL安装失败"
        return
    fi
    
    # 3. 编译并安装PPP_mangage
    echo "正在编译PPP_mangage..."
    go build -o ppp_mangage
    
    if [ $? -ne 0 ]; then
        echo "PPP_mangage编译失败"
        return
    fi
    
    # 4. 启动PPP_mangage
    echo "正在启动PPP_mangage..."
    start_PPP_mangage
    
    echo "所有组件安装完成并已启动"
    show_menu
}

# 显示主菜单
function show_menu() {
    PS3='请选择一个操作: '
    options=("一键完整安装" "一键完全卸载" 
             "安装redis_sentinel" "卸载redis_sentinel" "安装mysql_docker" "卸载mysql_docker" 
             "安装PPP_mangage" "卸载PPP_mangage" "启动PPP_mangage" "停止PPP_mangage" 
             "重启PPP_mangage" "查看PPP_mangage日志" "编译PPP_mangage" "返回菜单" "退出")
    select opt in "${options[@]}"; do
        case $opt in
            "一键完整安装")
                install_all
                ;;
            "一键完全卸载")
                uninstall_all
                ;;
            "安装redis_sentinel")
                install_redis_sentinel
                ;;
            "卸载redis_sentinel")
                uninstall_redis_sentinel
                ;;
            "安装mysql_docker")
                install_mysql_docker
                ;;
            "卸载mysql_docker")
                uninstall_mysql_docker
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
            "停止PPP_mangage")
                stop_PPP_mangage
                show_menu
                ;;
            "重启PPP_mangage")
                restart_PPP_mangage
                ;;
            "查看PPP_mangage日志")
                view_PPP_mangage
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