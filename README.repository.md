**Maintained by**: [raasss](https://github.com/raasss/)


# Quick reference

-	Issues can be filed at [GitHub Issues](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/issues).

-	Supported architectures are: `linux/amd64`, `linux/arm/v7`, `linux/arm64` 

-	Source of this content can be found at [README.docker.io.md](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/blob/main/README.docker.io.md)

# Introduction

FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features (mostly) useful for heavy-loaded sites. ([more info](https://www.php.net/manual/en/install.fpm.php))

# Quickstart guide

Starting a PHP-FPM instance with the latest version is simple. Running only php-fpm is hard to test, so we will run apache also via [`docker-compose`](https://github.com/docker/compose). If you don't have docker-compose tool installed, please go [here](https://docs.docker.com/compose/install/) and follow instractions.

Example `docker-compose.yml` for `php-fpm`:

```yaml
version: '3.7'

networks:
  private:
    driver: bridge


services:
  php-fpm:
    image: raasss/php-fpm-ubuntu-21.10:latest
    networks:
      - private
    ports:
      - "9000"
    volumes:
      - type: bind
        source: ./htdocs
        target: /var/www/html
    cap_add:
      - SYS_PTRACE
    environment:
      - PHP_FPM_CONF_1=global:log_level:notice
      - PHP_FPM_CONF_2=global:include:/etc/php/7.4/fpm/pool.d/*.conf
      - PHP_FPM_INI_1=PHP:memory_limit:128M
      - PHP_FPM_INI_2=Date:date.timezone:UTC
      - PHP_FPM_INI_3=Session:session.use_cookies:1
      - PHP_FPM_POOL_1=www:pm.status_path:/status
      - PHP_FPM_POOL_2=www:request_slowlog_timeout:2s
      - PHP_FPM_POOL_3=www:php_admin_value[memory_limit]:128M

  apache:
    image: raasss/apache-ubuntu-21.10:latest
    networks:
      - private
    ports:
      - "80"
      - "443"
    environment:
     - PHP_FPM_SERVER=php-fpm
    volumes:
      - type: bind
        source: ./htdocs
        target: /var/www/html
        read_only: true
```

In your current working directory create `docker-compose.yml` file. Create also directory `htdocs/` and populate it with some `.php` files. This will be root directory for local website development.

Run docker-compose and services should be up soon:

```console
$ docker-compose up -d
```

As we are using apache to access php-fpm, we can find port where apache listen for connections like this:

```console
$ docker-compose port apache 80
0.0.0.0:49154
```

In this example we can go to web browser and type in url like `http://0.0.0.0:49154`.

# Advance guide

## Container shell access

The `docker-compose exec` command allows you to run commands inside a Docker container.

The following command line will give you a bash shell inside your `php-fpm` container as root:

```console
$ docker-compose exec php-fpm bash
```

If you are developing in wordpress there is `wp-cli` pre-installed for you. The following command line will give you a bash shell inside your `php-fpm` container as user that php-fpm process is running as:

```console
$ docker-compose exec -u $(id -u) php-fpm bash
runasuser@bf6b9c2a76e4:/var/www/html$ wp cli info
OS:	Linux 5.10.0-1052-oem #54-Ubuntu SMP Tue Nov 23 09:06:13 UTC 2021 x86_64
Shell:	
PHP binary:	/usr/bin/php7.4
PHP version:	7.4.16
php.ini used:	/etc/php/7.4/cli/php.ini
MySQL binary:	
MySQL version:	
SQL modes:	
WP-CLI root dir:	phar://wp-cli.phar/vendor/wp-cli/wp-cli
WP-CLI vendor dir:	phar://wp-cli.phar/vendor
WP_CLI phar path:	/var/www/html
WP-CLI packages dir:	
WP-CLI global config:	
WP-CLI project config:	
WP-CLI version:	2.5.0

```

## Access logs

The log is available through Docker's container log:

```console
$ docker-compose logs php-fpm -f
```

You can omit `-f` if you don't want to tail logs in realtime.

## Customizing via environment variables

Customization of 3 files in docker image is implemented:

- `/etc/php/<version>/fpm/php-fpm.conf`
- `/etc/php/<version>/fpm/php.ini`
- `/etc/php/<version>/fpm/pool.d/www.conf`

These files are standard configuration files in INI format. Every INI file is consisted of `<section>` and `<key> = <value>` pairs.

This is how trimmed version of `php.ini` file looks like:

```ini
[PHP]

; Maximum amount of memory a script may consume (128MB)
; http://php.net/memory-limit
memory_limit = 128M

[Date]

; Defines the default timezone used by the date functions
; http://php.net/date.timezone
date.timezone = UTC

[Session]

; Whether to use cookies.
; http://php.net/session.use-cookies
session.use_cookies = 1
```

Here we can see 3 sections: `PHP`, `Data` and `Sessions`. And multiple `key=value` pairs:

- `memory_limit = 128M`
- `date.timezone = UTC`
- `session.use_cookies = 1`


To configure files above you need to add coresonding environment variables in following format:

- `PHP_FPM_CONF_*`
- `PHP_FPM_INI_*`
- `PHP_FPM_POOL_*`

Value of these environment variables need to be in format `<section>:<key>:<value>` as can be found in example `docker-compose.yml` file above.