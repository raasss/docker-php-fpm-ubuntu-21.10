#!/usr/bin/env bash

set -eux

rm -vf /run/php/*.pid

DOCKER_RUN_AS_GID=$(stat -c '%g' /var/www/html)
DOCKER_RUN_AS_UID=$(stat -c '%u' /var/www/html)

if [ "${DOCKER_RUN_AS_GID}" != "0" ]; then
  groupadd --non-unique -g ${DOCKER_RUN_AS_GID} runasgroup || true
  crudini --verbose --set /etc/php/7.4/fpm/pool.d/www.conf www group "${DOCKER_RUN_AS_GID}"
fi
if [ "${DOCKER_RUN_AS_UID}" != "0" ]; then
  useradd --non-unique -c "User running container on docker host" -d /home/runasuser -g runasgroup -m -N -s /bin/bash -u ${DOCKER_RUN_AS_UID} runasuser || true
  crudini --verbose --set /etc/php/7.4/fpm/pool.d/www.conf www user "${DOCKER_RUN_AS_UID}"
fi

for ENVVAR in $(env | grep -E '^PHP_FPM_CONF_.+')
do
  ENVVAR_SECTION=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 1)
  ENVVAR_KEY=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 2)
  ENVVAR_VALUE=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 3-)
  crudini --verbose --set "/etc/php/7.4/fpm/php-fpm.conf" "${ENVVAR_SECTION}" "${ENVVAR_KEY}" "${ENVVAR_VALUE}"
done

PHP_INI_CONFIGURATION_FILE="$(php-fpm7.4 -i | grep '^Loaded Configuration File' | awk '{print $5}')"
for ENVVAR in $(env | grep -E '^PHP_FPM_INI_.+')
do
  ENVVAR_SECTION=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 1)
  ENVVAR_KEY=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 2)
  ENVVAR_VALUE=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 3-)
  crudini --verbose --set "${PHP_INI_CONFIGURATION_FILE}" "${ENVVAR_SECTION}" "${ENVVAR_KEY}" "${ENVVAR_VALUE}"
done

for ENVVAR in $(env | grep -E '^PHP_FPM_POOL_.+')
do
  ENVVAR_SECTION=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 1)
  ENVVAR_KEY=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 2)
  ENVVAR_VALUE=$(echo ${ENVVAR} | cut -d '=' -f2 | cut -d ':' -f 3-)
  crudini --verbose --set "/etc/php/7.4/fpm/pool.d/www.conf" "${ENVVAR_SECTION}" "${ENVVAR_KEY}" "${ENVVAR_VALUE}"
done

php-fpm7.4 --test

exec /usr/sbin/php-fpm7.4 -R --nodaemonize --fpm-config /etc/php/7.4/fpm/php-fpm.conf

