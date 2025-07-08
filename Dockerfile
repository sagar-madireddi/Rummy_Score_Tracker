FROM ruby:3.2

WORKDIR /app

COPY . .

RUN gem install bundler
RUN bundle install

ENV PORT=8080
EXPOSE 8080

CMD ["ruby", "app.rb"]
