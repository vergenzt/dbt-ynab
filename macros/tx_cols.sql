{%- macro tx_cols(impls={}, fmt='{impl}', impldefault='null') %}
  {%- set colnames -%}
    tx_series_id
    tx_date
    recurrence
    amount_cents
    payee
    account_from
    account_to
    category
    memo
    tx_date_first
  {%- endset %}
  {%- for colname in colnames.split() %}
    {{ ', ' if not loop.first }}
    {{- fmt.format(impl=impls.get(colname, impldefault.format(colname=colname)), colname=colname) }}
  {%- endfor %}
{%- endmacro %}
