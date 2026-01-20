module API
  module V3
    module Logo
      class SwitchLogoAPI < ::API::OpenProjectAPI
        resources :switch_logo do
          post do
            error!("Forbidden", 403) unless current_user.admin?

            file_path = Rails.root.join("app/views/custom_styles/_inline_css_logo.erb")
            content = File.read(file_path)
            lines = content.lines

            # Find the line containing the logo path
            target_line_index = lines.find_index do |l|
              l.include?("/images/") && (l.include?("gosoft-logo.png") || l.include?("logo-chit.png"))
            end

            if target_line_index.nil?
              error!("Could not find active logo line in template", 500)
            end

            target_line = lines[target_line_index]

            if target_line.include?("gosoft-logo.png")
              new_logo = "logo-chit.png"
              target_line = target_line.sub("gosoft-logo.png", new_logo)
            elsif target_line.include?("logo-chit.png")
              new_logo = "gosoft-logo.png"
              target_line = target_line.sub("logo-chit.png", new_logo)
            else
              error!("Unexpected content: #{target_line.strip}", 500)
            end

            lines[target_line_index] = target_line
            File.write(file_path, lines.join)

            # Try to touch the file to trigger reload if needed, though in dev it usually works
            FileUtils.touch(file_path)

            { status: "switched", current_logo: new_logo }
          end
        end
      end
    end
  end
end
