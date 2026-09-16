FROM alpine:latest

# نصب پیش‌نیازهای اجرا
RUN apk add --no-cache curl bash ca-certificates tzdata openssl
ENV TZ=Asia/Tehran

# تعریف متغیرهای محیطی برای مبهم‌سازی و تغییر مسیرها
ENV XUI_DB_FOLDER="/app/core-panel/database"
ENV XUI_LOG_FOLDER="/app/core-panel/logs"
ENV XUI_BIN_FOLDER="/app/core-panel/binaries"

WORKDIR /app

# دانلود، استخراج و تغییر نام پوشه‌ها و فایل‌ها به نام‌های کاملاً عمومی
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    curl -sL "https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-${ARCH}.tar.gz" -o panel.tar.gz && \
    tar -zxvf panel.tar.gz && \
    rm -f panel.tar.gz && \
    mv x-ui core-panel && \
    chmod +x /app/core-panel/x-ui /app/core-panel/bin/xray-linux-*

# تغییر نام فایل اجرایی اصلی به یک نام عمومی
RUN mv /app/core-panel/x-ui /app/core-panel/core

# ساخت پوشه‌های مورد نیاز برای دیتابیس و لاگ‌ها
RUN mkdir -p /app/core-panel/database /app/core-panel/logs

# پورت پنل (می‌تونی یک پورت غیرپیش‌فرض و دلخواه بذاری)
EXPOSE 48293

# اجرای فایل اجرایی با مسیر جدید دیتابیس
WORKDIR /app/core-panel
CMD ["./core", "--db", "/app/core-panel/database/data.db"]
