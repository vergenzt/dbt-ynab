{%- macro case(cases, on=none, whens=none, thens=none, default=none) %}
  {%- if not whens or not thens %}
    {{- exceptions.raise_compiler_error('Must specify both `whens` and `thens`!') }}
  {%- endif -%}

  case {{- ' ' ~ on if on is not none else '' }}
  {%- for case in cases %}
  {%- if case[whens] is not none and case[thens] is not none %}
  when {{ case[whens] }} then {{ case[thens] }}
  {%- endif %}
  {%- endfor %}
  {%- if default is not none %}
  else {{default}}
  {%- endif %}
  end

{%- endmacro %}
