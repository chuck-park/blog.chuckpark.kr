# Category Archive Detail Pages Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** `/categories`를 카테고리 목록 전용 화면으로 바꾸고, 각 카테고리 상세 페이지에서 해당 카테고리 글만 노출되게 만든다.

**Architecture:** 기존 `categories` 레이아웃은 인덱스 전용으로 축소하고, 카테고리별 정적 페이지를 `_pages/categories/` 아래에 생성한다. 상세 페이지는 기존 `category` 레이아웃과 `posts-category` include를 재사용해 선택된 카테고리 글만 렌더링한다.

**Tech Stack:** Jekyll, Liquid, YAML data/front matter, shell validation script

---

### Task 1: 실패 조건 고정

**Files:**
- Create: `test/category-pages-check.sh`

**Step 1: Write the failing test**

빌드 산출물에서 아래를 검증한다.
- `_site/categories/index.html`에는 카테고리 섹션 목록만 있고 전체 포스트 섹션이 없어야 한다.
- `_site/categories/product/index.html` 같은 카테고리 상세 페이지가 생성되어야 한다.

**Step 2: Run test to verify it fails**

Run: `bash test/category-pages-check.sh`
Expected: FAIL because category detail pages do not exist yet.

### Task 2: 카테고리 인덱스/상세 구조 구현

**Files:**
- Modify: `_layouts/categories.html`
- Modify: `_pages/category-archive.md`
- Create: `_pages/categories/*.md`

**Step 1: Make `/categories` list-only**

카테고리 이름과 카운트만 보여주고, 각 항목은 상세 페이지로 이동하게 바꾼다.

**Step 2: Add static category detail pages**

현재 사용 중인 카테고리별로 정적 페이지를 생성한다.

**Step 3: Verify build output**

Run: `bundle exec jekyll build`
Expected: `_site/categories/<slug>/index.html` files exist.

### Task 3: 검증

**Files:**
- Test: `test/category-pages-check.sh`

**Step 1: Run test to verify it passes**

Run: `bash test/category-pages-check.sh`
Expected: PASS

**Step 2: Run full build**

Run: `bundle exec jekyll build`
Expected: PASS
