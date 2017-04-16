#!/usr/bin/env bash

if [[ ${#} != 1 ]]; then
  echo '> Please specify name for virtual host.'
  exit 1
fi

SERVER_ROOT='/etc/httpd'
DOCUMENT_ROOT='/home/webroot'
SUB_DOMAIN='murda'

VHOST_NAME=${1}
VHOST_NUM=$(ls "${SERVER_ROOT}/sites-available"| sort | tail -1 | cut -d '-' -f1)
VHOST_NUM=$((VHOST_NUM + 1))
VHOST_NUM=$(printf "%03d" ${VHOST_NUM})
CONF_NAME="${VHOST_NUM}-${VHOST_NAME}.conf"

VHOST_HOST="${VHOST_NAME}"
if [[ "${SUB_DOMAIN}" != '' ]]; then
  VHOST_HOST="${VHOST_HOST}.${SUB_DOMAIN}"
fi
VHOST_HOST="${VHOST_HOST}.dev"

if [[ ! -d "${DOCUMENT_ROOT}/${VHOST_NAME}" ]]; then
  echo '> Creating document root for virtual host.'
  mkdir "${DOCUMENT_ROOT}/${VHOST_NAME}"
fi

echo '> Creating virtual host:' ${CONF_NAME}
cat > "${SERVER_ROOT}/sites-available/${CONF_NAME}" <<EOL
<VirtualHost _default_:80>
  ServerName ${VHOST_HOST}
  DocumentRoot ${DOCUMENT_ROOT}/${VHOST_NAME}

  ErrorLog /var/log/httpd/${VHOST_NAME}-error.log
  LogFormat "%h %t \"%r\" %>s \"%{User-agent}i\"" extended
  CustomLog /var/log/httpd/${VHOST_NAME}-access.log extended
</VirtualHost>
EOL

echo '> Enabling virtual host:' ${CONF_NAME}
ln -sf "${SERVER_ROOT}/sites-available/${CONF_NAME}" "${SERVER_ROOT}/sites-enabled/${CONF_NAME}"

grep -e ${VHOST_HOST} /etc/hosts
if [[ ${?} -ne 0 ]]; then
  echo '> Adding hostname entry for virtual host.'
  cat >> /etc/hosts <<EOL

127.0.0.1    ${VHOST_HOST}
::1          ${VHOST_HOST}
EOL
fi