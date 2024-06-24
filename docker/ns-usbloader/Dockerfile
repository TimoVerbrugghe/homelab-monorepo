# Use an official OpenJDK image with Debian
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DISPLAY=:0

VOLUME /nsp
VOLUME /root/.java/.userPrefs/NS-USBloader

# Install wget (if not already installed)
RUN apt-get update && apt-get install -y \
    wget tar \
    libx11-6 libxxf86vm1 libgl1-mesa-glx \
    xvfb x11vnc openbox \
    supervisor \
    novnc websockify \
    openjdk-11-jdk \
    # OpenJFX is absolutely necessary because openjdx in docker apparently does not install JavaFX components
    openjfx

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install ns-usbloader
RUN wget https://github.com/developersu/ns-usbloader/releases/latest/download/ns-usbloader-7.1.jar && \
    chmod +x ns-usbloader-7.1.jar && \
    mkdir /usr/local/app && \
    mv ns-usbloader-7.1.jar /usr/local/app/ns-usbloader.jar

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Add the Openbox config file for maximizing windows
ADD rc.xml /root/.config/openbox/rc.xml

# Add preformatted preferences file for NS-USBLoader
ADD prefs.xml /root/.java/.userPrefs/NS-USBloader/prefs.xml

# Create a symbolic link between /usr/share/novnc/vnc.html and index.html
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Set the working directory
WORKDIR /usr/local/app/

# Expose port 8080 for noVNC and 6042 for NS-USBLoader file transfers
EXPOSE 8080
EXPOSE 6042

# Start Xvfb, Fluxbox, x11vnc & novnc server, and run the Java application
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]