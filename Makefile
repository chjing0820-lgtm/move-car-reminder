.PHONY: setup build install run test clean help

help:
	@echo "========================================"
	@echo "  挪车提醒 APP 一键部署"
	@echo "========================================"
	@echo ""
	@echo "可用命令："
	@echo "  make setup       - 初始化项目（第一次运行）"
	@echo "  make build       - 编译项目"
	@echo "  make install     - 编译并安装到手机"
	@echo "  make run         - 编译、安装、启动应用"
	@echo "  make uninstall   - 从手机卸载应用"
	@echo "  make test        - 发送测试短信"
	@echo "  make clean       - 清理编译文件"
	@echo "  make logcat      - 查看手机日志"
	@echo ""

# 初始化项目
setup:
	@echo "🔧 初始化项目..."
	@chmod +x gradlew
	@./gradlew --version
	@echo "✅ 初始化完成"
	@echo ""
	@echo "📋 请确保："
	@echo "  1. 手机已用 USB 线连接到电脑"
	@echo "  2. 手机已启用 USB 调试"
	@echo "  3. 已经允许了 USB 调试权限"
	@echo ""

# 编译项目
build:
	@echo "🔨 编译项目..."
	@./gradlew clean build -x test
	@echo "✅ 编译成功"

# 安装到手机
install: build
	@echo "📱 安装到手机..."
	@adb install -r app/build/outputs/apk/debug/app-debug.apk
	@echo "✅ 安装成功"

# 运行应用
run: install
	@echo "🚀 启动应用..."
	@adb shell am start -n com.example.move_car_alert/.MainActivity
	@echo "✅ 应用已启动"
	@echo ""
	@echo "📱 请在手机上点击 '开启监听' 按钮并允许所有权限"

# 卸载应用
uninstall:
	@echo "🗑️  卸载应用..."
	@adb uninstall com.example.move_car_alert
	@echo "✅ 卸载成功"

# 清理编译文件
clean:
	@echo "🧹 清理编译文件..."
	@./gradlew clean
	@echo "✅ 清理完成"

# 查看手机日志
logcat:
	@echo "📋 显示应用日志（按 Ctrl+C 退出）..."
	@adb logcat | grep -i "SmsReceiver\|MoveCarAlarmService\|move_car"

# 发送测试短信（需要手机端支持）
test:
	@echo "📨 发送测试短信..."
	@adb shell am start -a android.intent.action.SENDTO -d "sms:10086" \
		--es sms_body "测试挪车短信，请尽快移车" 2>/dev/null || \
		echo "⚠️  可能需要手动打开短信应用发送测试短信"
	@echo ""
	@echo "💡 提示：你也可以用另一部手机或电话给这部手机发送包含以下关键词的短信："
	@echo "    挪车、交警、违停、停车、车位、违章、车牌、请移车"

# 检查手机连接
check-device:
	@echo "🔍 检查手机连接..."
	@adb devices
	@echo ""

# 首次运行：完整流程
first-time: setup check-device run
	@echo ""
	@echo "🎉 首次配置完成！"
	@echo ""
	@echo "接下来的步骤："
	@echo "  1. ✅ 手机屏幕应该打开了应用"
	@echo "  2. 点击 '开启监听' 按钮"
	@echo "  3. 逐个允许权限请求（短信、通知、振动等）"
	@echo "  4. 当提示'设置为默认短信应用'时，选择允许"
	@echo "  5. ✅ 完成！应用开始后台监听"
	@echo ""
	@echo "📱 测试："
	@echo "  - 用另一部手机给这部手机发送包含'挪车'的短信"
	@echo "  - 手机应该立即振动 + 闹钟提醒"
	@echo ""
	@echo "查看日志："
	@echo "  make logcat"
	@echo ""
