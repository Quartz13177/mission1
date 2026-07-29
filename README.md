# 미션1 — 내 컴퓨터에 개발자용 '작업실' 꾸미기

터미널 · Docker(OrbStack) · Git/GitHub 를 직접 세팅하고,
직접 작성한 Dockerfile 로 웹 서버 컨테이너를 빌드해
**포트 매핑 / 바인드 마운트 / 볼륨 영속성**까지 검증한 기록입니다.
보너스 과제(Docker Compose, 환경 변수, SSH 키)도 모두 수행했습니다.

- **저장소**: https://github.com/Quartz13177/mission1
- **작업일**: 2026-07-29
- **모든 작업은 터미널(CLI)에서 직접 수행**했으며, 명령어와 출력 결과를 함께 기록했습니다.

---

## 1) 프로젝트 개요

| 항목 | 내용 |
|---|---|
| 목표 | "내 컴퓨터에서만 되는" 환경을 벗어나, 누구나 같은 방식으로 실행 가능한 환경 구축 |
| 핵심 도구 | 리눅스 CLI(터미널), Docker(OrbStack), Git / GitHub |
| 결과물 | 공식 nginx 이미지 기반 **커스텀 이미지 `my-custom-nginx:1.0` / `2.0`** + 정적 웹사이트 |
| 검증 항목 | 포트 매핑 2회, 바인드 마운트 변경 전/후, 볼륨 삭제 전/후, 헬스체크, 환경 변수 주입 |

### 왜 OrbStack 인가

서울캠퍼스 환경은 보안 정책상 `sudo` 사용이 제한되어 Docker Desktop 설치·데몬 제어가 어렵습니다.
**OrbStack** 은 관리자 권한 없이 macOS 에서 Docker 엔진을 구동해 주는 앱으로,
앱 실행 후에는 `docker build`, `docker run`, `docker ps` 등 **표준 docker 명령을 그대로** 사용할 수 있습니다.

실제로 `docker info` 출력의 `Context: orbstack` 항목으로 OrbStack 엔진에 연결되어 있음을 확인했습니다.

---

## 2) 실행 환경

| 항목 | 값 | 확인 명령 |
|---|---|---|
| OS | macOS 15.7.4 (빌드 24G517) | `sw_vers` |
| 쉘 / 터미널 | zsh (`/bin/zsh`) / macOS 기본 터미널 | `echo $SHELL` |
| 컨테이너 런타임 | **OrbStack** | `docker context ls`, `docker info` |
| Docker | 28.5.2 (build ecc6942) | `docker --version` |
| Docker Compose | v2.40.3 | `docker info` |
| Git | 2.53.0 | `git --version` |

```text
$ sw_vers && echo $SHELL && git --version && docker --version
ProductName:		macOS
ProductVersion:		15.7.4
BuildVersion:		24G517
/bin/zsh
git version 2.53.0
Docker version 28.5.2, build ecc6942
```

---

## 3) 수행 항목 체크리스트

### 필수
- [x] 터미널 기본 조작 (위치/목록/이동/생성/복사/이름변경/삭제/내용확인/빈 파일)
- [x] 파일 · 디렉토리 권한 변경 실습 (644 / 755 / 000, 변경 전·후 비교)
- [x] Docker 설치 및 점검 (`docker --version`, `docker info`)
- [x] Docker 기본 운영 (`images`, `ps -a`, `logs`, `stats`)
- [x] `hello-world` 실행 성공
- [x] `ubuntu` 컨테이너 내부 진입 및 명령 실행
- [x] 컨테이너 종료/유지 차이 관찰 (`run` vs `exec`)
- [x] Dockerfile 직접 작성 → 커스텀 이미지 빌드 성공
- [x] 포트 매핑 접속 2회 (8080 / 8081, 브라우저 확인)
- [x] 바인드 마운트 반영 확인 (호스트 변경 전/후)
- [x] 볼륨 영속성 검증 (컨테이너 삭제 전/후 + 대조 실험)
- [x] Git 설정 + GitHub / VSCode 연동
- [x] 트러블슈팅 기록 (4건)

### 보너스
- [x] **보너스 1** — Docker Compose 기초 (`docker-compose.yml` 작성, 단일 명령 실행)
- [x] **보너스 2** — Compose 멀티 컨테이너 + 컨테이너 간 네트워크 통신 확인
- [x] **보너스 3** — Compose 운영 명령 (`up` / `ps` / `logs` / `down`)
- [x] **보너스 4** — 환경 변수 주입으로 서버 포트 변경
- [x] **보너스 5** — GitHub SSH 키 설정 및 SSH 방식 push

---

## 4) 검증 방법 — 어떤 명령으로 무엇을 확인했는가

