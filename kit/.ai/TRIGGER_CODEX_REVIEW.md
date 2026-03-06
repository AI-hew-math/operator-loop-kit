완전한 REVIEW+ADVANCE 절차 (Brain/Codex)

1) main 최신화
git checkout main && git pull origin main

2) ai/claude 가져오기
git fetch origin ai/claude:ai/claude
git checkout ai/claude

3) RUN_ID / transcript 확인
RUN_ID=$(cat .ai/LAST_RUN_ID | tr -d '[:space:]')
test -f .ai/transcripts/claude_${RUN_ID}.md && test -s .ai/transcripts/claude_${RUN_ID}.md

4) 리뷰 근거 수집
git diff origin/main...ai/claude
transcript 요약(의도/명령/출력/편차)을 3~6줄로 정리

5) 재현 실행(필수)
make test; echo EXIT=$?

6) 승인 파일 생성(필수)
.ai/approvals/${RUN_ID}.approved 를 생성하고 아래 최소 항목을 포함:
- verdict: APPROVE
- run_id: ${RUN_ID}
- reviewed_commit: <ai/claude HEAD SHA>
- base: <origin/main SHA>
- commands_run: make test (EXIT + 실제 출력 핵심 1~3줄)
- notes: 근거 1~3줄

7) 승인 커밋 -> ai/claude 푸시
git add .ai/approvals/${RUN_ID}.approved
git commit -m "approve: ${RUN_ID}"
git push origin ai/claude

8) main 머지 + gate 확인 + push
git checkout main
git merge --no-ff ai/claude
./scripts/ai_gate.sh  # OK 아니면 즉시 중단: origin/main push 금지
git push origin main

9) 다음 사이클 준비
.ai/PLAN.md / .ai/HANDOFF_TO_CLAUDE.md / .ai/STATE.md 갱신 후 main에 커밋/푸시

마지막 줄: CYCLE_COMPLETE_READY_FOR_CLAUDE
