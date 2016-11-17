class Api::Usage::RecordsController < Api::Usage::BaseController
  private

  def find_resource
    @resource = current_account.build_usage_record(permitted_params)
  end

  def permitted_params
    params.permit("Category", "StartDate", "EndDate")
  end
end

