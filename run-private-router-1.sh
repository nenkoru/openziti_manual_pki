ziti edge login 127.0.0.1:1280 -u "admin" -p "admin" -y
ziti edge delete edge-router private-router-1
ziti edge create edge-router private-router-1 -o private-router-1.jwt -t -a public
ziti router enroll r1.yaml --jwt private-router-1.jwt
ziti router run r1.yaml 


