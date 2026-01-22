cat authelia configuration.yml
---
theme: dark
server:
  address: 'tcp://0.0.0.0:9091/'

log:
  level: info

authentication_backend:
  file:
    path: /config/users_database.yml

access_control:
  default_policy: deny
  rules:
    - domain: camera.domain.topdomain
      policy: one_factor

identity_validation:
  reset_password:
    jwt_secret: ""

session:
  secret: ""
  cookies:
    - domain: domain.topdomain
      authelia_url: https://auth.domain.topdomain
  expiration: 1h
  inactivity: 5m

storage:
  encryption_key: ""
  local:
    path: /config/db.sqlite3

notifier:
  filesystem:
    filename: /config/notification.txt
fred ~/docker/authelia ❯ 


cat users_database.yml 
---
users:
  username:
    password: "secret"
    displayname: Name
    email: email

  username:
    password: "secret"
    displayname: Name
    email: email
##########################################

cat config.yml 
---
streams:
  kids_bedroom:
    - rtsp://username:password@IP-address:554/stream1

api:
  listen: ":1984"

webrtc:
  listen: ":8555"
