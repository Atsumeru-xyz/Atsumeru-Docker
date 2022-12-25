# syntax=docker/dockerfile:1
FROM eclipse-temurin:11-jre

RUN mkdir -p /library
RUN mkdir -p /app
WORKDIR /app
RUN curl -s https://api.github.com/repos/AtsumeruDev/Atsumeru/releases/latest | grep "browser_download_url.*.jar" |  cut -d : -f 2,3 |  tr -d \" |  wget -O /app/Atsumeru.jar -i -

CMD ["java","-jar","Atsumeru.jar"]

EXPOSE 31337
LABEL org.opencontainers.image.source="https://github.com/AtsumeruDev"
LABEL version="1.0.0"
LABEL description="Free self-hosted mangas/comics/light novels media server"