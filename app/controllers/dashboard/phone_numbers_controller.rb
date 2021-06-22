module Dashboard
  class PhoneNumbersController < DashboardController
    def index
      @resources = apply_filters(phone_numbers_scope.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(permitted_params)
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def show
      @resource = record
    end

    def edit
      @resource = PhoneNumberForm.initialize_with(record)
      @resource
    end

    def update
      @resource = initialize_form(permitted_params)
      @resource.phone_number = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    private

    def permitted_params
      params.require(:phone_number).permit(:number, :account_id)
    end

    def phone_numbers_scope
      current_organization.phone_numbers
    end

    def initialize_form(params = {})
      form = PhoneNumberForm.new(params)
      form.carrier = current_carrier
      form
    end

    def record
      @record ||= phone_numbers_scope.find(params[:id])
    end
  end
end
