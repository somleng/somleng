module Dashboard
  class CarrierUsersController < DashboardController
    def index
      @resources = apply_filters(users_scope)
      @resources = paginate_resources(@resources)
    end

    def show
      @resource = record
    end

    def new
      @resource = initialize_form
    end

    def create
      @resource = initialize_form(form_params.permit(:name, :email, :role))
      @resource.inviter = current_user
      @resource.save

      respond_with_resource(
        @resource,
        notice: "An invitation email has been sent to #{@resource.email}."
      )
    end

    def edit
      @resource = UserForm.initialize_with(record)
    end

    def update
      @resource = initialize_form(form_params.permit(:role))
      @resource.user = record
      @resource.save

      respond_with_resource(@resource)
    end

    def destroy
      record.destroy
      respond_with_resource(record)
    end

    private

    def initialize_form(params = {})
      form = UserForm.new(params)
      form.carrier = current_carrier
      form
    end

    def form_params
      params.require(:user)
    end

    def users_scope
      current_carrier.carrier_users
    end

    def record
      @record ||= users_scope.find(params[:id])
    end

    def respond_with_resource(resource, options = {})
      respond_with(:dashboard, :carrier, resource, options)
    end
  end
end
