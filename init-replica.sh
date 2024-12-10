#!/bin/bash

# # Start MongoDB as a background process
# mongod --replSet rs0 --bind_ip_all &

# # Wait for MongoDB to start
# sleep 5

# # Initialize the replica set
# mongosh --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}]})"

# # Keep MongoDB running in the foreground
# wait

#!/bin/bash

# Start MongoDB without authentication as a background process
mongod --replSet rs0 --bind_ip_all > /var/log/mongod.log 2>&1 &

# Wait for MongoDB to start
sleep 15

# Check MongoDB logs for errors
if ! pgrep -x "mongod" > /dev/null; then
    echo "MongoDB failed to start. Check logs for details."
    cat /var/log/mongod.log
    exit 1
fi

# Initialize the replica set
mongosh --eval "
try {
  rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}]});
  print('Replica set initialized successfully.');
} catch (err) {
  print('Error initializing replica set: ' + err);
}" 

# Wait for replica set initialization
sleep 5

# Create an admin user
mongosh --eval "
try {
  db = db.getSiblingDB('admin');
  db.createUser({
    user: 'andrew',
    pwd: '46566656',
    roles: [{role: 'root', db: 'admin'}]
  });
  print('Admin user created successfully.');
} catch (err) {
  print('Error creating admin user: ' + err);
}" 

# Keep MongoDB running in the foreground
wait
