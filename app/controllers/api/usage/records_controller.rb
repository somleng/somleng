class Api::Usage::RecordsController < Api::Usage::BaseController
  self.responder = Api::Usage::RecordsResponder

  private

  def find_resource
    @resource = Usage::Record::Collection.new(
      permitted_params.merge("account" => current_account)
    )
    @resource.valid?
    @resource
  end

  def permitted_params
    params.permit("Category", "StartDate", "EndDate")
  end
end
