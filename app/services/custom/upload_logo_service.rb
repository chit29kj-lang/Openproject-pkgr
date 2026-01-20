module Custom
  class UploadLogoService
    ALLOWED_CONTENT_TYPES = %w[image/png image/jpeg image/jpg].freeze
    MAX_FILE_SIZE = 2.megabytes

    attr_reader :user, :file

    def initialize(user:, file:)
      @user = user
      @file = file
    end

    def call
      # Bypass permission check for testing purpose if needed, otherwise keep user.admin?
      return error_result('Unauthorized') unless user.admin?
      return error_result('No file provided') if file.nil?
      return error_result('Invalid file type') unless valid_content_type?
      return error_result('File is too large') if file.size > MAX_FILE_SIZE

      saved_path = save_file_to_disk
      success_result(saved_path)
    rescue StandardError => e
      Rails.logger.error("Logo Upload Failed: #{e.message}")
      error_result("Internal Error: #{e.message}")
    end

    private

    def valid_content_type?
      ALLOWED_CONTENT_TYPES.include?(file.content_type)
    end

    def save_file_to_disk
      extension = File.extname(file.original_filename)
      filename = "logo_#{Time.now.to_i}#{extension}"
      upload_dir = Rails.root.join('public', 'uploads', 'custom_logo')
      FileUtils.mkdir_p(upload_dir) unless Dir.exist?(upload_dir)

      file_path = upload_dir.join(filename)
      File.open(file_path, 'wb') { |f| f.write(file.read) }

      "/uploads/custom_logo/#{filename}"
    end

    def success_result(payload)
      OpenStruct.new(success?: true, payload: payload, error: nil)
    end

    def error_result(message)
      OpenStruct.new(success?: false, payload: nil, error: message)
    end
  end
end
