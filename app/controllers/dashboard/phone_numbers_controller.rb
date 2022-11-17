module Dashboard
  class PhoneNumbersController < DashboardController
    skip_before_action :find_record
    prepend_before_action :find_owner, only: :destroy
    prepend_before_action :find_manager, only: %i[edit update release]
    prepend_before_action :find_owner_or_manager, only: :show

    def index
      @resources = apply_filters(owners_or_managers.includes(:account))
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(required_params.permit(:number, :account_id, :enabled))
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def edit
      @resource = PhoneNumberForm.initialize_with(record)
    end

    def update
      permitted_params = record.assigned? ? required_params.permit(:enabled) : required_params.permit(:account_id, :enabled)
      @resource = initialize_form(permitted_params)
      @resource.phone_number = record
      @resource.save

      respond_with(:dashboard, @resource)
    end

    def destroy
      record.destroy
      respond_with(:dashboard, record)
    end

    def release
      record.release!
      respond_with(:dashboard, record)
    end

    private

    attr_reader :record

    def required_params
      params.require(:phone_number)
    end

    def owners
      parent_scope.phone_numbers
    end

    def managers
      parent_scope.managing_phone_numbers
    end

    def owners_or_managers
      owners.or(managers)
    end

    def find_owner
      @record = find_record(owners)
    end

    def find_manager
      @record = find_record(managers)
    end

    def find_owner_or_manager
      @record = find_record(owners_or_managers)
    end

    def find_record(scope)
      scope.find(params[:id])
    end

    def initialize_form(params = {})
      form = PhoneNumberForm.new(params)
      form.carrier = current_carrier
      form
    end
  end
end
