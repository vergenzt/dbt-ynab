select
  account
  , sum(balance_change) over (partition by account order by balance_date) as balance_cents
  , balance_change
  , balance_date
  , {{ tx_cols() }}
from
  (
    select
      account_from as account
      , amount_cents as balance_change
      , tx_date as balance_date
      , *
    from
      {{ ref('txs') }}

    union all

    select
      account_to as account
      , -amount_cents as balance_change
      , tx_date as balance_date
      , *
    from
      {{ ref('txs') }}
    where
      account_to is not null
  )
order by
  tx_date
