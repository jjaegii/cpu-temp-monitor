# CPU 온도 모니터링

## 개요

이 가이드는 CPU 온도를 모니터링하는 도커 컨테이너를 빌드하고 실행하는 방법을 설명합니다. `Package id 0`의 온도가 70°C를 초과할 경우, 컨테이너는 Gmail의 SMTP 서버를 사용하여 이메일 경고를 전송합니다.

## 사전 요구 사항

1. 시스템에 Docker가 설치되어 있어야 합니다.
2. Gmail 계정과 생성된 앱 비밀번호가 있어야 합니다. [여기](https://myaccount.google.com/security)에서 앱 비밀번호를 생성할 수 있습니다.

## 실행 방법

### 1. Docker 이미지 빌드 및 실행

#### Dockerfile 및 monitor.sh 준비

현재 디렉토리에 `Dockerfile`과 `monitor.sh` 파일이 있는지 확인하십시오.

#### Docker 이미지 빌드

터미널을 열고 `Dockerfile`과 `monitor.sh` 파일이 있는 디렉토리로 이동한 후, 다음 명령어를 실행하여 Docker 이미지를 빌드합니다:

```sh
docker build -t your-dockerhub-username/cpu-monitor:latest .
```

`your-dockerhub-username`을 실제 Docker Hub 사용자 이름으로 바꾸세요.

#### Docker 컨테이너 실행

다음 명령어를 실행하여 Docker 컨테이너를 실행합니다. 환경 변수를 실제 값으로 대체하십시오:

```sh
docker run -d \
  --name cpu-monitor \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=your-email@gmail.com \
  -e SMTP_PASS=your-app-password \
  -e EMAIL_TO=recipient@example.com \
  your-dockerhub-username/cpu-monitor:latest
```

환경 변수:
- `SMTP_HOST`: SMTP 서버 주소 (Gmail: `smtp.gmail.com`)
- `SMTP_PORT`: SMTP 서버 포트 (Gmail: `587`)
- `SMTP_USER`: Gmail 주소
- `SMTP_PASS`: Gmail 앱 비밀번호
- `EMAIL_TO`: 경고를 받을 이메일 주소

#### 컨테이너 확인

컨테이너가 정상적으로 실행 중인지 확인하려면 다음 명령어를 실행하십시오:

```sh
docker ps
```

`cpu-monitor`라는 이름의 컨테이너가 실행 중인 것을 확인할 수 있습니다.

#### 로그 확인

스크립트가 제대로 실행되는지 확인하려면 다음 명령어로 컨테이너 로그를 확인하십시오:

```sh
docker logs cpu-monitor
```

### 2. Docker Hub에서 이미지 Pull 및 실행

이미지 빌드 대신 Docker Hub에서 이미지를 직접 Pull하여 사용할 수도 있습니다.

#### Docker 이미지 Pull

다음 명령어를 사용하여 Docker Hub에서 이미지를 Pull합니다:

```sh
docker pull jjaegii/cpu-monitor:latest
```

#### Docker 컨테이너 실행

다음 명령어를 실행하여 Docker 컨테이너를 실행합니다:

```sh
docker run -d \
  --name cpu-monitor \
  -e SMTP_HOST=smtp.gmail.com \
  -e SMTP_PORT=587 \
  -e SMTP_USER=your-email@gmail.com \
  -e SMTP_PASS=your-app-password \
  -e EMAIL_TO=recipient@example.com \
  jjaegii/cpu-monitor:latest
```

### 3. Kubernetes에 배포

Kubernetes 클러스터에 배포하려면 `deployment.yaml` 파일을 사용하십시오.

#### deployment.yaml 파일

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-monitor
  labels:
    app: cpu-monitor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-monitor
  template:
    metadata:
      labels:
        app: cpu-monitor
    spec:
      containers:
      - name: cpu-monitor
        image: jjaegii/cpu-monitor:latest
        env:
        - name: SMTP_HOST
          value: "smtp.gmail.com"
        - name: SMTP_PORT
          value: "587"
        - name: SMTP_USER
          value: "your-email@gmail.com"
        - name: SMTP_PASS
          value: "your-app-password"
        - name: EMAIL_TO
          value: "recipient@example.com"
```

#### Kubernetes에 배포

다음 명령어를 사용하여 Kubernetes 클러스터에 배포합니다:

```sh
kubectl apply -f deployment.yaml
```

## 추가 정보

- Docker 데몬이 센서에 접근할 수 있도록 설정해야 합니다. 시스템 구성에 따라 컨테이너를 관리자 권한으로 실행해야 할 수 있습니다.
- 모니터링 스크립트는 60초마다 온도를 확인합니다. 다른 주기로 변경하려면 `monitor.sh` 파일에서 sleep 시간을 조정하십시오.

## 문제 해결

- Gmail 인증 문제 발생 시, 앱 비밀번호가 정확한지 확인하고 Gmail 계정 설정에서 보안 수준이 낮은 앱의 접근을 허용해야 할 수 있습니다.
- 호스트 시스템에서 `sensors` 명령어가 사용 가능하고 예상된 출력을 제공하는지 확인하십시오. 필요시 `lm-sensors`를 호스트에 설치해야 합니다.

