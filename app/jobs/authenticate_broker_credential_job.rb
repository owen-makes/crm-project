class AuthenticateBrokerCredentialJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  discard_on Iol::Base::AuthError do |job|
    credential = BrokerCredential.find(job.arguments.first)
    credential.update(status: :error)
  end

  retry_on Iol::Base::NetworkError, wait: 30.seconds, attempts: 5

  def perform(credential_id)
    credential = BrokerCredential.find(credential_id)

    result = Broker::Authenticate.call(credential)

    unless result.success?
      credential.update(status: :error)
      # Raising keeps the job in “retry” state so you see it in the Web UI
      raise(StandardError, result.error)
    end

    credential.update(status: :ok, last_authenticated_at: Time.current)
  end
end
