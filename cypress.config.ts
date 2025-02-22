import { defineConfig } from 'cypress'

export default defineConfig({
  env: {
    auth_base_url: 'http://localhost:8081/auth',
    auth_realm: 'example',
    auth_client_id: 'js-console',
  },
  video: false,
  e2e: {
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      return require('./cypress/plugins/index.js')(on, config)
    },
    baseUrl: 'http://localhost:8080',
  },
})
