# Blog Series Next Steps Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 선물·옵션 입문 시리즈를 3편 구조로 재정렬하고, 2편과 3편 초안을 완성 가능한 상태로 만든다.

**Architecture:** 기존 1편은 유지·보강 대상으로 두고, 2편과 3편은 새 파일로 작성한다. 기존 `oi-short-covering-explained` 글은 즉시 삭제하지 않고 3편 완성 전까지 참고 재료로 유지한다. 현재 작업 단계는 게시 전 초안 정리이므로 기준 위치는 `_posts/`가 아니라 `_drafts/`다. 계획 수립 시점 기준으로 `_drafts/2026-04-01-futures-options-basics.md`, `_drafts/2026-04-01-oi-short-covering-explained.md`는 확인됐고, 2편과 3편 대상 파일은 `_drafts/`에 새로 만들거나 옮기는 전제로 진행한다.

**Tech Stack:** Jekyll, Markdown front matter, local git workflow, `bundle exec jekyll build`

---

### Task 1: 현재 초안 파일 실제 위치 확인

**Files:**
- Check: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/`

**Step 1: 시리즈 관련 파일 검색**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
rg -n "futures|options|short covering|open interest|베이시스|호가창|체결강도" _drafts
```

Expected: 사용자가 언급한 초안이 `_drafts/`에서 확인되거나, 없는 파일은 새로 만들 대상임이 확인된다.

**Step 2: 파일명 확정**

확정 대상:

```text
_drafts/2026-04-01-futures-options-basics.md
_drafts/2026-04-01-trading-basics-volume-tick-orderbook.md
_drafts/2026-04-01-market-microstructure-short-covering-liquidity.md
_drafts/2026-04-01-oi-short-covering-explained.md
```

**Step 3: 상태 메모**

결과를 작업 메모나 커밋 메시지 전 단계 기록으로 남긴다.

**Step 4: Commit**

이 단계는 조사만이므로 커밋하지 않는다.

### Task 2: 1편을 시리즈 기준 문서로 고정

**Files:**
- Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-futures-options-basics.md`

**Step 1: front matter 점검**

확인할 항목:

```yaml
title:
date:
categories:
tags:
description:
```

**Step 2: 1편 구조 고정**

본문 섹션 순서:

```text
왜 이 시리즈를 공부하는가
롱/숏
만기
청산
OI
베이시스
2편 예고
```

**Step 3: 시리즈 링크 문장 추가**

본문 마지막에 다음 연결 문장 포함:

```text
2편에서는 거래량, 체결강도, 호가창, 지지/저항처럼 실제 매매 화면을 읽는 데 필요한 기초 개념을 정리합니다.
```

**Step 4: 로컬 빌드 검증**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
bundle exec jekyll build
```

Expected: build succeeds

**Step 5: Commit**

```bash
git add _drafts/2026-04-01-futures-options-basics.md
git commit -m "docs: finalize series part one outline"
```

### Task 3: 2편 신규 작성

**Files:**
- Create or Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-trading-basics-volume-tick-orderbook.md`

**Step 1: 기본 front matter 작성**

```yaml
---
title: "거래량·체결강도·호가창·지지와 저항 기초"
layout: single
date: 2026-04-01
categories: [product]
tags: [trading, volume, orderbook]
description: "거래량, 체결강도, 호가창, 지지와 저항을 초보자 관점에서 연결해 설명하는 트레이딩 기초 글"
---
```

**Step 2: 문서 골격 작성**

본문 순서:

```text
이 글의 목적
거래량이 의미하는 것
체결강도는 언제 참고할 것인가
호가창을 어떻게 읽는가
지지/저항을 왜 모두가 보게 되는가
초보가 오해하기 쉬운 지점
3편 예고
```

**Step 3: 예시 삽입**

반드시 포함:
- 거래량 증가 + 방향성 미확정 예시
- 체결강도 수치가 높아도 가격이 못 가는 예시
- 호가창 벽이 실제 체결 전 사라질 수 있는 예시
- 지지/저항이 깨진 뒤 함정이 나오는 예시

**Step 4: 시리즈 연결 문장 작성**

마지막 문장:

```text
3편에서는 유동성, 매수벽과 매도벽, 숏커버, 가격 급변 구조처럼 시장 미시구조 감각으로 이어갑니다.
```

**Step 5: 로컬 빌드 검증**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
bundle exec jekyll build
```

Expected: build succeeds

**Step 6: Commit**

