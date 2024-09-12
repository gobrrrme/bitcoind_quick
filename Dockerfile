FROM ruimarinho/bitcoin-core:latest

# Install necessary tools
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Copy your configuration file and setup script
COPY bitcoin.conf /home/bitcoin/.bitcoin/bitcoin.conf
COPY setup_pruned_node.sh /usr/local/bin/setup.sh
COPY setup_pruned_node.sh /usr/local/bin/bitcoind_setup.sh

# Make the script executable
RUN chmod +x /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/bitcoind_setup.sh

# Set the data directory
ENV BITCOIN_DATA=/data

# Expose ZMQ and RPC ports
EXPOSE 3000 8332 8333

# Use the setup script as the entrypoint
ENTRYPOINT ["/usr/local/bin/setup_pruned_node.sh"]

# Default command (can be overridden)
CMD ["-conf=/home/bitcoin/.bitcoin/bitcoin.conf", "-datadir=/data", "-zmqpubrawblock=tcp://0.0.0.0:3000"]
