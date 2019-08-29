FROM ubuntu:xenial

# Defaults
ARG RUBY_VERSION="2.5.3"

# Install libraries
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        libpq-dev \
        unzip \
        openjdk-8-jre && \
    rm -rf /var/lib/apt/lists/*
RUN \curl -sSL https://get.rvm.io | bash -s stable

# Install ruby version
RUN /bin/bash -l -c "rvm install ${RUBY_VERSION}"
RUN /bin/bash -l -c "gem install bundler --no-rdoc --no-ri"
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh"

# Install allure
COPY allure-commandline-2.9.0.zip .
RUN unzip allure-commandline-2.9.0.zip
RUN rm allure-commandline-2.9.0.zip
ENV PATH="/allure-2.9.0/bin:${PATH}"
ENV ALLURE_CONFIG="/allure-config/allure.properties"

# Copy test scripts
WORKDIR /tests
COPY Gemfile .
COPY Gemfile.lock .
RUN /bin/bash -l -c bundle install
COPY . .

RUN chmod +x spec/*
ENTRYPOINT ["/bin/bash", "-l", "-c"]