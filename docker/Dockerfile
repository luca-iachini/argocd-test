ARG GOLANG_IMAGE=golang:1.17.1-alpine

FROM ${GOLANG_IMAGE} AS build
ARG PACKAGE_NAME

RUN mkdir -p /app
WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY go/${PACKAGE_NAME} .
RUN go build -o ./server main.go

FROM ${GOLANG_IMAGE} AS serve

RUN mkdir -p /app

WORKDIR /app
COPY --from=build /app/server .

EXPOSE 9080

ENTRYPOINT ["./server"]