<!-- Example: multi-line JSON constant using JSON<< ... >>.
     Engines parse BODY as JsonValue then compile it to canonical JSON (see json_spacing). -->

<constants>
DEFAULT_TZ: "Z"

API_CONFIG: JSON<<
{
  "api_base_path": "/v1",
  "default_time_zone": DEFAULT_TZ,
  "retries": 3,
  "timeout_ms": 2000
}
>>
</constants>
