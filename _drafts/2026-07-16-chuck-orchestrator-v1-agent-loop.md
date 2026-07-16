---
title: "Chuck Orchestrator ver.1: 하나의 GitHub Issue를 Human Review까지 이어주는 Agent Loop"
categories:
  - engineering
tags:
  - agentic-coding
  - orchestration
  - codex
  - github
  - git-worktree
  - multi-agent
excerpt: "Harness와 Skill만으로는 이어지지 않던 Developer와 Reviewer의 다음 행동을 GitHub Issue, 독립 Worktree, 저장소 소유 WORKFLOW.md로 연결한 첫 번째 오케스트레이션 설계입니다."
---

에이전트를 활용해 개발하다 보면 어느 순간부터 코드를 잘 작성하는 것보다 다른 문제가 더 크게 보이기 시작합니다.

계획을 세우는 Agent가 있고, 구현하는 Agent가 있고, 변경 내용을 검토하는 Agent도 있습니다. 각 역할에 맞는 문서와 Skill을 준비하면 개별 작업의 품질은 분명히 좋아집니다.

그런데 실제 개발은 역할 하나로 끝나지 않습니다.

```text
계획
  -> 계획 검토
  -> 개발
  -> 코드 리뷰
  -> 수정
  -> 재검토
  -> 사람의 최종 판단
```

각 단계는 잘 동작해도 다음 단계를 누가 시작할지는 여전히 사람이 결정하고 있었습니다.

저는 이 문제를 `chuck-ai-harness`를 직접 관리하면서 더 선명하게 느꼈습니다. 새 프로젝트가 따라야 할 문서 구조, Git/PR 규칙, 리뷰 레벨, 검증 명령을 정리했지만 정작 그 하네스 자체를 수정할 때는 제가 Agent에게 다음 행동을 계속 알려주고 있었습니다.

“계획을 검토해줘.”

“이제 구현해줘.”

“새로운 컨텍스트에서 리뷰해줘.”

“리뷰 결과를 반영하고 다시 확인해줘.”

이 정도면 여러 Agent가 협업하는 시스템이라기보다, 사람이 Agent 사이에서 메시지를 전달하는 시스템에 가까웠습니다.

여기서 필요했던 것이 orchestration layer였습니다.

## 하네스만으로는 연결되지 않는 것

처음에는 필요한 개발 규칙을 모두 Skill로 만들면 되는지 고민했습니다. 새 프로젝트를 시작할 때 Skill을 불러오고, 계획·개발·리뷰 Skill을 순서대로 실행하면 충분해 보였습니다.

하지만 Skill과 orchestration은 해결하는 문제가 다릅니다.

```text
chuck-ai-harness
  -> 저장소가 지켜야 할 구조, 정책, 문서, 검증 기준

skills
  -> 특정 역할이 일을 수행하는 방법

chuck-orchestrator
  -> 지금 누구의 차례인지 판단하고 다음 역할을 실행

CI와 Reviewer
  -> 결과가 계약을 만족하는지 독립적으로 검증

human
  -> 목표 승인, 새로운 결정, 고위험 판단, 최종 merge
```

하네스는 “이 저장소에서 어떻게 일해야 하는가”를 알려줍니다. Skill은 “이 종류의 일을 어떻게 수행하는가”를 알려줍니다. 그러나 둘 다 “Developer가 끝났으니 이제 Reviewer를 실행해야 한다”는 상태 전이를 책임지지는 않습니다.

그래서 `chuck-ai-harness`를 없애고 모든 것을 오케스트레이터로 옮기는 방향은 선택하지 않았습니다. 오히려 저장소의 규칙과 실행 조정을 분리하기로 했습니다.

