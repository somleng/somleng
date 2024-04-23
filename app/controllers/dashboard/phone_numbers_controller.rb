module Dashboard
  class PhoneNumbersController < DashboardController
    def index
      @filtered_resources = apply_filters(phone_numbers_scope.includes(:account))
      @resources = paginate_resources(@filtered_resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(required_params.permit(:number, :account_id, :enabled, :type, :country, :price))
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
      permitted_params = [ :enabled, :type, :country, :price ]
      permitted_params << :account_id unless record.assigned?
      permitted_params = required_params.permit(permitted_params)
      @resource = initialize_form(permitted_params)
      @resource.phone_number = record
      @resource.number = record.number
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    def bulk_destroy
      @resources = apply_filters(phone_numbers_scope)
      ApplicationRecord.transaction do
        @resources.release_all
        @resources.destroy_all
      end

      respond_with(@resources, location: dashboard_phone_numbers_path(filter: request.query_parameters["filter"]))
    end

    def release
      record.release!
      respond_with(:dashboard, record)
    end

    private

    def required_params
      params.require(:phone_number)
    end

    def phone_numbers_scope
      parent_scope.phone_numbers
    end

    def initialize_form(params = {})
      form = PhoneNumberForm.new(params)
      form.carrier = current_carrier
      form
    end

    def find_record?
      super || action_name.in?(%w[release])
    end

    def record
      @record ||= phone_numbers_scope.find(params[:id])
    end
  end
end
