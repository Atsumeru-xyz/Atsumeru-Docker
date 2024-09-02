# syntax=docker/dockerfile:1
FROM eclipse-temurin:11-jre

RUN mkdir -p /library
RUN mkdir -p /app
WORKDIR /app
RUN curl -s https://api.github.com/repos/Atsumeru-xyz/Atsumeru/releases/latest | grep "browser_download_url.*.jar" |  cut -d : -f 2,3 |  tr -d \" |  wget -O Atsumeru.jar -i -

ENTRYPOINT ["sh", "-c", "java -Dserver.port=31337 ${JAVA_OPT_XMX} -jar Atsumeru.jar"]

EXPOSE 31337

HEALTHCHECK --interval=1m --timeout=5s --retries=3 --start-period=1m CMD curl -o /dev/null -s -w "%{http_code}\n" http://localhost:31337/api/server/ping | grep -qE "^[4]" && exit 0 || echo "Atsumeru , blyat, upal!" && exit 1

LABEL org.opencontainers.image.source="https://github.com/Atsumeru-xyz"
LABEL version="1.0.3"
LABEL description="Free self-hosted mangas/comics/light novels media server"
LABEL maintainer="OlegEnot"
