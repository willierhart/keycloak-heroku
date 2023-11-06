FROM docker.io/maven:3.8.7-openjdk-18 as mvn_builder

# The following token was restricted to be only able to pull
# Jeff Tian's GitHub Packages, so it's OK to be public and included
# in the source code
ENV GH_TOKEN=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
RUN mkdir -p /root/.m2
COPY settings.xml /root/.m2/settings.xml

RUN mkdir -p /opt/keycloak
COPY . /opt/keycloak
RUN cd /opt/keycloak && mvn clean install
