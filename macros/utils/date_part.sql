{%- macro sqlite__date_part(datepart, date) %}
  {#- https://www.sqlite.org/lang_datefunc.html #}
  {%- set part_fmts = dict(
    year='%Y',
    month='%m',
    week='%U',
    day='%d',
    hour='%H',
    minute='%M',
    second='%S',
  ) %}

  {%- if datepart not in part_fmts %}
    {%- do exceptions.raise_compiler_error('Unsupported datepart: ' ~ datepart) %}
  {%- endif -%}

  cast(strftime({{ date }}, {{ dbt.string_literal(part_fmts[datepart]) }}) as integer)
{%- endmacro %}
