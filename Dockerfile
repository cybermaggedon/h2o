
FROM fedora:27

# H2O version
ARG VERSION=unknown

# Install Java
RUN dnf install -y java-1.8.0-openjdk && \
    dnf install -y zip && \
    dnf clean all

# Unpack H2O
COPY h2o-${VERSION}.zip /
RUN unzip h2o-${VERSION}.zip && rm -f h2o-${VERSION}.zip

# Install start script
COPY start /

# Run /start script
WORKDIR h2o-${VERSION}
CMD [ "/start" ]



