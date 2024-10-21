#/bin/bash
# update/append contact email for certbot account

# list current account contact
$ certbot show_account
...
Account details for server https://acme-v02.api.letsencrypt.org/directory:
  Account URL: https://acme-v02.api.letsencrypt.org/acme/acct/123123123
  Account Thumbprint: 123abc123abc123abc
  Email contacts: admin1@test.org

# replace admin1 email with admin2 email
$ certbot update_account --email admin2@test.org
$ certbot show_account
...
Account details for server https://acme-v02.api.letsencrypt.org/directory:
  Account URL: https://acme-v02.api.letsencrypt.org/acme/acct/123123123
  Account Thumbprint: 123abc123abc123abc
  Email contacts: admin2@test.org

# append admin2 email to admin1
$ certbot update_account --email admin1@test.org,admin2@test.org
...
Account details for server https://acme-v02.api.letsencrypt.org/directory:
  Account URL: https://acme-v02.api.letsencrypt.org/acme/acct/123123123
  Account Thumbprint: 123abc123abc123abc
  Email contacts: admin1@test.org, admin2@test.org
