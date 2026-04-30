---
title: "Vercel에서 React와 Express를 함께 배포할 때 헷갈렸던 것들"
categories:
  - engineering
tags:
  - vercel
  - serverless
  - react
  - express
  - postgres
excerpt: "정적 호스팅, Vercel Function, Express BFF, pooled connection이 각각 어떤 역할을 하는지 실제 배포 구조 기준으로 정리했습니다."
---

React 앱을 Vercel에 배포하려고 하면 처음에는 구조가 꽤 헷갈립니다.

React/Vite 앱은 빌드하면 `index.html`, JavaScript, CSS 같은 정적 파일이 됩니다. 그런데 실제 서비스에는 로그인, 세션 확인, DB 저장, 외부 API 호출 같은 서버 로직도 필요합니다.

그러면 자연스럽게 질문이 생깁니다.

```text
정적 파일은 CDN에서 내려준다.
그런데 API 서버는 어디서 도는 걸까?
Express 서버를 Vercel에서 계속 켜두는 걸까?
Vercel Function은 매 요청마다 Express를 새로 실행하는 걸까?
DB connection은 어떻게 관리해야 할까?
```

이번 글은 이 질문들을 정리한 기록입니다.

## 현재 구조

현재 앱은 React/Vite 프론트엔드와 Express BFF를 함께 씁니다. 배포 구조를 단순화하면 이렇습니다.

```text
브라우저
  |
  | 화면 요청
  v
Vercel CDN
  -> Vite build 결과 반환


브라우저
  |
  | /api/... 요청
  v
Vercel Function: api/[...path].ts
  |
  v
Express app
  |
  |-- 로그인/세션/수확/시드 전환 로직
  |
  |-- Postgres
  |
  |-- Toss API
```

화면은 정적 파일로 배포됩니다. API는 Vercel Function에서 처리됩니다.

이 둘을 제대로 나누는 것이 핵심입니다.

<!-- IMAGE NOTE
purpose: 전체 배포 구조를 한눈에 보여주기 위함
suggestion: 브라우저에서 화면 요청은 Vercel CDN으로, /api 요청은 Vercel Function과 Express app으로 갈라지는 흐름 다이어그램
placement: "현재 구조" 섹션 첫 설명 뒤
-->

## 정적 호스팅의 역할

정적 호스팅은 완성된 파일을 그대로 내려주는 방식입니다.

Vite 빌드 결과는 보통 이런 형태입니다.

```text
dist/index.html
dist/assets/*.js
dist/assets/*.css
```

이 파일들은 Vercel CDN에서 빠르게 서빙됩니다.

정적 호스팅의 장점은 단순함입니다. 서버 프로세스를 직접 운영하지 않아도 되고, HTML과 JavaScript, CSS를 CDN에서 빠르게 내려줄 수 있습니다.

하지만 정적 앱만으로 처리하면 안 되는 일이 있습니다.

```text
DATABASE_URL 사용
mTLS 인증서 사용
세션 쿠키 검증
DB 저장
수확 보상 검증
Toss server-to-server API 호출
```

브라우저에서도 공개 API 호출은 할 수 있습니다. 하지만 서버 비밀값이 필요한 로직을 브라우저에서 처리하면 안 됩니다.

예를 들어 `DATABASE_URL`, mTLS 인증서, promotion code 같은 값은 클라이언트 번들에 들어가면 안 됩니다. 이런 일은 서버 쪽에서 처리해야 합니다.

## SPA 라우팅과 rewrite

React SPA는 보통 하나의 `index.html`에서 여러 화면을 처리합니다.

예를 들어 사용자가 아래 경로로 접근한다고 하겠습니다.

```text
/harvests
/terms/service
/dashboard
```

실제 빌드 결과물에 `harvests.html`이나 `dashboard.html`이 따로 있는 것은 아닙니다. React Router가 브라우저 안에서 현재 URL을 보고 알맞은 화면을 렌더링합니다.

그래서 화면 경로는 `index.html`로 보내야 합니다.

문제는 모든 요청을 `index.html`로 보내면 API까지 깨진다는 점입니다.

나쁜 예시는 이런 설정입니다.

