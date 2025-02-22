# cypress-keycloak-commands

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->

[![All Contributors](https://img.shields.io/badge/all_contributors-6-orange.svg?style=flat-square)](#contributors-)

<!-- ALL-CONTRIBUTORS-BADGE:END -->

Cypress commands for login with [Keycloak](https://www.keycloak.org/).

- Setup Keycloak configuration from Cypress configuration or environment variables
- Use Fixtures to store users data
- Returns you the tokens of the logged user for calling backend APIs from your test code
- Fake login command for integration testing
- Tested with Keycloak 5-20

## Usage

### Installing

Install the package using npm:

```
npm i -D cypress-keycloak-commands
```

or Yarn:

```
yarn add -D cypress-keycloak-commands
```

Import the package in the file `cypress/support/commands.js` (or `cypress/support/commands.ts`):

```typescript
import "cypress-keycloak-commands";
```

### Setup Keycloak configuration

Setup the Keycloak configuration in `cypress.json` configuration file:

```json
{
  "env": {
    "auth_base_url": "https://auth.server/auth",
    "auth_realm": "my_realm",
    "auth_client_id": "my_client_id",
    "auth_client_secret": "my_client_secret"
  }
}
```

You can override this settings for some tests using [Environment variables](https://docs.cypress.io/guides/guides/environment-variables.html).

### Login commands for E2E Tests

#### Cypress best practices

Cypress states in [it's docs](https://docs.cypress.io/guides/references/best-practices#Using-after-or-afterEach-hooks): "State reset should go before each test". We strongly agree with this best practice. Unfortunately or luckily, Keycloak 18 has better support for logout based on the OpenID Connect RP-Initiated Logout specification, [see here](https://www.keycloak.org/2022/04/keycloak-1800-released#_openid_connect_logout), therefore we need to provide the `id_token_hint` when logging out. Hence, `cy.kcLogout()` depends on the token provided by `cy.kcLogin()` and it might be necessary to work with `beforeEach()` and `afterEach()` blocks.

For logging in with Keycloak there are two possibilities:

#### Using Variables

This is the recommended approach, since it enables the usage of [Environment variables](https://docs.cypress.io/guides/guides/environment-variables.html) for production environments.

```typescript
describe("Keycloak Login", () => {
  beforeEach(() => {
    cy.kcLogin({
      username: "user",
      password: "password"
    });
    cy.visit("/");
  });

  afterEach(() => {
    cy.kcLogout();
  });
});
```

#### Using fixtures

Create a [fixture](https://docs.cypress.io/api/commands/fixture.html) containing the user credentials under the directory `cypress/fixtures/users`. For example you can create a file `cypress/fixtures/users/user.json` with this content:

```json
{
  "username": "user",
  "password": "password"
}
```

When you have a fixture you can login using the `kcLogin` command, passing the name of the fixture, and you can perform a logout using the `kcLogout` command:

```typescript
describe("Keycloak Login", () => {
  beforeEach(() => {
    cy.kcLogin("user");
    cy.visit("/");
  });

  afterEach(() => {
    cy.kcLogout();
  });
});
```

#### Login Options

Cypress will print the username and password combination in it's log. In case you want to mask the password, use the optional options interface.

```typescript
describe("Keycloak Login", () => {
  beforeEach(() => {
    cy.kcLogin("user", { mask: true });
    cy.visit("/");
  });

  afterEach(() => {
    cy.kcLogout();
  });
});
```

#### Get user tokens for calling APIs from E2E tests

If you need to call backend APIs from your tests using the token of the logged user (for example to [set up the state bypassing the UI](https://docs.cypress.io/guides/getting-started/testing-your-app.html#Bypassing-your-UI)) you can get the retrieved user tokes from the kcLogin command:

```typescript
describe("Keycloak Login", () => {
  beforeEach(() => {
    cy.kcLogin("user").as("tokens");
    cy.visit("/");
  });

  afterEach(() => {
    cy.kcLogout();
  })

  it("should call an API with the token", () => {
    cy.get("@tokens").then(tokens => {
      cy.request({
        url: "/my_api"
        auth: {
          bearer: tokens.access_token
        }
      });
    });
  });
});
```

Note: if you use Typescript you have to specify the return type of the `cy.get` command:

```typescript
cy.get<KcTokens>("@tokens");
```

### Fake Login for Integration testing

If you are doing an integration test that doesn't call a real backend API, maybe you don't need to authenticate a real user to a running Keycloak instance, but if your app uses the Keycloak Javascript Adapter to check if a user is logged in, you will need to have a mocked user.

To create mocked user data, you need three tokens (access token, refresh token, id token) of a real user returned by your Keycloak instance. You can get them for example from the Dev Tools of your browser, searching for calls to the `token` endpoint of Keycloak. If your app calls the `/account` endpoint to retrieve user information you will also need to have the response returned for the API. Then you can create the fixture with the fake user data:

```json
{
  "fakeLogin": {
    "access_token": "...",
    "refresh_token": "...",
    "id_token": "...",
    "account": {
      "username": "user",
      "firstName": "Sample",
      "lastName": "User",
      "email": "sample-user@example",
      "emailVerified": false,
      "attributes": {}
    }
  }
}
```

With the fixture in place, you can use the `kcFakeLogin` command to perform a fake login without hitting a real Keycloak instance.

The Fake Login is performed loading a page and passing some keycloak initialization parameters in the URL. If you need to visit a page different from the homepage you must pass its url to the `kcFakeLogin` command as second parameter (instead of using `cy.visit`):

```typescript
describe("Keycloak Fake Login", () => {
  beforeEach(() => {
    cy.kcFakeLogin("user", "pageToVisit");
  });
});
```

#### Session Status iframe

At the moment within Cypress is not possible to mock iframe loading and APIs called from an iframe. For this reason, when you use `kcFakeLogin` you have to disable the Session Status iframe, otherwise the Javascript adapter will redirect you to the real Keycloak instance. You can disable it only when the app is running inside Cypress:

```typescript
const checkLoginIframe = window.Cypress ? false : true;

var initOptions = {
  responseMode: "fragment",
  flow: "standard",
  onLoad: "login-required",
  checkLoginIframe
};
```

## Acknowledgements

Other solutions that have inspired this library:

- https://vrockai.github.io/blog/2017/10/28/cypress-keycloak-intregration/
- https://www.npmjs.com/package/cypress-keycloak

## License

MIT

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Fredx87"><img src="https://avatars2.githubusercontent.com/u/13420283?v=4?s=100" width="100px;" alt="Gianluca Frediani"/><br /><sub><b>Gianluca Frediani</b></sub></a><br /><a href="#infra-Fredx87" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#tool-Fredx87" title="Tools">🔧</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Fredx87" title="Tests">⚠️</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Fredx87" title="Documentation">📖</a> <a href="#ideas-Fredx87" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Fredx87" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/groie"><img src="https://avatars3.githubusercontent.com/u/5516998?v=4?s=100" width="100px;" alt="Ilkka Harmanen"/><br /><sub><b>Ilkka Harmanen</b></sub></a><br /><a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=groie" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://rm3l.org/"><img src="https://avatars.githubusercontent.com/u/593208?v=4?s=100" width="100px;" alt="Armel Soro"/><br /><sub><b>Armel Soro</b></sub></a><br /><a href="#ideas-rm3l" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=rm3l" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://www.patrickvanzadel.com/"><img src="https://avatars.githubusercontent.com/u/650886?v=4?s=100" width="100px;" alt="Patrick van Zadel"/><br /><sub><b>Patrick van Zadel</b></sub></a><br /><a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Shuyinsama" title="Code">💻</a> <a href="#ideas-Shuyinsama" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Shuyinsama" title="Documentation">📖</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Shuyinsama" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/davidkaufmann"><img src="https://avatars.githubusercontent.com/u/12951672?v=4?s=100" width="100px;" alt="David Kaufmann"/><br /><sub><b>David Kaufmann</b></sub></a><br /><a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=davidkaufmann" title="Code">💻</a> <a href="#ideas-davidkaufmann" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=davidkaufmann" title="Documentation">📖</a> <a href="#maintenance-davidkaufmann" title="Maintenance">🚧</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://bloeckchengrafik.github.io/"><img src="https://avatars.githubusercontent.com/u/37768199?v=4?s=100" width="100px;" alt="Christian Bergschneider"/><br /><sub><b>Christian Bergschneider</b></sub></a><br /><a href="https://github.com/Fredx87/cypress-keycloak-commands/commits?author=Bloeckchengrafik" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
