# Instructions


## Build the image, test the image

```bash

# if on mac - this will work
docker build -t hants/mongo-replica-on:v85 .

# if for linux: - will only work on linux, give errors on mac: 
docker build --platform linux/amd64 -t hants/mongo-replica-on:v85 .


docker run --name testABC -p 27017:27017 hants/mongo-replica-on:v85

docker exec -it testABC mongosh --eval "rs.status()"



    
```

## Push the image to docker hub

```bash

docker push hants/mongo-replica-on:v85
    
```

## For connecting:

- Then need to use the new user, e.g., andrew 
- Connection string here needs to include the replica set name, e.g., rs0
- Connection string here needs to include the authSource=admin to authenticate against the admin database

```bash
mongodb://andrew:{password}@20.62.193.224:27017/?replicaSet=rs0&authSource=admin
```