| # | 검증 항목 | 사용한 명령 | 확인 포인트 |
|---|---|---|---|
| 1 | 터미널 기본 조작 | `pwd` `ls -la` `cd` `mkdir` `touch` `cat` `cp` `mv` `rm` | 각 명령 후 `ls -la` 로 상태 변화 확인 |
| 2 | 권한 | `ls -l` → `chmod 755/644/000` → `ls -l` | 실행 권한 유무로 스크립트 실행 성공/실패가 바뀜 |
| 3 | Docker 점검 | `docker --version`, `docker info` | `Server:` 출력 = 데몬 정상, `Context: orbstack` 확인 |
| 4 | 기본 운영 | `docker run hello-world`, `images`, `ps -a`, `logs`, `stats --no-stream` | 이미지/컨테이너 목록, 로그, 자원 사용량 |
| 5 | 종료/유지 차이 | `docker run -it` vs `docker exec -it` + `docker ps` | `exit` 후 Exited / Up 여부 비교 |
| 6 | 커스텀 이미지 | `docker build -t my-custom-nginx:1.0 .` | 빌드 성공, `docker images` 등록 확인 |
| 7 | 포트 매핑 | `-p 8080:80` / `-p 8081:80` + `curl` + 브라우저 | 같은 이미지로 두 포트 동시 응답 |
| 8 | 헬스체크 | `docker ps` | STATUS 에 `(healthy)` 표시 |
| 9 | 바인드 마운트 | `-v "$(pwd)/site":/usr/share/nginx/html:ro` + `curl` 전/후 | 재빌드 없이 v1 → v2 반영 |
| 10 | 볼륨 영속성 | `docker volume create` → 쓰기 → `docker rm -f` → 새 컨테이너에서 `cat` | 컨테이너 삭제 후에도 데이터 유지 |
| 11 | Git / GitHub | `git config --list`, `git log --oneline`, VSCode Publish | 사용자 정보 설정, 원격 push 성공 |
| 12 | Compose (보너스) | `docker compose up -d` / `ps` / `logs` / `down` | 컨테이너 2개 동시 기동, 서비스 이름 통신 |
| 13 | 서비스 디스커버리 (보너스) | `docker compose exec checker ping -c 2 web` | 이름 `web` → IP 자동 변환 확인 |
| 14 | 환경 변수 (보너스) | `-e APP_PORT=9090` + `docker exec ... grep listen` | 같은 이미지에서 내부 포트가 80 → 9090 으로 변경됨 |
| 15 | SSH 인증 (보너스) | `ssh -T git@github.com`, `git push` | 토큰 없이 인증 및 push 성공 |

---

## 5) 터미널 조작 로그

### 5-1. 위치 확인 · 목록 · 이동 · 생성

```text
$ pwd
/Users/save50843720

$ ls
Desktop		Downloads	Movies		OrbStack	Public
Documents	Library		Music		Pictures

$ mkdir -p ~/codyssey/mission1 && cd ~/codyssey/mission1 && pwd
/Users/save50843720/codyssey/mission1
```

### 5-2. 파일 생성 · 내용 확인

```text
$ mkdir -p practice/docs practice/backup
$ touch practice/docs/empty.txt
$ echo "first line" > practice/docs/memo.txt
$ echo "second line" >> practice/docs/memo.txt
$ cat practice/docs/memo.txt
first line
second line

$ ls -la practice/docs
total 8
drwxr-xr-x  4 save50843720  save50843720  128 Jul 29 19:34 .
drwxr-xr-x  4 save50843720  save50843720  128 Jul 29 19:33 ..
-rw-r--r--  1 save50843720  save50843720    0 Jul 29 19:34 empty.txt
-rw-r--r--  1 save50843720  save50843720   23 Jul 29 19:35 memo.txt
```

- `empty.txt` 0바이트 / `memo.txt` 23바이트 → `>` (덮어쓰기)와 `>>` (이어쓰기)의 차이 확인

### 5-3. 복사 · 이동/이름변경 · 삭제

```text
$ cp practice/docs/memo.txt practice/backup/memo_copy.txt
$ ls -la practice/backup
-rw-r--r--  1 save50843720  save50843720   23 Jul 29 19:40 memo_copy.txt

$ mv practice/backup/memo_copy.txt practice/backup/memo_backup.txt   # 이름 변경
$ mv practice/docs/empty.txt practice/backup/                        # 폴더 이동
$ ls -la practice/backup
-rw-r--r--  1 save50843720  save50843720    0 Jul 29 19:34 empty.txt
-rw-r--r--  1 save50843720  save50843720   23 Jul 29 19:40 memo_backup.txt

$ rm practice/backup/empty.txt
$ ls -la practice/backup
-rw-r--r--  1 save50843720  save50843720   23 Jul 29 19:40 memo_backup.txt
```

**관찰**: `cp` 로 만든 사본은 수정 시각이 새로 찍히고(19:40), `mv` 로 옮긴 파일은 원래 시각(19:34)이 유지됨.
→ `cp` 는 새 파일을 만들고, `mv` 는 같은 파일의 위치·이름만 바꾼다는 것이 시각으로 증명됨.

---

## 6) 권한 실습 (변경 전 / 후)

### 6-1. 파일 (`hello.sh`)

```text
$ echo 'echo "script executed"' > practice/hello.sh
$ ls -l practice/hello.sh
-rw-r--r--  1 save50843720  save50843720  23 Jul 29 19:46 practice/hello.sh

$ ./practice/hello.sh
zsh: permission denied: ./practice/hello.sh

$ chmod 755 practice/hello.sh
$ ls -l practice/hello.sh
-rwxr-xr-x  1 save50843720  save50843720  23 Jul 29 19:46 practice/hello.sh

$ ./practice/hello.sh
script executed
```

| | 권한 표기 | 숫자 | 실행 결과 |
|---|---|---|---|
| 변경 전 | `-rw-r--r--` | 644 | `permission denied` ❌ |
| 변경 후 | `-rwxr-xr-x` | 755 | `script executed` ✅ |

### 6-2. 디렉토리 (`practice/docs`)

```text
$ ls -ld practice/docs
drwxr-xr-x  3 save50843720  save50843720  96 Jul 29 19:42 practice/docs

$ chmod 000 practice/docs
$ ls -ld practice/docs
d---------  3 save50843720  save50843720  96 Jul 29 19:42 practice/docs

$ ls practice/docs
ls: practice/docs: Permission denied

$ chmod 755 practice/docs
$ ls practice/docs
memo.txt
```

**결론**: 디렉토리의 `x` 는 "실행"이 아니라 **"그 폴더 안으로 진입할 권한"** 이다.
`x` 가 없으면 진입 자체가 불가능하므로 목록 조회(`ls`)까지 막힌다.

---

## 7) Docker 설치 점검 및 기본 운영 로그

### 7-1. 데몬 동작 확인

