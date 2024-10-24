ziti edge login 127.0.0.1:1280 -u "admin" -p "admin" -y
ziti edge delete edge-router private-router-2
ziti edge create edge-router private-router-2 -o private-router-2.jwt -t -a public
ziti router enroll r2.yaml --jwt private-router-2.jwt
ziti router run r2.yaml 


