# Bitcoind Quick

A dockerized bitcoin core container for quickly spinning up a (pruned) node with zmq support for running public-pool

## Setup and Usage

Setup involves a two-step process, initial setup and then running the container.

### Step 1: Initial Setup

Before running the container for the first time, you need to run the one of the two setup scripts.

If you only want a bitcoind container and no public pool, run bitcoind_setup.sh

This script:

1. Creates necessary directories
2. Generates secure RPC credentials
3. Creates a `bitcoin.conf` file with appropriate settings
4. Downloads a UTXO snapshot to speed up initial synchronization (if needed)

Run the setup script:

```bash
./setup.sh
```

If you want bitcoind and public pool, run setup.sh

This script:

1. Does everything the above script does
2. Prepares files and populates them with credentials

**IMPORTANT**: The script you chose will display your RPC credentials. Make sure to save these in a secure location immediately. They will not be shown again.

### UTXO Snapshot Option

During the setup process, you will be given the option to download a UTXO snapshot. This snapshot can significantly speed up the initial synchronization of your Bitcoin node, but it requires downloading about 16GB of data.

- If you choose 'Yes', the script will download and extract the snapshot, reducing the time needed for initial sync.
- If you choose 'No', the setup will skip the snapshot download. Your node will perform a full sync from the genesis block, which will take longer but doesn't require the additional download.

Consider your available bandwidth and storage when making this choice. If you have limited bandwidth or are in a hurry to get your node running, the snapshot can be very helpful.

### Step 2: Running the Container

After the initial setup, you can start your Bitcoin node using 


Docker run:

```bash
docker run -d \
  -p 8333:8333 \
  -p 8332:8332 \
  -p 3000:3000 \
  -v /root/bitcoind-data:/data \
  --name bitcoind \
  printergobrrr/bitcoind:pool
```

or Docker Compose:

```bash
docker-compose up -d bitcoind
```

Your `docker-compose.yml` file should look something like this:

```yaml
version: '3'
services:
  bitcoind:
    build: .
    volumes:
      - ./bitcoind-data:/data
    ports:
      - "3000:3000"
      - "8333:8333"
	  - "8332:8332"
```

This configuration ensures that:
- The `bitcoin.conf` file and blockchain data persist between container restarts
- The necessary ports are exposed for ZMQ and P2P network connections

**Important Security Note**: 
Port 8332 is the RPC port used by Bitcoin Core for API access. For security reasons, this port should only be used for internal connections and should not be exposed on the host machine to the public internet.


Basic ufw setup to secure your install
```
# Deny all non-explicitly allowed ports
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH access
sudo ufw allow ssh

# Allow HTTP and HTTPS access for Let's Encrypt certificate issuance and pool UI
sudo ufw allow http
sudo ufw allow https

# Allow bitcoind p2p port
sudo ufw allow 8333/tcp

# Allow pool stratum port
sudo ufw allow 3333/tcp

# Enable UFW
sudo ufw enable
```
 
### Monitoring Your Node

Check the synchronization progress:

```bash
docker logs -f bitcoind
```

(Press CTRL+C to exit logs)

### Security Note

The `bitcoin.conf` file contains your RPC credentials. Keep this file secure and never share it. If you need to change the credentials, you'll need to modify `bitcoin.conf` and restart the container.

This setup process ensures a secure and efficient initialization of your Bitcoin node, leveraging a UTXO snapshot for faster initial synchronization when needed.
