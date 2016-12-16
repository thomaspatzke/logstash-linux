# Linux Logstash Config

This is a [Logstash](https://www.elastic.co/products/logstash) configuration for Linux systems. It includes
configuration and patterns provided by other projects in addition to custom created patterns/configs. This configuration
was tested on a [Ubuntu Server](https://www.ubuntu.com/server) 16.04 LTS and includes patterns and configuration for the
following log files and services:

* Apache access logs (`/var/log/apache2/*-access.log`)
    * Usage of default Logstash *COMBINEDAPACHELOG* pattern.
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

Default output is a local Elasticsearch instance. Indices are created per log file (apache, auth and mail) and month.

Searches, visualizations and dashboards for Kibana are included for the areas mentioned above:

![Authentication](/images/Dashboard-Authentication.png)

![Failed SSH Authentication](/images/Dashboard-Failed_Logins.png)

![Mail](/images/Dashboard-Mail.png)

![Web](/images/Dashboard-Web.png)

## Usage

### Logstash Configuration

Clone this repository and initialize the submodules with `git submodule update --init`. Copy or link the directories
`conf.d`, `patterns.d` and `ext` into `/etc/logstash` or merge their content into your existing directories and restart
logstash.

The user `logstash` has to be member of the `adm` group or the permissions of the above mentioned files must be changed
appropriately that Logstash is able to access them. Only read access is required!

The configuration contains an *import input configuration* (`conf.d/10-import.conf`) that reads the above mentioned logs
from the directory `/var/log/import` and keeps the state in separate sincedb filtes. The intention of this config is the
processing of rotated logs. The logs have to be unpacked before. After the import is finished the content of the import
directory and the associated sincedb files can be removed.

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

1. `searches.json?
2. `visualizations.json`
3. `dashboards.json`
