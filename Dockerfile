ARG KEYCLOAK_VERSION=22.0.5

FROM docker.io/maven:3.8.7-openjdk-18 as mvn_builder

# The following token was restricted to be only able to pull
# Jeff Tian's GitHub Packages, so it's OK to be public and included
# in the source code
ENV GH_TOKEN_BASE64=Z2hwXzFaNm5tRWQzTFFuY1RUV3hZSVdlZTNLMjBTY2xXdjNoUkk5Nwo

RUN mkdir -p /root/.m2
COPY settings.xml /root/.m2/settings.xml

RUN mkdir -p /opt/keycloak
COPY . /opt/keycloak
RUN cd /opt/keycloak && GH_TOKEN=$(echo $GH_TOKEN_BASE64 | base64 --decode) mvn install -s /root/.m2/settings.xml

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder
COPY --from=mvn_builder /opt/keycloak/target/*.jar /opt/keycloak/providers/
COPY --from=mvn_builder /opt/keycloak/target/*.jar /opt/keycloak/deployments/

#COPY  temp/* /opt/keycloak/themes/base/admin/resources/partials
#COPY  ui/font_iconfont /opt/keycloak/themes/keycloak/common/resources/lib/font_iconfont
#COPY  ui/theme.properties /opt/keycloak/themes/keycloak/login/
COPY idps/dingding/keycloak-services-social-dingding-22.0.6.jar /opt/keycloak/providers/

ENV KC_PROXY_ADDRESS_FORWARDING=true

USER 1000

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

CMD ["start-dev", "--hostname-strict=false", "--http-port=$PORT", "--proxy=edge", "--db=postgres", "--db-url=$DB_URL", "--db-username=$DB_USERNAME", "--db-password=$DB_PASSWORD", "--features=\"preview,scripts\""]