```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

이 설정은 `/api/auth/session` 같은 API 요청까지 `index.html`로 보내버립니다. API는 JSON이나 401 응답을 줘야 하는데 HTML을 반환하게 됩니다.

그래서 현재 앱은 `/api/`를 제외한 경로만 `index.html`로 보냅니다.

```json
{
  "rewrites": [
    {
      "source": "/:path((?!api/).*)",
      "destination": "/index.html"
    }
  ]
}
```

의미는 이렇습니다.

```text
/api/... 요청은 Function으로 보낸다.
그 외 화면 경로는 index.html로 보낸다.
화면 라우팅은 React가 처리한다.
```

여기서 중요한 점은 Vercel이 모든 요청을 무조건 정적 페이지로 보는 것이 아니라는 점입니다. Vercel은 정적 파일, rewrite, Function 등을 라우팅 규칙에 따라 나눠 처리합니다.

## Vercel Function과 Express

현재 프로젝트는 `api/[...path].ts`를 API 입구로 사용합니다.

`[...path]`는 catch-all 라우트입니다. 그래서 아래 요청들이 하나의 Function으로 들어올 수 있습니다.

```text
/api/auth/session
/api/harvests
/api/harvests/claim
/api/progression/events/batch
/api/seeds/convert
```

흐름은 이렇습니다.

```text
/api/... 요청
  -> Vercel Function 호출
  -> getRuntimeServerApp()
  -> createServerApp()
  -> Express route handler 실행
```

`api/[...path].ts`는 Vercel Function의 입구입니다. `runtime-app.ts`는 런타임에서 Express app을 준비합니다. `create-app.ts`에는 실제 API 라우트가 등록됩니다.

예를 들면 이런 라우트들이 있습니다.

```text
GET  /api/auth/session
POST /api/auth/toss/exchange
POST /api/progression/events/batch
POST /api/harvests/claim
GET  /api/harvests
POST /api/seeds/convert
```

Vercel에서는 Express 앱을 default export로 배포하는 방식도 공식 지원합니다. 다만 이 프로젝트는 `/api/[...path].ts`를 명시적인 API 입구로 두고, 그 안에서 Express app을 연결하는 방식을 씁니다.

## Function은 매번 Express를 새로 만들까?

처음에는 “API 요청이 올 때마다 Express 서버를 새로 켜는 건가?”라고 생각하기 쉽습니다.

정확히는 그렇지 않습니다.

첫 요청이 들어오면 Vercel Function 인스턴스가 생성되고, 모듈이 로드됩니다. 이때 Express app 객체도 만들어집니다.

```text
첫 요청
  -> Function 인스턴스 생성
  -> 모듈 로드
  -> Express app 객체 생성
  -> 요청 처리
```

그 Function 인스턴스가 살아 있는 동안에는 이미 만든 Express app을 재사용할 수 있습니다.

```text
다음 요청
  -> 같은 Function 인스턴스 재사용
  -> 기존 Express app 재사용
  -> 요청 처리
```

현재 코드도 이런 방식입니다.

```ts
let runtimeApp: RuntimeServerApp | null = null

export function getRuntimeServerApp(): RuntimeServerApp {
  if (runtimeApp) {
    return runtimeApp
  }

  runtimeApp = createServerApp(...)
  return runtimeApp
}
```

다만 전통적인 서버처럼 영구적으로 살아 있다고 가정하면 안 됩니다.

Vercel이 Function 인스턴스의 생명주기를 관리합니다. 트래픽이 줄거나, 시간이 지나거나, 배포가 바뀌거나, 스케일링이 일어나면 인스턴스는 사라질 수 있습니다.

정확한 표현은 이렇습니다.

```text
Vercel Function은 매 요청마다 반드시 Express app을 새로 만들지는 않는다.
살아 있는 인스턴스 안에서는 Express app을 재사용할 수 있다.
하지만 인스턴스 재사용을 영구적인 계약처럼 의존하면 안 된다.
```

## 전통적인 웹서버와의 차이

전통적인 Express 서버는 보통 이렇게 동작합니다.

```text
사용자 브라우저
  |
  v
항상 켜져 있는 Node.js 서버
Express app.listen(3000)
  |
  |-- 정적 파일 서빙
  |-- API 요청 처리
  |-- DB/API 통신
```

서버 프로세스가 계속 떠 있고, 포트를 열고 요청을 기다립니다.

반면 Vercel 구조는 정적 파일과 API 처리가 분리됩니다.

```text
화면 요청
  -> Vercel CDN
  -> index.html, JS, CSS 반환
```

```text
API 요청
  -> Vercel Function
  -> Express app
  -> DB/API 통신
```

차이를 압축하면 이렇습니다.

```text
전통 서버:
브라우저 -> 항상 켜진 서버 -> 정적 파일/API/DB 처리

Vercel:
브라우저 -> CDN -> 정적 파일 처리
브라우저 -> Function -> API 처리
```

전통 서버는 서버 프로세스와 메모리 상태가 오래 유지되기 쉽습니다. Vercel Function은 인스턴스가 생겼다 사라질 수 있고, 동시에 여러 인스턴스가 생길 수도 있습니다.

<!-- IMAGE NOTE
purpose: 전통 서버와 Vercel serverless 구조의 차이를 시각적으로 비교하기 위함
suggestion: 왼쪽에는 항상 켜진 Express 서버가 정적 파일과 API를 모두 처리하는 그림, 오른쪽에는 CDN과 Function이 분리된 그림
placement: "전통적인 웹서버와의 차이" 섹션 마지막 문단 아래
-->

## DB connection과 pooled connection

이 차이는 DB 연결에서 중요해집니다.

전통적인 서버에서는 보통 서버 프로세스 하나가 DB connection pool 하나를 오래 들고 갑니다.

```text
Express 서버 1개
  |
  v
