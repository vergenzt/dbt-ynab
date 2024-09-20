select
  *
from
  {{ source('ynab_api', 'scheduled_transactions') }}
