#!/usr/bin/env bash

# SET THESE VALUES BEFORE RUNNING -------------------
JARPATH="/Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar"
FUSIONURL=https://axway-appc-se.sandbox.fusion.services.axway.com/
PROJECT="LBclitest"
INTEGRATION="flow1"
DATA_PLANE="Shared Data Plane"

# DON'T MODIFY BELOW ------------------

# Turn on echo
set -x
set -euo pipefail

# --- Prompt for inputs ---
read -r -p "Username: " USERNAME
read -r -s -p "Password: " PASSWORD
echo   # newline after hidden password input
read -r -p "Version: " VER
read -r -p "Target deployment environment (CHECK/LIVE): " TARGET_ENV

DEPLOYMENT_NAME="${PROJECT}_dj_${VER}"
PROJECT_VERSION="${PROJECT},${VER}"

# Log in
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar auth login -u leor.brenman@gmail.com -p ******** --url https://axway-appc-se.sandbox.fusion.services.axway.com/
java -jar "${JARPATH}" auth login -u "${USERNAME}" -p "${PASSWORD}" --url "${FUSIONURL}"
# Deactivate event
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar project event disable -n LBclitest -in flow1 -cn 'Shared Data Plane'
java -jar "${JARPATH}" project event disable -n "${PROJECT}" -in "${INTEGRATION}" -cn "${DATA_PLANE}"
# Create deployment job
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar deployment create -n LBclitest_dj_V78 -d LBclitest_dj_V78 -pv LBclitest,V78
java -jar "${JARPATH}" deployment create -n "${DEPLOYMENT_NAME}" -d "${DEPLOYMENT_NAME}" -pv "${PROJECT_VERSION}"
# Switch to TARGET_ENV
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar environment switch -n CHECK
java -jar "${JARPATH}" environment switch -n "${TARGET_ENV}"
# Deactivate project event in TARGET_ENV
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar project event disable -n LBclitest -in flow1 -cn 'Shared Data Plane'
java -jar "${JARPATH}" project event disable -n "${PROJECT}" -in "${INTEGRATION}" -cn "${DATA_PLANE}"
# Switch to DESIGN
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar environment switch -n DESIGN
java -jar "${JARPATH}" environment switch -n DESIGN
# Run deployment job to TARGET_ENV
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar deployment run -n LBclitest_dj_V78 -e CHECK
java -jar "${JARPATH}" deployment run -n "${DEPLOYMENT_NAME}" -e "${TARGET_ENV}"
# Switch to TARGET_ENV
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar environment switch -n CHECK
java -jar "${JARPATH}" environment switch -n "${TARGET_ENV}"
# Activate project event in TARGET_ENV
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar project event enable -n LBclitest -in flow1 -cn 'Shared Data Plane'
java -jar "${JARPATH}" project event enable -n "${PROJECT}" -in "${INTEGRATION}" -cn "${DATA_PLANE}"
# Log out
# java -jar /Users/lbrenman/Downloads/fusion-cli-1.0.0-runner.jar auth logout
java -jar "${JARPATH}" auth logout