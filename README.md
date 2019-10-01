# Linux Logstash Config

This is a [Logstash](https://www.elastic.co/products/logstash) configuration for Linux systems. It includes
configuration and patterns provided by other projects in addition to custom created patterns/configs. This configuration
was tested on a [Ubuntu Server](https://www.ubuntu.com/server) 16.04 LTS and includes patterns and configuration for the
following log files and services:

* Httpd combined access logs (`/var/log/apache2/*-access.log`, Apache and nginx)
    * Usage of default Logstash *HTTPD_COMBINEDLOG* pattern.
    * The *vhost* attribute is aquired from the beginning of the file name until the first -. Example: `patzke.org-access.log` sets *vhost* to `patzke.org`.
    * The filter *geoip* and *useragent* are applied to the corresponding fields.
* Authentication logs (`/var/log/auth.log`)
    * Generic parsing of PAM log records
    * OpenSSH sshd:
        * Successful and failed authentication
        * Disconnect event
    * sudo
    * su
    * systemd-logind
    * Account management tools:
        * useradd
        * groupadd
        * usermod
        * userdel
        * groupdel
* Mailserver logs (`/var/log/mail.log`)
    * [Postfix](https://github.com/whyscream/postfix-grok-patterns)
    * Dovecot
    * Postgrey
    * [SpamAssassin spamd](https://github.com/ajmyyra/logstash-mail-log)
    * GeoIP postprocessing of client IPs

Default output is a local Elasticsearch instance. Indices are created per log file (httpd_access, httpd_error, auth and mail) and month.

Searches, visualizations and dashboards for Kibana are included for the areas mentioned above:

Authentication Dashboard:
![Authentication](/images/Dashboard-Authentication.png)

Failed SSH Authentication Dashboard:
![Failed SSH Authentication](/images/Dashboard-Failed_Logins.png)

Mail Dashboard:
![Mail](/images/Dashboard-Mail.png)

Web Dashboard:
![Web](/images/Dashboard-Web.png)

Further, a Docker Compose configuration is included, that sets up an ELK stack configured with the Logstash
configuration with a log source directory mounted from the host system.

## Usage

### Logstash Configuration

#### Initial

Clone this repository and initialize the submodules with `git submodule update --init`. Copy or link the directories
`conf.d`, `patterns.d` and `ext` into `/etc/logstash` or merge their content into your existing directories and restart
logstash. Most environment-specific configuration values can be set by environment variables which are described below.

The user `logstash` has to be member of the `adm` group or the permissions of the above mentioned files must be changed
appropriately that Logstash is able to access them. Only read access is required!

The configuration contains an *import input configuration* (`conf.d/10-import.conf`) that reads the above mentioned logs
from the directory `/var/log/import` and keeps the state in separate sincedb filtes. The intention of this config is the
processing of rotated logs. The logs have to be unpacked before. After the import is finished the content of the import
directory and the associated sincedb files can be removed.

#### Environment

The configuration can be changed with environment variables without touching the files:

Variable                 | Default Value                                               | Description | Configuration File                                                                                                 |
-------------------------|-------------------------------------------------------------|-------------|--------------------------------------------------------------------------------------------------------------------|
LL_LOG_HTTPD             | /var/log/apache2/*-access.log                               |             | 10-input.conf                                                                                                      |
LL_SINCEDB_HTTPD_ACCESS  | /var/lib/logstash/plugins/inputs/file/httpd_access.sincedb  |             | 10-input.conf                                                                                                      |
LL_SINCEDB_HTTPD_ERROR   | /var/lib/logstash/plugins/inputs/file/httpd_error.sincedb   |             | 10-input.conf                                                                                                      |
LL_LOG_AUTH              | /var/log/auth.log                                           |             | 10-input.conf                                                                                                      |
LL_SINCEDB_AUTH          | /var/lib/logstash/plugins/inputs/file/auth.sincedb          |             | 10-input.conf                                                                                                      |
LL_LOG_MAIL              | /var/log/mail.log                                           |             | 10-input.conf                                                                                                      |
LL_SINCEDB_MAIL          | /var/lib/logstash/plugins/inputs/file/mail.sincedb          |             | 10-input.conf                                                                                                      |
LL_LOG_IMPORT_HTTPD_ACCESS | /var/log/import/*-access.log.*                              |             | 10-import.conf                                                                                                     |
LL_SINCEDB_IMPORT_HTTPD_ACCESS | /var/lib/logstash/plugins/inputs/file/httpd_access-import.sincedb |             | 10-import.conf                                                                                                     |
LL_LOG_IMPORT_HTTPD_ERROR | /var/log/import/*-error.log.*                              |             | 10-import.conf                                                                                                     |
LL_SINCEDB_IMPORT_HTTPD_ERROR | /var/lib/logstash/plugins/inputs/file/httpd_error-import.sincedb |             | 10-import.conf                                                                                                     |
LL_LOG_IMPORT_AUTH       | /var/log/import/auth.log.*                                  |             | 10-import.conf                                                                                                     |
LL_SINCEDB_IMPORT_AUTH   | /var/lib/logstash/plugins/inputs/file/auth-import.sincedb   |             | 10-import.conf                                                                                                     |
LL_LOG_IMPORT_MAIL       | /var/log/import/mail.log.*                                  |             | 10-import.conf                                                                                                     |
LL_SINCEDB_IMPORT_MAIL   | /var/lib/logstash/plugins/inputs/file/mail-import.sincedb   |             | 10-import.conf                                                                                                     |
LL_PATTERN_DIR           | /etc/logstash/patterns.d                                    |             | 30-filter-auth.conf, 50-filter-dovecot.conf, 50-filter-postfix.conf, 50-filter-postgrey.conf, 65-filter-spamd.conf |
LL_ES_HOST               | 127.0.0.1                                                   |             | 90-output.conf

#### Updating

This project includes dependency projects as submodules. Updating requires the following steps:

1. git pull
2. git submodule update

### Kibana

#### Setting up Indices

Click on the *Add New* button in the area *Management*, *Index Patterns* and create the following patterns:

* `logstash-auth-*`
* `logstash-mail-*`
* `logstash-web-*`

Time-field is always `@timestamp`, changing defaults is not required.

#### Importing Searches, Visualizations and Dashboards

Navigate into the area *Management*, *Saved Objects* and import the JSON files from the `kibana/` directory in following
order:

1. `searches.json`
2. `visualizations.json`
3. `dashboards.json`

### Docker

A complete ELK stack with running *logstash-linux* configuration and host-mounted log dropzone can be set up quickly
with the Docker configurations included in this project by conducting the following steps:

1. Change into directory *docker-elk*

2. Choose your preferred ELK flavor and its corresponding Docker compose file: *docker-compose-elk-with-x-pack.yml* or *docker-compose-elk-oss.yml*.
2. Run `docker-compose -f docker-compose-elk-foobar.yml build`
3. Run `docker-compose -f docker-compose-elk-foobar.yml  up`

Drop your log files into the appropriate directory in `log-dropzone/`. They will be picked up automatically by Logstash.

Please be aware that the Docker containers used as base are provided by Elastic and are subject to their terms of use.
This applies particularly to the X-Pack extensions which have to be licensed properly for production environments.

The logstash-linux Kibana searches, visualizations and dashboards included in this project are not yet included in the containers, but can easily
imported as desribed above.
