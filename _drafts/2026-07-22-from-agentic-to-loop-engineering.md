---
title: "Agentic Engineering에서 Loop Engineering까지: 병목은 어떻게 이동했나"
categories:
  - engineering
tags:
  - agentic-engineering
  - harness-engineering
  - loop-engineering
  - agentic-coding
  - orchestration
  - multi-agent
excerpt: "코딩 에이전트와 일하는 방식이 agentic engineering, harness engineering, loop engineering으로 이동해온 흐름을 정리하고, 각 단계에서 무엇이 병목이었는지, 저는 각 단계에서 무엇을 만들었는지 이야기합니다."
---

어느 순간부터 프롬프트를 잘 쓰는 것이 더 이상 병목이 아니었습니다.

에이전트는 이미 코드를 잘 작성합니다. 좋은 모델에 좋은 지시를 주면 웬만한 구현은 끝납니다. 그런데도 제 하루는 여전히 바빴습니다. 무엇이 바쁘게 만드는지 들여다보니, 시기마다 그 대상이 달랐습니다.

처음에는 **에이전트에게 무엇을 어떻게 시킬지**가 일이었습니다. 그 다음에는 **에이전트가 일하는 환경을 정비하는 것**이 일이 되었습니다. 지금은 **제가 개입하는 방식 자체를 설계하는 것**이 일이 되고 있습니다.

저는 이 흐름을 세 단계로 정리하고 있습니다.

```text
agentic engineering
  -> 사람이 매 턴 지시하고 판단한다
  -> engineering의 대상: 프롬프트와 코드

harness engineering
  -> 에이전트가 일하는 환경을 만든다
  -> engineering의 대상: 문서, 도구, 검증 구조

loop engineering
  -> 사람의 개입 자체를 설계한다
  -> engineering의 대상: 상태 전이와 피드백 루프
```

각 단계는 이전 단계를 대체하지 않습니다. 이전 단계의 병목이 다음 단계를 불렀습니다. "병목의 이동"이라는 표현은 제가 이 글을 위해 정리한 프레임이지만, 세 용어 자체는 모두 실제로 쓰이는 용어입니다. 먼저 그 연대기부터 짚고 시작하겠습니다.

## 세 용어는 실제로 이 순서로 태어났습니다

흥미롭게도 세 용어가 명명된 순서는 제가 겪은 순서와 같습니다. 모두 2026년의 일입니다.

