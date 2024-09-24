{%- macro lit(s) %}
  {{- dbt.string_literal(s) }}
{%- endmacro %}
