FROM alpine:latest

# نصب پیش‌نیازهای اجرا
RUN apk add --no-cache curl bash ca-certificates tzdata openssl
ENV TZ=Asia/Tehran

# تعیین پورت دلخواه از طریق متغیر محیطی پنل
ENV XUI_PORT=48293

WORKDIR /app

# دانلود، استخراج و تغییر نام ساختار اصلی به نام‌های کاملاً عمومی
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then ARCH="amd64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi && \
    curl -sL "https://github.com/mhsanaei/3x-ui/releases/latest/download/x-ui-linux-${ARCH}.tar.gz" -o panel.tar.gz && \
    tar -zxvf panel.tar.gz && \
    rm -f panel.tar.gz && \
    mv x-ui core-panel && \
    chmod +x /app/core-panel/x-ui /app/core-panel/bin/xray-linux-*

# تغییر نام فایل اجرایی اصلی به یک نام عمومی
RUN mv /app/core-panel/x-ui /app/core-panel/core

# ساخت پوشه اختصاصی برای دیتابیس در مسیر امن
RUN mkdir -p /app/core-panel/database

WORKDIR /app/core-panel

# باز کردن پورت جدید در داکر
EXPOSE 48293

# پیوند دادن مسیر پیش‌فرض دیتابیس به پوشه امن خودمان
RUN rm -rf /etc/x-ui && ln -s /app/core-panel/database /etc/x-ui

# اجرای صحیح پنل
CMD ["./core", "run"]
