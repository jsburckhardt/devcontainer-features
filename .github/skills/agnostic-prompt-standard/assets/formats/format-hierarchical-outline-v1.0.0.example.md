<format id="OUTLINE_V1" name="Hierarchical Outline" purpose="Generate a semantic multilevel numbered outline.">
## <OUTLINE_TITLE>

<LEVEL_1_NUMBER> <STATEMENT>
 <LEVEL_2_NUMBER> <STATEMENT>
  <LEVEL_3_NUMBER> <STATEMENT>

…

WHERE:
- <OUTLINE_TITLE> is String; title for the outline.
- <LEVEL_1_NUMBER> is String; format "N" (e.g., "1", "2", "3").
- <LEVEL_2_NUMBER> is String; format "N.N" (e.g., "1.1", "1.2").
- <LEVEL_3_NUMBER> is String; format "N.N.N" (e.g., "1.1.1", "1.1.2"); maximum depth.
- <STATEMENT> is String; single atomic statement; topic, instruction, or information; NO obvious statements.
- … denotes repetition; one space indentation per level; up to 3 levels deep.
</format>