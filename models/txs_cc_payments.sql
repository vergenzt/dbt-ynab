
{%- set cut_sym = lit('✂') %}
{%- set cut_day_start -%}
  {{- dbt.position(cut_sym, 'credit_accounts.account') }}
  {{- ' + 1' }} {#- skip cutsym #}
  {{- ' + 1' }} {#- skip space #}
{%- endset %}
{%- set cut_day_str -%}
  substring(credit_accounts.account, {{cut_day_start}}, 2)
{%- endset %}
{%- set cut_day_int = cast(cut_day_str, dbt.type_int()) %}

{%- set cc_stmt_date -%}
  {%- set tx_date_shifted = dbt.dateadd('day', '-1*'~cut_day_int, 'tx_date') %}
  {%- set tx_date_trunced = dbt.date_trunc('month', tx_date_shifted) %}
  {%- set tx_date_unshifted = dbt.dateadd('day', cut_day_int, tx_date_trunced) %}
  {{- tx_date_unshifted }}
{%- endset %}
{%- set cc_stmt_due_date = dbt.dateadd('day', 26, cc_stmt_date) %}

select
  {{
    tx_cols(
      fmt='{impl} as {colname}',
      impls=dict(
        tx_series_id=dbt.concat([ lit('cc-payment-'), 'credit_accounts.account' ]),
        tx_date=cc_stmt_due_date,
        amount_cents='sum(amount_cents)',
        payee=dbt.concat([ lit('Payment for '), cc_stmt_date, lit(' to '), 'credit_accounts.account' ]),
        account_from=lit('Checking'),
        account_to='credit_accounts.account',
        category=dbt.concat([ lit('Credit Card Payments: '), 'credit_accounts.account' ]),
      ),
    )
  }}
from
  (
    select * from {{ ref('txs_initial_balance') }}
    union all
    select * from {{ ref('txs_scheduled') }}
  ) as credit_txs
  join {{ ref('accounts') }} as credit_accounts on
    credit_accounts.account_subtype = 'Credit Card'
    and credit_accounts.account = credit_txs.account_from

where
  {{cc_stmt_due_date}} <= {{ config.require('forecast_max_date') }}

group by
  {{cc_stmt_date}}
  , credit_accounts.account
