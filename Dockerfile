FROM golang:1.24-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 https://github.com/AminMGMT/BackPack.git .

ENV GOPROXY=https://proxy.golang.org,https://mirror-go.runflare.com,https://goproxy.cn,direct
ENV GOSUMDB=off
ENV GOTOOLCHAIN=local

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /backpack .

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/backpack /root/BackPack/backups

COPY --from=builder /backpack /usr/local/bin/backpack

RUN chmod +x /usr/local/bin/backpack

ENTRYPOINT ["/usr/local/bin/backpack"]
