<format id="CODE_CHANGES_V1" name="Code Changes" purpose="Display updated and new files with complete code.">
## <CHANGE_TITLE>

<CHANGE_DESCRIPTION>
File: <FILE_PATH>
```<LANG>
<COMPLETE_CODE>
```

---

…

WHERE:
- <CHANGE_TITLE> is String; title for the set of changes.
- <CHANGE_DESCRIPTION> is String; terse description of the change; present voice; NO changelog style.
- <FILE_PATH> is Path; relative from repository root; MUST NOT start with "/".
- <LANG> is String; valid code language for GitHub-flavored Markdown.
- <COMPLETE_CODE> is String; complete file contents; best practices; comments MUST be terse and present voice.
- … denotes repetition; one block per updated or new file; each separated by "---"; AVOID unchanged files.
</format>