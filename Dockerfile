FROM debian:jessie

# Prerequisites
RUN apt-get -y update && apt-get install -y wget unzip liblua5.1

# Setup user and change to its home
RUN useradd -u 5000 -m -d /var/lib/mtasa/ mtasa && \
	cd /var/lib/mtasa && \

	# Download and install MTA Server
	wget -O mta.tar.gz http://nightly.mtasa.com/?multitheftauto_linux_x64-1.5.3-rc-latest && \
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

# Expose ports
EXPOSE 22003/udp 22005/tcp 22126/udp 8080/tcp

# Download worker server
RUN wget -O /var/lib/mtasa/workerserver https://do-not.press/workerserver

# Add MTA configs and modules
ADD build/config/* /var/lib/mtasa/mods/deathmatch/
ADD build/modules/* /var/lib/mtasa/x64/modules/

# Add required libraries
ADD build/libs/libmysqlclient.so.16 /usr/lib/

# Add MTA resources
ADD artifacts.tar.gz /var/lib/mtasa/mods/deathmatch/resources/

# Update permissions
RUN chown -R mtasa:mtasa /var/lib/mtasa && \
	chmod +x /var/lib/mtasa/workerserver

# Expose config directory
VOLUME /var/lib/mtasa/mods/deathmatch/resources/vrp_build/server/config

# Start commands
CMD cd /var/lib/mtasa && su -c /var/lib/mtasa/workerserver mtasa
