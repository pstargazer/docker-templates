_DOMAIN=dflat
USER=1000
USERGROUP=users
PERMS=765

CERT_DIR=./_certs
CERT_DB_URL=${_DOMAIN}-db
CERT_HTTP_URL=${_DOMAIN}-backend
DIR=.

.PHONY: _prepare perms perms-moduless clean

_prepare: _certs perms-modules
	git submodule sync
	git submodule update --init
	git config --local --add safe.directory ./app_backend
	git config --local --add safe.directory ./app_frontend
	cp ./.gitconfig app_frontend
	cp ./.gitconfig app_backend


perms-modules:
	sudo chown ${USER}:${USERGROUP} -R app_backend app_frontend
	sudo chmod ${PERMS} -R app_backend app_frontend

_certs:
	mkdir ${CERT_DIR}
	cd ${CERT_DIR}
	# generate root.csr root.key
	openssl req -new -nodes -text -out ${CERT_DIR}/root.csr \
	  -keyout ${CERT_DIR}/root.key -subj "/CN=dflat-backend"
			chmod og-rwx ${CERT_DIR}/root.key
	# generate root.pem
	openssl x509 -req -in ${CERT_DIR}/root.csr -text -days 3650 \
	  -extfile /etc/ssl/openssl.cnf -extensions v3_ca \
	  -signkey ${CERT_DIR}/root.key -out ${CERT_DIR}/root.pem


	# generate server.csr and server.key
	openssl req -new -nodes -text -out ${CERT_DIR}/server.csr \
	  -keyout ${CERT_DIR}/server.key -subj "/CN=dflat-db"
	chmod og-rwx ${CERT_DIR}/server.key

	# generate server.crt
	openssl x509 -req -in ${CERT_DIR}/server.csr -text -days 365 \
	  -CA ${CERT_DIR}/root.pem -CAkey ${CERT_DIR}/root.key -CAcreateserial \
	  -out ${CERT_DIR}/server.crt

	rm  ./${CERT_DIR}/*.csr
	# move rootcert to app folder
	mkdir _services/app/certs/ _services/app/certs/certs
	cp ./${CERT_DIR}/root.key _services/app/certs
	cp ./${CERT_DIR}/root.pem _services/app/certs
	mkdir _services/postgres/certs _services/postgres/certs/certs
	cp ./${CERT_DIR}/root.pem _services/postgres/certs/certs
	cp ./${CERT_DIR}/server.crt _services/postgres/certs/certs
	cp ./${CERT_DIR}/server.key _services/postgres/certs

clean:
	# delete certificates
	rm -rf ${CERT_DIR}
	rm -rf _services/app/certs
	rm -rf _services/postgres/certs
