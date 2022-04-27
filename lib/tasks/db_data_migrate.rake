namespace :db do
  namespace :data_migrate do
    task create_interactions: :environment do
      PhoneCall.completed.where(beneficiary_fingerprint: nil).find_each do |phone_call|
        beneficiary = phone_call.outbound? ? phone_call.to : phone_call.from
        beneficiary_country = ResolvePhoneNumberCountry.call(
          beneficiary,
          fallback_country: phone_call.carrier.country
        )
        next if beneficiary_country.blank?

        phone_call.transaction do
          phone_call.update_columns(
            beneficiary_fingerprint: beneficiary,
            beneficiary_country_code: beneficiary_country.alpha2
          )

          Interaction.create!(
            interactable: phone_call,
            account: phone_call.account,
            carrier: phone_call.carrier,
            beneficiary_fingerprint: phone_call.beneficiary_fingerprint,
            beneficiary_country_code: phone_call.beneficiary_country_code,
            created_at: phone_call.created_at,
            updated_at: phone_call.created_at
          )
        end
      end
    end

    task update_phone_call_beneficiary_data: :environment do
      PhoneCall.where(beneficiary_fingerprint: nil).find_each do |phone_call|
        beneficiary = phone_call.outbound? ? phone_call.to : phone_call.from
        next unless Phony.plausible?(beneficiary)

        beneficiary_country = ResolvePhoneNumberCountry.call(
          beneficiary,
          fallback_country: phone_call.carrier.country
        )
        next if beneficiary_country.blank?

        phone_call.update_columns(
          beneficiary_fingerprint: beneficiary,
          beneficiary_country_code: beneficiary_country.alpha2
        )
      end
    end

    task migrate_refile_to_active_storage: :environment do
      CallDataRecord.where.not(file_id: nil).where.missing(:file_attachment).find_each do |cdr|
        s3_object = Aws::S3::Resource.new.bucket("cdr.somleng.org").object("store/#{cdr.file_id}")

        cdr.file.attach(
          io: s3_object.get.body,
          filename: cdr.file_filename,
          content_type: cdr.file_content_type
        )
      end
    end
  end
end
