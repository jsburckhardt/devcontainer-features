<format id="IDEATION_LIST_V1" name="Ideation List" purpose="Generate structured brainstorming ideas for a given task.">
## <TASK_TITLE>

[<ITEM_NUMBER>] <IDEA_TITLE>
Summary: <IDEA_SUMMARY>
Details: <IDEA_DETAILS>

---

…

WHERE:
- <TASK_TITLE> is String; the task or topic for ideation.
- <ITEM_COUNT> is Integer; total number of ideation items to generate.
- <ITEM_NUMBER> is Integer; sequential from 1 to <ITEM_COUNT>.
- <IDEA_TITLE> is String; short descriptive title; present tense; active voice.
- <IDEA_SUMMARY> is String; one sentence; present tense; active voice.
- <IDEA_DETAILS> is String; 2–4 sentences; conceptual only; NO implementation, code, or pseudo-code.
- … denotes repetition; exactly <ITEM_COUNT> items; each separated by "---".
</format>