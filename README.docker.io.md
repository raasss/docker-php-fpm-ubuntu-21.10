# Quick reference

-	**Maintained by**:  
	[raasss](https://github.com/raasss/)

# Supported tags and respective `Dockerfile` links

-	[`0.1.7`, `latest`](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/blob/0.1.7/Dockerfile)
-	[`7.4.3-4ubuntu2.8-0.0.7`, `7.4.3-4ubuntu2.8`](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/blob/7.4.3-4ubuntu2.8/Dockerfile)
-	[`7.4.3-4ubuntu1-0.0.15`, `7.4.3-4ubuntu1`](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/blob/7.4.3-4ubuntu1-0.0.15/Dockerfile)
-	[`7.4.3-4ubuntu2.7-0.0.7`, `7.4.3-4ubuntu2.7`](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/blob/7.4.3-4ubuntu2.7-0.0.7/Dockerfile)

# Quick reference (cont.)

-	**Where to file issues**:  
	Issues can be filed on [GitHub Issues](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/issues) under specific branch named by specific package version.

-	**Supported architectures**:
    `linux/amd64`, `linux/arm/v7`, `linux/arm64` 

-	**Source of this description**:  
	[README.docker.io.md]([here](https://github.com/raasss/docker-php-fpm-ubuntu-21.10/blob/main/README.docker.io.md))

# What is PHP-FPM?

FPM (FastCGI Process Manager) is an alternative PHP FastCGI implementation with some additional features (mostly) useful for heavy-loaded sites. ([more info](https://www.php.net/manual/en/install.fpm.php))

# How to use this docker image

## Start a `php-fpm` server instance via [`docker-compose`](https://github.com/docker/compose)

Starting a PHP-FPM instance with the latest version is simple:

Example `docker-compose.yml` for `mariadb`:

```yaml
version: '3.5'

networks:
  private:
    driver: bridge

services:
  php:
    image: raasss/php-fpm-ubuntu-21.10:latest
    networks:
      - private
    ports:
      - "19000:9000"
    volumes:
      - type: bind
        source: ./src
        target: /var/www/html
    cap_add:
      - SYS_PTRACE

  web:
    image: raasss/apache-ubuntu-21.10:latest
    networks:
      - private
    ports:
      - "8080:80"
      - "8443:443"
    environment:
     - PHP_FPM_SERVER=php
    volumes:
      - type: bind
        source: ./src
        target: /var/www/html
        read_only: true
```

Run `docker-compose up`, wait for it to initialize completely, and visit `http://localhost:8080/`, `http://0.0.0.0:8080/`, `http://127.0.0.1:8080/`, or `http://host-ip:8080/` (as appropriate).

## Container shell access

The `docker-compose exec` command allows you to run commands inside a Docker container. The following command line will give you a bash shell inside your `php` container:

```console
$ docker-compose exec php bash
```

The log is available through Docker's container log:

```console
$ docker-compose logs php
```

## Using a custom MariaDB configuration file

The startup configuration is specified in the file `/etc/mysql/my.cnf`, and that file in turn includes any files found in the `/etc/mysql/conf.d` directory that end with `.cnf`. Settings in files in this directory will augment and/or override settings in `/etc/mysql/my.cnf`. If you want to use a customized MariaDB configuration, you can create your alternative configuration file in a directory on the host machine and then mount that directory location as `/etc/mysql/conf.d` inside the `mariadb` container.

If `/my/custom/config-file.cnf` is the path and name of your custom configuration file, you can start your `mariadb` container like this (note that only the directory path of the custom config file is used in this command):

```console
$ docker run --name some-mariadb -v /my/custom:/etc/mysql/conf.d -e MARIADB_ROOT_PASSWORD=my-secret-pw -d mariadb:latest
```

This will start a new container `some-mariadb` where the MariaDB instance uses the combined startup settings from `/etc/mysql/my.cnf` and `/etc/mysql/conf.d/config-file.cnf`, with settings from the latter taking precedence.

### Configuration without a `cnf` file

Many configuration options can be passed as flags to `mysqld`. This will give you the flexibility to customize the container without needing a `cnf` file. For example, if you want to run on port 3808 just run the following:

```console
$ docker run --name some-mariadb -e MARIADB_ROOT_PASSWORD=my-secret-pw -d mariadb:latest --port 3808
```

If you would like to see a complete list of available options, just run:

```console
$ docker run -it --rm mariadb:latest --verbose --help
```

## Environment Variables

When you start the `mariadb` image, you can adjust the initialization of the MariaDB instance by passing one or more environment variables on the `docker run` command line. Do note that none of the variables below will have any effect if you start the container with a data directory that already contains a database: any pre-existing database will always be left untouched on container startup.

From tag 10.2.38, 10.3.29, 10.4.19, 10.5.10 onwards, and all 10.6 tags, the `MARIADB_*` equivalent variables are provided. `MARIADB_*` variants will always be used in preference to `MYSQL_*` variants.

One of `MARIADB_ROOT_PASSWORD`, `MARIADB_ALLOW_EMPTY_ROOT_PASSWORD`, or `MARIADB_RANDOM_ROOT_PASSWORD` (or equivalents, including `*_FILE`), is required. The other environment variables are optional.

### `MARIADB_ROOT_PASSWORD` / `MYSQL_ROOT_PASSWORD`

This specifies the password that will be set for the MariaDB `root` superuser account. In the above example, it was set to `my-secret-pw`.

### `MARIADB_ALLOW_EMPTY_ROOT_PASSWORD` / `MYSQL_ALLOW_EMPTY_PASSWORD`

Set to a non-empty value, like `yes`, to allow the container to be started with a blank password for the root user. *NOTE*: Setting this variable to `yes` is not recommended unless you really know what you are doing, since this will leave your MariaDB instance completely unprotected, allowing anyone to gain complete superuser access.

### `MARIADB_RANDOM_ROOT_PASSWORD` / `MYSQL_RANDOM_ROOT_PASSWORD`

Set to a non-empty value, like `yes`, to generate a random initial password for the root user. The generated root password will be printed to stdout (`GENERATED ROOT PASSWORD: .....`).

### `MARIADB_ROOT_HOST` / `MYSQL_ROOT_HOST`

This is the hostname part of the root user created. By default this is `%`, however it can be set to any default [MariaDB allowed hostname component](https://mariadb.com/kb/en/create-user/#host-name-component).

### `MARIADB_DATABASE` / `MYSQL_DATABASE`

This variable allows you to specify the name of a database to be created on image startup.

### `MARIADB_USER` / `MYSQL_USER`, `MARIADB_PASSWORD` / `MYSQL_PASSWORD`

These are used in conjunction to create a new user and to set that user's password. Both user and password variables are required for a user to be created. This user will be granted all access ([corresponding to `GRANT ALL`](https://mariadb.com/kb/en/grant/#the-all-privileges-privilege)) to the `MARIADB_DATABASE` database.

Do note that there is no need to use this mechanism to create the root superuser, that user gets created by default with the password specified by the `MARIADB_ROOT_PASSWORD` / `MYSQL_ROOT_PASSWORD` variable.

### `MARIADB_INITDB_SKIP_TZINFO` / `MYSQL_INITDB_SKIP_TZINFO`

By default, the entrypoint script automatically loads the timezone data needed for the `CONVERT_TZ()` function. If it is not needed, any non-empty value disables timezone loading.

## Docker Secrets

As an alternative to passing sensitive information via environment variables, `_FILE` may be appended to the previously listed environment variables, causing the initialization script to load the values for those variables from files present in the container. In particular, this can be used to load passwords from Docker secrets stored in `/run/secrets/<secret_name>` files. For example:

```console
$ docker run --name some-mysql -e MARIADB_ROOT_PASSWORD_FILE=/run/secrets/mysql-root -d mariadb:latest
```

Currently, this is only supported for `MARIADB_ROOT_PASSWORD`, `MARIADB_ROOT_HOST`, `MARIADB_DATABASE`, `MARIADB_USER`, and `MARIADB_PASSWORD` (and `MYSQL_*` equivalents of these).

# Initializing a fresh instance

When a container is started for the first time, a new database with the specified name will be created and initialized with the provided configuration variables. Furthermore, it will execute files with extensions `.sh`, `.sql`, `.sql.gz`, `.sql.xz` and `.sql.zst` that are found in `/docker-entrypoint-initdb.d`. Files will be executed in alphabetical order. `.sh` files without file execute permission are sourced rather than executed. You can easily populate your `mariadb` services by [mounting a SQL dump into that directory](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-file-as-a-data-volume) and provide [custom images](https://docs.docker.com/reference/builder/) with contributed data. SQL files will be imported by default to the database specified by the `MARIADB_DATABASE` / `MYSQL_DATABASE` variable.

# Caveats

## Where to Store Data

Important note: There are several ways to store data used by applications that run in Docker containers. We encourage users of the `mariadb` images to familiarize themselves with the options available, including:

-	Let Docker manage the storage of your database data [by writing the database files to disk on the host system using its own internal volume management](https://docs.docker.com/engine/tutorials/dockervolumes/#adding-a-data-volume). This is the default and is easy and fairly transparent to the user. The downside is that the files may be hard to locate for tools and applications that run directly on the host system, i.e. outside containers.
-	Create a data directory on the host system (outside the container) and [mount this to a directory visible from inside the container](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume). This places the database files in a known location on the host system, and makes it easy for tools and applications on the host system to access the files. The downside is that the user needs to make sure that the directory exists, and that e.g. directory permissions and other security mechanisms on the host system are set up correctly.

The Docker documentation is a good starting point for understanding the different storage options and variations, and there are multiple blogs and forum postings that discuss and give advice in this area. We will simply show the basic procedure here for the latter option above:

1.	Create a data directory on a suitable volume on your host system, e.g. `/my/own/datadir`.
2.	Start your `mariadb` container like this:

	```console
	$ docker run --name some-mariadb -v /my/own/datadir:/var/lib/mysql -e MARIADB_ROOT_PASSWORD=my-secret-pw -d mariadb:latest
	```

The `-v /my/own/datadir:/var/lib/mysql` part of the command mounts the `/my/own/datadir` directory from the underlying host system as `/var/lib/mysql` inside the container, where MariaDB by default will write its data files.

## No connections until MariaDB init completes

If there is no database initialized when the container starts, then a default database will be created. While this is the expected behavior, this means that it will not accept incoming connections until such initialization completes. This may cause issues when using automation tools, such as `docker-compose`, which start several containers simultaneously.

## Usage against an existing database

If you start your `mariadb` container instance with a data directory that already contains a database (specifically, a `mysql` subdirectory), the `$MARIADB_ROOT_PASSWORD` variable should be omitted from the run command line; it will in any case be ignored, and the pre-existing database will not be changed in any way.

## Creating database dumps

Most of the normal tools will work, although their usage might be a little convoluted in some cases to ensure they have access to the `mysqld` server. A simple way to ensure this is to use `docker exec` and run the tool from the same container, similar to the following:

```console
$ docker exec some-mariadb sh -c 'exec mysqldump --all-databases -uroot -p"$MARIADB_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
```

## Restoring data from dump files

For restoring data. You can use the `docker exec` command with the `-i` flag, similar to the following:

```console
$ docker exec -i some-mariadb sh -c 'exec mysql -uroot -p"$MARIADB_ROOT_PASSWORD"' < /some/path/on/your/host/all-databases.sql
```

## Creating backups with Mariabackup

To perform a backup using Mariabackup, an additional volume for the backup needs to be included when the container is started like this:

```console
$ docker run --name some-mariadb -v /my/own/datadir:/var/lib/mysql -v /my/own/backupdir:/backup -e MARIADB_ROOT_PASSWORD=my-secret-pw -d mariadb:latest
```

Mariabackup will run as the `mysql` user in the container, so the permissions on `/backup` will need to ensure that it can be written to by this user:

```console
$ docker exec some-mariadb chown mysql: /backup
```

To perform the backup:

```console
$ docker exec --user mysql some-mariadb mariabackup --backup --target-dir=/backup --user=root --password=my-secret-pw
```

If you wish to take a copy of the `/backup` you can do so without stopping the container or getting an inconsistent backup.

```console
$ docker exec --user mysql some-mariadb tar --create --xz --file - /backup > backup.tar.xz
```

## Restore backups with Mariabackup

These steps restore the backup made with Mariabackup.

At some point before doing the restore, the backup needs to be prepared. Here `/my/own/backupdir` contains a previous backup. Perform the prepare like this:

```console
$ docker run --user mysql --rm -v /my/own/backupdir:/backup mariadb:latest mariabackup --prepare --target-dir=/backup
```

Now that the image is prepared, start the container with both the data and the backup volumes and restore the backup:

```console
$ docker run --user mysql --rm -v /my/own/newdatadir:/var/lib/mysql -v /my/own/backupdir:/backup mariadb:latest mariabackup --copy-back --target-dir=/backup
```

With `/my/own/newdatadir` containing the restored backup, start normally as this is an initialized data directory:

```console
$ docker run --name some-mariadb -v /my/own/newdatadir:/var/lib/mysql -d mariadb:latest
```

For further information on Mariabackup, see the [Mariabackup Knowledge Base](https://mariadb.com/kb/en/mariabackup-overview/).

## How to reset root and user passwords

If you have an existing data directory and wish to reset the root and user passwords, and to create a database on which the user can fully modify, perform the following steps.

First create a `passwordreset.sql` file:

```text
CREATE USER IF NOT EXISTS root@localhost IDENTIFIED BY 'thisismyrootpassword';
SET PASSWORD FOR root@localhost = PASSWORD('thisismyrootpassword');
GRANT ALL ON *.* TO root@localhost WITH GRANT OPTION;
CREATE USER IF NOT EXISTS root@'%' IDENTIFIED BY 'thisismyrootpassword';
SET PASSWORD FOR root@'%' = PASSWORD('thisismyrootpassword');
GRANT ALL ON *.* TO root@'%' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS myuser@'%' IDENTIFIED BY 'thisismyuserpassword';
SET PASSWORD FOR myuser@'%' = PASSWORD('thisismyuserpassword');
CREATE DATABASE IF NOT EXISTS databasename;
GRANT ALL ON databasename.* TO myuser@'%';
```

Adjust `myuser`, `databasename` and passwords as needed.

Then:

```console
$ docker run --rm -v /my/own/datadir:/var/lib/mysql -v /my/own/passwordreset.sql:/passwordreset.sql:z mariadb:latest --init-file=/passwordreset.sql
```

On restarting the MariaDB container on this `/my/own/datadir`, the `root` and `myuser` passwords will be reset.

## How to install MariaDB plugins

MariaDB has many plugins, most are not enabled by default, some are in the mariadb container, others need to be installed from additional packages.

The following methods summarize the [MariaDB Blog article - Installing plugins in the MariaDB Docker Library Container](https://mariadb.org/installing-plugins-in-the-mariadb-docker-library-container/) on this topic.

### Which plugins does the container contain?

To see which plugins are available in the mariadb:

```console
$ docker run --rm mariadb:latest ls -C /usr/lib/mysql/plugin
```

### Enabling a plugin using flags

Using the `--plugin-load-add` flag with the plugin name (can be repeated), the plugins will be loaded and ready when the container is started:

For example enable the `simple\_password\_check` plugin:

```console
$ docker run --name some-mariadb -e MARIADB_ROOT_PASSWORD=my-secret-pw --network=host -d mariadb:latest --plugin-load-add=simple_password_check
```

### Enabling a plugin in the configuration files

`plugin-load-add` can be used as a configuration option to load plugins. The example below load the [FederatedX Storage Engine](https://mariadb.com/kb/en/federatedx-storage-engine/).

```console
$ printf "[mariadb]\nplugin-load-add=ha_federatedx\n" > /my/custom/federatedx.conf
$ docker run --name some-mariadb -v /my/custom:/etc/mysql/conf.d -e MARIADB_ROOT_PASSWORD=my-secret-pw -d mariadb:latest
```

### Install a plugin using SQL in /docker-entrypoint-initdb.d

[`INSTALL SONAME`](https://mariadb.com/kb/en/install-soname/) can be used to install a plugin as part of the database initialization.

Create the SQL file used in initialization:

```console
$ echo 'INSTALL SONAME "disks";' > my_initdb/disks.sql
```

In this case the `my\_initdb` is a `/docker-entrypoint-initdb.d` directory per "Initializing a fresh instance" section above.

### Identifing additional plugins in additional packages

A number of plugins are in separate packages to reduce their installation size. The package names of MariaDB created plugins can be determined using the following command:

```console
$ docker run --rm mariadb:latest sh -c 'apt-get update -qq && apt-cache search mariadb-plugin'
```

### Creating a image with plugins from additional packages

A new image needs to be created when using additional packages. The mariadb image can be used as a base however:

In the following the [CONNECT Storage Engine](https://mariadb.com/kb/en/connect/) is installed:

```dockerfile
FROM mariadb:latest
RUN apt-get update && \
    apt-get install mariadb-plugin-connect -y && \
    rm -rf /var/lib/apt/lists/*
```

Installing plugins from packages creates a configuration file in the directory `/etc/mysql/mariadb.conf.d/` that loads the plugin on startup.

# License

View [license information](https://mariadb.com/kb/en/library/licensing-faq/) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

Some additional license information which was able to be auto-detected might be found in [the `repo-info` repository's `mariadb/` directory](https://github.com/docker-library/repo-info/tree/master/repos/mariadb).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.