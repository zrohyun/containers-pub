# containers-pub

[![publish-base-images](../../actions/workflows/publish-base-images.yml/badge.svg)](../../actions/workflows/publish-base-images.yml)

GHCR에 재사용 가능한 CI 베이스 이미지를 배포하기 위한 저장소입니다.

## 이미지 구성

다음 3개 이미지를 관리합니다.

- `base-ubuntu-apt`: apt 업데이트 및 공통 apt 패키지 포함
- `base-ubuntu-brew`: Homebrew 설치에 필요한 패키지와 brew 포함
- `base-ubuntu-apt-brew`: `base-ubuntu-apt` 기반에 brew를 추가한 통합 이미지

## 태그 정책

예시 태그:

- `ghcr.io/<owner>/base-ubuntu-apt:24.04`
- `ghcr.io/<owner>/base-ubuntu-apt:24.04-YYYYMMDD`

동일 정책을 brew/apt-brew에도 적용합니다.

- `24.04`: 롤링 태그
- `24.04-YYYYMMDD`: 고정 태그

## 배포 워크플로

워크플로 파일: `.github/workflows/publish-base-images.yml`

동작:

1. 날짜 태그(`YYYYMMDD`) 계산
2. `base-ubuntu-apt` 빌드/푸시
3. `base-ubuntu-brew` 빌드/푸시
4. 같은 날짜의 `base-ubuntu-apt`를 베이스로 `base-ubuntu-apt-brew` 빌드/푸시

트리거:

- 수동 실행(`workflow_dispatch`)
- 매주 월요일 UTC 03:00 스케줄 실행
- `main` 브랜치에 아래 파일 변경이 포함된 push
  - `.github/workflows/publish-base-images.yml`
  - `docker/packages/apt-common.txt`
  - `docker/ubuntu-apt/Dockerfile`
  - `docker/ubuntu-brew/Dockerfile`
  - `docker/ubuntu-apt-brew/Dockerfile`

## 로컬 빌드/테스트

Docker가 설치되어 있다면 아래 스크립트로 3개 이미지를 순차 빌드하고 기본 검증(`apt-get --version`, `brew --version`)을 수행할 수 있습니다.

```bash
./scripts/local-build-test.sh
```

스크립트는 단계별 빌드/검증 시간과 총 시간을 출력하고, 실행 로그를 아래 경로에 저장합니다.

- `_hub/_data/logs/local-build-test_YYYYMMDDTHHMMSSZ.log`

## 커스터마이징

- apt 기본 패키지: `docker/packages/apt-common.txt`
- Dockerfile:
  - `docker/ubuntu-apt/Dockerfile`
  - `docker/ubuntu-brew/Dockerfile`
  - `docker/ubuntu-apt-brew/Dockerfile`
- 로컬 점검 스크립트:
  - `scripts/local-build-test.sh`
