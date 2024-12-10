# Base image
FROM mongo:6

# Copy the mongod.conf into the container
COPY mongod.conf /etc/mongod.conf

# Copy the initialization script
COPY init-replica.sh /usr/local/bin/init-replica.sh

# Ensure proper permissions for the script
RUN chmod +x /usr/local/bin/init-replica.sh

# Set the default command
CMD ["/usr/local/bin/init-replica.sh"]

# Expose the default MongoDB port
EXPOSE 27017
