{%- macro sqlite__date_trunc(datepart, date) %}
  {%- if datepart == 'month' -%}
    (substring({{ date }}, 1, 7) || '-01')
  {%- else %}
    {%- do exceptions.raise_compiler_error('datepart not supported yet: ' ~ datepart) %}
  {%- endif %}
{%- endmacro %}
