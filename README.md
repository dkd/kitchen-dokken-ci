This image based on official [ruby:3.1.6-slim-bookworm](https://hub.docker.com/layers/library/ruby/3.1.6-slim-bookworm/images/sha256-6bafc2a374cc0acd9f915429a456341dc4f9c4114c2e00127ac28ea0c3849b3c?context=explore) docker image and provides the complete test suite for running [kitchen.ci](https://kitchen.ci/) regression tests of [CHEF](https://www.chef.io/) cookbooks. One may use either local or as part of [GitLab CI](https://docs.gitlab.com/ee/ci/pipelines/) CI-Pipeline.

Following `gems` are additionally installed:

* `rubocop`
* `overcommit`
* `inspec`
* `berkshelf`
* `test-kitchen`
* `kitchen-docker`
* `kitchen-inspec`
* `kitchen-dokken`

### Dockerfile
```
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
```

## Usage
```
docker run -ti -v /var/run/docker.sock:/var/run/docker.sock -v /path/to/your/cookbook:/path/to/cookbook/in/container dkd/kitchen-dokken-ci:0.1.0 bash
root@3478eadc9bd4:/# cd  /path/to/cookbook/in/container
root@3478eadc9bd4:/path/to/cookbook/in/container# cookstyle .
Inspecting X files
......
X files inspected, no offenses detected
root@3478eadc9bd4:/path/to/cookbook/in/container# kitchen list/create/converge/test/destroy <suite|all>
```

## Contributing

* Fork the repo.
* Create a branch from the `master` branch and name it 'feature/name-of-feature': `git checkout -b feature/my-new-feature` (We follow [this branching model] (http://nvie.com/posts/a-successful-git-branching-model/))
* Make sure you test your new feature.
* Commit your changes together with specs for them using [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/): i.e. `git commit -am 'feat: Add some feature'`.
* Push your changes to your feature branch.
* Submit a pull request to the `master` branch. Describe your feature in the pull request. Make sure you commit the specs.
* A pull request does not necessarily need to represent the final, finished feature. Feel free to treat it as a base for discussion.
