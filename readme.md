﻿# lambda-certbot

Basically a fork from: https://github.com/kingsoftgames/certbot-lambda/tree/master


## Package your lambda.zip
```
sudo bash ./package.sh 
```

## Deploy it
```
terraform -chdir tf apply -auto-approve
```
