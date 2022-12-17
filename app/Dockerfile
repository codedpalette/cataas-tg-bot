FROM --platform=$BUILDPLATFORM golang:1.19 as builder

ARG TARGETARCH

WORKDIR /usr/src/app
COPY ../go.mod ../go.sum ./
RUN go mod download && go mod verify
COPY ../*.go .
RUN GOOS=linux GOARCH=$TARGETARCH go build -v -o /usr/local/bin/app ./...

FROM alpine:latest
WORKDIR /root
COPY --from=builder /usr/local/bin/app .
CMD /root/app