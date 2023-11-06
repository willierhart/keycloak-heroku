docker build --build-arg="GH_TOKEN=$2" -f Dockerfile.keycloak-heroku.mvn.builder -t jefftian/keycloak-builder:"$1" .
docker images
docker push jefftian/keycloak-builder:"$1"
