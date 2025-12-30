FROM golang:1.23-alpine as builder

WORKDIR /app

COPY main.go .

RUN CGO_ENABLED=0 go build -o server main.go

FROM alpine:3

WORKDIR /app

COPY --from=builder /app/server .

ENV PORT 8080

CMD ["./server"]
