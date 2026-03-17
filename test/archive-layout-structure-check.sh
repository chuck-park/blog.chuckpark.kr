#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build >/tmp/archive-layout-structure-check.log 2>&1

home_file="_site/index.html"
categories_file="_site/categories/index.html"
posts_file="_site/year-archive/index.html"
tags_file="_site/tags/index.html"

for file in "$home_file" "$categories_file" "$posts_file" "$tags_file"; do
  test -f "$file"
done

if ! rg -q '<div class="section">' "$home_file"; then
  echo "home archive should render section wrapper"
  exit 1
fi

if ! rg -q '<div class="container">' "$home_file"; then
  echo "home archive should render container wrapper"
  exit 1
fi

if ! rg -q 'col-12 col-lg-9 mb-5' "$home_file"; then
  echo "home archive cards should render column wrappers"
  exit 1
fi

if ! rg -q '<div class="row justify-content-center">' "$categories_file"; then
  echo "categories archive should render row wrapper"
  exit 1
fi

if ! rg -q '<div class="row justify-content-center">' "$posts_file"; then
  echo "posts archive should render row wrapper"
  exit 1
fi

if ! rg -q '<div class="row justify-content-center">' "$tags_file"; then
  echo "tags archive should render row wrapper"
  exit 1
fi

echo "archive layout structure check passed"
