# 05 Grammar

This document defines the normative EBNF for the agentic control DSL.

> NOTE: This is a reference grammar. Engines MAY extend it, but prompts that claim APS v1.0
> conformance MUST remain within this grammar unless the host explicitly opts into extensions.

## EBNF

```ebnf
Letter        = "A"…"Z" | "a"…"z" ;
LowerLetter   = "a"…"z" ;
Digit         = "0"…"9" ;
Space         = " " ;
Newline       = "\n" ;
Tab           = "\t" ;

UpperSym      = ( "A"…"Z" | "0"…"9" | "_" ){2,24} ;
Placeholder   = "<", ( "A"…"Z" | "0"…"9" | "_" ){1,64}, ">" ;
Bool          = "true" | "false" ;
Number        = "-"? Digit, { Digit }, [ ".", Digit, { Digit } ] ;
String        = "\"", { <any char except " or \"> | "\\\"" | "\\\\" }, "\"" ;
EnumLit       = "enum(", UpperSym, { ",", UpperSym }, ")" ;

BlockType     = "JSON" | "TEXT" | "YAML" | "CSV" ;
BlockOpen     = UpperSym, ":", Space, BlockType, "<<", EOL ;
BlockClose    = ">>" ;
BlockValue    = BlockType, "<<", EOL, { <any line except BlockClose>, EOL }, BlockClose ;

JsonKey       = LowerLetter, { LowerLetter | Digit | "_" | "-" } ;
JsonValue     = String | Number | Bool | "null" | JsonObj | JsonArr | UpperSym ;
JsonPair      = "\"", JsonKey, "\"", ":", Space?, JsonValue ;
JsonObj       = "{", Space?, [ JsonPair, { ",", Space?, JsonPair } ], Space?, "}" ;
JsonArr       = "[", Space?, [ JsonValue, { ",", Space?, JsonValue } ], Space?, "]" ;

IdLower       = LowerLetter, { LowerLetter | Digit | "_" | "-" } ;
Key           = IdLower ;
Value         = String | Number | Bool | JsonObj | JsonArr | UpperSym | Placeholder | EnumLit ;

StaticConst   = UpperSym, ":", Space, ( Value | BlockValue ) ;

Param         = Key, "=", Value ;
ParamList     = Param, { ",", Space, Param } ;

BacktickId    = "`", IdLower, "`" ;

RunStmt       = "RUN", Space, BacktickId, [ Space, "where:", Space, ParamList ] ;
UseStmt       = "USE", Space, BacktickId, [ Space, "where:", Space, ParamList ],
                [ Space, "(", "atomic", [ ",", Space, "timeout_ms", "=", Number ], [ ",", Space, "retry", "=", Number ], ")" ] ;
CaptureStmt   = "CAPTURE", Space, UpperSym, { ",", Space, UpperSym }, Space, "from", Space, BacktickId,
                [ Space, "map:", Space, "\"", <path>, "\"", "→", UpperSym, { ",", Space, "\"", <path>, "\"", "→", UpperSym } ] ;
SetStmt       = "SET", Space, UpperSym, Space, ":=", Space, Value, [ Space, "(", "from ", ( BacktickId | "INP" | UpperSym | "Agent Inference" ), ")" ] ;
UnsetStmt     = "UNSET", Space, UpperSym ;
ReturnPairs   = IdLower, "=", Value, { ",", Space, IdLower, "=", Value } ;
ReturnList    = UpperSym, { ",", Space, UpperSym } ;
ReturnStmt    = "RETURN", ":", Space, ( ReturnList | ReturnPairs ) ;
AssertStmt    = "ASSERT", Space, <expr> | "ASSERT ALL:", Space, "[", <expr>, { ",", Space, <expr> }, "]" ;
TellStmt      = "TELL", [ Space, String ], [ Space, "why:", UpperSym ], [ Space, "level=", ("brief" | "full") ], [ Space, "outcome:", String ] ;
MileStmt      = "MILESTONE", Space, String ;

SnapList      = "[", UpperSym, { ",", Space, UpperSym }, "]" ;
RedactList    = "[", UpperSym, { ",", Space, UpperSym }, "]" ;
SnapStmt      = "SNAP", Space, SnapList, [ Space, "delta", "=", Bool ], [ Space, "redact", "=", RedactList ] ;

IfStmt        = "IF", Space, <expr>, ":" ;
ElseIfStmt    = "ELSE IF", Space, <expr>, ":" ;
ElseStmt      = "ELSE", ":" ;
WhenStmt      = "WHEN", Space, <condition-text-no-colon>, ":" ;
ThenStmt      = "THEN", Space, <condition-text-no-colon>, ":" ;
GivenStmt     = "GIVEN", Space, <condition-text-no-colon>, ":" ;

EOL           = Newline ;
WithBlock     = "WITH", Space, JsonObj, ":", EOL, { <indented Statement>, EOL } ;
ParBlock      = "PAR", ":", EOL, { <indented UseStmt>, EOL } ;
JoinBlock     = "JOIN", ":", EOL, { <indented CaptureStmt>, EOL } ;

ForEachStmt   = "FOREACH", Space, IdLower, Space, "IN", Space, UpperSym, ":", EOL, { <indented Statement>, EOL } ;

TryBlock      = "TRY", ":", EOL, { <indented Statement>, EOL },
                "RECOVER", Space, "(", IdLower, ")", ":", EOL, { <indented Statement>, EOL } ;

WhereSection  = "WHERE:", EOL, { WhereDef, EOL } ;
WhereDef      = "- ", Placeholder, Space, Constraint ;
Constraint    = TypeConst | EnumConst | FormatConst | RegexConst ;

TypeConst     = "is", Space, ("String" | "Number" | "Boolean" | "ISO8601" | "URI" | "Path") ;
EnumConst     = "is one of:", Space, Value, { ",", Space, Value } ;
FormatConst   = "matches format:", Space, UpperSym ;  # Recursive validation
RegexConst    = "matches", Space, String ;

Statement     = RunStmt | UseStmt | CaptureStmt | SetStmt | UnsetStmt | ReturnStmt | AssertStmt
              | TellStmt | MileStmt | WithBlock | ParBlock | JoinBlock | ForEachStmt | TryBlock
              | IfStmt | ElseIfStmt | ElseStmt | GivenStmt | WhenStmt | ThenStmt | SnapStmt ;

Program       = { Statement, EOL } ;
```

## Notes (non-normative)

- Indentation is significant for block bodies (`WITH`, `PAR`, `JOIN`, `TRY`, `FOREACH`).
- `<expr>` and `<path>` are intentionally unspecified in v1.0 and are engine-defined.
