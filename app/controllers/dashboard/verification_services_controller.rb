module Dashboard
  class VerificationServicesController < DashboardController
    def index
      @resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(required_params.permit(:friendly_name, :code_length, :account_id))
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def edit
      @resource = VerificationServiceForm.initialize_with(record)
    end

    def update
      permitted_params = required_params.permit(:friendly_name, :code_length)
      @resource = initialize_form(permitted_params)
      @resource.verification_service = record
      @resource.account = record.account
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def initialize_form(params = {})
      form = VerificationServiceForm.new(params)
      form.carrier = current_carrier
      form.account = current_account unless current_user.carrier_user?
      form
    end

    def scope
      parent_scope.verification_services
    end

    def record
      @record ||= scope.find(params[:id])
    end

    def required_params
      params.require(:verification_service)
    end
  end
end
