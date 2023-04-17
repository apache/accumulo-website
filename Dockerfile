FROM ruby:2.7.8-slim-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /site

COPY Gemfile /site/Gemfile
COPY Gemfile.lock /site/Gemfile.lock

RUN gem update --system && bundle install && gem cleanup

ENV HOST=0.0.0.0
ENV PORT=4000

EXPOSE $PORT

CMD bundle exec jekyll serve --force-polling -H $HOST -P $PORT
