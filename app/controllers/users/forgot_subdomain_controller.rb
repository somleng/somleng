module Users
  class ForgotSubdomainController < ApplicationController
    respond_to :html
    layout "devise"

    def new
      @resource = ForgotSubdomainForm.new
    end

    def create
      @resource = ForgotSubdomainForm.new(permitted_params)
      if @resource.save
        flash[:notice] = "You will receive an email with your subdomain in a few minutes."
      end

      respond_with(@resource, location: new_forgot_subdomain_path)
    end

    private

    def permitted_params
      params.require(:user).permit(:email)
    end
  end
end
