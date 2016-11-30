class Api::Usage::RecordsController < Api::Usage::BaseController
  self.responder = Api::Usage::RecordsResponder

  private

  def find_resource
    @resource = current_account.build_usage_record_collection(permitted_params)
    @resource.valid?
    @resource
  end

  def permitted_params
    params.permit("Category", "StartDate", "EndDate")
  end
end

