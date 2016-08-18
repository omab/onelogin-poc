# OneLogin bug PoC

Mixing OneLogin [Delegate Authentication](https://developers.onelogin.com/api-docs/1/users/delegate-authentication)
with [Log User Out API](https://developers.onelogin.com/api-docs/1/users/log-user-out)
don't play nice.

## Requirements

1. OneLogin app
2. OneLogin account (`User A`)
3. A beer

## Description

1. `User A` inputs credentials
2. Backend delegates authentication to OneLogin
   a. a `session token` is created
   b. the `session token` is delivered to the front-end
3. Front-end fills the `token` in an HTML `<form>`
4. Front-end `POST`s the form to OneLogin `session_via_api_token`
   endpoint
5. OneLogin logs the user in based on the `session token` and returns
   back to the `referrer`
6. Almost profit!
7. User logs out
8. Backend logs out from the app and from OneLogin with API
9. `User A` inputs the credentials again
10. Backend delegates authentication to OneLogin
    a. a `session token` is created
    b. the `session token` is delivered to the front-end
11. Front-end fills the `token` in an HTML `<form>`
12. Front-end `POST`s the form to OneLogin `session_via_api_token`
    endpoint
13. OneLogin redirects to their login form with a `You have been
    logged out via the API.` message
14. Have a drink

## Possible reasons

A possible reason for this problems is that OneLogin relies on the
browser cookie in the second `POST` request ignoring the `session
token`, deciding that the user was logged out instead of logging in
the new user based on the new `token`.


## Running the PoC

1. Install dependencies:

   ```
   $ bundle install
   ```

2. Run the `sinatra` application

   ```
   $ CLIENT_SECRET=ONELOGIN_APP_CLIENT_SECRET CLIENT_ID=ONELOGIN_APP_CLIENT_ID SUBDOMAIN=ONELOGIN_SUBDOMAIN ruby app.rb
   ```

4. Open `http://localhost:9494`

5. Login with a OneLogin user account

6. Click the `OneLogin Session` button to login on OneLogin

7. Logout and try to login again (same or different account)
