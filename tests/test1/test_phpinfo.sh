RESULT="$(curl --silent ${DOCKER_HOST_URL}/phpinfo.php)"

echo "${RESULT}" | grep 'phpinfo()'
