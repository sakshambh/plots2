# Dockerfile # Plots2
# https://github.com/publiclab/plots2

FROM ruby:2.4.4-stretch

LABEL description="This image deploys Plots2."

# Set correct environment variables.
RUN mkdir -p /app
ENV HOME /root

#RUN echo \
#   'deb ftp://ftp.us.debian.org/debian/ jessie main\n \
#    deb ftp://ftp.us.debian.org/debian/ jessie-updates main\n \
#    deb http://security.debian.org jessie/updates main\n' \
#    > /etc/apt/sources.list

# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update -qq && apt-get install -y build-essential bundler libmariadbclient-dev ruby-rmagick libfreeimage3 wget curl procps cron make nodejs google-chrome-stable

# Install yarn
RUN npm config set strict-ssl false
RUN npm install -g yarn

RUN rm -r /usr/local/bundle

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile /tmp/Gemfile
ADD Gemfile.lock /tmp/Gemfile.lock
RUN bundle install --jobs=4

ADD . /app
WORKDIR /app

RUN yarn install && yarn postinstall
RUN passenger-config compile-nginx-engine --connect-timeout 60 --idle-timeout 60
