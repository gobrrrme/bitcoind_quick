FROM ruimarinho/bitcoin-core:latest
# Install necessary tools
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*
# Set the data directory
ENV BITCOIN_DATA=/data
# Expose ZMQ and RPC ports
EXPOSE 3000 8332 8333
# Default command (can be overridden)
CMD ["-conf=/home/bitcoin/.bitcoin/bitcoin.conf", "-datadir=/data", "-zmqpubrawblock=tcp://0.0.0.0:3000"]
