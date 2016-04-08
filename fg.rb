# A Rails Starter

# Bootstrap
gem 'bootstrap-generators'
generate 'bootstrap:install'

# run 'bin/rake rails:template LOCATION=https://raw.github.com/RailsApps/rails-composer/master/composer.rb'

# TODO: Add omniauth domain restriction
# If we set up omniauth, restrict it to fitmentgroup.
# something along the lines of
# find /config.omniauth(.*?)\n/
# replace with config.omniauth\1 {hd: 'fitmentgroup.com'}



if yes?("Add Raven/Sentry? (y/n)")
  dsn = ask("What's the DSN? (Or leave blank for now)")
  # Raven / Sentry
  gem 'sentry-raven'

  initializer 'raven.rb', <<-CODE.gsub(/^ {4}/, '')
    Raven.configure do |config|
      config.dsn = '#{dsn}'
    end
  CODE

  if dsn.length == 0
    raven_config = 'config/initializers/raven.rb'
    insert_into_file raven_config, <<-EOF.gsub(/^ {6}/,'')
      Uncomment the following and add your Sentry DSN.
      http://www.getsentry.com for more info.
    EOF
    comment_lines raven_config, /.*/
  end

end

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

