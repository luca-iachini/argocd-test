ARG GOLANG_IMAGE=golang:1.16.5-alpine

FROM ${GOLANG_IMAGE} AS build

RUN set -ex \
    && GRPC_HEALTH_PROBE_VERSION=v0.4.5 \
    && wget -qO /go/bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/${GRPC_HEALTH_PROBE_VERSION}/grpc_health_probe-linux-amd64 \
    && chmod +x /go/bin/grpc_health_probe

RUN mkdir -p /app
WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY . .
RUN go build -o ./server cmd/order/main.go

FROM ${GOLANG_IMAGE} AS serve

RUN mkdir -p /app

WORKDIR /app
COPY --from=build /go/bin/grpc_health_probe /bin/grpc_health_probe
COPY --from=build /app/server .

EXPOSE 8080

ENTRYPOINT ["./server"]