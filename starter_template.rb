# Tim's Rails Starter

# Bootstrap
gem 'bootstrap-generators'

after_bundle do
  generate 'bootstrap:install --force'
end

# Raven / Sentry
gem 'sentry-raven'

initializer 'raven.rb', <<-CODE.gsub(/^ {2}/, '')
  # Uncomment and add your DSN to have Raven report errors to Sentry.
  # http://www.getsentry.com

  # Raven.configure do |config|
  #   config.dsn = ''
  # end
CODE

# Docker
file 'Dockerfile', <<-EOF.gsub(/^ {2}/, '')
  FROM ruby:2.2.0

  CMD rails s -b 0.0.0.0

  EXPOSE 3000

  RUN apt-get update -qq && apt-get install -y build-essential nodejs

  # for Postgres
  # RUN apt-get update -qq && apt-get install -y libpq-dev

  # for nokogiri
  # RUN apt-get update -qq && apt-get install -y libxml2-dev libxslt1-dev

  # for capybara-webkit
  # RUN apt-get update -qq && apt-get install -y libqt4-webkit libqt4-dev xvfb

  RUN mkdir /myapp
  WORKDIR /myapp

  ADD Gemfile* .

  RUN bundle install

  ADD . .
EOF

file 'docker-compose.yml', <<-EOF.gsub(/^ {2}/, '')
  version: '2'
  services:
    app:
      build: .
      command: bundle exec rails s -b 0.0.0.0 -p 3000
      ports:
        - "3000:3000"
EOF


# Git
after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
