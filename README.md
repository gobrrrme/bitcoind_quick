# Bitcoind Quick

A dockerized bitcoin core container for quickly spinning up a (pruned) node with zmq support for running public-pool

## Setup and Usage

Clone the repository:
   ```bash
   git clone https://github.com/gobrrrme/bitcoind_quick
   cd bitcoind_quick
   ```

Setup involves a two-step process, initial setup and then running the container.

### Step 1: Initial Setup

Before running the container for the first time, you need to run one of the two setup scripts.

Make the setup scripts executable:
   ```bash
   chmod +x setup.sh
   chmod +x bitcoind_setup.sh
   ```

If you want just the bitcoind container and don't plan to run public pool, run bitcoind_setup.sh

This script:

1. Creates necessary directories
2. Generates secure RPC credentials
3. Creates a `bitcoin.conf` file with appropriate settings (edit it to your liking)
4. Downloads a UTXO snapshot to speed up initial synchronization (optional)

Run the setup script:

```bash
./setup.sh
```

If you want bitcoind and public-pool, run setup.sh

This script:

1. Does everything the above script does
2. Prepares additional files for publicpool and populates them with credentials

```bash
./bitcoind_setup.sh
```

**IMPORTANT**: The script you chose will display your RPC credentials. Make sure to save these in a secure location immediately. They will not be shown again.

### UTXO Snapshot Option

During the setup process, you will be given the option to download a UTXO snapshot. This snapshot can significantly speed up the initial synchronization of your Bitcoin node, but it requires downloading about 16GB of data.

- If you choose 'Yes', the script will download and extract the snapshot, reducing the time needed for initial sync.
- If you choose 'No', the setup will skip the snapshot download. Your node will perform a full sync from the genesis block, which will take longer but doesn't require the additional download.

Consider your available bandwidth and storage when making this choice. If you have limited bandwidth or are in a hurry to get your node running, the snapshot can be very helpful.

### Step 2: Running the Container

After the initial setup, you can start your Bitcoin node using 

If you just want the bitcoin container, use Docker run:

```bash
docker run -d \
  -p 8333:8333 \
  -p 8332:8332 \
  -p 3000:3000 \
  -v ./bitcoind-data:/data \
  --name bitcoind \
  bitcoind_quick
```

if you want bitcoin and public-pool, use Docker Compose:

```bash
docker-compose up -d bitcoind
```
**The bitcoin container needs to sync before you can start the rest**

A basic `docker-compose.yml` file can be found in the repo.


This bitcoin container configuration ensures that:
- The `bitcoin.conf` file and blockchain data persist between container restarts
- The necessary ports are exposed for ZMQ and P2P network connections

**Security Note**: 
Port 8332 is the RPC port used by Bitcoin Core for API access. This port should only ever be used for internal connections, it can be dangerous to expose it on the host machine.


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

### Public Pool Setup

Once your container is synced, start the rest of the containers one by one:

```bash
docker-compose up -d traefik
docker-compose up -d public-pool
docker-compose up -d public-pool-ui
docker-compose up -d watchtower
```

Check the logs of the publicpool container:

```bash
docker logs -f public-pool
```

(Press CTRL+C to exit logs)

### That's basically it.
If your pool runs as expected, it's time to point miners to it.


# Use this software at your own risk!
# I'm not a software engineer, you might encounter bugs or problems I didn't account for. If so, please create an issue.

If all went well, your public-pool should be reachable on the configured domain or on localhost.
