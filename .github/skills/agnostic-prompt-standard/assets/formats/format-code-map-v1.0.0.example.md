<format id="CODE_MAP_V1" name="Code Map" purpose="Display relevant code snippets with links to source">
<AREA_TITLE>
> [<SHORT_DESC>](../../../<REPO_NAME>/<REL_PATH>#L<LINE_FROM>-L<LINE_TO>)
```<LANG>
<LINE_FROM>: <code line>
<LINE_FROM+1>: <code line>
…
<LINE_TO>: <code line>
```

WHERE:
- <AREA_TITLE> is the title of the area being described.
- <REPO_NAME> is a single path segment.
- <REL_PATH> is repo-relative and MUST NOT start with "/".
- <LINE_FROM> and <LINE_TO> are integers; LINE_TO ≥ LINE_FROM.
- <SHORT_DESC> is a short description of the code snippet.
- <LANG> is a valid code language for GitHub-flavored Markdown.
</format>
