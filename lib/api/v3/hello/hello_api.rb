module API
  module V3
    module Hello
      class HelloAPI < ::API::OpenProjectAPI
        resources :hello do
          get do
            { message: "Hello World" }
          end
        end
      end
    end
  end
end
