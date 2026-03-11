<!-- Example: multi-line CSV constant using CSV<< ... >>.
     Engines parse BODY as CSV then compile it to canonical JSON rows (see 00 Structure / 02 Linting). -->

<constants>
DEFAULT_TZ: "Z"

SERVICE_TABLE: CSV<<
service,region,default_tz,enabled,note
billing,us-east-1,DEFAULT_TZ,true,"Primary billing region"
support,ap-southeast-2,"Australia/Brisbane",true,"Escalations use ""follow the sun"""
reporting,eu-west-1,DEFAULT_TZ,false,"EU, West"
>>
</constants>
