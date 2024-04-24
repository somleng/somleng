module Dashboard
  class AvailablePhoneNumbersController < DashboardController
    def index
      @resources = paginate_resources(apply_filters(scope))
    end

    private

    def scope
      parent_scope.available_phone_numbers
    end

    def filter_class(*)
      AvailablePhoneNumberFilter
    end
  end
end
