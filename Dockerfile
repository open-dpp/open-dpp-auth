FROM openjdk:21-slim AS healthcheck
WORKDIR /opt/healthcheck
COPY ./keycloak/Healthcheck.java Healthcheck.java
COPY ./keycloak/Manifest.txt Manifest.txt
RUN javac Healthcheck.java
RUN jar cvfm healthcheck.jar Manifest.txt Healthcheck.class

FROM quay.io/keycloak/keycloak:26.0.6 AS builder

# Enable health and metrics support
# ENV KC_HEALTH_ENABLED=true
# ENV KC_METRICS_ENABLED=true

# Configure a database vendor
# ENV KC_DB=postgres

WORKDIR /opt/keycloak

# Copy custom theme
# COPY --from=node /keywind/theme/ ./themes/

# for demonstration purposes only, please make sure to use proper certificates in production instead
# RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.0.6
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# ENV KC_DB=postgres
# ENV KC_DB_URL_HOST=postgres
# ENV KC_DB_SCHEMA=keycloak
# ENV KC_DB_USERNAME=keycloak
# ENV KC_DB_PASSWORD=keycloak
# ENV KC_HOSTNAME=auth.opendpp.localhost

# Copy the custom .jar
# COPY --from=maven /data/target/deploy/ /opt/keycloak/providers/

# Copy the realm configuration
COPY ./keycloak/realm-export.json /opt/keycloak/data/import/realm.json

# Create healthcheck script
WORKDIR /opt/healthcheck
COPY --from=healthcheck /opt/healthcheck/healthcheck.jar /opt/healthcheck/healthcheck.jar

WORKDIR /opt/keycloak

# --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false

ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
