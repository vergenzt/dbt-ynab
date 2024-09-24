{%- set twiceAMonthImpl %}
  {%- set dayn = dbt_date.day_of_month('tx_date') %} {# current row's day #}
  {%- set day1 = dbt_date.day_of_month('tx_date_first') %} {# original start day #}
  {%- set day0 -%} {# start day in 1st half of month #}
    case
    when {{day1}} > 15 then {{ day1 }} - 15
    else {{day1}}
    end
  {%- endset %} 
  {%- set eom = dbt.last_day(datepart='month', date='tx_date') %}
  case
  when {{dayn}} = {{day0}} then
    -- 15 days later, or EOM (whichever comes first)
    least({{ dbt.dateadd('day', 15, 'tx_date') }}, {{ eom }})
  else
    -- day0 in following month
    {{ dbt.dateadd('day', day0, eom) }}
  end
{%- endset %}

{%- set recurrences = [
  dict( ynab_label=lit('twiceAMonth'),  my_label=lit(' 0.5 months'),       impl=twiceAMonthImpl ),
  dict( ynab_label=lit('weekly'),       my_label=lit(' 0 months 1 week'),  impl=dbt.dateadd('day', 7, 'tx_date') ),
  dict( ynab_label=lit('every4Weeks'),  my_label=lit(' 0 months 4 weeks'), impl=dbt.dateadd('day', 28, 'tx_date') ),
  dict( ynab_label=lit('monthly'),      my_label=lit(' 1 month'),          impl=dbt.dateadd('month', 1, 'tx_date') ),
  dict( ynab_label=lit('every3Months'), my_label=lit(' 3 months'),         impl=dbt.dateadd('month', 3, 'tx_date') ),
  dict( ynab_label=lit('twiceAYear'),   my_label=lit(' 6 months'),         impl=dbt.dateadd('month', 6, 'tx_date') ),
  dict( ynab_label=lit('yearly'),       my_label=lit('12 months'),         impl=dbt.dateadd('month', 12, 'tx_date') ),
  dict( ynab_label=lit('never'),        my_label='null',                   impl=none ),
] %}

with recursive
  {{ this.identifier }}(
    {{ tx_cols(fmt='{colname}') }}
  )
  as (
    select
      {{
        tx_cols(dict(
          tx_series_id='txs.id',
          tx_date=dbt.cast('date_next', api.Column.translate_type('date')),
          recurrence=case(recurrences, on='frequency', whens='ynab_label', thens='my_label'),
          amount_cents='amount / 10',
          payee='payee_name',
          account_from='accounts_from.account',
          account_to='accounts_to.account',
          category='category_name',
          memo='memo',
          tx_date_first=dbt.cast('date_first', api.Column.translate_type('date')),
        ))
      }}
    from
      {{ ynab_api('scheduled_transactions') }} as txs
      left join {{ ref('accounts') }} as accounts_from using (account_id)
      left join {{ ref('accounts') }} as accounts_to on
        accounts_to.account_id = txs.transfer_account_id

    union all

    select
      {{
        tx_cols(
          impldefault='{colname}',
          impls=dict(
            tx_date=case(recurrences, on='recurrence', whens='my_label', thens='impl') ~ ' as tx_date_new',
          ),
        )
      }}
    from
      {{ this.identifier }}
    where
      recurrence is not null
      and tx_date_new <= {{ config.require('forecast_max_date') }}
  )

select
  *
from
  {{ this.identifier }}
