#!/bin/bash

echo "Welcome to the Public Pool Setup Script"
echo "---------------------------------------"

read -p "Are you setting up for a home network (H) or public server (P)? " setup_type

if [[ $setup_type == "H" || $setup_type == "h" ]]; then
    export TRAEFIK_API_INSECURE=true
    export DOMAIN="localhost"
    # Other home network specific settings
else
    export TRAEFIK_API_INSECURE=false
    read -p "Enter your domain name e.g. public-pool.io : " DOMAIN
    export DOMAIN
    read -p "Enter your email for Let's Encrypt: " ACME_EMAIL
    export ACME_EMAIL
    # Other public server specific settings
fi

# Function to generate random credential strings
generate_random_string() {
    openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | fold -w 21 | head -n 1
}

# Create necessary directories
mkdir -p bitcoind-data

# Generate secure RPC credentials
RPC_USER=$(generate_random_string)
RPC_PASSWORD=$(generate_random_string)

# Create bitcoin.conf if it doesn't exist
if [ ! -f bitcoin.conf ]; then
    cat > bitcoin.conf <<EOF
# Bitcoin Core configuration
rpcuser=$RPC_USER
rpcpassword=$RPC_PASSWORD
rpcallowip=0.0.0.0/0
rpcbind=0.0.0.0
zmqpubrawblock=tcp://0.0.0.0:3000
whitelist=172.16.0.0/12
disablewallet=1
prune=5000
EOF
    echo "Created bitcoin.conf"
fi

# Update configuration files
sed -i "s/REPLACE_RPC_USER/$RPC_USER/" bitcoin.conf
sed -i "s/REPLACE_RPC_PASSWORD/$RPC_PASSWORD/" bitcoin.conf
sed -i "s/REPLACE_RPC_USER/$RPC_USER/" pool.env
sed -i "s/REPLACE_RPC_PASSWORD/$RPC_PASSWORD/" pool.env

# Prompt for UTXO snapshot download
if [ ! -d "bitcoind-data/blocks" ] || [ ! -d "bitcoind-data/chainstate" ]; then
    read -p "Do you want to download the UTXO snapshot? This will speed up initial sync but requires about 16GB of data. (y/n) " choice
    case "$choice" in 
      y|Y ) 
        echo "Downloading latest UTXO snapshot signed by Nicolas Dorier (thanks Nicolas!)"
        echo "~16GB ...go grab a coffee :D this will take a while..."
        wget -O utxo-snapshot.tar https://eu2.contabostorage.com/1f50a74c9dc14888a8664415dad3d020:utxosets/utxo-snapshot-bitcoin-mainnet-820852.tar
        echo "Extracting UTXO snapshot..."
        tar -xvf utxo-snapshot.tar -C bitcoind-data
        rm utxo-snapshot.tar
        echo "Success! Blockchain snapshot extracted"
        ;;
      n|N ) 
        echo "Skipping UTXO snapshot download. Initial sync will take longer."
        ;;
      * ) 
        echo "Invalid input. Skipping UTXO snapshot download."
        ;;
    esac
else
    echo "Blockchain data already exists. Skipping download prompt."
fi

echo ""
echo "WARNING: The following credentials will only be displayed ONCE."
echo "Please save them in a secure location immediately!!!!1!1!"
echo ""
echo "Generated RPC credentials:"
echo "RPC User: $RPC_USER"
echo "RPC Password: $RPC_PASSWORD"
echo ""
echo "These credentials have been automatically added to your bitcoin.conf and pool.env. You're welcome"
echo "Make sure to keep these files secure and do not share them."
echo "Setup complete. You can now run 'docker compose up -d bitcoind'"
echo "After starting the bitcoin container, wait until it's fully synced before starting the rest"
echo "Check the status with 'docker logs -f bitcoind'  (press CRTL+C to exit logs)"
echo "Start the rest of the containers using 'docker compose up -d'"
