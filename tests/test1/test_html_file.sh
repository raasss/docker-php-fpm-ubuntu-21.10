RESULT="$(curl --silent ${DOCKER_HOST_URL}/index.html)"

test "${RESULT}" == "index.html"
