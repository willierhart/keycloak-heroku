FROM docker.io/maven:3.8.7-openjdk-18 as mvn_builder
RUN mkdir -p /opt/keycloak
COPY . /opt/keycloak
RUN cd /opt/keycloak && mvn clean install
