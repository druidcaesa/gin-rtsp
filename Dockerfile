# 第一阶段：编译 Go 代码
FROM golang as builder

WORKDIR /app
COPY . .

ENV CGO_ENABLED=0
ENV GO111MODULE=on

# 设置 Go Module 代理
RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go mod download

# 增加调试信息
RUN go build -o main .

# 第二阶段：构建最终镜像
FROM ubuntu

ENV TZ=Asia/Shanghai
ENV LANG=en_US.UTF-8
ENV LOG_LEVEL=info

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g'  /etc/apt/sources.list \
    && apt-get update \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && apt-get install -y locales tzdata ffmpeg \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /app/main .

EXPOSE 3000

CMD ["./main"]
