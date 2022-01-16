RESULT="$(curl --silent ${DOCKER_HOST_URL}/ping)"

test "${RESULT}" == "pong"
