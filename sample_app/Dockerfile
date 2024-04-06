FROM ruby:3.3.0

WORKDIR /workspace

RUN apt-get update \
  && apt-get install -y locales default-mysql-client awscli --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

WORKDIR /workspace/sample_app

ENTRYPOINT ["./bin/start_server"]
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