```bash
git add _drafts/2026-04-01-trading-basics-volume-tick-orderbook.md
git commit -m "docs: add trading basics series draft"
```

### Task 4: 3편 신규 작성

**Files:**
- Create or Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-market-microstructure-short-covering-liquidity.md`
- Reference Only: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-oi-short-covering-explained.md`

**Step 1: 기본 front matter 작성**

```yaml
---
title: "유동성·매수벽·숏커버로 보는 가격 급변 구조"
layout: single
date: 2026-04-01
categories: [product]
tags: [market-microstructure, liquidity, short-covering]
description: "유동성, 벽 주문, 숏커버, 돌파와 가짜 돌파를 초보자 관점에서 설명하는 시장 미시구조 입문 글"
---
```

**Step 2: 기존 short covering 글에서 가져올 재료 추출**

재활용 대상:
- 숏커버 정의
- 숏 포지션 청산이 왜 매수 압력으로 보이는지
- 가격 급변이 구조적으로 생기는 이유

**Step 3: 3편 구조 작성**

본문 순서:

```text
왜 가격은 갑자기 튀는가
유동성이란 무엇인가
매수벽/매도벽은 무엇을 보여주고 무엇은 못 보여주는가
숏커버는 어떻게 터지는가
돌파와 가짜 돌파는 어떻게 구분할 것인가
초보가 속는 대표 패턴
시리즈 마무리
```

**Step 4: 초보 관점 경고 문장 삽입**

반드시 포함:

```text
호가창의 큰 주문은 방향 힌트일 수는 있지만, 그 자체로 확정 신호는 아닙니다.
```

**Step 5: 로컬 빌드 검증**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
bundle exec jekyll build
```

Expected: build succeeds

**Step 6: Commit**

```bash
git add _drafts/2026-04-01-market-microstructure-short-covering-liquidity.md
git commit -m "docs: add market microstructure series draft"
```

### Task 5: 기존 short covering 글 처리 보류 상태 명시

**Files:**
- Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-oi-short-covering-explained.md`

**Step 1: 파일이 존재하면 상태 주석 또는 front matter 메모 추가**

예시:

```yaml
series_status: reference_only
```

또는 본문 상단 메모:

```text
이 글은 이후 시리즈 3편 통합 재료로 유지합니다.
```

**Step 2: 공개 유지 여부 판단 전까지 삭제 금지**

이 단계에서는 archive/delete 하지 않는다.

**Step 3: 빌드 검증**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
bundle exec jekyll build
```

Expected: build succeeds

**Step 4: Commit**

```bash
git add _drafts/2026-04-01-oi-short-covering-explained.md
git commit -m "docs: mark short covering draft as reference"
```

### Task 6: 시리즈 간 링크와 메타 정리

**Files:**
- Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-futures-options-basics.md`
- Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-trading-basics-volume-tick-orderbook.md`
- Modify: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-market-microstructure-short-covering-liquidity.md`

**Step 1: 제목/설명 중복 점검**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
rg -n "^title:|^description:" _drafts/2026-04-01-*.md
```

Expected: 세 글이 서로 다른 설명과 역할을 가진다.

**Step 2: 시리즈 연결 문장 최종 정리**

정리 대상:
- 1편 → 2편
- 2편 → 3편
- 3편 → 1편 또는 시리즈 종결

**Step 3: 최종 빌드**

Run:

```bash
cd /Users/chuck/Workspace/blog.chuckpark.kr
bundle exec jekyll build
```

Expected: build succeeds

**Step 4: 최종 Commit**

```bash
git add _drafts/2026-04-01-*.md
git commit -m "docs: connect futures series drafts"
```

### Task 7: 배포 및 리뷰 체크리스트

**Files:**
- Check: `/Users/chuck/Workspace/blog.chuckpark.kr/_drafts/2026-04-01-*.md`

**Step 1: 배포 전 확인**

체크리스트:
- 시리즈 순서가 1편 → 2편 → 3편으로 자연스럽다
- 각 글의 도입이 서로 중복되지 않는다
- 3편이 2편의 확장처럼 읽힌다
- 기존 `oi-short-covering-explained`의 역할이 애매하게 남지 않는다

**Step 2: push**

```bash
git push origin master
```

**Step 3: 공개 후 확인**

확인 대상:
- 글 3개 permalink
- RSS 반영
- internal link 동작

**Step 4: 후속 결정**

결정 항목:
- `2026-04-01-oi-short-covering-explained.md` 유지
- archive
- 삭제
