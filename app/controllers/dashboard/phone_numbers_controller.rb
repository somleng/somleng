module Dashboard
  class PhoneNumbersController < DashboardController
    def index
      @filtered_resources = apply_filters(scope.includes(:account))
      @resources = paginate_resources(@filtered_resources)
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(required_params.permit(:number, :enabled, :type, :country, :price))
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
      permitted_params = required_params.permit(permitted_params)
      @resource = initialize_form(permitted_params)
      @resource.phone_number = record
      @resource.number = record.number
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      ApplicationRecord.transaction do
        record.release!
        record.destroy
      end
      respond_with(:dashboard, record)
    end

    def bulk_destroy
      @resources = apply_filters(scope)
      ApplicationRecord.transaction do
        @resources.release_all
        @resources.destroy_all
      end

      respond_with(@resources, location: dashboard_phone_numbers_path(filter: request.query_parameters["filter"]))
    end

    private

    def required_params
      params.require(:phone_number)
    end

    def scope
      current_carrier.phone_numbers
    end

    def initialize_form(params = {})
      form = PhoneNumberForm.new(params)
      form.carrier = current_carrier
      form
    end

    def record
      @record ||= scope.find(params[:id])
    end
  end
end
