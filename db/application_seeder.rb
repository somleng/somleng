class ApplicationSeeder
  FORMATS = {
    :human => "human",
    :basic_auth => "basicauth"
  }

  OUTPUTS = {
    :all => "all",
    :user => "user",
    :admin => "admin",
    :incoming_phone_number => "incoming_phone_number"
  }

  DEFAULT_FORMAT = :human
  DEFAULT_OUTPUT = :all

  attr_accessor :format,
                :output,
                :admin_account_permissions,
                :incoming_phone_number

  def initialize(options = {})
    self.format = options[:format]
    self.output = options[:output]
    self.admin_account_permissions = options[:admin_account_permissions]
    self.incoming_phone_number = options[:incoming_phone_number]
  end

  def seed!
    user_account = create_user_account!
    user_access_token = create_access_token!(user_account)

    print_account_info(user_account, "User") if output_user?

    if create_admin_account?
      admin_account = create_admin_account!
      account_access_token = create_access_token!(admin_account)
      print_account_info(admin_account, "Admin") if output_admin?
    end

    if create_incoming_phone_number?
      incoming_phone_number = create_incoming_phone_number!(user_account)
      print("Incoming Phone Number:    #{incoming_phone_number.phone_number}\n") if output_incoming_phone_number?
    end
  end

  def format
    @format ||= FORMATS[default_format]
  end

  def output
    @output ||= OUTPUTS[default_output]
  end

  def admin_account_permissions
    @admin_account_permissions ||= ENV["ADMIN_ACCOUNT_PERMISSIONS"]
  end

  def incoming_phone_number
    @incoming_phone_number ||= JSON.parse(ENV["INCOMING_PHONE_NUMBER"] || "{}")
  end

  private

  def create_incoming_phone_number!(account)
    account.incoming_phone_numbers.where(
      :phone_number => incoming_phone_number["phone_number"]
    ).first_or_create!(incoming_phone_number)
  end

  def create_incoming_phone_number?
    incoming_phone_number.present?
  end

  def sanitize_account_permissions(raw_permissions)
    permissions = raw_permissions.split(",").map(&:to_sym)
    permissions = Account.values_for_permissions if permissions == [:all]
    permissions.zip(permissions).to_h.slice(
      *Account.values_for_permissions
    ).values
  end

  def create_admin_account!
    permissions = sanitize_account_permissions(admin_account_permissions)

    account = (permissions.any? ? Account.with_permissions(*permissions) : Account.without_permissions).first_or_initialize

    if account.new_record?
      account.permissions = permissions
      account.save!
    end

    account
  end

  def create_admin_account?
    admin_account_permissions.present?
  end

  def print_account_info(account, type = "User")
    print(
      basic_auth_format? ? "#{account.sid}:#{account.auth_token}" : "#{type} Account SID:         #{account.sid}\n#{type} Account Auth Token:  #{account.auth_token}\n"
    )
  end

  def create_user_account!
    Account.without_permissions.first_or_create!
  end

  def create_access_token!(account)
    account.access_token || account.create_access_token!
  end

  def default_format
    (ENV["FORMAT"] && ENV["FORMAT"].to_sym) || DEFAULT_FORMAT
  end

  def default_output
    (ENV["OUTPUT"] && ENV["OUTPUT"].to_sym) || DEFAULT_OUTPUT
  end

  def human_format?
    format == FORMATS[:human]
  end

  def basic_auth_format?
    format == FORMATS[:basic_auth]
  end

  def output_all?
    output == OUTPUTS[:all]
  end

  def output_user?
    output == OUTPUTS[:user] || output_all?
  end

  def output_admin?
    output == OUTPUTS[:admin] || output_all?
  end

  def output_incoming_phone_number?
    output == OUTPUTS[:incoming_phone_number] || output_all?
  end
end
