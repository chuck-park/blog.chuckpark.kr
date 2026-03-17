---
title: "OpenClaw 활용 사례: chuckpark.kr · blog · utils 도메인 운영 실전기"
categories: devlog
tags:
  - openclaw
  - cloudflare
  - github-pages
  - dns
  - domain-setup
  - automation
---

# OpenClaw 활용 사례: chuckpark.kr · blog · utils 도메인 운영 실전기

## 한 줄 요약
OpenClaw를 단순 코딩 도구가 아니라 운영 파트너로 활용해, 도메인 3개(`chuckpark.kr`, `blog.chuckpark.kr`, `utils.chuckpark.kr`)를 분리 구축하고 DNS/HTTPS 이슈까지 정리한 과정을 기록한다.

## 왜 이 작업을 시작했나
처음에는 로컬 서버 + 터널 기반으로 사이트를 확인했다. 빠르게 수정하고 확인하는 데는 좋았지만, 운영 관점에서는 분명한 한계가 있었다.

- 세션이 끊기면 URL이 바뀜
- 머신 상태(전원, 네트워크)에 서비스 가용성이 종속됨
- 도메인 단위로 역할 분리가 어려움

그래서 구조를 아래처럼 분리하기로 했다.

- `chuckpark.kr`: 메인 사이트
- `blog.chuckpark.kr`: 블로그
- `utils.chuckpark.kr`: 작은 도구 모음(비밀번호 생성기, 글자수 계산기)

## OpenClaw를 어떻게 썼나
이번 작업에서 OpenClaw는 “명령 실행기”가 아니라, 운영 절차를 정리하고 실수를 줄이는 역할을 했다.

- 리포지토리 정리/분리 작업
- GitHub Pages 전환 및 도메인 연결 순서 점검
- Cloudflare DNS 이슈 원인 파악
- 배포 후 응답 코드(502, 526 등) 기준 진단
- UI 수정/커밋/푸시 반복 자동화

핵심은 한 번에 다 바꾸는 게 아니라, **문제를 분리해서 단계별로 전환**한 것이다.

## 실제로 겪은 문제들

### 1) `chuckpark.kr` 접속 불가 (502/526)
메인 도메인이 안 열릴 때 가장 먼저 헷갈렸던 건 DNS 자체 문제인지, 원본(origin) 문제인지였다.

- 502: Cloudflare는 살아있지만 원본 연결 실패
- 526: 원본 인증서 검증 실패(HTTPS 체인 문제)

여기서 얻은 교훈은 단순했다.

> 도메인 전환 직후에는 Cloudflare를 무조건 Proxied로 두기보다, DNS only로 먼저 안정화한 뒤 올리는 게 안전하다.

### 2) 블로그 UI가 갑자기 깨짐
`blog.chuckpark.kr`를 새 리포로 분리한 뒤 UI가 깨졌는데, 원인은 Jekyll 설정이었다.

- `baseurl`이 잘못 남아 경로가 `/blog.chuckpark.kr/...` 형태로 꼬임
- `repository`도 이전 리포를 바라보고 있었음

해결은 명확했다.

- `baseurl: ""`로 정리
- `repository`를 새 블로그 리포로 교체

### 3) 브라우저 `Not secure` 표시
사이트 자체는 열리는데 브라우저에서 보안 경고가 뜨는 경우가 있었다. 대부분은 아래 순서를 놓쳐서 생긴다.

- Custom domain 연결
- DNS 검증 완료 대기
- `Enforce HTTPS` 활성화

즉, 도메인을 붙였다고 끝난 게 아니다. **검증 완료 + HTTPS 강제**까지가 마무리다.

<!-- IMAGE NOTE
purpose: GitHub Pages custom domain 연결 후 DNS 검증과 HTTPS 강제 적용 순서를 시각적으로 설명
suggestion: Pages 설정 화면에서 Custom domain, DNS Check in Progress, Enforce HTTPS 비활성 상태를 함께 보여주는 캡처(첨부한 이미지)
placement: "브라우저 Not secure 표시" 섹션 첫 문단 아래
-->

## utils.chuckpark.kr 첫 기능: 비밀번호 생성기 + 글자수 계산기
유틸 도메인에는 먼저 작은 기능 2개를 배포했다.

1. 비밀번호 생성기
- 길이 선택(기본 20)
- 영문 대/소문자, 숫자, 특수문자 옵션 선택
- `crypto.getRandomValues` 기반 생성
- 복사 버튼 + 피드백

2. 글자수 계산기
- 전체 글자수
- 공백 제외 글자수
- 단어 수
- 줄 수

처음부터 거창한 제품을 붙이기보다, 즉시 쓸 수 있는 도구를 하나씩 추가하는 방식이 유지보수에 유리했다.

## 이번 작업에서 정리한 운영 원칙
1. 도메인 전환은 한 번에 하지 않는다. (메인/블로그/유틸 분리)
2. DNS는 먼저 단순하게 붙이고, 캐시/프록시는 나중에 올린다.
3. GitHub Pages는 `Custom domain + CNAME + Enforce HTTPS`를 한 세트로 본다.
4. 경로 깨짐 이슈가 나면 Jekyll `baseurl`부터 먼저 본다.
5. 임시 터널은 개발용으로만 쓰고, 운영은 고정 호스팅으로 끝낸다.

## 마무리
OpenClaw를 써서 가장 크게 얻은 건 속도보다 **절차 안정성**이었다.

도메인·DNS·배포 작업은 작은 실수 하나로 장애가 나기 쉽다. 하지만 문제를 분리하고 체크리스트 형태로 진행하면, 혼자 운영하는 환경에서도 충분히 안정적으로 굴릴 수 있다.

이번 작업은 그걸 확인한 사례였다.
