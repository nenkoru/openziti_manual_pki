1. Copy the root ca of the bayfut
`cp ~/code/repos/bayfut_pki/pems/bayfut_root_ca.pem`
or from the trust root, or from the github

2.  
```
cat > engine.conf <<EOF
openssl_conf = openssl_init
 
[openssl_init]
engines = engine_section
 
[engine_section]
pkcs11 = pkcs11_section
 
[pkcs11_section]
engine_id = pkcs11
dynamic_path = /opt/homebrew/lib/engines-3/pkcs11.dylib
MODULE_PATH = /opt/homebrew/lib/libykcs11.dylib
default_algorithms = ALL

EOF
```
3. alias yubissl='OPENSSL_CONF=engine.conf openssl' (possibly into the .zshrc)

4. Create an alias for yubissl
`alias yubissl='OPENSSL_CONF=engine.conf openssl'`

5. Create an intermediate CA for Openziti
```
openssl genrsa -aes256 \
    -out ./pems/openziti_ica.key.pem 2048

openssl req -new -sha256 \
    -key ./pems/openziti_ica.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Bayfut/OU=Openziti ICA" \
    -out ./pems/openziti_ica.pem.csr

yubissl x509 \
    -req -in ./pems/openziti_ica.pem.csr \
    -CA ./pems/bayfut_root_ca.pem \
    -CAkeyform engine \
    -engine pkcs11 \
    -CAkey slot_0-id_1 \
    -days 600 \
    -extensions v3_intermediate_ca \
    -extfile extensions.conf \
    -out "./pems/openziti_ica.pem"
```

6. Create a control-plane intermediate CA
```
openssl genrsa -aes256 \
    -out ./pems/openziti_controlplane_ica.key.pem 2048

openssl req -new -sha256 \
    -key ./pems/openziti_controlplane_ica.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Bayfut/OU=Openziti ControlPlane ICA" \
    -out ./pems/openziti_controlplane_ica.pem.csr

openssl x509 \
    -req -in ./pems/openziti_controlplane_ica.pem.csr \
    -CA ./pems/openziti_ica.pem \
    -CAkey ./pems/openziti_ica.key.pem \
    -days 600 \
    -extensions v3_intermediate_ca_end_certs_only \
    -extfile extensions.conf \
    -out "./pems/openziti_controlplane_ica.pem"
```

7. Create a edge intermediate CA
```
openssl genrsa -aes256 \
    -out ./pems/openziti_edge_ica.key.pem 2048

openssl req -new -sha256 \
    -key ./pems/openziti_edge_ica.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Bayfut/OU=Openziti ControlPlane ICA" \
    -out ./pems/openziti_edge_ica.pem.csr

openssl x509 \
    -req -in ./pems/openziti_edge_ica.pem.csr \
    -CA ./pems/openziti_ica.pem \
    -CAkey ./pems/openziti_ica.key.pem \
    -days 600 \
    -extensions v3_intermediate_ca_end_certs_only \
    -extfile extensions.conf \
    -out "./pems/openziti_edge_ica.pem"
```
8. Create a sign(identities) intermediate CA
```
openssl genrsa -aes256 \
    -out ./pems/openziti_sign_ica.key.pem 2048

openssl rsa \
    -in ./cas/openziti_sign_ica.key.pem \
    -out ./cas/openziti_sign_ica.key.pem

openssl req -new -sha256 \
    -key ./pems/openziti_sign_ica.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Bayfut/OU=Openziti Sign ICA" \
    -out ./pems/openziti_sign_ica.pem.csr

openssl x509 \
    -req -in ./pems/openziti_sign_ica.pem.csr \
    -CA ./pems/openziti_ica.pem \
    -CAkey ./pems/openziti_ica.key.pem \
    -days 600 \
    -extensions v3_intermediate_ca_end_certs_only \
    -extfile extensions.conf \
    -out "./pems/openziti_sign_ica.pem"
```

