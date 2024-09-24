{%- set types = [
  dict( ynab_type=lit('checking'),     type=lit('Budget'),   subtype=lit('Checking') ),
  dict( ynab_type=lit('savings'),      type=lit('Budget'),   subtype=lit('Savings') ),
  dict( ynab_type=lit('creditCard'),   type=lit('Budget'),   subtype=lit('Credit Card') ),
  dict( ynab_type=lit('lineOfCredit'), type=lit('Budget'),   subtype=lit('Line of Credit') ),
  dict( ynab_type=lit('mortgage'),     type=lit('Loan'),     subtype=lit('Mortgage') ),
  dict( ynab_type=lit('studentLoan'),  type=lit('Loan'),     subtype=lit('Student Loan') ),
  dict( ynab_type=lit('autoLoan'),     type=lit('Loan'),     subtype=lit('Auto Loan') ),
  dict( ynab_type=lit('otherDebt'),    type=lit('Loan'),     subtype=lit('Other') ),
  dict( ynab_type=lit('otherAsset'),   type=lit('Tracking'), subtype=lit('Asset Value') ),
] %}

select
  id as account_id
  , name as account
  , {{ case(types, on='type', whens='ynab_type', thens='type') }} as account_type
  , {{ case(types, on='type', whens='ynab_type', thens='subtype') }} as account_subtype
  , balance / 10 as balance_cents
from
  {{ ynab_api('accounts') }}
