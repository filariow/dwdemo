FROM golang:1.20
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

WORKDIR /app
COPY . .
RUN go get -v ./...
RUN go build -ldflags="-s -w" -o vault-cli main.go

CMD "/app/vault-cli"
