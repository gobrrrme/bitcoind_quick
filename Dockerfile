FROM ruimarinho/bitcoin-core:latest
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*
ENV BITCOIN_DATA=/data
EXPOSE 3000 8332 8333
ENTRYPOINT ["bitcoind"]
CMD ["-conf=/data/bitcoin.conf", "-datadir=/data", "-zmqpubrawblock=tcp://0.0.0.0:3000"]
