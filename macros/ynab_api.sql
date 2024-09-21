{%- macro ynab_api(path) -%}
  (
    {%- set head, _, _ = path.partition('/') %}
    select
      unnest(json.data.{{head}}, max_depth:=2) -- list -> rows, struct -> cols
    from
      read_json('{{ config.require("ynab_api_url") }}/{{path}}', records:=false)
  )
{%- endmacro %}