pg Pool 1개
  |
  v
Postgres
```

물론 전통 서버도 여러 인스턴스로 스케일아웃하면 각 프로세스마다 pool이 생깁니다. 하지만 serverless 환경은 인스턴스 생성과 소멸, 동시 확장이 더 탄력적입니다. 그래서 DB connection 수를 더 조심해야 합니다.

Vercel Function 인스턴스가 여러 개 생기면 이런 구조가 됩니다.

```text
Function 인스턴스 A -> pg Pool
Function 인스턴스 B -> pg Pool
Function 인스턴스 C -> pg Pool
```

각 인스턴스가 DB 연결을 만들면, 트래픽 증가 시 DB connection 수가 빠르게 늘 수 있습니다. Postgres에는 동시에 열 수 있는 connection 수 제한이 있으므로 이 부분이 병목이 될 수 있습니다.

그래서 pooled connection을 씁니다.

```text
Vercel Functions 여러 개
  |
  v
pooled connection
  |
  v
실제 Postgres
```

pooled connection은 앱과 DB 사이의 연결 중간층입니다. 앱 인스턴스들이 DB에 직접 무작정 연결하지 않고, pooler를 통해 연결을 재사용하거나 조절합니다.

현재 앱은 Vercel 환경에서 DB pool 정리를 돕기 위해 `attachDatabasePool`도 사용합니다.

```ts
if (process.env.VERCEL) {
  attachDatabasePool(pool)
}
```

이 코드는 Vercel Function 환경에서 idle connection 정리를 돕습니다.

다만 이것과 Neon 같은 DB provider의 pooled connection string은 서로 다른 층입니다. 둘 다 함께 쓰는 것이 좋습니다.

```text
앱 코드:
pg Pool + attachDatabasePool

DB URL:
Neon pooled connection string
```

## 이 앱에 맞는 배포 방식

현재 구조에서는 Vercel + Neon Postgres 조합이 가장 자연스럽습니다.

```text
Vercel
  - React/Vite 정적 파일 배포
  - /api/* Vercel Function 배포

Neon Postgres
  - production DB
  - pooled connection string을 DATABASE_URL로 사용
```

배포 후 흐름은 다음과 같습니다.

```text
1. Vercel이 npm run build 실행
2. Vite 정적 파일을 CDN에 올림
3. api/[...path].ts를 Vercel Function으로 빌드
4. 사용자가 화면 접속
5. 브라우저가 CDN에서 JS/CSS 수신
6. 브라우저가 /api/... 호출
7. Vercel Function 안의 Express app이 요청 처리
8. Express app이 Postgres/Toss API와 통신
```

이 구조에서 피해야 할 것은 정적 호스팅만으로 배포하는 것입니다. 화면은 열릴 수 있지만 `/api/...` 요청을 처리할 서버 로직이 없으면 로그인, 수확, 진행 동기화, 시드 전환이 실패합니다.

## 정리

핵심은 네 가지입니다.

```text
정적 호스팅:
HTML, JS, CSS 같은 파일을 CDN에서 내려주는 방식

동적 처리:
요청 시 서버 코드가 실행되는 방식

Vercel Function:
Vercel에서 API 요청을 처리하는 serverless 함수

pooled connection:
serverless 환경에서 DB 연결 폭주를 줄이기 위한 연결 중간층
```

현재 앱은 정적 호스팅만으로는 부족합니다. 화면은 정적 파일로 배포하지만, 로그인, 수확, 진행 동기화, 시드 전환 같은 기능은 서버 로직이 필요합니다.

따라서 구조는 이렇게 잡는 것이 맞습니다.

```text
화면:
Vercel CDN에서 Vite 정적 빌드 파일 제공

API:
Vercel Function에서 Express BFF 실행

DB:
Neon Postgres pooled connection 사용
```

가장 중요한 점은 `/api/...` 요청이 `index.html`로 가면 안 된다는 것입니다.

SPA 화면 경로는 `index.html`로 보내되, API 경로는 Function으로 보내야 합니다. 이 구분이 Vercel에서 React SPA와 Express BFF를 함께 배포할 때의 핵심입니다.

## 참고 문서

- [Vercel Node.js Functions](https://vercel.com/docs/functions/runtimes/node-js)
- [Vercel Rewrites](https://vercel.com/docs/rewrites)
- [Vercel Project Configuration](https://vercel.com/docs/project-configuration/vercel-json)
- [Express on Vercel](https://vercel.com/guides/using-express-with-vercel)
- [Neon connection pooling](https://neon.com/docs/connect/connection-pooling)
