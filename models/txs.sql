{%- set models %}
  txs_cc_payments
  txs_initial_balance
  txs_scheduled
{%- endset %}

{%- for model in models.strip().split() %}
  {%- if not loop.first %}
  union all
  {%- endif %}
  select * from {{ ref(model) }}
{%- endfor %}

