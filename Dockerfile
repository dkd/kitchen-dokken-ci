FROM ruby:3.1.6-slim-bookworm
LABEL maintainer="Ivan Golman <ivan.golman@dkd.de>, dkd Internet Service GmbH"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN apt-get update && \
    apt-get install -y locales && \
    DEBIAN_FRONTEND=noninteractive && \
    DEBCONF_NONINTERACTIVE_SEEN=true && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

RUN apt-get update && \
    apt-get install -y software-properties-common gcc g++ git make rsync ssh vim-tiny tar xz-utils curl wget gnupg2 ruby ruby-dev && \
    apt-get clean && apt-get autoclean && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*log /var/log/apt/* /var/lib/dpkg/*-old /var/cache/debconf/*-old && \
    ln -s /usr/bin/vi /usr/bin/vim

COPY vendor /vendor
RUN cd /vendor/kitchen-dokken/ && \
    gem build kitchen-dokken.gemspec -o kitchen-dokken-2.20.7.gem && \
    gem install kitchen-dokken-2.20.7.gem --ignore-dependencies
COPY Gemfile /Gemfile
RUN bundle config set --global no_document true && bundle install

CMD ["/bin/bash"]