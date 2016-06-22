class Api::OutgoingCallsController < Api::BaseController
  def create
    outgoing_call = current_account.outgoing_calls.build(permitted_params)
    outgoing_call.save
    render(:json => outgoing_call, :status => :created)
  end

  private

  def permitted_params
    params.permit
  end
end
