select
  *
from
  {{ source('ynab_api', 'accounts') }}
