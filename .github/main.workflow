workflow "publish release to npm" {
  on = "release"
  resolves = ["npm publish"]
}

action "npm install" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "install"
}

action "npm audit" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  args = "audit"
  needs = ["npm install"]
}

action "npm publish" {
  uses = "actions/npm@59b64a598378f31e49cb76f27d6f3312b582f680"
  secrets = ["NPM_AUTH_TOKEN"]
  args = "publish"
  needs = ["npm audit"]
}
