# Homepage Redesign — Design Spec

**Date:** 2026-05-14  
**Status:** Approved

## Problem

The homepage feels thin to a cold visitor. The hero text is decent but undersells the differentiation angle. The three signpost cards are generic section links with minimal context — a visitor has to click through to understand what makes the work interesting.

## Goal

Lead with the hiring signal, then use the signpost cards to pull curious visitors deeper into the work. A cold visitor should leave with a strong first impression of the three-way intersection (digital twins + causal inference + agentic tooling) and enough concrete detail in each card to decide whether to click through.

## Changes

### 1 — Hero lede rewrite

Replace the current masthead lede with:

> I sit at the intersection of **causal inference**, **Bayesian hierarchical modeling**, and **agentic tooling** — a combination that's rare in pharma. Right now that means patient-level *digital twins* of oncology tumor dynamics at AstraZeneca: joint longitudinal-survival models that borrow across trials to support Phase 3 initiation decisions. Before that: field experiments in Kenya and South Asia, real-estate market design, and RL for intervention policy.

No structural changes to the masthead, availability block, or CTA buttons.

### 2 — Signpost cards

Add a Writing card (making four total). Each card gets title + one problem-framing sentence. Remove topic-keyword lists.

| # | Title | Problem sentence |
|---|-------|-----------------|
| 01 | About | How an economist ends up building digital twins: field experiments, causal inference, and the path to pharma. |
| 02 | Projects | Six technical projects: predicting Phase 3 outcomes from Phase 2 tumor dynamics, decomposing competing risks in survival data, and building agentic tooling for Bayesian modeling teams. |
| 03 | Research | Peer-reviewed work on migration, social norms, and incentive design — where the causal-inference instincts were trained. |
| 04 | Writing | Methodological notes on Bayesian modeling, survival analysis, and the tools I work in. |

## Out of scope

- No structural changes to `index.qmd` beyond the lede text and signpost cards
- No changes to other pages
- No new sections (highlight strip considered and deferred)

## Files to change

- `index.qmd` — hero lede, signpost cards
