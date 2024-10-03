select
  {{
    tx_cols(
      fmt='{impl} as {colname}',
      impls=dict(
        tx_series_id=dbt.concat([ lit('initial-balance-'), 'account' ]),
        tx_date=cast(dbt.current_timestamp(), api.Column.translate_type('date')),
        amount_cents='balance_cents',
        payee=dbt.concat([ lit('Initial balance: '), 'account' ]),
        account_from='account',
      ),
    )
  }}
from
  {{ ref('accounts') }}
