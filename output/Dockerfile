# This Dockerfile builds an ruby environment for jekyll that empowers
# making updates to the accumulo website without requiring the dev
# to maintain a local ruby development environment.

FROM ruby:2.7.8-slim-bullseye as base

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /mnt/workdir

# Copy over the Gemfiles so that all build dependencies are installed
# during the docker build. At runtime, these will be available to Jekyll
# from the mounted directory. But that's not available during the
# docker build, so we need to copy them in to pre-install the Gems

COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

# Gems will be installed under GEM_HOME which is set by the ruby image.
# See https://hub.docker.com/_/ruby for details.

RUN gem update --system && bundle install && gem cleanup

ENV HOST=0.0.0.0
ENV PORT=4000

EXPOSE $PORT

# Configure the default command to build from the mounted repository.
CMD bundle exec jekyll serve --force-polling -H $HOST -P $PORT
