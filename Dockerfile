FROM openjdk:8
MAINTAINER Guangwen Zhou <zgwmike@hotmail.com>

ARG DEBIAN_FRONTEND=noninteractive
ENV BUILDMASTER localhost
ENV BUILDMASTER_PORT 9989
ENV WORKERNAME docker

COPY    buildbot.tac /buildbot/buildbot.tac

# Install sbt
RUN echo "deb http://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
    apt-get update && \
    apt-get -y upgrade

RUN apt-get -y install -q \
        sbt \
        build-essential \
        git \
        python-dev \
        libffi-dev \
        libssl-dev \
        python-pip \
        curl && \
    rm -rf /var/lib/apt/lists/* && \
    curl -Lo /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/local/bin/dumb-init 

RUN	pip install -U pip virtualenv && \
    pip install --upgrade cffi && \
    pip install 'twisted[tls]' && \
    pip install -U setuptools && \
    pip install buildbot-worker && \
    pip install ansible && \
    useradd -ms /bin/bash buildbot && chown -R buildbot /buildbot

USER buildbot
WORKDIR /buildbot

CMD ["/usr/local/bin/dumb-init", "twistd", "-ny", "buildbot.tac"]