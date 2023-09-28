FROM ubuntu:22.04
#warp-svc use systemd ,docker run systemd is Insecure 

# install supervisor and Docker Engine 
#COPY sources.list /etc/sources.list
RUN --mount=type=cache,target=/var/cache/apt \
    apt update \
    && apt install -y curl gpg  \
    && curl https://pkg.cloudflareclient.com/pubkey.gpg |  gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/  jammy main" |  tee /etc/apt/sources.list.d/cloudflare-client.list \
    && apt update \
    && apt install cloudflare-warp -y \
    && apt-get autoremove -y \
    &&  apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# init.sh is a warp-cli init file
COPY init.sh /init.sh
CMD ["/init.sh"]