```text
$ docker info | head -20
Client:
 Version:    28.5.2
 Context:    orbstack
 Plugins:
  compose: Docker Compose (Docker Inc.)
    Version:  v2.40.3

Server:
 Containers: 0
 Images: 0
 Server Version: 28.5.2
 Storage Driver: overlay2
```

- `Server:` 항목 출력 = **데몬 정상 동작**
- `Context: orbstack` = **OrbStack 엔진 사용 중** (sudo 없이 컨테이너 실행 가능한 근거)

### 7-2. hello-world 실행

```text
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
```

- 로컬에 이미지가 없으면 **자동으로 Docker Hub 에서 내려받은 뒤 실행**됨을 확인.

### 7-3. 이미지 / 컨테이너 목록

```text
$ docker images
REPOSITORY    TAG       IMAGE ID       CREATED        SIZE
hello-world   latest    e2ac70e7319a   4 months ago   10.1kB

$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED         STATUS                     NAMES
77313c6453f2   hello-world   "/hello"   2 minutes ago   Exited (0) 2 minutes ago   silly_bose
```

- 이미지 생성일(4 months ago)과 컨테이너 생성일(2 minutes ago)이 다르다
  → **이미지(설계도)와 컨테이너(실행체)는 별개**임을 확인.
- `Exited (0)` = 임무(`/hello`) 완료 후 정상 종료. **컨테이너는 메인 프로세스 수명과 함께 끝난다.**

### 7-4. ubuntu 컨테이너 내부 진입

```text
$ docker run -it --name m1-ubuntu ubuntu bash
root@f468f631be48:/# ls
bin   dev  home  lib64  mnt  proc  run   srv  tmp  var
boot  etc  lib   media  opt  root  sbin  sys  usr

root@f468f631be48:/# echo "hello from container"
hello from container

root@f468f631be48:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"

root@f468f631be48:/# exit
exit
```

**호스트는 macOS 15.7.4 인데 컨테이너 안은 Ubuntu 26.04 LTS** → 격리된 실행 환경임을 확인.

### 7-5. 종료 / 유지의 차이 (`run` vs `exec`)

```text
# run 으로 진입 후 exit → 컨테이너 종료
$ docker ps -a
f468f631be48   ubuntu   "bash"   Exited (0) About a minute ago   m1-ubuntu

$ docker start m1-ubuntu && docker ps
m1-ubuntu
f468f631be48   ubuntu   "bash"   Up Less than a second   m1-ubuntu

# exec 으로 진입 후 exit → 컨테이너 유지
$ docker exec -it m1-ubuntu bash
root@f468f631be48:/# echo "exec test"
exec test
root@f468f631be48:/# exit

$ docker ps
f468f631be48   ubuntu   "bash"   Up 2 minutes   m1-ubuntu
```

| 구분 | `docker run -it ... bash` | `docker exec -it ... bash` |
|---|---|---|
| 동작 | 새 컨테이너 생성 후 bash 실행 | 실행 중인 컨테이너에 bash 추가 실행 |
| bash 의 신분 | 메인 프로세스(주인) | 추가 프로세스(손님) |
| `exit` 시 | **컨테이너 종료** | **컨테이너 유지** |

→ 운영 중인 서비스 내부를 점검할 때는 반드시 `exec` 을 사용해야 한다.

### 7-6. 로그 · 자원 사용량

```text
$ docker logs silly_bose | head -6
Hello from Docker!
This message shows that your installation appears to be working correctly.

$ docker stats --no-stream
CONTAINER ID   NAME        CPU %   MEM USAGE / LIMIT     MEM %   PIDS
f468f631be48   m1-ubuntu   0.00%   1.168MiB / 15.67GiB   0.01%   1
```

- **종료된 컨테이너의 로그도 보존**된다 → 장애 원인 사후 분석에 활용.
- 우분투 컨테이너의 메모리 사용량이 **1.168MiB**, 기동 시간 1초 미만.
  가상머신(보통 1~4GB, 수십 초)과 비교하면 컨테이너가 가벼운 이유가 수치로 확인된다.

---

## 8) 커스텀 이미지 (Dockerfile)

### 8-1. 선택한 기존 베이스

`nginx:alpine` — 공식 웹 서버 이미지.
과제 제시 방식 중 **(A) 웹 서버 베이스 이미지 활용 + 정적 콘텐츠/설정 교체** 를 선택.

### 8-2. 작성한 Dockerfile (최종 v2.0)

```dockerfile
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
```

`conf/default.conf.template`

