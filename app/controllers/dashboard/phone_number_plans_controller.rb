module Dashboard
  class PhoneNumberPlansController < DashboardController
    def index
      @resources = paginate_resources(apply_filters(scope.includes(:account)))
    end

    def show
      @resource = record
    end

    def new
      @resource = initialize_form(phone_number_id: params[:phone_number_id])
    end

    def create
      @resource = initialize_form(permitted_params)
      @resource.save

      respond_with(
        :dashboard,
        @resource,
        location: -> { edit_dashboard_incoming_phone_number_path(@resource.phone_number_plan.incoming_phone_number) }
      )
    end

    private

    def initialize_form(options = {})
      form = PhoneNumberPlanForm.new
      form.phone_number = phone_numbers_scope.find(options[:phone_number_id])
      form.account = current_account
      form
    end

    def scope
      parent_scope.phone_number_plans
    end

    def phone_numbers_scope
      parent_scope.available_phone_numbers
    end

    def record
      @record ||= scope.find(params[:id])
    end

    def permitted_params
      params.require(:phone_number_plan).permit(:phone_number_id)
    end
  end
end
