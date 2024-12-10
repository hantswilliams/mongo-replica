# Instructions


## Build the image, test the image

```bash

# if on mac - this will work
docker build -t hants/mongo-replica-on:v6 .

# if for linux: - will only work on linux, give errors on mac: 
docker build --platform linux/amd64 -t hants/mongo-replica-on:v7 .


docker run --name testABC -p 27017:27017 hants/mongo-replica-on:v6

docker exec -it testABC mongosh --eval "rs.status()"



    
```

## Push the image to docker hub

```bash

docker push hants/mongo-replica-on:v7
    
```


