FROM ruby:2.6
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
CMD ["jekyll", "serve"]
