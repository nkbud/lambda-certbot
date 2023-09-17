#!/bin/bash
set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

readonly PYTHON="python3.8"
readonly VENV="certbot/venv"
${PYTHON} -m venv "${VENV}"
source "${VENV}/bin/activate"
pip3 install -r requirements.txt
# python venv, pip install

readonly CERTBOT_ZIP_FILE="lambda-certbot.zip"
readonly CERTBOT_SITE_PACKAGES=${VENV}/lib/${PYTHON}/site-packages
pushd ${CERTBOT_SITE_PACKAGES}
    zip -r -q ${SCRIPT_DIR}/certbot/${CERTBOT_ZIP_FILE} . -x "/*__pycache__/*"
popd
# .zip the packages

mv "${SCRIPT_DIR}/certbot/${CERTBOT_ZIP_FILE}" "${SCRIPT_DIR}/${CERTBOT_ZIP_FILE}"
zip -g "${CERTBOT_ZIP_FILE}" main.py
mv "${SCRIPT_DIR}/${CERTBOT_ZIP_FILE}" "${SCRIPT_DIR}/tf/${CERTBOT_ZIP_FILE}"
# add main.py, move it into place