9. Create a client, server certificates for controlplane
```
openssl genrsa -aes256 \
    -out ./certs/openziti_controlplane_certs.key.pem 2048

openssl rsa \
    -in ./certs/openziti_controlplane_certs.key.pem \
    -out ./certs/openziti_controlplane_certs.key.pem

openssl req -new -sha256 \
    -key ./certs/openziti_controlplane_certs.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Openziti ControlPlane Server Cert/OU=Openziti ControlPlane" \
    -addext "subjectAltName = DNS:controller.openziti.macos,IP:127.0.0.1" \
    -out ./certs/openziti_controlplane_server.pem.csr

openssl req -new -sha256 \
    -key ./certs/openziti_controlplane_certs.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Openziti ControlPlane Client Cert/OU=Openziti ControlPlane" \
    -addext "subjectAltName = DNS:controller.openziti.macos,IP:127.0.0.1" \
    -out ./certs/openziti_controlplane_client.pem.csr

openssl x509 \
    -req -in ./certs/openziti_controlplane_server.pem.csr \
    -CA ./cas/openziti_controlplane_ica.pem \
    -CAkey ./cas/openziti_controlplane_ica.key.pem \
    -days 600 \
    -extensions v3_end_cert \
    -extfile extensions.conf \
    -copy_extensions copyall \
    -out "./certs/openziti_controlplane_server.pem"

openssl x509 \
    -req -in ./certs/openziti_controlplane_client.pem.csr \
    -CA ./cas/openziti_controlplane_ica.pem \
    -CAkey ./cas/openziti_controlplane_ica.key.pem \
    -days 600 \
    -extensions v3_end_cert \
    -extfile extensions.conf \
    -copy_extensions copyall \
    -out "./certs/openziti_controlplane_client.pem"
```

10. Create a client, server certificates for edge
```
openssl genrsa -aes256 \
    -out ./certs/openziti_edge_certs.key.pem 2048

openssl rsa \
    -in ./certs/openziti_edge_certs.key.pem \
    -out ./certs/openziti_edge_certs.key.pem

openssl req -new -sha256 \
    -key ./certs/openziti_edge_certs.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Openziti ControlPlane Server Cert/OU=Openziti ControlPlane" \
    -addext "subjectAltName = DNS:router.openziti.macos,IP:127.0.0.1" \
    -out ./certs/openziti_edge_server.pem.csr

openssl req -new -sha256 \
    -key ./certs/openziti_edge_certs.key.pem \
    -subj "/C=RU/ST=Saint-Petersburg/O=Bayfut/CN=Openziti ControlPlane Client Cert/OU=Openziti ControlPlane" \
    -addext "subjectAltName = DNS:router.openziti.macos,IP:127.0.0.1" \
    -out ./certs/openziti_edge_client.pem.csr

openssl x509 \
    -req -in ./certs/openziti_edge_server.pem.csr \
    -CA ./cas/openziti_edge_ica.pem \
    -CAkey ./cas/openziti_edge_ica.key.pem \
    -days 600 \
    -extensions v3_end_cert \
    -extfile extensions.conf \
    -copy_extensions copyall \
    -out "./certs/openziti_edge_server.pem"

openssl x509 \
    -req -in ./certs/openziti_edge_client.pem.csr \
    -CA ./cas/openziti_edge_ica.pem \
    -CAkey ./cas/openziti_edge_ica.key.pem \
    -days 600 \
    -extensions v3_end_cert \
    -extfile extensions.conf \
    -copy_extensions copyall \
    -out "./certs/openziti_edge_client.pem"
```


11. Create a chain of CAs for controlplane and edge in PEM container
```
cat ./bayfut_root_ca.pem ./cas/openziti_ica.pem > ./cas/openziti_controlplane_cas.pem
cp ./cas/openziti_controlplane_cas.pem ./cas/openziti_edge_cas.pem
```

12. Create a chain of certificates for server of controlplane
```
cat ./certs/openziti_controlplane_server.pem ./cas/openziti_controlplane_ica.pem ./cas/openziti_ica.pem ./bayfut_root_ca.pem > ./certs/openziti_controlplane-server.chain.pem
```

13. Create a chain of certificates for server of edge
```
cat ./certs/openziti_edge_server.pem ./cas/openziti_edge_ica.pem ./cas/openziti_ica.pem ./bayfut_root_ca.pem > ./certs/openziti_edge-server.chain.pem
```

14. Create a chain of certificates for sign(identities) ica
```
cat ./cas/openziti_sign_ica.pem ./cas/openziti_ica.pem ./bayfut_root_ca.pem > ./cas/openziti_sign_ica.chain.pem
```


15. Init an edge
```
ziti controller edge init controller_config.yaml -u "admin" -p "admin"
```
