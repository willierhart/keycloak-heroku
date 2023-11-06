ARG KEYCLOAK_VERSION=22.0.5
ARG GH_TOKEN

FROM docker.io/maven:3.8.7-openjdk-18 as mvn_builder
ENV GH_TOKEN=$GH_TOKEN
RUN mkdir -p /root/.m2
COPY settings.xml /root/.m2/settings.xml

RUN mkdir -p /opt/keycloak
COPY . /opt/keycloak
RUN cd /opt/keycloak && mvn install -s /root/.m2/settings.xml

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder
COPY --from=mvn_builder /opt/keycloak/target/*.jar /opt/keycloak/providers/
COPY --from=mvn_builder /opt/keycloak/target/*.jar /opt/keycloak/deployments/

COPY idps/wechat-mobile/keycloak-services-social-weixin.jar \
    /opt/keycloak/providers/

#COPY  temp/* /opt/keycloak/themes/base/admin/resources/partials
#COPY  ui/font_iconfont /opt/keycloak/themes/keycloak/common/resources/lib/font_iconfont
#COPY  ui/theme.properties /opt/keycloak/themes/keycloak/login/

ENV KC_PROXY_ADDRESS_FORWARDING=true

USER 1000

RUN /opt/keycloak/bin/kc.sh build --health-enabled=true

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/
WORKDIR /opt/keycloak

CMD ["start-dev", "--hostname-strict=false", "--http-port=$PORT", "--proxy=edge", "--db=postgres", "--db-url=$DB_URL", "--db-username=$DB_USERNAME", "--db-password=$DB_PASSWORD", "--features=\"preview,scripts\""]


