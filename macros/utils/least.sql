{%- macro least(exprs) %}
  {% do return(adapter.dispatch('least')(exprs)) %}
{%- endmacro %}

{%- macro sqlite__least(exprs) -%}
  min({{ exprs | join(', ') }})
{%- endmacro %}
  
