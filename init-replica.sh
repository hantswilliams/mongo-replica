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

# Generate a key file if it doesn't already exist
if [ ! -f /data/keyfile ]; then
    echo "Generating key file for replica set authentication..."
    openssl rand -base64 756 > /data/keyfile
    chmod 600 /data/keyfile
fi

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

# Generate mongod.conf if it doesn't exist
if [ ! -f /etc/mongod.conf ]; then
    echo "Creating mongod.conf..."
    cat <<EOF > /etc/mongod.conf
net:
  port: 27017
  bindIp: 0.0.0.0  # Allow connections from any IP

security:
  authorization: enabled
  keyFile: /data/keyfile

replication:
  replSetName: rs0
EOF
fi

# Check if the replica set is already initialized
IS_REPLICA_SET_INITIATED=$(mongosh --quiet --eval "try { rs.status().ok } catch (err) { 0 }" || echo "0")

if [ "$IS_REPLICA_SET_INITIATED" -eq "1" ]; then
    echo "Replica set is already initialized."
else
    echo "Initializing replica set..."
    mongosh --quiet --eval "
    try {
      rs.initiate({_id: 'rs0', members: [{_id: 0, host: '20.62.193.224:27017'}]});
      print('Replica set initialized successfully.');
    } catch (err) {
      print('Error initializing replica set: ' + err);
    }" || exit 1
    sleep 5
fi

# Check if the admin user already exists
IS_USER_EXISTS=$(mongosh --quiet --eval "
try {
  db = db.getSiblingDB('admin');
  db.getUser('andrew') !== null ? 1 : 0;
} catch (err) {
  print('Error checking user: ' + err);
  0;
}" || echo "0")

if [ "$IS_USER_EXISTS" -eq "1" ]; then
    echo "Admin user already exists."
else
    echo "Creating admin user..."
    mongosh --quiet --eval "
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
    }" || exit 1
fi

# Restart MongoDB with authentication if necessary
echo "Restarting MongoDB with authentication enabled..."
mongod --shutdown
sleep 5
mongod --replSet rs0 --auth --keyFile /data/keyfile --bind_ip_all > /var/log/mongod.log 2>&1 &

# Wait for MongoDB to restart
sleep 15

# Check if MongoDB restarted successfully
if ! pgrep -x "mongod" > /dev/null; then
    echo "MongoDB failed to restart. Check logs for details."
    cat /var/log/mongod.log
    exit 1
fi

echo "MongoDB is running with replica set and authentication enabled."

# Keep MongoDB running in the foreground
tail -f /var/log/mongod.log

