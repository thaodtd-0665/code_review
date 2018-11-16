module RailsAdmin
  module Config
    module Actions
      class ResetMerged < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register self

        register_instance_option :root do
          true
        end

        register_instance_option :http_methods do
          %i[get post]
        end

        register_instance_option :controller do
          proc do
            if request.get?
              render @action.template_name
            elsif request.post?
              User.update merged: 0
              flash[:success] = "Merged counter has been reset successfully"
              redirect_to reset_merged_path
            end
          end
        end
      end
    end
  end
end
