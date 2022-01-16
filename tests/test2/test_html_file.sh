RESULT="$(curl --silent ${DOCKER_HOST_URL}/test2.html)"

test "${RESULT}" == "test2.html"
