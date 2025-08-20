# Secure SSH Authentication

## Box A 192.168.16.192
## Box B 192.168.16.106

### Generate PKI keys
ssh-keygeb -b 4096 -t rsa

### Copy key - Box B
ssh-copy-id watsondebuser@192.168.16.194

### Copy Key - Box A

ssh-copy-id watson@192.168.16.106



Now you use ssh with needing the password :-)
