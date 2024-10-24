ziti edge login 127.0.0.1:1280 -u "admin" -p "admin" -y
ziti edge delete edge-router test-edge-router
ziti edge create edge-router test-edge-router -o test-edge-router.jwt -t -a public
ziti router enroll test-edge-router_config.yaml --jwt test-edge-router.jwt
ziti router run test-edge-router_config.yaml 


