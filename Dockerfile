FROM ubuntu:latest

# Build with
#    docker build -t kelvinlawson/android-studio .
#
# Run the first time with: "./android-save-state.sh" so that
# it downloads, installs and saves installation packages inside
# the container:
#  * ./android-save-state.sh
#  * Accept prompts and install
#  * Quit
#  * Commit current container state as main image:
#    docker ps -a
#    docker commmit <id> kelvinlawson/android-studio
#  * You can now run the ready-installed container using
#    "android.sh".
#
# On further runs where you are not installing any studio
# packages run with "./android.sh"
#
# If you wish to update the container at any point (e.g. when
# installing new SDK versions from the SDK Manager) then run
# with "./android-save-state.sh" and commit the changes to
# your container.
#
# Notes: To run under some Window Managers (e.g. awesomewm) run
# "wmname LG3D" on the host OS first.
#
# USB device debugging:
#  Change the device ID in 51-android.rules.
#  Add "--privileged -v /dev/bus/usb:/dev/bus/usb" to the startup cmdline

RUN dpkg --add-architecture i386 && apt-get update

# Download latest Android Studio bundle as per https://developer.android.com/studio/index.html
RUN apt-get install -y curl unzip grep
RUN DOWNLOAD_URL=$(curl -s https://developer.android.com/studio/index.html | \
    grep -Eo https://dl.google.com/dl/android/studio/ide-zips/[0-9]+.[0-9]+.[0-9]+.[0-9]+/android-studio-ide-[0-9]+.[0-9]+-linux.zip) && \
    curl -o /tmp/studio.zip $DOWNLOAD_URL && \
    unzip -d /opt /tmp/studio.zip && \
    rm /tmp/studio.zip

# Install X11
RUN apt-get install -y x11-apps sudo

# Install prerequisites, as per https://developer.android.com/studio/troubleshoot.html#linux-libraries - as of v2.2 OpenJDK is pre-bundled.
RUN apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 libz1:i386 libbz2-1.0:i386
# RUN apt-get install -y lib32c6 lib32ncurses5 lib32stdc++6 lib32z1 lib32bz2-1.0

# Install other useful tools
RUN apt-get install -y git vim ant

# Clean up
RUN apt-get clean && apt-get purge

# Set up permissions for X11 access.
# Replace 1000 with your user / group id.
RUN export uid=502 gid=20 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

# Set up USB device debugging (device is ID in the rules files)
# ADD 51-android.rules /etc/udev/rules.d
# RUN chmod a+r /etc/udev/rules.d/51-android.rules

USER developer
ENV HOME /home/developer
CMD /opt/android-studio/bin/studio.sh

