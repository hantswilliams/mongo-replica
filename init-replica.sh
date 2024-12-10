#!/bin/bash

# Start MongoDB as a background process
mongod --replSet rs0 --bind_ip_all &

# Wait for MongoDB to start
sleep 5

# Initialize the replica set
mongosh --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}]})"

# Keep MongoDB running in the foreground
wait
