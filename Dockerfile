FROM guilhem/twemproxy

ENV GOLANG_VERSION 1.7.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 43ad621c9b014cde8db17393dc108378d37bc853aa351a6c74bf6432c1bbd182

RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
    ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
ENV SOURCE_DIR $GOPATH/src/github.com/kubernetes-twemproxy
ENV TWEMPROXY_CONFIG_PATH /etc/twemproxy

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$SOURCE_DIR" "$TWEMPROXY_CONFIG_PATH" && chmod -R 777 "$GOPATH"

COPY main.go /go/src/github.com/kubernetes-twemproxy/
COPY vendor /go/src/github.com/kubernetes-twemproxy/vendor
COPY template.yaml $TWEMPROXY_CONFIG_PATH/

WORKDIR $SOURCE_DIR

RUN go build

RUN cp kubernetes-twemproxy /usr/local/bin

RUN rm -fr $GOPATH /usr/local/go

WORKDIR /usr/local

ENTRYPOINT ["/usr/local/bin/kubernetes-twemproxy", "-twemproxy", "/usr/sbin/nutcracker"]
