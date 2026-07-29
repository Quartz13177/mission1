FROM nginx:alpine

LABEL org.opencontainers.image.title="my-custom-nginx"
LABEL org.opencontainers.image.description="Codyssey mission1 custom web server"

# 환경 변수 - 실행할 때 -e 옵션으로 바꿀 수 있다 (설정과 코드의 분리)
ENV APP_ENV=dev
ENV APP_PORT=80

COPY site/ /usr/share/nginx/html/

# nginx 공식 이미지는 templates 폴더의 ${변수}를 시작할 때 실제 값으로 치환해 준다
COPY conf/default.conf.template /etc/nginx/templates/default.conf.template

EXPOSE 80

# 헬스체크도 환경 변수를 따라간다
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:${APP_PORT}/ || exit 1