이 구분은 OpenAI의 [Harness Engineering](https://openai.com/index/harness-engineering/)에서 설명하는 방향과도 맞닿아 있습니다. 거대한 `AGENTS.md` 하나에 모든 내용을 넣기보다 짧은 안내 문서가 구조화된 저장소 문서를 가리키게 하고, 실패를 더 강한 프롬프트가 아니라 도구·문서·검증 구조의 개선으로 되돌리는 방식입니다.

<!-- IMAGE NOTE
purpose: Harness, Skill, Orchestrator, Reviewer, Human의 책임이 겹치지 않는다는 점을 한눈에 보여주기 위함
suggestion: 아래에서 위로 chuck-ai-harness(정책) -> skills(역할별 실행법) -> chuck-orchestrator(상태 연결) -> reviewer/CI(검증) -> human(승인)이 쌓인 레이어 다이어그램
placement: "하네스만으로는 연결되지 않는 것" 섹션의 역할 구분 설명 뒤
-->

## GitHub를 작업 상태의 기준으로 삼았습니다

오케스트레이터가 생기면 별도의 작업 데이터베이스가 필요할 것처럼 보입니다. 하지만 첫 버전에서는 새로운 상태 저장소를 만들지 않기로 했습니다.

이미 실제 개발 작업은 GitHub Issue와 Pull Request에 남아 있기 때문입니다.

Issue에는 목표, 범위, 제외 범위, 완료 조건, 검증 방법을 적습니다. PR에는 실제 diff, commit, 검증 결과, review comment가 남습니다. 사람이 최종적으로 확인하는 장소도 GitHub입니다.

따라서 첫 버전에서는 GitHub Issue label을 작업 제어 상태로 사용합니다.

| 상태 | 의미 | 다음 주체 |
| --- | --- | --- |
| `agent:ready` | 요구사항과 검증 기준이 준비됨 | Orchestrator |
| `agent:running` | Developer가 작업 중 | Developer |
| `agent:review` | 최신 변경의 독립 검토가 필요함 | Reviewer |
| `agent:human-review` | Agent 검토가 끝나 사람의 판단이 필요함 | Human |
| `agent:blocked` | 자동으로 결정하거나 복구할 수 없음 | Planner 또는 Human |

완료를 뜻하는 `agent:done` label은 만들지 않습니다. PR이 merge되고 Issue가 닫히는 기존 GitHub 흐름을 완료 상태로 그대로 사용합니다.

여기서 label은 Reviewer Finding의 세부 상태까지 표현하지 않습니다. `IMPLEMENTATION_DEFECT`, `TEST_OR_DOC_GAP`, `REVIEWER_VERIFIED` 같은 세부 기록은 PR comment와 연결된 Task에 남깁니다. label은 오직 지금 누가 행동해야 하는지만 보여줍니다.

## WORKFLOW.md는 대상 저장소가 소유합니다

오케스트레이터가 여러 프로젝트를 관리하기 시작하면 모든 프로젝트의 규칙을 중앙 설정으로 모으고 싶어집니다. 하지만 그렇게 하면 오케스트레이터가 각 저장소보다 더 많은 프로젝트 지식을 가져야 합니다.

저는 반대 방향을 선택했습니다.

```text
plant-farming/WORKFLOW.md
  -> plant-farming의 작업·검증·리뷰 규칙

chuck-ai-harness/WORKFLOW.md
  -> chuck-ai-harness의 작업·검증·리뷰 규칙

chuck-orchestrator/WORKFLOW.md
  -> chuck-orchestrator 자체의 작업 규칙
```

각 저장소가 루트의 `WORKFLOW.md`를 직접 소유하고 version control합니다. 오케스트레이터는 이 파일을 읽을 뿐, 생성하거나 덮어쓰지 않습니다.

이 경계는 OpenAI가 공개한 [Symphony SPEC](https://github.com/openai/symphony/blob/main/SPEC.md)에서 참고했습니다. Symphony는 Issue tracker에서 작업을 읽고, Issue별 격리 workspace를 만들고, 저장소가 소유한 `WORKFLOW.md`에서 Agent prompt와 runtime 정책을 불러오는 장기 실행 서비스입니다. 성공 상태 역시 반드시 `Done`일 필요 없이 `Human Review` 같은 handoff 상태가 될 수 있습니다.

다만 Chuck Orchestrator가 Symphony를 사용하는 것은 아닙니다. Symphony의 현재 명세는 Linear 중심이고, polling·동시 실행·재시도·reconciliation까지 포함한 장기 실행 서비스입니다. 제가 첫 번째로 확인하고 싶은 것은 더 작았습니다.

> GitHub Issue 하나를 Developer와 Reviewer가 실제로 주고받은 뒤, 사람이 볼 수 있는 Draft PR까지 안정적으로 전달할 수 있는가?

따라서 Symphony의 구조적 원칙만 참고하고 구현 범위는 일회 실행 CLI로 줄였습니다.

## Worktree는 대상 프로젝트에서 파생됩니다

처음 구조를 그릴 때 가장 헷갈렸던 부분은 Worktree가 어느 프로젝트에 속하는가였습니다.

`chuck-orchestrator`가 Worktree를 생성하니 오케스트레이터 프로젝트의 일부처럼 느껴집니다. 그러나 Worktree 안에 있는 파일과 branch는 작업 대상 저장소의 것입니다.

```text
/Users/openclaw/Workspace/chuck-orchestrator
  -> 오케스트레이터 프로그램의 소스

/Users/openclaw/.local/share/chuck-orchestrator/
  repos/github.com/chuck-park/chuck-ai-harness
    -> 오케스트레이터가 관리하는 기준 clone

  worktrees/github.com/chuck-park/chuck-ai-harness/issue-42
    -> chuck-ai-harness에서 파생된 Issue 전용 Worktree
```

Developer Codex의 현재 작업 디렉터리는 마지막 Worktree입니다. 그 안에는 대상 저장소에서 checkout된 `AGENTS.md`, `WORKFLOW.md`, `README.md`, 소스 코드가 있습니다.

이 구조를 선택한 이유는 사용자가 직접 사용하는 `/Workspace/chuck-ai-harness` checkout을 건드리지 않기 위해서입니다. 대상 저장소 안의 `.worktrees/`에 넣는 방법도 있지만, 구조 검사나 파일 검색, IDE 인덱싱이 Worktree 내부까지 훑는 문제가 생길 수 있습니다. 오케스트레이터 전용 runtime 경로에 모아두면 생성·보존·정리 책임도 명확해집니다.

<!-- IMAGE NOTE
purpose: chuck-orchestrator 소스 저장소와 대상 저장소의 기준 clone, Worktree, 사용자 checkout 관계를 명확히 보여주기 위함
suggestion: 왼쪽에 /Workspace/chuck-orchestrator, 오른쪽에 /Workspace/chuck-ai-harness 사용자 checkout, 아래에 ~/.local/share/chuck-orchestrator/repos와 worktrees를 배치하고 Worktree가 chuck-ai-harness에서 파생됨을 점선으로 표시
placement: Worktree 경로 예시 다음
-->

## Developer와 Reviewer는 같은 일을 하지 않습니다

여러 Agent를 쓴다고 해서 모든 역할이 파일을 수정할 수 있게 하지는 않았습니다.

Developer는 Issue와 저장소 규칙을 읽고 Worktree 파일을 수정합니다. 자체 검증도 실행합니다. 하지만 commit, push, PR 생성, label 변경은 하지 않습니다.

Reviewer는 Developer의 세션을 이어받지 않습니다. 매 review round마다 새로운 context에서 원본 Issue, `WORKFLOW.md`, 기준 branch와 최신 head의 전체 diff, 검증 결과를 읽습니다. 저장소는 read-only로 봅니다.

Git commit, push, Draft PR 생성, GitHub comment, label 변경은 오케스트레이터만 담당합니다.

```text
Developer Codex
  -> 파일 수정
  -> 자체 검증

Chuck Orchestrator
  -> 검증 명령 재실행
  -> commit
  -> push
  -> Draft PR 생성
  -> label 변경

Reviewer Codex
  -> 최신 전체 diff 독립 검토
  -> PASS 또는 Reviewer Finding 반환
```

이렇게 나눈 이유는 Agent의 판단과 외부 상태 변경을 분리하기 위해서입니다. Developer가 예상하지 못한 branch를 만들거나 PR 상태를 바꾸는 일을 줄이고, 오케스트레이터가 재실행할 때 이미 끝난 작업을 확인하기도 쉬워집니다.

Anthropic의 [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)에서는 한 모델이 결과를 만들고 다른 모델이 평가와 피드백을 제공하는 반복을 evaluator-optimizer 패턴으로 설명합니다. 이번 Developer–Reviewer 구조는 이 패턴에 가깝습니다. 평가 기준이 문서와 검증 명령으로 명확하고, Reviewer의 피드백으로 결과를 개선할 수 있을 때 잘 맞습니다.

## Chuck Orchestrator ver.1의 실제 흐름

첫 실행은 상시 서비스가 아니라 명시적으로 시작하는 명령입니다.

```bash
chuck-orchestrator run \
  --repo chuck-park/chuck-ai-harness \
  --issue 42
```

실행 흐름은 다음과 같습니다.

```text
1. Issue #42와 agent:ready 확인
2. 대상 저장소의 WORKFLOW.md 로드
3. Issue 전용 branch와 Worktree 생성
4. Developer Codex 실행
5. WORKFLOW.md의 검증 명령 재실행
6. commit, push, Draft PR 생성
7. agent:review로 변경
8. 새로운 Reviewer Codex 실행
9. finding이 있으면 기존 Developer 세션 재개
10. 최대 2회까지 수정과 재검토 반복
11. 통과하면 agent:human-review로 변경
12. 자동 merge 없이 종료
```

중간에 실패하면 Issue별 상태 JSON에 branch, Worktree, PR 번호, Developer session ID, review round, 마지막 head SHA를 남깁니다. 같은 명령을 다시 실행하면 이미 존재하는 clone, Worktree, branch, commit, PR을 확인하고 마지막으로 안전하게 끝난 단계부터 이어갑니다.

동일 Issue가 두 번 실행되는 것은 lock으로 막습니다. 세 번째 수정 요청이 필요하거나, 새로운 제품 결정이 필요하거나, 자동 복구할 수 없는 Git 충돌이 생기면 `agent:blocked`에서 멈춥니다.

중요한 것은 실패하지 않는 시스템이 아니라 실패했을 때 어디서 멈췄는지 알 수 있는 시스템입니다.

<!-- IMAGE NOTE
purpose: GitHub label과 Developer, Orchestrator, Reviewer, Human의 순차 실행 및 수정 왕복을 한눈에 보여주기 위함
suggestion: GitHub Issue, Orchestrator, Developer Worktree, Reviewer, Human을 세로 lane으로 두고 ready -> running -> review -> running -> review -> human-review 메시지를 표시한 sequence diagram
placement: 전체 실행 단계 목록 다음
-->

## 첫 번째 작업은 README 한 곳만 바꿉니다

오케스트레이터를 만들면 처음부터 복잡한 기능 개발에 적용해보고 싶어집니다. 하지만 첫 파일럿은 `chuck-ai-harness`의 README 문서 수정으로 정했습니다.

Issue의 목표는 단순합니다.

```text
README에서 planner, developer, reviewer 분업 기준을
쉽게 찾을 수 있도록 agent development workflow 링크와
한 문장의 설명을 추가한다.
```

변경 범위는 `README.md` 한 파일입니다. `AGENTS.md`, workflow 정본, 스크립트, scaffold 출력은 수정하지 않습니다. 검증은 구조 검사와 `git diff --check`입니다.

원래 이런 문서 수정은 위험도가 낮아 독립 Reviewer를 생략할 수도 있습니다. 이번에는 결과물보다 orchestration loop 자체를 검증하는 것이 목적이므로 의도적으로 Reviewer를 실행합니다.

확인하려는 것은 다음과 같습니다.

- 사용자 checkout을 건드리지 않고 외부 Worktree에서 작업하는가
- Developer와 Reviewer가 서로 다른 context에서 실행되는가
- Developer 결과를 믿지 않고 오케스트레이터가 검증을 다시 실행하는가
- 실제 Draft PR과 GitHub comment가 생성되는가
- Reviewer가 통과시키면 자동 merge하지 않고 사람에게 넘기는가
- 중간 실패 후 같은 명령으로 중복 없이 재개되는가

Reviewer가 문제를 찾지 않는다면 억지로 오류를 만들지는 않습니다. 실제 finding 수정 왕복은 자동화 테스트로 검증하고, 파일럿에서 finding이 발생하면 같은 Developer session을 재개하는 흐름까지 관찰합니다.

<!-- IMAGE NOTE
purpose: 추상적인 시스템 설명을 실제 README 문서 수정 사례로 연결하기 위함
suggestion: Issue #42의 Goal/Scope/Acceptance Criteria 카드에서 Worktree의 README 수정, 검증, Draft PR, Human Review로 이어지는 4단계 예시 흐름
placement: 첫 파일럿에서 확인할 항목 목록 뒤
-->

## 처음부터 멀티에이전트 플랫폼을 만들지 않는 이유

처음 구상은 더 컸습니다. Planner가 Task를 나누고, 여러 Developer가 병렬로 구현하고, Reviewer가 결과를 검토하고, 실패하면 자동 재시도하는 시스템을 떠올렸습니다.

하지만 그렇게 시작하면 정작 중요한 수직 흐름보다 scheduler, concurrency, token budget, stall detection, dashboard 같은 운영 기능을 먼저 만들게 됩니다.

GitHub의 [Agentic Workflows](https://github.github.com/gh-aw/)도 검토했습니다. 자연어 Markdown을 GitHub Actions workflow로 만들고, read-only token, sandbox, safe output 같은 guardrail을 제공한다는 점이 매력적입니다. Issue triage, 문서 유지보수, 정기 보고처럼 GitHub Actions 안에서 끝나는 작업이라면 좋은 출발점입니다.

다만 이번에 직접 확인하려는 것은 로컬 Mac mini의 지속 Worktree, 동일 Developer session 재개, 로컬 Codex 실행이었습니다. 그래서 첫 구현 기반을 GitHub Actions가 아니라 로컬 일회 실행 CLI로 정했습니다.

그렇다고 곧바로 Symphony 수준의 daemon을 만드는 것도 아닙니다.

Anthropic이 [멀티에이전트 리서치 시스템](https://www.anthropic.com/engineering/multi-agent-research-system)을 설명하며 지적한 것처럼 멀티에이전트는 더 많은 token과 조정 비용을 사용하고, 모든 Agent가 같은 context에 의존하는 작업에는 잘 맞지 않을 수 있습니다. 특히 코딩은 조사 작업보다 실제 병렬화할 수 있는 단위가 적습니다.

그래서 ver.1은 병렬 Agent보다 Developer 한 명과 독립 Reviewer 한 명의 수직 루프에 집중합니다.

```text
ver.1
  -> 하나의 Issue
  -> 하나의 Worktree
  -> Developer와 Reviewer의 수직 루프
  -> Human Review에서 종료

ver.2 후보
  -> agent:ready polling
  -> process 재시작 복구
  -> backoff와 stale run 감지
  -> merge 후 cleanup

ver.3 후보
  -> 여러 저장소
  -> 여러 Issue 동시 실행
  -> 우선순위와 concurrency limit
```

미래 버전을 생각하되, ver.1의 완료 조건에 필요하지 않은 추상화는 넣지 않는 것이 이번 설계의 중요한 원칙입니다.

## 자동 개발보다 먼저 확인해야 할 것

Chuck Orchestrator ver.1의 목표는 사람이 사라지는 것이 아닙니다.

사람이 반복해서 하던 연결 작업을 줄이고, 사람의 시간을 목표 승인과 새로운 결정, 고위험 검토, 최종 merge에 사용하는 것이 목적입니다.

그래서 성공 상태도 `Done`이 아니라 `Human Review`입니다.

이 설계가 실제로 증명해야 하는 것은 거대한 멀티에이전트 시스템을 만들 수 있는지가 아닙니다. 아주 작은 Issue 하나가 명확한 정책 안에서 Developer와 Reviewer를 거쳐, 중간 상태와 근거를 잃지 않고 사람 앞까지 도착할 수 있는지입니다.

그 흐름이 반복해서 안정적으로 동작한 뒤에야 polling, 병렬 작업, Planner 자동화가 의미를 갖습니다.

지금은 첫 번째 README Issue를 끝까지 보내보는 것으로 충분합니다.

## 참고한 자료

- [OpenAI Symphony SPEC](https://github.com/openai/symphony/blob/main/SPEC.md)
- [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/)
- [Anthropic Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Anthropic Multi-agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [GitHub Agentic Workflows](https://github.github.com/gh-aw/)
