{%- macro cast(val, type) -%}
  cast({{ val }} as {{ type }})
{%- endmacro %}
