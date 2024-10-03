{% macro sqlite__dateadd(datepart, interval, from_date_or_timestamp) -%}
  date({{ from_date_or_timestamp }}, {{ dbt.concat([ interval, lit(' '), lit(datepart) ]) }})
{%- endmacro %}
