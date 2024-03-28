ARG KEYCLOAK_VERSION=24.0.0

FROM docker.io/maven:3.8.7-openjdk-18 as mvn_builder

# The following token was restricted to be only able to pull
# Jeff Tian's GitHub Packages, so it's OK to be public and included
# in the source code
ENV GH_TOKEN_BASE64="Z2hwX0Z1VEpidGtVVUJJbWdhbm1KSFRENTdDOGRTTkJIcjE4WmhqOQo="

RUN mkdir -p /root/.m2
COPY settings.xml /root/.m2/settings.xml

RUN mkdir -p /opt/keycloak
COPY . /opt/keycloak
RUN cd /opt/keycloak && GH_TOKEN=$(echo $GH_TOKEN_BASE64 | base64 --decode) mvn install -s /root/.m2/settings.xml

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder
COPY --from=mvn_builder /opt/keycloak/target/*.jar /opt/keycloak/providers/
COPY --from=mvn_builder /opt/keycloak/target/*.jar /opt/keycloak/deployments/

ENV KC_PROXY_ADDRESS_FORWARDING=true

USER 1000

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

ENV JAVA_OPTS="-Xms64m -Xmx300m"

CMD ["start", "--hostname-strict=false", "--http-port=$PORT", "--proxy=edge", "--db=postgres", "--db-url=$DB_URL", "--db-username=$DB_USERNAME", "--db-password=$DB_PASSWORD", "--spi-phone-default-service=dummy", "--spi-phone-default-duplicate-phone=false"]


