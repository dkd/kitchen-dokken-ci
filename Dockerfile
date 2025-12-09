FROM ruby:3.4.7-slim-bookworm@sha256:8dba3b1bf6b1bdd3aefb0deef9d866fa16f8eb346566d9d592e78af7e6d34d4e
LABEL maintainer="Ivan Golman <ivan.golman@dkd.de>, dkd Internet Service GmbH"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt update && \
    apt install -y locales && \
    DEBIAN_FRONTEND=noninteractive && \
    DEBCONF_NONINTERACTIVE_SEEN=true && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

RUN apt update && \
    apt install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    gcc \
    g++ \
    git \
    make \
    rsync \
    ssh \
    vim-tiny \
    tar \
    xz-utils \
    curl \
    wget \
    gnupg2 \
    ruby-dev \
    libyaml-dev

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt update && apt install -y  docker-ce-cli

RUN apt-get clean && apt-get autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*log /var/log/apt/* /var/lib/dpkg/*-old /var/cache/debconf/*-old && \
    ln -s /usr/bin/vi /usr/bin/vim

#COPY vendor /vendor
#RUN cd /vendor/kitchen-dokken/ && \
#    gem build kitchen-dokken.gemspec -o kitchen-dokken-2.20.7.gem && \
#    gem install kitchen-dokken-2.20.7.gem --ignore-dependencies
COPY Gemfile /Gemfile
RUN bundle config set --global no_document true && bundle install

CMD ["/bin/bash"]
