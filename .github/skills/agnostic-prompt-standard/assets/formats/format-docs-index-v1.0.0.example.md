<format id="DOCS_INDEX_V1" name="Documentation Index" purpose="Token-efficient hierarchical documentation map for AI navigation.">
# <PROJECT_TITLE> Documentation Map

> Fetch the complete documentation index at: <INDEX_URL>
> Last updated: <TIMESTAMP>

## <GROUP_NAME>

### [<PAGE_TITLE>](<PAGE_URL>)
* <HEADING_TEXT>
  * <SUBHEADING_TEXT>

...

WHERE:
- <PROJECT_TITLE> is String; name of the project or documentation set.
- <INDEX_URL> is URI; URL where this index can be fetched.
- <TIMESTAMP> is ISO8601; when the index was generated.
- <GROUP_NAME> is String; documentation section/category name.
- <PAGE_TITLE> is String; title of the documentation page.
- <PAGE_URL> is URI; link to the documentation page.
- <HEADING_TEXT> is String; H2/H3 heading text from the page.
- <SUBHEADING_TEXT> is String; nested heading under parent.
- ... denotes repetition; groups contain pages, pages contain headings.
</format>
