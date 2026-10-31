module Dashboard
  class AlphanumericSenderIdsController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(required_params.permit(:account_id, :sender_id))
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def required_params
      params.require(:alphanumeric_sender_id)
    end

    def initialize_form(params = {})
      form = AlphanumericSenderIDForm.new(params)
      form.carrier = current_carrier
      form.account = current_account unless current_user.carrier_user?
      form
    end

    def scope
      parent_scope.alphanumeric_sender_ids
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
