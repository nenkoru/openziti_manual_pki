Okay, so this markdown would walk you through of the steps it takes to bootstrap the PKI for openziti.
Take a look into the pki_topology.(.png|puml) to see the way the PKI is bootstrapped as well as some notes.

1. Create a self-signed root CA
```
openssl req \
    -new -x509 \
    -days 3650 \
    -keyout ./pki/root_ca.key \
    -subj "/C=US/ST=ST=Los Angeles/O=MyBestOrg/CN=MyBestOrg" \
    -out ./pki/root_ca.cert \
    -config ./pki/extensions.conf \
    -extensions v3_ca \
    -nodes
```
2. Create an intermediate CA for Openziti
```
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
```

3. Create a network components intermediate CA
```
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
```

4. Create an edge intermediate CA
```
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
```
5. Create a sign(identities) intermediate CA
```
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
```

6. Create a client, server certificates for network components
```
openssl genrsa \
    -out ./pki/end_certs/openziti_network_components_certs.key 2048

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_network_components_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Network Components Server Cert/OU=Openziti Network Components" \
    -addext "subjectAltName = DNS:components.openziti.macos,IP:127.0.0.1" \
    -out ./pki/end_certs/openziti_network_components_server.csr

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_network_components_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Network Components Client Cert/OU=Openziti Network Components" \
    -addext "subjectAltName = DNS:components.openziti.macos,IP:127.0.0.1" \
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
```

7. Create a client, server certificates for edge
```
openssl genrsa \
    -out ./pki/end_certs/openziti_edge_certs.key 2048

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_edge_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Edge Server Cert/OU=Openziti Edge" \
    -addext "subjectAltName = DNS:edge.openziti.localdomain,IP:127.0.0.2" \
    -out ./pki/end_certs/openziti_edge_server.csr

openssl req -new -sha256 \
    -key ./pki/end_certs/openziti_edge_certs.key \
    -subj "/C=US/ST=Los Angeles/O=MyBestOrg/CN=Openziti Edge Client Cert/OU=Openziti Edge" \
    -addext "subjectAltName = DNS:edge.openziti.localdomain,IP:127.0.0.2" \
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
```


8. Create a chain of CAs for network components and edge in PEM container
```
rm ./pki/cas/openziti_network_components_cas.pem ./pki/cas/openziti_edge_cas.pem
cat ./pki/root_ca.cert ./pki/cas/openziti_ica.cert > ./pki/cas/openziti_network_components_cas.pem
cp ./pki/cas/openziti_network_components_cas.pem ./pki/cas/openziti_edge_cas.pem
```

9. Create a chain of certificates for server of network components
```
rm ./pki/end_certs/openziti_network_components-server.chain.pem
cat ./pki/end_certs/openziti_network_components_server.cert \
    ./pki/cas/openziti_network_components_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/end_certs/openziti_network_components-server.chain.pem
```

10. Create a chain of certificates for the server of edge
```
rm ./pki/end_certs/openziti_edge-server.chain.pem
cat ./pki/end_certs/openziti_edge_server.cert \
    ./pki/cas/openziti_edge_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/end_certs/openziti_edge-server.chain.pem
```

11. Create a chain of certificates for sign(identities) intermediate CA
```
rm ./pki/cas/openziti_sign_ica.chain.pem
cat ./pki/cas/openziti_sign_ica.cert \
    ./pki/cas/openziti_ica.cert \
    ./pki/root_ca.cert > ./pki/cas/openziti_sign_ica.chain.pem
```

12. Init an edge
```
ziti controller edge init controller_config.yaml -u "admin" -p "admin"
```

13. Run the controller
```
ziti controller run controller_config.yaml
```

14. Login into the controller
```
ziti edge login 127.0.0.2:1280 -u "admin" -p "admin"
```

15. Enroll the router(in a separate window)
```
ziti edge delete edge-router test-edge-router
ziti edge create edge-router test-edge-router -o test-edge-router.jwt -t -a public
ziti router enroll test-edge-router_config.yaml --jwt test-edge-router.jwt
```

16. Run the router(in a separate window)
```
ziti router run test-edge-router_config.yaml 
```
