FROM debian:jessie

# Prerequisites
RUN apt-get -y update && apt-get install -y --no-install-recommends ca-certificates wget unzip liblua5.1-0

# Set timezone
ENV TZ=Europe/Berlin
RUN echo $TZ | tee /etc/timezone && \
	dpkg-reconfigure --frontend noninteractive tzdata

# Setup user and change to its home
RUN useradd -u 5000 -m -d /var/lib/mtasa/ mtasa && \
	cd /var/lib/mtasa && \

	# Download and install MTA Server
	wget -O mta.tar.gz https://linux.mtasa.com/dl/153/multitheftauto_linux_x64-1.5.3.tar.gz && \
	tar xfz mta.tar.gz && mv multitheftauto*/* ./ && \
	rm -Rf multitheftauto* && \
	rm mta.tar.gz && \

	# Download default resources
	mkdir /var/lib/mtasa/mods/deathmatch/resources && \
	cd /var/lib/mtasa/mods/deathmatch/resources && \
	wget -O res.zip https://mirror.mtasa.com/mtasa/resources/mtasa-resources-latest.zip && \
	unzip res.zip && \
	rm res.zip && \

	# Create modules directory and delete bad shipped libs
	mkdir /var/lib/mtasa/x64/modules && \
	rm -Rf /var/lib/mtasa/x64/linux-libs

# Expose ports (22005/tcp is exposed dynamically)
EXPOSE 8080/tcp

# Add worker server
ADD build/workerserver /var/lib/mtasa/workerserver

# Add entrypoint script
ADD build/docker-entrypoint.sh /docker-entrypoint.sh

# Add MTA configs and modules
ADD build/config/* /var/lib/mtasa/mods/deathmatch/
ADD build/modules/* /var/lib/mtasa/x64/modules/
ADD vrp/server/config/config.json.dist /var/lib/mtasa/config.json.dist

# Add required libraries
ADD build/libs/libmysqlclient.so.16 /usr/lib/

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

# Start commands
USER mtasa
CMD ["/docker-entrypoint.sh"]
