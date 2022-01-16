RESULT="$(curl --silent ${DOCKER_HOST_URL})"

test "${RESULT}" == "index.html"
