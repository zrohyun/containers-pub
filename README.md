# containers-pub

[![publish-base-images](../../actions/workflows/publish-base-images.yml/badge.svg)](../../actions/workflows/publish-base-images.yml)

GHCR 재사용형 CI 베이스 이미지 배포 저장소.

## 이미지 구성

관리 대상 3개 이미지.

- `base-ubuntu-apt`: apt 업데이트 및 공통 apt 패키지 포함
- `base-ubuntu-brew`: Homebrew 설치 필요 패키지 및 brew 포함
- `base-ubuntu-apt-brew`: `base-ubuntu-apt` 기반 brew 추가 통합 이미지

## 태그 정책

예시 태그.

- `ghcr.io/<owner>/base-ubuntu-apt:24.04`
- `ghcr.io/<owner>/base-ubuntu-apt:24.04-YYYYMMDD`

동일 정책 brew/apt-brew 적용.

- `24.04`: 롤링 태그
- `24.04-YYYYMMDD`: 고정 태그

## 배포 워크플로

워크플로 파일: `.github/workflows/publish-base-images.yml`

동작 규칙.

1. 날짜 태그(`YYYYMMDD`) 계산
2. `schedule`/`workflow_dispatch`: 3개 이미지 전체 빌드/푸시
3. `push`: 변경된 Dockerfile/패키지 기준 선택 빌드
4. `base-ubuntu-apt` 변경 시 `base-ubuntu-apt-brew` 동시 빌드

트리거 조건.

- 수동 실행(`workflow_dispatch`)
- 매주 월요일 UTC 03:00 스케줄 실행
- `main` 브랜치 대상 아래 파일 변경 포함 push
  - `.github/workflows/publish-base-images.yml`
  - `docker/packages/apt-common.txt`
  - `docker/ubuntu-apt/Dockerfile`
  - `docker/ubuntu-brew/Dockerfile`
  - `docker/ubuntu-apt-brew/Dockerfile`

## 로컬 빌드/테스트

Docker 설치 환경 기준, 아래 스크립트로 3개 이미지 순차 빌드 및 기본 검증(`apt-get --version`, `brew --version`) 수행.

```bash
./scripts/local-build-test.sh
```

스크립트 출력 항목: 단계별 빌드/검증 시간, 총 시간, 실행 로그 경로.

- `_hub/_data/logs/local-build-test_YYYYMMDDTHHMMSSZ.log`

## 커스터마이징

- apt 기본 패키지: `docker/packages/apt-common.txt`
- Dockerfile:
  - `docker/ubuntu-apt/Dockerfile`
  - `docker/ubuntu-brew/Dockerfile`
  - `docker/ubuntu-apt-brew/Dockerfile`
- 로컬 점검 스크립트:
  - `scripts/local-build-test.sh`