| 시기 | 용어 | 주요 계기 |
| --- | --- | --- |
| 2026년 2월 | agentic engineering | Andrej Karpathy가 vibe coding의 대립항으로 제안, Simon Willison·Addy Osmani가 채택 |
| 2026년 2월 | harness engineering | OpenAI가 [Harness engineering](https://openai.com/index/harness-engineering/)을 공개, martinfowler.com이 정식화 |
| 2026년 6월 | loop engineering | Boris Cherny·Peter Steinberger의 발언이 확산된 뒤 Addy Osmani가 [명명](https://addyosmani.com/blog/loop-engineering/) |

한 가지 미리 밝혀둘 것이 있습니다. agentic engineering은 좁게는 첫 번째 단계를 가리키지만, 넓게는 에이전트로 소프트웨어를 만드는 활동 전체를 가리키는 umbrella term으로도 쓰입니다. Karpathy와 Willison이 말하는 agentic engineering은 후자에 가깝습니다. 이 글에서는 흐름을 대비시키기 위해 **사람이 매 턴 개입하는 초기 단계**라는 좁은 의미로 사용합니다.

## 1단계: Agentic Engineering — 에이전트에게 일을 시키다

첫 번째 단계는 에이전트가 구현을 담당하고 사람이 매 턴 지시와 판단을 담당하는 방식입니다.

Karpathy는 vibe coding과 대비하며 이렇게 표현했습니다.

> Vibe coding raises the floor. Agentic engineering is about extrapolating the ceiling.

결과를 검증하지 않고 분위기로 코드를 받아들이는 vibe coding과 달리, agentic engineering에서는 사람이 아키텍처와 품질과 정합성을 소유합니다. 구현은 에이전트가 하지만 매 턴의 방향 결정과 결과 검토는 사람의 일입니다.

저의 이 시기는 Claude Code와 Codex에게 작업 단위로 지시하고, diff를 읽고, 다음 지시를 만드는 반복이었습니다. 생산성은 분명히 올랐습니다. 혼자서는 미루던 작업들이 하루 안에 끝나기 시작했습니다.

그런데 곧 이상한 점이 보였습니다. 같은 실수를 매번 다시 교정하고 있었습니다. 커밋 메시지 규칙, 검증 명령, 문서 위치, PR 크기. 세션이 바뀌면 에이전트는 다시 백지가 되었고, 저는 같은 맥락을 다시 프롬프트로 설명했습니다.

이 단계의 병목은 명확했습니다. **모든 턴에 사람의 판단이 필요하고, 그 판단의 대부분이 반복이라는 것**입니다.

## 2단계: Harness Engineering — 에이전트의 환경을 만들다

두 번째 단계의 핵심은 관점의 전환입니다. 에이전트의 실패를 더 좋은 프롬프트로 고치는 것이 아니라, 실패가 재발하지 않는 **환경**으로 고치는 것입니다.

이 담론에서 harness는 모델을 제외한 에이전트의 나머지 전부를 뜻합니다. martinfowler.com의 [Harness Engineering](https://martinfowler.com/articles/harness-engineering.html) 글은 이를 간단한 등식으로 정리합니다.

```text
Agent = Model + Harness

Harness
  -> system prompt, AGENTS.md 같은 문서
  -> 에이전트가 쓸 수 있는 도구와 명령
  -> lint, test, CI 같은 검증 장치
  -> 작업 규칙과 피드백 구조
```

Mitchell Hashimoto의 원칙이 이 단계의 태도를 가장 잘 보여줍니다.

> Anytime you find an agent makes a mistake, you take the time to engineer a solution such that the agent never makes that mistake again.

OpenAI의 [Harness engineering](https://openai.com/index/harness-engineering/)은 이 방식의 밀도를 보여준 사례입니다. 소수의 엔지니어가 사람 손으로 코드를 거의 작성하지 않고 Codex와 함께 내부 제품을 만들었는데, 그 비결은 더 정교한 프롬프트가 아니라 저장소 문서 구조, 도구, 검증 루프의 개선이었습니다.

저의 이 시기 결과물이 `chuck-ai-harness`와 chuck-skills입니다. 새 프로젝트가 따라야 할 문서 구조, Git과 PR 규칙, 리뷰 레벨, 검증 명령을 저장소가 소유하는 `AGENTS.md`와 `WORKFLOW.md`로 정리했습니다. 역할별 작업 방법은 skill로 만들어 재사용했습니다. 에이전트가 실수하면 프롬프트를 다듬는 대신 하네스를 고쳤습니다.

효과는 분명했습니다. 세션이 바뀌어도 같은 설명을 반복하지 않게 되었고, 개별 작업의 품질이 안정되었습니다.

하지만 새로운 병목이 드러났습니다. 계획, 계획 검토, 구현, 코드 리뷰, 수정, 재검토로 이어지는 실제 개발 흐름에서 **각 단계는 잘 동작해도 다음 단계를 누가 시작할지는 여전히 제가 결정하고 있었습니다.** "이제 구현해줘", "새로운 컨텍스트에서 리뷰해줘"를 반복하는 저는 에이전트 사이의 메시지 전달자였습니다.

하네스는 "이 저장소에서 어떻게 일해야 하는가"를 알려줄 뿐, "지금 누구의 차례인가"를 판단하지 않습니다.

<!-- IMAGE NOTE
purpose: 세 단계에서 engineering 대상과 병목이 이동하는 것을 한눈에 보여주기 위함
suggestion: 가로 3열(agentic/harness/loop) 다이어그램. 각 열에 위에는 engineering 대상(프롬프트와 코드 / 환경 / 개입 방식), 아래에는 병목(매 턴 판단 / 다음 차례 연결 / 검증과 신뢰)을 두고, 병목이 다음 열의 대상으로 화살표로 이어지는 구조
placement: "하네스는 ... 판단하지 않습니다" 문단 뒤
-->

## 3단계: Loop Engineering — 개입 자체를 설계하다

세 번째 단계는 지금 막 형성되고 있는 흐름입니다. 사람이 에이전트에게 프롬프트를 보내는 행위 자체를 시스템으로 대체하는 것입니다.

Claude Code를 만든 Boris Cherny의 표현이 이 단계를 상징합니다.

> I don't prompt Claude anymore. I have loops running that prompt Claude.

Peter Steinberger는 같은 방향을 더 직접적으로 말합니다.

> You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents.

원형은 단순합니다. Geoffrey Huntley의 [Ralph](https://ghuntley.com/ralph/)는 프롬프트 파일을 에이전트에게 반복해서 먹이는 bash loop 하나였습니다. 여기서 출발한 흐름이 지금은 구조화되고 있습니다. OpenAI의 [Symphony SPEC](https://github.com/openai/symphony/blob/main/SPEC.md)처럼 Issue tracker에서 작업을 읽고, 격리된 workspace를 만들고, 저장소가 소유한 규칙을 불러와 에이전트를 실행하고, 사람에게는 handoff 상태로 전달하는 장기 실행 서비스까지 등장했습니다.

이 단계에서 사람이 설계하는 것은 개별 프롬프트가 아닙니다.

```text
loop engineering에서 설계하는 것
  -> 작업 계약: 목표, 범위, 완료 조건, 검증 방법
  -> 상태 전이: 어떤 조건에서 다음 역할이 실행되는가
  -> 개입 지점: 어디까지 자동이고 어디부터 사람인가
```

작업을 계약 형태로 잘 정의해두면, 각 에이전트는 사람의 감독 없이 혹은 최소한의 개입으로 다음 단계를 이어갑니다. 사람은 루프 안의 전달자에서 루프 밖의 설계자로 이동합니다.

저의 이 시기 시도가 `chuck-orchestrator`입니다. GitHub Issue 하나를 계약으로 삼아 Developer 에이전트와 독립 Reviewer 에이전트가 주고받은 뒤, 자동 merge 없이 사람이 검토할 Draft PR까지 전달하는 orchestration loop입니다. 성공 상태를 `Done`이 아니라 `Human Review`로 정의한 것이 핵심입니다. 이 설계는 다음 글에서 자세히 다루겠습니다.

물론 이 단계에도 병목은 있습니다. 오히려 더 어려운 병목입니다. 루프가 사람 없이 돌수록 **검증과 신뢰**가 문제의 중심이 됩니다. 에이전트의 자체 보고를 믿을 수 있는가, 리뷰는 충분히 독립적인가, 실패했을 때 어디서 멈췄는지 알 수 있는가. 그리고 루프에 넣을 **작업 계약의 품질**이 결과 품질의 상한이 됩니다. 모호한 Issue를 루프에 넣으면 모호한 결과가 반복될 뿐입니다.

Armin Ronacher가 [The Coming Loop](https://lucumr.pocoo.org/2026/6/23/the-coming-loop/)에서 지적했듯, 루프는 새로운 만능이 아니라 검증 없이 돌리면 쓰레기를 양산하는 증폭기이기도 합니다. 루프를 돌리는 것 자체는 쉽습니다. 어려운 것은 루프가 만든 결과를 사람이 신뢰할 수 있게 만드는 구조입니다.

## 사람의 일은 사라지지 않고 이동합니다

세 단계를 지나며 제 역할은 이렇게 이동했습니다.

```text
agentic engineering
  -> 구현 지시자: 매 턴 지시하고 diff를 판단

harness engineering
  -> 규칙 설계자: 저장소의 문서, 도구, 검증 구조를 소유

loop engineering
  -> 계약 설계자와 승인자: 목표를 정의하고 최종 판단
```

주의할 것은 이것이 사다리가 아니라는 점입니다. 지금도 저는 세 방식을 모두 사용합니다. 탐색적인 작업은 매 턴 대화하며 진행하고, 반복되는 실수는 하네스로 고정하고, 계약이 명확한 작업만 루프에 넣습니다. 단계가 올라갈수록 자유도가 줄어드는 대신 사람의 시간이 덜 들기 때문에, **어떤 작업을 어느 단계에 배치할지 판단하는 것** 자체가 새로운 기술이 됩니다.

프롬프트를 잘 쓰는 것에서 시작한 일이, 에이전트의 환경을 만드는 일이 되었고, 이제는 사람의 개입을 설계하는 일이 되었습니다. 병목은 사라지지 않고 이동합니다. 다음 병목은 검증과 신뢰입니다.

다음 글에서는 이 세 번째 단계의 첫 구현인 Chuck Orchestrator ver.1을 다룹니다. 하나의 GitHub Issue가 사람의 개입 없이 Developer와 Reviewer를 거쳐 Human Review까지 도착하는 구조입니다.

## 참고한 자료

- [Addy Osmani, Agentic Engineering](https://addyosmani.com/blog/agentic-engineering/)
- [Simon Willison, Agentic Engineering Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/what-is-agentic-engineering/)
- [OpenAI, Harness engineering](https://openai.com/index/harness-engineering/)
- [Birgitta Böckeler, Harness Engineering (martinfowler.com)](https://martinfowler.com/articles/harness-engineering.html)
- [Anthropic, Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Addy Osmani, Loop Engineering](https://addyosmani.com/blog/loop-engineering/)
- [Geoffrey Huntley, Ralph](https://ghuntley.com/ralph/)
- [OpenAI Symphony SPEC](https://github.com/openai/symphony/blob/main/SPEC.md)
- [Armin Ronacher, The Coming Loop](https://lucumr.pocoo.org/2026/6/23/the-coming-loop/)
- [Steve Yegge, Revenge of the Junior Developer](https://sourcegraph.com/blog/revenge-of-the-junior-developer)
