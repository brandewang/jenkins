FROM k8s-harbor.test.fruitday.com/base/springboot:v1

MAINTAINER nijq@fruitday.com

ARG path

COPY ${path} /opt/

CMD ["/etc/init.d/app"]
