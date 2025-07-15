FROM openjdk:8-jre-alpine
ADD https://ewebos.tenfell.cn/php/api.php?module=channel&action=downWebos&id=2db082fce31e65d7b32d080745ce3267 /webos/webos.zip
RUN unzip /webos/webos.zip -d /webos/
EXPOSE 8088
WORKDIR /webos/api
CMD sh restart.sh ; sleep 999999d