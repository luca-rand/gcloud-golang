FROM buildpack-deps:stretch-scm

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
  g++ \
  gcc \
  libc6-dev \
  make \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.13.1

RUN wget -O go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
RUN tar -C /usr/local -xzf go.tgz
RUN rm go.tgz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN go version

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

ARG CLOUD_SDK_VERSION=265.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ARG INSTALL_COMPONENTS
RUN apt-get update -qqy && apt-get install -qqy \
  curl \
  gcc \
  python-dev \
  python-setuptools \
  apt-transport-https \
  lsb-release \
  openssh-client \
  git \
  gnupg \
  && easy_install -U pip && \
  pip install -U crcmod && \
  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update && apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 $INSTALL_COMPONENTS && \
  gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image && \
  gcloud --version

VOLUME ["/root/.config"]