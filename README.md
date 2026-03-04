# containers-pub

[![publish-base-images](../../actions/workflows/publish-base-images.yml/badge.svg)](../../actions/workflows/publish-base-images.yml)

GHCR 재사용형 CI 베이스 이미지 배포 저장소.

## 이미지 구성

관리 대상은 `base-ubuntu-apt-brew` 단일 이미지.

- Ubuntu 24.04 기반
- `apt-get update` 수행 후 Homebrew 설치에 필요한 최소 패키지 설치
  - `ca-certificates`, `curl`, `git`, `build-essential`, `procps`, `file`
- non-root `linuxbrew` 사용자 생성 및 Homebrew 설치

## 태그 정책

- `ghcr.io/<owner>/base-ubuntu-apt-brew:24.04`
- `ghcr.io/<owner>/base-ubuntu-apt-brew:24.04-YYYYMMDD`

- `24.04`: 롤링 태그
- `24.04-YYYYMMDD`: 고정 태그

## 배포 워크플로

워크플로 파일: `.github/workflows/publish-base-images.yml`

트리거 조건.

- 수동 실행(`workflow_dispatch`)
- 매월 1일 UTC 03:00 스케줄 실행
- `main` 브랜치 대상 아래 파일 변경 포함 push
  - `.github/workflows/publish-base-images.yml`
  - `docker/ubuntu-apt-brew/Dockerfile`

## 로컬 빌드/테스트

Docker 설치 환경 기준:

```bash
./scripts/local-build-test.sh
```

검증 항목.

- `apt-get --version`
- `git --version`
- `curl --version`
- `brew --version`

## 커스터마이징

- Dockerfile:
  - `docker/ubuntu-apt-brew/Dockerfile`
- 로컬 점검 스크립트:
  - `scripts/local-build-test.sh`