```nginx
server {
    listen       ${APP_PORT};
    server_name  localhost;

    root  /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

> 최초 버전(`1.0`)은 포트가 80 으로 고정된 형태였고,
> 보너스 4를 수행하면서 환경 변수로 포트를 바꿀 수 있는 `2.0` 으로 개선했습니다.

### 8-3. 커스텀 포인트와 목적

| 지시어 | 커스텀 내용 | 목적 |
|---|---|---|
| `FROM nginx:alpine` | 공식 이미지를 출발점으로 지정 | 검증된 웹 서버 위에 내 것만 얹는다 |
| `LABEL` | 제목·설명 메타데이터 | `docker inspect` 로 출처 추적 |
| `ENV APP_ENV=dev` | 실행 모드를 환경 변수로 분리 | 설정과 코드의 분리 |
| `ENV APP_PORT=80` | 내부 포트를 환경 변수로 분리 | 재빌드 없이 실행 시 포트 변경 가능 |
| `COPY site/ ...` | 기본 페이지를 내 페이지로 교체 | "공식 이미지 + 내 콘텐츠" = 나만의 이미지 |
| `COPY conf/*.template` | nginx 설정을 템플릿으로 주입 | `${APP_PORT}` 치환으로 포트 가변화 |
| `EXPOSE 80` | 사용 포트 문서화 | 협업자가 열어야 할 포트 파악 |
| `HEALTHCHECK` | 자체 응답 확인 | "실행 중"이 아닌 **"정상 응답 중"** 확인 |

### 8-4. 빌드 로그

```text
$ docker build -t my-custom-nginx:1.0 .
[+] Building 6.5s (7/7) FINISHED                                docker:orbstack
 => [internal] load build definition from Dockerfile                       0.2s
 => [internal] load metadata for docker.io/library/nginx:alpine            2.4s
 => [internal] load build context                                          0.2s
 => => transferring context: 1.15kB                                        0.0s
 => [1/2] FROM docker.io/library/nginx:alpine@sha256:4a73073bd557c65b7595  3.0s
 => [2/2] COPY site/ /usr/share/nginx/html/                                0.2s
 => exporting to image                                                     0.2s
 => => naming to docker.io/library/my-custom-nginx:1.0                     0.0s

$ docker images
REPOSITORY        TAG       IMAGE ID       CREATED         SIZE
my-custom-nginx   1.0       193a86e6ba02   7 seconds ago   62.4MB
ubuntu            latest    de7345b16e94   2 weeks ago     100MB
hello-world       latest    e2ac70e7319a   4 months ago    10.1kB
```

- 내가 추가한 파일은 1KB 남짓인데 이미지는 62.4MB
  → 대부분이 **베이스 이미지(nginx + alpine 리눅스)** 의 용량.
  "밑바닥부터 만들지 않고 공식 이미지 위에 얹는다"는 방식의 실체.

2.0 재빌드 시에는 변경되지 않은 레이어가 캐시로 재사용되어 빌드 시간이 6.5s → 2.7s 로 단축되었다.

```text
$ docker build -t my-custom-nginx:2.0 .
[+] Building 2.7s (8/8) FINISHED                                docker:orbstack
 => CACHED [1/3] FROM docker.io/library/nginx:alpine@sha256:4a73073bd557c  0.0s
 => [2/3] COPY site/ /usr/share/nginx/html/                                0.1s
 => [3/3] COPY conf/default.conf.template /etc/nginx/templates/default.co  0.2s
 => => naming to docker.io/library/my-custom-nginx:2.0                     0.0s
```

---

## 9) 포트 매핑 접속 증거

```text
$ docker run -d -p 8080:80 --name m1-web-8080 my-custom-nginx:1.0
1f1facb9ef3c4012fa93fd407539e9cb10c5534fbfbfb64f2cdfa8707d2fc35c

$ docker run -d -p 8081:80 --name m1-web-8081 my-custom-nginx:1.0
b2229150f3aba40e76cf48340c760592bb0b205319b3619516b81f569a6ce99b

$ docker ps
CONTAINER ID   IMAGE                 STATUS                            PORTS                     NAMES
b2229150f3ab   my-custom-nginx:1.0   Up 3 seconds (health: starting)   0.0.0.0:8081->80/tcp      m1-web-8081
1f1facb9ef3c   my-custom-nginx:1.0   Up 8 minutes (healthy)            0.0.0.0:8080->80/tcp      m1-web-8080

$ curl -s http://localhost:8081 | head -5
<!doctype html>
<html lang="ko">
<head>
<meta charset="utf-8">
<title>미션1 - 나의 개발 워크스테이션</title>
```

**브라우저 접속 확인**: `http://localhost:8080/`, `http://localhost:8081/` 모두 정상 표시
(증빙: `docs/screenshots/port_8080.png`, `port_8081.png` — 주소창 포함)

### 포트 매핑이 필요한 이유

```
-p 8080:80   →  m1-web-8080
-p 8081:80   →  m1-web-8081
      ↑   ↑
 호스트 포트만 다름 / 컨테이너 내부 포트는 둘 다 80
```

- 컨테이너는 **격리된 공간**이라 내부 포트가 겹쳐도 충돌하지 않는다.
- 반면 호스트 포트는 한 번에 하나의 프로그램만 사용할 수 있으므로 8080 / 8081 로 분리했다.
- 즉 `-p` 는 **"호스트의 문 → 컨테이너의 문"** 을 연결하는 선언이며,
  이 연결이 없으면 브라우저에서 컨테이너에 접근할 수 없다.

### 헬스체크 동작 확인

`STATUS` 열에 `(health: starting)` → `(healthy)` 로 변화.
Dockerfile 에 작성한 `HEALTHCHECK` 가 실제로 응답을 확인하고 정상 판정했음을 의미한다.

---

## 10) 바인드 마운트 반영 (변경 전 / 후)

```text
$ echo "v1 : 원본 파일입니다" > site/message.txt

# 이미지에 내장된 컨테이너(8080)에는 이 파일이 없다
$ curl -i http://localhost:8080/message.txt | head -1
HTTP/1.1 404 Not Found

# 호스트 폴더를 연결한 컨테이너(8082)
$ docker run -d -p 8082:80 -v "$(pwd)/site":/usr/share/nginx/html:ro --name m1-web-mount my-custom-nginx:1.0
b3a2a06829f49dee16f533a21d9cea83c3764852da31cae5cccd925ea1b07a6e

$ curl http://localhost:8082/message.txt
v1 : 원본 파일입니다

# 호스트에서 파일만 수정 (재빌드/재시작 없음)
$ echo "v2 : 호스트에서 수정했습니다" > site/message.txt

$ curl http://localhost:8082/message.txt
v2 : 호스트에서 수정했습니다
```

| 접속 대상 | 마운트 | 결과 |
|---|---|---|
| `localhost:8080` | 없음 | **404 Not Found** |
| `localhost:8082` | 있음 | `v1 : 원본 파일입니다` |
| `localhost:8082` (파일 수정 후) | 있음 | **`v2 : 호스트에서 수정했습니다`** |

- **이미지는 빌드 시점의 스냅샷**이라 이후에 만든 파일이 들어있지 않다(8080 → 404).
- **바인드 마운트는 호스트 폴더를 실시간으로 비추는 창**이라 재빌드 없이 즉시 반영된다.
- `ro`(read only) 를 지정해 컨테이너가 호스트 파일을 수정하지 못하도록 제한했다.
- `$(pwd)` 를 사용한 이유: Docker 는 상대 경로를 받지 않고 **절대 경로만** 허용한다.

---

## 11) 볼륨 영속성 (컨테이너 삭제 전 / 후)

```text
$ docker volume create m1-data
m1-data

$ docker run -d --name vol-test -v m1-data:/data alpine sleep infinity
$ docker exec vol-test sh -c 'echo "important data" > /data/hello.txt'
$ docker exec vol-test cat /data/hello.txt
important data

# 컨테이너 완전 삭제
$ docker rm -f vol-test
vol-test

# 완전히 새로운 컨테이너에 같은 볼륨 연결
$ docker run -d --name vol-test2 -v m1-data:/data alpine sleep infinity
212904fed90c51b34a8221228fc4c2e3fbfbbb44c7709f3252451e294a1d78eb

$ docker exec vol-test2 cat /data/hello.txt
important data
```

### 대조 실험 — 볼륨에 저장 vs 컨테이너 내부에 저장

```text
$ docker exec vol-test2 sh -c 'echo "saved inside container" > /tmp/only.txt'
$ docker exec vol-test2 cat /tmp/only.txt
saved inside container

$ docker rm -f vol-test2
$ docker run -d --name vol-test3 -v m1-data:/data alpine sleep infinity

$ docker exec vol-test3 cat /data/hello.txt
important data                                        ← 볼륨: 유지됨 ✅

$ docker exec vol-test3 cat /tmp/only.txt
cat: can't open '/tmp/only.txt': No such file or directory   ← 컨테이너 내부: 소실 ❌
```

| 저장 경로 | 성격 | 컨테이너 삭제 후 |
|---|---|---|
| `/data/hello.txt` | 볼륨 `m1-data` 연결 | **유지됨** |
| `/tmp/only.txt` | 컨테이너 자체 저장 계층 | **소실됨** |

**결론**: 컨테이너의 저장 계층은 컨테이너 수명과 함께 사라진다.
따라서 유지해야 할 데이터는 반드시 볼륨에 저장해야 하며,
그래야 "컨테이너는 언제든 버리고 다시 만들 수 있다"는 원칙이 성립한다.

### 바인드 마운트 vs 볼륨

| | 바인드 마운트 | 볼륨 |
|---|---|---|
| 표기 | `-v "$(pwd)/site":/...` (경로) | `-v m1-data:/data` (이름) |
| 저장 위치 | 호스트의 지정한 폴더 | Docker 가 관리하는 영역 |
| 주 용도 | 개발 중 수정 즉시 반영 | 데이터 영구 보관 |

---

## 12) Git 설정 및 GitHub / VSCode 연동

```text
$ git config --list --global
user.name=박한솔
user.email=****@****.com          (공개 저장소 게시를 고려해 마스킹)
init.defaultbranch=main

$ git init
Initialized empty Git repository in /Users/save50843720/codyssey/mission1/.git/

$ git status
On branch main
No commits yet
Untracked files:
	.gitignore
	Dockerfile
	site/

$ git add .
$ git commit -m "Feat: 미션1 개발 워크스테이션 구성(커스텀 Dockerfile + 정적 사이트)"
[main (root-commit) 53ec14e] ...
 4 files changed, 53 insertions(+)

$ git log --oneline
5bc2c6b (HEAD -> main, origin/main) 보너스과제 - docker Compose 구성 및 환경변수 기반 포트 설정
53ec14e Feat: 미션1 개발 워크스테이션 구성(커스텀 Dockerfile + 정적 사이트)
```

- `.gitignore` 에 `practice/` 를 등록해 실습용 임시 파일을 저장소에서 제외했다.
  실제로 `git status` 의 목록에 `practice/` 가 나타나지 않는 것으로 동작을 확인했다.
- `origin/main` 표시는 로컬 커밋이 GitHub 에 정상 반영되었음을 의미한다.
- GitHub 최초 업로드는 **VSCode 의 Source Control → Publish Branch** 기능으로 수행했다.
  GitHub 는 비밀번호 방식 push 를 지원하지 않으므로 토큰 발급이 필요한데,
  VSCode 의 GitHub 통합이 브라우저 OAuth 인증으로 이를 대신 처리한다.
  (증빙: `docs/screenshots/vscode_github.png`)
- 이후 보너스 5를 수행하며 원격 주소를 **SSH 방식으로 전환**했다. (아래 13-3 참고)

---

## 13) 보너스 과제 수행 결과

### 13-1. 보너스 1·2·3 — Docker Compose

`docker-compose.yml`

```yaml
services:
  # 1) 내가 만든 커스텀 이미지로 웹 서버를 띄운다
  web:
    build: .
    image: my-custom-nginx:1.0
    container_name: m1-web-compose
    environment:
      APP_ENV: compose
    ports:
      - "8090:80"
    volumes:
      - ./site:/usr/share/nginx/html:ro
    restart: unless-stopped

  # 2) 보조 서비스 : 5초마다 web 에 접속해 보는 감시용 컨테이너
  checker:
    image: alpine
    container_name: m1-checker
    depends_on:
      - web
    command: sh -c "while true; do wget -q -O /dev/null http://web:80/ && echo '[checker] web is UP' || echo '[checker] web is DOWN'; sleep 5; done"
    restart: unless-stopped
```

실행 · 상태 · 로그 · 종료:

```text
$ docker compose up -d
[+] Running 3/3
 ✔ Network mission1_default  Created                                       0.1s
 ✔ Container m1-web-compose  Started                                       0.4s
 ✔ Container m1-checker      Started                                       0.6s

$ docker compose ps
NAME             IMAGE                 SERVICE   STATUS                   PORTS
m1-checker       alpine                checker   Up 8 seconds
m1-web-compose   my-custom-nginx:1.0   web       Up 9 seconds (healthy)   0.0.0.0:8090->80/tcp

$ docker compose logs checker
m1-checker  | [checker] web is UP
m1-checker  | [checker] web is UP
   ... (5초 간격 반복) ...

$ docker compose exec checker ping -c 2 web
PING web (192.168.97.2): 56 data bytes
64 bytes from 192.168.97.2: seq=0 ttl=64 time=0.035 ms
64 bytes from 192.168.97.2: seq=1 ttl=64 time=0.066 ms
--- web ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss

$ docker network ls
NETWORK ID     NAME               DRIVER    SCOPE
79940012c1b7   mission1_default   bridge    local

$ docker compose down
[+] Running 3/3
 ✔ Container m1-checker      Removed                                      10.2s
 ✔ Container m1-web-compose  Removed                                       0.3s
 ✔ Network mission1_default  Removed                                       0.1s
```

**배움 포인트 1 — 실행 명령이 문서화된 실행 설정으로 바뀐다**

| `docker run` 옵션 | Compose 표기 |
|---|---|
| `-p 8090:80` | `ports:` |
| `-v ./site:...:ro` | `volumes:` |
| `--name m1-web-compose` | `container_name:` |
| `-e APP_ENV=compose` | `environment:` |

긴 옵션을 외울 필요 없이 `docker compose up -d` 한 줄로 동일 환경을 재현할 수 있다.

**배움 포인트 2 — 서비스 디스커버리**

`checker` 컨테이너는 IP 가 아니라 **서비스 이름 `web`** 으로 접속했고,
`ping web` 결과 이름이 실제 IP(`192.168.97.2`)로 변환되는 것을 확인했다.
컨테이너 IP 는 재생성마다 바뀌므로, 이름으로 부르는 방식이 필요하다.
Compose 가 프로젝트 전용 네트워크(`mission1_default`)와 내부 DNS 를 자동 구성해 준다.

**배움 포인트 3 — 운영 상태 확인 루틴**

| 명령 | 용도 |
|---|---|
| `up -d` | 서비스 시작 |
| `ps` | 상태 확인 |
| `logs` | 문제 진단 |
| `down` | 컨테이너 + 네트워크 정리 |

### 13-2. 보너스 4 — 환경 변수로 포트 변경

```text
$ docker run -d -p 8092:80 --name m1-web-default my-custom-nginx:2.0
$ docker run -d -e APP_PORT=9090 -p 8093:9090 --name m1-web-envport my-custom-nginx:2.0

$ curl -s http://localhost:8092 | head -1
<!doctype html>
$ curl -s http://localhost:8093 | head -1
<!doctype html>

$ docker exec m1-web-default grep listen /etc/nginx/conf.d/default.conf
    listen       80;
$ docker exec m1-web-envport grep listen /etc/nginx/conf.d/default.conf
    listen       9090;
```

| 컨테이너 | 실행 옵션 | 컨테이너 내부 설정 | 접속 |
|---|---|---|---|
| `m1-web-default` | (환경 변수 미지정) | `listen 80;` | `localhost:8092` 정상 |
| `m1-web-envport` | `-e APP_PORT=9090` | **`listen 9090;`** | `localhost:8093` 정상 |

**동일한 이미지 `my-custom-nginx:2.0`** 에서 만든 두 컨테이너의 내부 설정이 서로 다르다.
이미지를 다시 빌드하지 않고 **실행 시점의 환경 변수만으로** 동작을 바꾼 것이다.

원리: nginx 공식 이미지는 시작 시 `/etc/nginx/templates/*.template` 의 `${변수}` 를
환경 변수 값으로 치환해 설정으로 배치한다.

**배움 포인트 — 설정과 코드의 분리**

| 방식 | 포트를 바꾸려면 |
|---|---|
| 설정 파일에 값을 직접 기입 | 파일 수정 → 재빌드 → 재배포 |
| 환경 변수로 분리 | 실행 시 `-e APP_PORT=9090` 추가만 |

실무에서는 같은 이미지를 개발·스테이징·운영에 그대로 쓰고 환경 변수만 다르게 준다.
그래야 "테스트한 그 이미지"를 그대로 운영에 올릴 수 있다.

### 13-3. 보너스 5 — GitHub SSH 키 설정

```text
$ ssh-keygen -t ed25519 -C "****@****.com"
Your identification has been saved in /Users/save50843720/.ssh/id_ed25519
Your public key has been saved in /Users/save50843720/.ssh/id_ed25519.pub

$ cat ~/.ssh/id_ed25519.pub | pbcopy        # 공개 키만 복사해 GitHub 에 등록

$ ssh -T git@github.com
The authenticity of host 'github.com (20.200.245.247)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Hi Quartz13177! You've successfully authenticated, but GitHub does not provide shell access.

$ git remote set-url origin git@github.com:Quartz13177/mission1.git
$ git remote -v
origin	git@github.com:Quartz13177/mission1.git (fetch)
origin	git@github.com:Quartz13177/mission1.git (push)

$ git push
Enumerating objects: 8, done.
Writing objects: 100% (6/6), 1.59 KiB | 1.59 MiB/s, done.
To github.com:Quartz13177/mission1.git
   53ec14e..5bc2c6b  main -> main
```

**배움 포인트 — 인증 방식의 차이와 보안 습관**

| | HTTPS | SSH |
|---|---|---|
| 주소 형식 | `https://github.com/사용자/저장소.git` | `git@github.com:사용자/저장소.git` |
| 인증 수단 | Personal Access Token / 브라우저 OAuth | **키 파일** |
| 매 요청 인증 | 필요 (자격 증명 저장으로 완화) | 불필요 |

- SSH 키는 **개인 키(`id_ed25519`)** 와 **공개 키(`id_ed25519.pub`)** 한 쌍으로 동작한다.
  GitHub 에는 **공개 키만** 등록하며, 개인 키는 어떤 경우에도 외부에 노출하지 않는다.
- 최초 접속 시 표시되는 호스트 지문(fingerprint) 확인은
  "접속 대상이 진짜 GitHub 인지" 검증하는 절차로, 중간자 공격을 방지한다.
- `Hi <계정명>! You've successfully authenticated` 가 인증 성공 메시지이며,
  뒤에 붙는 `but GitHub does not provide shell access` 는 오류가 아니다.
- 실습 편의를 위해 passphrase 를 비웠으나,
  실무에서는 passphrase 를 설정하고 macOS 키체인에 등록하는 방식이 권장된다.

---

## 14) 핵심 개념 정리

### 절대 경로 vs 상대 경로
- **절대 경로**: 최상위 `/` 부터 전부 적은 주소. 예) `/Users/save50843720/codyssey/mission1`
  → 어디서 실행해도 같은 곳을 가리킨다.
- **상대 경로**: **지금 내 위치**를 기준으로 한 주소. 예) `site`, `../..`
  → 현재 위치가 바뀌면 가리키는 대상도 바뀐다.
- 실제로 바인드 마운트에서 `-v "$(pwd)/site":...` 처럼 `$(pwd)` 를 붙인 이유가 이것이다.
  Docker 는 절대 경로만 받으므로 상대 경로를 절대 경로로 변환해 전달해야 한다.

### 파일 권한 (r/w/x, 644 / 755)
- `r`(read, 4) · `w`(write, 2) · `x`(execute, 1) 를 더해서 표기한다.
- 세 자리는 순서대로 **소유자 / 그룹 / 그 외 사용자**.
  - `644` = `rw- r-- r--` → 문서·설정 파일의 표준
  - `755` = `rwx r-x r-x` → 실행 파일·디렉토리의 표준
- **디렉토리의 `x` 는 "진입 권한"** 이다. 없으면 `ls` 조회조차 불가능하다(실습에서 확인).

### 이미지 vs 컨테이너
- **이미지** = 붕어빵 틀(설계도). 읽기 전용이며 빌드 시점에 고정된다.
- **컨테이너** = 그 틀로 찍어낸 붕어빵(실행체). 언제든 지우고 다시 만들 수 있다.
- 이미지 하나로 컨테이너 여러 개를 만들 수 있다(8080 / 8081 실습이 그 증거).

### 포트 매핑이 필요한 이유
컨테이너는 격리된 공간이므로, 내부에서 서비스 중이어도 외부에서는 접근 경로가 없다.
`-p 8080:80` 은 **"호스트 8080 → 컨테이너 80"** 통로를 여는 선언이며,
호스트 포트만 바꾸면 같은 이미지를 여러 포트에서 동시에 서비스할 수 있다.

### Docker 볼륨(영속 데이터)
컨테이너의 저장 계층은 컨테이너와 함께 사라진다.
볼륨은 Docker 가 관리하는 독립 저장 공간이라 컨테이너를 삭제해도 데이터가 유지된다.
대조 실험(`/data` vs `/tmp`)으로 이 차이를 직접 확인했다.

### Git 과 GitHub 의 역할 차이
- **Git**: 내 컴퓨터에서 동작하는 **버전 관리 프로그램**. 인터넷 없이도 커밋·되돌리기가 가능하다.
- **GitHub**: Git 기록을 올려 두는 **원격 협업 플랫폼**. 백업·공유·코드 리뷰의 장소.
- 비유하면 Git 은 내 작업 일지, GitHub 는 그 일지를 올려두는 공용 서류함이다.

---

## 15) 트러블슈팅

### ① 컨테이너 안에서 한글 입력 시 화면이 깨짐

- **문제**: `docker run -it ubuntu bash` 로 진입 후 `echo "컨테이너 안에서..."` 입력 중 화면이 사라짐.
- **원인 가설**: 기본 `ubuntu` 이미지는 용량 최소화를 위해 한글 언어 설정(locale)과 폰트를 포함하지 않는다.
  다중 바이트 문자를 처리하지 못해 일부 바이트가 제어 문자로 해석된 것으로 보인다.
- **확인**: 호스트(맥) 터미널에서는 한글이 정상 출력됨 → 컨테이너 내부 환경 문제로 범위를 좁힘.
- **해결**: `Enter` → `Control + C` → `reset` 순으로 화면 복구.
  이후 컨테이너 내부에서는 영어만 입력하도록 실습 방식을 변경했다.
  한글이 필요하다면 이미지에 언어 패키지를 추가하고 `ENV LANG=C.UTF-8` 을 설정해야 한다.
- **배운 점**: 컨테이너는 "필요한 것만 담은 최소 환경"이다.
  호스트에 있는 폰트·언어 설정이 컨테이너 안에는 없으며, 필요하면 Dockerfile 에 직접 넣어야 한다.

### ② 명령어 띄어쓰기로 엉뚱한 폴더가 생성됨

- **문제**: `practice/backup` 을 만들려 했으나 `practice/back` 과 `up` 폴더가 생성됨.
- **원인**: 입력한 명령이 `mkdir -p practice/docs practice/back up` 이었다.
  터미널은 **공백을 인자 구분자로 해석**하므로 `practice/back` 과 `up` 이 별개 인자로 전달되었다.
- **확인**: `ls practice` 에 `backup` 이 없고 `back` 이 존재, `ls` 에 `up` 이 존재함을 확인.
- **해결**: `rmdir practice/back`, `rmdir up` 으로 정리 후 `mkdir practice/backup` 으로 재생성.
- **배운 점**: 파일·폴더 이름에 공백을 쓰지 않는 개발 관습의 이유를 체감했다.
  공백이 필요하면 따옴표로 묶어야 한다(`mkdir "my folder"`).
  삭제 시에는 빈 폴더만 지우는 `rmdir` 을 먼저 고려해 `rm -rf` 사고를 예방한다.

### ③ 컨테이너 이름 중복 (Conflict)

- **문제**: `docker run --name vol-test ...` 실행 시
  `Conflict. The container name "/vol-test" is already in use` 오류 발생.
- **원인**: 컨테이너 이름은 한 호스트에서 중복될 수 없는데, 같은 명령을 두 번 실행했다.
- **확인**: `docker ps -a` 로 동일 이름 컨테이너가 이미 존재함을 확인.
- **해결**: `docker rm -f vol-test` 로 기존 컨테이너를 제거한 뒤 재실행.
  (또는 다른 이름 사용, 또는 `docker start` 로 기존 컨테이너 재사용)
- **배운 점**: 실습 스크립트에서 `docker rm -f <이름> 2> /dev/null` 을 먼저 실행하는 관례가
  "항상 같은 상태에서 시작하기 위한" 것임을 이해했다.
  참고로 `docker volume create` 는 이미 존재해도 오류가 나지 않아 재실행에 안전하다.

### ④ 오타로 인한 명령 실패 — 오류 메시지 읽는 법

실습 중 발생한 입력 오류와, 각 오류 메시지가 알려 준 단서를 정리한다.

| 입력 | 오류 메시지 | 단서 | 해결 |
|---|---|---|---|
| `docker bulid -t ...` | `unknown shorthand flag: 't' in -t` | 옵션이 아니라 **하위 명령 자체**가 잘못됨 | `docker build` |
| `curl -s http://localhost8081` | (출력 없음) | `-s` 가 오류까지 숨김 → 호스트/포트 사이 **콜론 누락** | `http://localhost:8081` |
| `wget -q -0 - http://web:80/` | `wget: unrecognized option: 0` | `-O`(대문자 O) 대신 **숫자 0** 입력 | `-O` |

- **배운 점**: 오류 메시지는 원인을 좁히는 가장 빠른 단서다.
  `unrecognized option` 은 옵션 문자를, `unknown shorthand flag` 는 명령 자체를 먼저 의심한다.
- 특히 `-s`(silent) 처럼 출력을 줄이는 옵션은 **오류 메시지까지 숨기므로**,
  문제를 진단할 때는 해당 옵션을 빼고 실행해야 한다.

---

## 16) 보안 및 개인정보 처리

- `git config --list` 출력의 이메일은 공개 저장소 게시를 고려해 마스킹했다.
- 저장소에 토큰·비밀번호·개인키를 커밋하지 않도록 **첫 커밋 전에 `.gitignore` 를 먼저 작성**했다.
- GitHub 최초 인증은 VSCode 의 브라우저 OAuth 방식을 사용해
  **토큰 문자열이 터미널이나 화면에 노출되지 않도록** 했다.
- SSH 키는 **공개 키(`.pub`)만** GitHub 에 등록했고, **개인 키는 어디에도 노출하지 않았다.**
- 스크린샷 첨부 시 토큰·비밀번호·인증 코드가 포함되지 않았는지 확인했다.

---

## 17) 재현 방법

```bash
# 0. OrbStack 앱을 먼저 실행 (Docker 엔진 기동)
git clone https://github.com/Quartz13177/mission1.git
cd mission1

# 1. 커스텀 이미지 빌드
docker build -t my-custom-nginx:2.0 .

# 2. 포트 매핑 실행 (두 포트)
docker run -d -p 8080:80 --name m1-web-8080 my-custom-nginx:2.0
docker run -d -p 8081:80 --name m1-web-8081 my-custom-nginx:2.0
open http://localhost:8080
open http://localhost:8081

# 3. 환경 변수로 내부 포트 변경 (보너스 4)
docker run -d -e APP_PORT=9090 -p 8093:9090 --name m1-web-envport my-custom-nginx:2.0
docker exec m1-web-envport grep listen /etc/nginx/conf.d/default.conf

# 4. 바인드 마운트 확인
docker run -d -p 8082:80 -v "$(pwd)/site":/usr/share/nginx/html:ro --name m1-web-mount my-custom-nginx:2.0
curl http://localhost:8082/message.txt
echo "v3 : 다시 수정" > site/message.txt
curl http://localhost:8082/message.txt

# 5. 볼륨 영속성 확인
docker volume create m1-data
docker run -d --name vol-a -v m1-data:/data alpine sleep infinity
docker exec vol-a sh -c 'echo "important data" > /data/hello.txt'
docker rm -f vol-a
docker run -d --name vol-b -v m1-data:/data alpine sleep infinity
docker exec vol-b cat /data/hello.txt

# 6. Compose 로 한 번에 실행 (보너스 1~3)
docker compose up -d
docker compose ps
docker compose logs checker
docker compose down

# 7. 정리
docker rm -f m1-web-8080 m1-web-8081 m1-web-mount m1-web-envport vol-b
```

## 18) 파일 구조

```
mission1/
├── Dockerfile                    # 커스텀 이미지 설계도 (직접 작성)
├── docker-compose.yml            # 보너스: 실행 설정 문서화 (web + checker)
├── .gitignore                    # 실습용 임시 폴더/OS 파일 제외
├── conf/
│   └── default.conf.template     # 보너스: ${APP_PORT} 치환용 nginx 설정 템플릿
├── site/                         # 웹 서버가 서비스하는 정적 콘텐츠
│   ├── index.html                #   메인 페이지
│   └── message.txt               #   바인드 마운트 검증용 파일
├── docs/screenshots/             # 브라우저 · VSCode 연동 캡처
└── README.md                     # 본 기술 문서
```
