<format id="TABLE_API_COVERAGE_V1" name="API Coverage Table" purpose="Report API operation coverage against a specification.">
## <TABLE_NAME>
| Operation | URI | SpecRef | Gap |
| --- | --- | --- | --- |
| <OPERATION> | <URI> | <SPEC_REF> | <GAP> |

WHERE:
- <TABLE_NAME> is the title for the API coverage table.
- <OPERATION> is the HTTP method, one of: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`.
- <URI> is the absolute path of the API endpoint, starting with `/`.
- <SPEC_REF> is a reference to the relevant part of the API specification, one of: `OpenAPI: <PATH_OR_COMPONENT>` or `Swagger: <PATH_OR_COMPONENT>`.
- <GAP> is the coverage gap analysis code, one of: `OK`, `MISSING_PATH`, `MISSING_METHOD`, `REQ_SCHEMA_MISMATCH`, `RESP_SCHEMA_MISMATCH`, `STATUS_CODE_MISSING`.
</format>
