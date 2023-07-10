FROM debian:bookworm

# Prerequisites
RUN apt-get -y update && apt-get install -y --no-install-recommends ca-certificates wget unzip openssl libncursesw5

# Set timezone
ENV TZ=Europe/Berlin
RUN echo $TZ | tee /etc/timezone && \
	dpkg-reconfigure --frontend noninteractive tzdata

# Setup user and change to its home
RUN useradd -u 5000 -m -d /var/lib/mtasa/ mtasa

WORKDIR /var/lib/mtasa

	# Download and install MTA Server
RUN	wget -q -O mta.tar.gz https://nightly.multitheftauto.com/multitheftauto_linux_x64-1.6.0-rc-21884.tar.gz && \
	tar xfz mta.tar.gz && mv multitheftauto*/* ./ && \
    ls -ls && \
	rm -Rf multitheftauto* && \
	rm mta.tar.gz

	# Download default resources
RUN	mkdir /var/lib/mtasa/mods/deathmatch/resources && \
	cd /var/lib/mtasa/mods/deathmatch/resources && \
	wget -O res.zip https://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip && \
	unzip res.zip && \
	rm res.zip

	# Create modules directory and delete bad shipped libs
RUN	mkdir /var/lib/mtasa/x64/modules && \
	rm -Rf /var/lib/mtasa/x64/linux-libs

# Expose ports (22003/udp, 22126/udp, 22005/tcp are exposed dynamically)
EXPOSE 8080/tcp

# Add subproject artitifacts
ADD build/workerserver /var/lib/mtasa/workerserver
ADD build/ml_gps.so /var/lib/mtasa/x64/modules/ml_gps.so
ADD build/ml_jwt.so /var/lib/mtasa/x64/modules/ml_jwt.so

# Add entrypoint script
ADD build/docker-entrypoint.sh /docker-entrypoint.sh

# Add MTA configs and modules
ADD build/config/* /var/lib/mtasa/mods/deathmatch/
ADD build/modules/* /var/lib/mtasa/x64/modules/

# Add MTA resources
ADD artifacts.tar.gz /var/lib/mtasa/mods/deathmatch/resources/

# Remove config files to ensure they are copied to the exposed volume on start
RUN rm /var/lib/mtasa/mods/deathmatch/resources/vrp_build/server/config/*

# Update permissions
RUN chown -R mtasa:mtasa /var/lib/mtasa && \
	chmod +x /var/lib/mtasa/workerserver && \
	chmod +x /docker-entrypoint.sh

# Expose config directory
VOLUME /var/lib/mtasa/mods/deathmatch/resources/vrp_build/server/config

# Expose server data dirs
VOLUME /var/lib/mtasa/mods/deathmatch/logs
VOLUME /var/lib/mtasa/mods/deathmatch/dumps

# Start commands
USER mtasa
CMD ["/docker-entrypoint.sh"]
