# 1) 어떤 이미지에서 출발할지 - 전 세계가 쓰는 공식 nginx 웹서버 (가벼운 alpine 버전)
FROM nginx:alpine

# 2) 이미지에 이름표 붙이기 - 누가 왜 만든 이미지인지 추적할 수 있게
LABEL org.opencontainers.image.title="my-custom-nginx"
LABEL org.opencontainers.image.description="Codyssey mission1 custom web server"

# 3) 환경 변수 - 설정을 코드에서 분리한다
ENV APP_ENV=dev

# 4) 내가 만든 웹 페이지를 nginx의 기본 페이지 자리에 복사한다 (터미널 cp 와 같은 개념)
COPY site/ /usr/share/nginx/html/

# 5) 이 컨테이너가 사용하는 포트를 문서화 (실제 개방은 docker run -p 가 담당)
EXPOSE 80

# 6) 헬스체크 - 10초마다 "너 정상 응답하니?" 물어본다
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/ || exit 1
