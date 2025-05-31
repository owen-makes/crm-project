class RefreshBrokerTokenJob < ApplicationJob
  queue_as :default

  def perform(credential_id)
    credential = BrokerCredential.find(credential_id)
    result = Broker::RefreshToken.call(credential)
    unless result.success?
      credential.update(status: :error, last_error: result.error)
      raise(StandardError, result.error)
    end
  end
end
