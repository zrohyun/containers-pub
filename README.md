# containers-pub

GHCR로 재사용 가능한 CI 베이스 이미지를 배포하는 저장소입니다.

## 왜 분리하나?

요청하신 구조(`base-ubuntu-apt`, `base-ubuntu-brew`, `base-ubuntu-apt-brew`)가 CI 시간/유지보수 관점에서 가장 실용적입니다.

- `base-ubuntu-apt`: apt 업데이트 + 공통 apt 패키지
- `base-ubuntu-brew`: brew만 필요한 파이프라인용 (brew 설치 전제 패키지 포함)
- `base-ubuntu-apt-brew`: apt 레이어 위에 brew까지 포함한 통합 이미지

`brew` 설치 시에도 의존 패키지 설치를 위해 `apt`는 일부 필요합니다. 다만 이미지를 분리해 두면, brew가 필요 없는 작업에서 불필요한 레이어를 당기지 않아 더 빠릅니다.

## 태그 정책

예시 태그:

- `ghcr.io/<owner>/base-ubuntu-apt:24.04`
- `ghcr.io/<owner>/base-ubuntu-apt:24.04-YYYYMMDD`

동일 정책을 brew/apt-brew에도 적용합니다.

- `24.04`: 편의용 최신 롤링 태그
- `24.04-YYYYMMDD`: 재현성/롤백용 고정 태그

## 배포 워크플로

워크플로 파일: `.github/workflows/publish-base-images.yml`

동작:

1. 날짜 태그(`YYYYMMDD`) 계산
2. `base-ubuntu-apt` 푸시
3. `base-ubuntu-brew` 푸시
4. 같은 날짜의 `base-ubuntu-apt`를 베이스로 `base-ubuntu-apt-brew` 푸시

트리거:

- 수동 실행(`workflow_dispatch`)
- 매주 월요일 UTC 03:00 스케줄 실행

## 로컬 빌드/테스트

Docker가 설치되어 있다면 아래 스크립트로 3개 이미지를 순차 빌드하고 간단 검증(`apt-get --version`, `brew --version`)까지 수행할 수 있습니다.

```bash
./scripts/local-build-test.sh
```

스크립트는 각 단계별 빌드/검증 소요 시간과 총 시간을 통계로 출력하며, 전체 실행 로그를 아래 경로에 저장합니다.

- `_hub/_data/logs/local-build-test_YYYYMMDDTHHMMSSZ.log`

## 커스터마이징

- apt 기본 패키지: `docker/packages/apt-common.txt`
- Dockerfile:
  - `docker/ubuntu-apt/Dockerfile`
  - `docker/ubuntu-brew/Dockerfile`
  - `docker/ubuntu-apt-brew/Dockerfile`
- 로컬 점검 스크립트:
  - `scripts/local-build-test.sh`
