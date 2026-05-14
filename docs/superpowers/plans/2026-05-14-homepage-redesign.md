# Homepage Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the homepage hero lede to lead with the three-way skill intersection, and replace the three signpost cards with four richer cards that each include a problem-framing sentence.

**Architecture:** Single file edit to `index.qmd`. The masthead `.masthead-lede` div gets new prose; the `.signposts` block gets four `.signpost` divs instead of three, each with a label, heading link, and one-sentence problem framing. No CSS changes needed — the existing `.signpost` styles support four cards.

**Tech Stack:** Quarto (static site generator), HTML-in-Markdown via `{=html}` fences and Quarto divs, Bootstrap utility classes via Cosmo theme.

---

### Task 1: Rewrite the hero lede

**Files:**
- Modify: `index.qmd` lines 88–90

- [ ] **Step 1: Open `index.qmd` and locate the `.masthead-lede` div**

It currently reads (lines 88–90):
```markdown
::: {.masthead-lede}
I build **hierarchical models** for longitudinal and survival data — currently patient-level *digital twins* of oncology tumor dynamics at AstraZeneca. Prior work spans field experiments in East Africa and South Asia, real-estate market design, and reinforcement learning for intervention policy.
:::
```

- [ ] **Step 2: Replace the lede text**

Replace the content of `.masthead-lede` with:
```markdown
::: {.masthead-lede}
I sit at the intersection of **causal inference**, **Bayesian hierarchical modeling**, and **agentic tooling** — a combination that's rare in pharma. Right now that means patient-level *digital twins* of oncology tumor dynamics at AstraZeneca: joint longitudinal-survival models that borrow across trials to support Phase 3 initiation decisions. Before that: field experiments in Kenya and South Asia, real-estate market design, and RL for intervention policy.
:::
```

- [ ] **Step 3: Verify render**

```bash
quarto render index.qmd
```

Expected: no errors, `docs/index.html` updated. Open in browser and confirm the new lede text appears in the hero section.

- [ ] **Step 4: Commit**

```bash
git add index.qmd docs/index.html
git commit -m "Rewrite hero lede to lead with three-way skill intersection"
```

---

### Task 2: Replace signpost cards with four problem-framing cards

**Files:**
- Modify: `index.qmd` lines 107–133 (the `.signposts` block)

- [ ] **Step 1: Locate the `.signposts` block in `index.qmd`**

It currently reads (lines 107–133):
```markdown
::: {.signposts}

::: {.signpost}
::: {.signpost-label}
01 — Bio
:::
### [About](about.qmd)
Background, experience, and the methods I work in.
:::

::: {.signpost}
::: {.signpost-label}
02 — Projects
:::
### [Projects](projects.qmd)
Digital-twin tumor dynamics, multistate survival, LFO-CV, agentic Bayesian workflows.
:::

::: {.signpost}
::: {.signpost-label}
03 — Papers
:::
### [Research](research.qmd)
Peer-reviewed and working papers on migration, incentives, and social norms.
:::

:::
```

- [ ] **Step 2: Replace the entire `.signposts` block**

```markdown
::: {.signposts}

::: {.signpost}
::: {.signpost-label}
01 — Bio
:::
### [About](about.qmd)
How an economist ends up building digital twins: field experiments, causal inference, and the path to pharma.
:::

::: {.signpost}
::: {.signpost-label}
02 — Projects
:::
### [Projects](projects.qmd)
Six technical projects: predicting Phase 3 outcomes from Phase 2 tumor dynamics, decomposing competing risks in survival data, and building agentic tooling for Bayesian modeling teams.
:::

::: {.signpost}
::: {.signpost-label}
03 — Research
:::
### [Research](research.qmd)
Peer-reviewed work on migration, social norms, and incentive design — where the causal-inference instincts were trained.
:::

::: {.signpost}
::: {.signpost-label}
04 — Writing
:::
### [Writing](writing/index.qmd)
Methodological notes on Bayesian modeling, survival analysis, and the tools I work in.
:::

:::
```

- [ ] **Step 3: Verify render**

```bash
quarto render index.qmd
```

Expected: no errors. Open `docs/index.html` in browser and confirm:
- Four cards visible
- Each has a problem-framing sentence (not a keyword list)
- Writing card links correctly to `/writing/`

- [ ] **Step 4: Commit**

```bash
git add index.qmd docs/index.html
git commit -m "Replace signpost cards with four problem-framing cards"
```
