# Source skills and adaptations

Reviewed 2026-10-24. These are inputs to a custom composition, not installed
dependencies. Links pin the revisions inspected. Skills are third-party writing
workflows; admissions policy comes from the university sources in
[admissions-guidance.md](admissions-guidance.md).

## Composition map

| Component | Keep | Adapt for undergraduate PS | Leave out |
| --- | --- | --- | --- |
| obra: writing-clearly-and-concisely | Concrete language, economy, related words together, paragraph unity, emphasis | Precision and understandable thought outrank sounding professional; topic sentences and active voice are contextual tools | Universal professional register, automatic delegation, blanket rules for every paragraph |
| forjd: better-writing | Read the brief, light edits need a reason, preserve voice, mark factual gaps, context before stylistic rules | Use the student's original as voice evidence; retain literary detail and mixed feelings; prioritize insight before surface polish | AI detection/evasion framing, mandatory voice statistics, blanket literalism, genre rules for marketing and technical documents |
| danjdewhurst: line-editing | Structure before sentence polish; clarity, precision, economy, rhythm, voice; rationale for edits | Work paragraph by paragraph on a short first-person application essay, with student-owned facts | Novel CLI, character registries, printing, publishing, prerequisites for a story project |
| danjdewhurst: scene-craft and voice-style | Orientation, meaningful scene choice, legible time shifts, voice grounded in the author's text | Use scenes and reflection flexibly within the limit; inspect chronology separately from presentation | Invented dialogue, tension escalation, cliffhangers, required in-medias-res, mandatory flashback mechanics |

## Inspected revisions

- [obra/the-elements-of-style, 05fc4f0](https://github.com/obra/the-elements-of-style/tree/05fc4f0d2b97b7c042dd9949ad658568e4a1324e/skills/writing-clearly-and-concisely): `SKILL.md`; its rule summary points to Strunk's 1918 text. Used as conceptual guidance, with independently written PS instructions; no source files copied. The inspected repository did not supply a root license file.
- [forjd/better-writing, 8e45d0b](https://github.com/forjd/better-writing/tree/8e45d0b241fc042d39444f499bbce4cfdb7a6c86/skills/better-writing): `SKILL.md`, `references/voice-and-context.md`. MIT; attribution retained in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
- [danjdewhurst/story-skills, 57121ee](https://github.com/danjdewhurst/story-skills/tree/57121ee512c6d4218a285c6991193347944f31b0/skills): `line-editing/SKILL.md`, `line-editing/references/line-edit-checklist.md`, `scene-craft/SKILL.md`, `scene-craft/references/openings.md`, `scene-craft/references/flashbacks-time.md`, `voice-style/SKILL.md`. MIT; attribution retained in [THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).

## How to tune

Tune one demonstrated behavior at a time: missed chronology, over-editing a
distinctive phrase, decorative metaphors hiding meaning, or feedback that fails
to give the student an actionable next step. Compare against the student's brief
and original, not an imagined Ivy League voice.

Keep reusable editorial methods here; keep applicant names, private document
URLs, family histories, drafts, and school decisions in the applicant's workspace.
If adopting a whole upstream package later, pin it through dotfiles'
`.chezmoiexternal.toml` and reassess overlap. This custom skill belongs in
`agents/personal-skills/` and is deployed through a chezmoi-managed symlink.
