class AccountMembershipFilter < ResourceFilter
  filter_with AccountIdFilter, DateFilter
end
