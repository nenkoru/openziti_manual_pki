rm -rf ./db
git checkout db

rm -rf ./pki
git checkout pki

openssl req \
    -new -x509 \
    -days 3650 \
    -keyout ./pki/root_ca.key \
    -subj "/C=US/ST=ST=Los Angeles/O=MyBestOrg/CN=MyBestOrg" \
    -out ./pki/root_ca.cert \
    -config ./pki/extensions.conf \
    -extensions v3_ca \
    -nodes
	
openssl genrsa -out ./pki/cas/openziti_ica.key 2048

openssl req -new -sha256 \
    -key ./pki/cas/openziti_ica.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=MyBestOrg/OU=Openziti ICA" \
    -out ./pki/cas/openziti_ica.csr

openssl x509 \
    -req -in ./pki/cas/openziti_ica.csr \
    -CA ./pki/root_ca.cert \
    -CAkey ./pki/root_ca.key \
    -days 600 \
    -extensions v3_intermediate_ca \
    -extfile ./pki/extensions.conf \
    -out "./pki/cas/openziti_ica.cert"
	
openssl genrsa \
    -out ./pki/cas/openziti_network_components_ica.key 2048

openssl req -new -sha256 \
    -key ./pki/cas/openziti_network_components_ica.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=MyBestOrg/OU=Openziti Network Components ICA" \
    -out ./pki/cas/openziti_network_components_ica.csr

openssl x509 \
    -req -in ./pki/cas/openziti_network_components_ica.csr \
    -CA ./pki/cas/openziti_ica.cert \
    -CAkey ./pki/cas/openziti_ica.key \
    -days 600 \
    -extensions v3_intermediate_ca_end_certs_only \
    -extfile ./pki/extensions.conf \
    -out "./pki/cas/openziti_network_components_ica.cert"
	
openssl genrsa \
    -out ./pki/cas/openziti_edge_ica.key 2048

openssl req -new -sha256 \
    -key ./pki/cas/openziti_edge_ica.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=MyBestOrg/OU=Openziti Edge ICA" \
    -out ./pki/cas/openziti_edge_ica.csr

openssl x509 \
    -req -in ./pki/cas/openziti_edge_ica.csr \
    -CA ./pki/cas/openziti_ica.cert \
    -CAkey ./pki/cas/openziti_ica.key \
    -days 600 \
    -extensions v3_intermediate_ca_end_certs_only \
    -extfile ./pki/extensions.conf \
    -out "./pki/cas/openziti_edge_ica.cert"

openssl genrsa \
    -out ./pki/cas/openziti_sign_ica.key 2048

openssl req -new -sha256 \
    -key ./pki/cas/openziti_sign_ica.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=MyBestOrg/OU=Openziti Sign ICA" \
    -out ./pki/cas/openziti_sign_ica.csr

openssl x509 \
    -req -in ./pki/cas/openziti_sign_ica.csr \
    -CA ./pki/cas/openziti_ica.cert \
    -CAkey ./pki/cas/openziti_ica.key \
    -days 600 \
    -extensions v3_intermediate_ca_end_certs_only \
    -extfile ./pki/extensions.conf \
    -out "./pki/cas/openziti_sign_ica.cert"

openssl genrsa \
    -out ./pki/end_certs/openziti_network_components_certs.key 2048

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_network_components_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Network Components Server Cert/OU=Openziti Network Components" \
    -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" \
    -out ./pki/end_certs/openziti_network_components_server.csr

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_network_components_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Network Components Client Cert/OU=Openziti Network Components" \
    -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" \
    -out ./pki/end_certs/openziti_network_components_client.csr

openssl x509 \
    -req -in ./pki/end_certs/openziti_network_components_server.csr \
    -CA ./pki/cas/openziti_network_components_ica.cert \
    -CAkey ./pki/cas/openziti_network_components_ica.key \
    -days 600 \
    -extensions v3_end_cert \
    -extfile ./pki/extensions.conf \
    -copy_extensions copyall \
    -out "./pki/end_certs/openziti_network_components_server.cert"

openssl x509 \
    -req -in ./pki/end_certs/openziti_network_components_client.csr \
    -CA ./pki/cas/openziti_network_components_ica.cert \
    -CAkey ./pki/cas/openziti_network_components_ica.key \
    -days 600 \
    -extensions v3_end_cert \
    -extfile ./pki/extensions.conf \
    -copy_extensions copyall \
    -out "./pki/end_certs/openziti_network_components_client.cert"
	
openssl genrsa \
    -out ./pki/end_certs/openziti_edge_certs.key 2048

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_edge_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Edge Server Cert/OU=Openziti Edge" \
    -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" \
    -out ./pki/end_certs/openziti_edge_server.csr

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_edge_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Edge Client Cert/OU=Openziti Edge" \
    -addext "subjectAltName = DNS:localhost,IP:127.0.0.1" \
    -out ./pki/end_certs/openziti_edge_client.csr

openssl x509 \
    -req -in ./pki/end_certs/openziti_edge_server.csr \
    -CA ./pki/cas/openziti_edge_ica.cert \
    -CAkey ./pki/cas/openziti_edge_ica.key \
    -days 600 \
    -extensions v3_end_cert \
    -extfile ./pki/extensions.conf \
    -copy_extensions copyall \
    -out "./pki/end_certs/openziti_edge_server.cert"

openssl x509 \
    -req -in ./pki/end_certs/openziti_edge_client.csr \
    -CA ./pki/cas/openziti_edge_ica.cert \
    -CAkey ./pki/cas/openziti_edge_ica.key \
    -days 600 \
    -extensions v3_end_cert \
    -extfile ./pki/extensions.conf \
    -copy_extensions copyall \
    -out "./pki/end_certs/openziti_edge_client.cert"

cat ./pki/root_ca.cert ./pki/cas/openziti_ica.cert > ./pki/cas/openziti_network_components_cas.pem
cp ./pki/cas/openziti_network_components_cas.pem ./pki/cas/openziti_edge_cas.pem

cat ./pki/end_certs/openziti_network_components_server.cert \
    ./pki/cas/openziti_network_components_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/end_certs/openziti_network_components-server.chain.pem

cat ./pki/end_certs/openziti_network_components_client.cert \
    ./pki/cas/openziti_network_components_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/end_certs/openziti_network_components-client.chain.pem

cat ./pki/end_certs/openziti_edge_server.cert \
    ./pki/cas/openziti_edge_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/end_certs/openziti_edge-server.chain.pem

cat ./pki/cas/openziti_sign_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/cas/openziti_sign_ica.chain.pem

ziti controller edge init ./controller_config.yaml -u "admin" -p "admin"
