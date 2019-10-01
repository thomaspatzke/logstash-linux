FROM docker.elastic.co/logstash/logstash-x-pack:6.2.4

COPY docker-elk/logstash-x-pack.yml /usr/share/logstash/config/logstash.yml
COPY conf.d /usr/share/logstash/pipeline/
COPY patterns.d /usr/share/logstash/pipeline/patterns.d
COPY ext /usr/share/logstash/ext
WORKDIR /usr/share/logstash/pipeline
RUN ln -s ../ext .

ENV LL_LOG_HTTPD_ACCESS /logs/apache/*-access.log
ENV LL_LOG_HTTPD_ERROR /logs/apache/*-error.log
ENV LL_LOG_AUTH /logs/auth/auth.log
ENV LL_LOG_MAIL /logs/mail/mail.log
ENV LL_LOG_IMPORT_HTTPD_ACCESS /logs/apache-import/*-access.log.*
ENV LL_LOG_IMPORT_HTTPD_ERROR /logs/apache-import/*-error.log.*
ENV LL_LOG_IMPORT_AUTH /logs/auth-import/auth.log.*
ENV LL_LOG_IMPORT_MAIL /logs/mail-import/mail.log.*                                  
ENV LL_PATTERN_DIR /usr/share/logstash/pipeline/patterns.d
ENV LL_ES_HOST http://elasticsearch:9200
