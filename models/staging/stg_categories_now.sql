select
  *
from
  {{ source('ynab_api', 'categories_now') }}
