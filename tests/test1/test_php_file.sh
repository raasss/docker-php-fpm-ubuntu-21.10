RESULT="$(curl --silent ${DOCKER_HOST_URL}/index.php)"

test "${RESULT}" == "index.php"
