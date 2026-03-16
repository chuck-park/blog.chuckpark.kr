---
title: "[AI로 서비스 만들기] 카카오 로그인 붙이기: KOE101 트러블슈팅"
categories: devlog
tags:
  - ai로서비스만들기
  - kakao-login
  - nextauth
  - oauth
  - troubleshooting
  - koe101
---

# [AI로 서비스 만들기] 카카오 로그인 붙이기: KOE101 트러블슈팅

## 한 줄 요약
카카오 로그인에서 `KOE101`이 뜰 때, 특히 에러 화면에 **앱 이름이 비어 있다면** Redirect URI보다 먼저 `KAKAO_CLIENT_ID`(REST API 키) 자체를 의심해야 합니다.

## 이 글의 위치
이 글은 **‘AI로 서비스 만들기’ 시리즈** 중 **‘카카오로 로그인 붙이기’** 챕터의 트러블슈팅 파트입니다.  
구현 자체보다, 연동 중 막혔을 때 빠르게 복구하는 데 초점을 맞췄습니다.

## 문제 상황
로컬 환경(`http://localhost:3000`)에서 카카오 로그인 버튼을 누르면 동의 화면 대신 아래 에러가 노출됐습니다.

> Admin Settings Issue (KOE101)  
> An error in the service settings prevents the service from being used.

여기서 중요한 힌트는 에러 화면의 앱명 영역이 비어 있었다는 점입니다.

- `<span class="txt_name"></span>` 형태로 앱 이름이 렌더링되지 않음

이 상태는 단순 URI 불일치가 아니라, 카카오 측에서 앱 식별 자체가 제대로 안 되는 케이스를 강하게 시사합니다.

## 먼저 점검한 항목
`KOE101`은 범용 에러라 아래 항목을 순서대로 확인했습니다.

### 1) Redirect URI
- 카카오 디벨로퍼스 > 카카오 로그인 > Redirect URI
- `http://localhost:3000/api/auth/callback/kakao` 등록 여부 확인

### 2) Web 플랫폼 도메인
- 카카오 디벨로퍼스 > 앱 설정 > 플랫폼 > Web
- `http://localhost:3000` 등록 여부 확인

### 3) Client Secret 사용 여부
- `.env.local`에 `KAKAO_CLIENT_SECRET`을 넣었다면
- 카카오 콘솔의 보안 설정과 일치하는지 확인

여기까지 모두 맞아도 문제는 계속됐습니다.

## 루트코즈: KAKAO_CLIENT_ID 오입력
브라우저 네트워크 탭에서 authorize 요청 파라미터를 확인했을 때, `client_id` 값이 카카오 앱의 REST API 키 형식과 맞지 않았습니다.

핵심은 이겁니다.

- 카카오 REST API 키는 앱 콘솔에서 발급된 정식 키여야 함
- `.env.local`의 `KAKAO_CLIENT_ID`에 다른 플랫폼 키/잘못된 문자열이 들어가 있으면 `KOE101`이 발생할 수 있음
- 앱 이름 공란은 “해당 키로 앱을 찾지 못한다”는 강한 신호

## 최종 해결 절차 (복구 체크리스트)
1. 카카오 디벨로퍼스 > 내 애플리케이션 > 해당 앱 선택
2. **앱 설정 > 앱 키 > REST API 키** 복사
3. `.env.local`의 `KAKAO_CLIENT_ID`를 위 키로 교체
4. `KAKAO_CLIENT_SECRET` 사용 시 콘솔 보안값과 정확히 맞춤
5. 개발 서버 완전 재시작 (`Ctrl+C` 후 `npm run dev`)

## 재발 방지 규칙
- `KOE101`이 뜨면 순서를 고정해서 점검:
  1) Redirect URI  
  2) 플랫폼 도메인  
  3) `KAKAO_CLIENT_ID` 실값
- 특히 **앱 이름 공란**이면 1순위는 `KAKAO_CLIENT_ID`
- 로컬/스테이징/프로덕션 env 파일을 분리해서 키 혼용 방지

## 마무리
카카오 로그인 연동에서 `KOE101`은 흔하지만, 원인은 케이스별로 다릅니다.  
이번 케이스의 핵심 교훈은 간단합니다.

**“설정은 다 맞는 것 같은데 앱명이 비어 있다면, Client ID부터 다시 보자.”**

<!-- IMAGE NOTE
purpose: KOE101 대응 순서를 한눈에 보여주기 위함
suggestion: Redirect URI -> 플랫폼 도메인 -> Client ID 검증의 3단계 체크 플로우 다이어그램
placement: "재발 방지 규칙" 섹션 바로 위
-->
