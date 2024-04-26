module Dashboard
  class ReleasedPhoneNumbersController < DashboardController
    def index
      @resources = paginate_resources(apply_filters(scope))
    end

    private

    def scope
      parent_scope.released_managed_incoming_phone_numbers
    end

    def filter_class(*)
      ReleasedPhoneNumberFilter
    end
  end
end
