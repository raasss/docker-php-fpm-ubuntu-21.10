RESULT="$(curl --silent ${DOCKER_HOST_URL}/status)"

echo "${RESULT}" | grep '^pool:'