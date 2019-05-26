'use strict'

class APIKeySMPlugin {

  constructor(serverless, options) {
    this.serverless = serverless
    this.options = options || {}
    this.provider = this.serverless.getProvider('aws')
    this.stage = this.options.stage || this.serverless.service.provider.stage

    this.hooks = { 'after:deploy:deploy': this.exportApiKey.bind(this) }
  }

  async exportApiKey() {
    this.serverless.cli.log('serverless-plugin-api-key-sm starting...')

    this.serverless.cli.log('getting stack...')
    const stack = (await this.provider.request(
      'CloudFormation', 'describeStacks',
      { StackName: this.provider.naming.getStackName(this.stage) }
    )).Stacks[0]

    this.serverless.cli.log('getting stack outputs...')
    const stackOutputs = stack.Outputs.reduce(
      (os, o) => ({ ...os, ...{ [o.OutputKey]: o.OutputValue } }), {}
    )

    this.serverless.cli.log('processing stack outputs...')
    const {
      AWSApiGatewayApiKeyId,
      AWSSecretsManagerSecretAPIArn
    } = stackOutputs

    this.serverless.cli.log('getting api key value...')
    const apiKeyValue = (await this.provider.request(
      'APIGateway', 'getApiKey',
      { apiKey: AWSApiGatewayApiKeyId, includeValue: true }
    )).value

    this.serverless.cli.log('exporting api key value...')
    await this.provider.request(
      'SecretsManager', 'putSecretValue',
      {
        SecretId: AWSSecretsManagerSecretAPIArn,
        SecretString: apiKeyValue
      }
    )

    this.serverless.cli.log('serverless-plugin-api-key-sm finished...')
  }
}

module.exports = APIKeySMPlugin
