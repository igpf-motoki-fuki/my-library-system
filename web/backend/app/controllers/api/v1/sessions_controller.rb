module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)
        yield self.resource if block_given?
        render json: {
          status: { code: 200, message: 'ログインに成功しました。' },
          data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }
      end

      def destroy
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        yield if block_given?
        render json: {
          status: 200,
          message: 'ログアウトに成功しました。'
        }
      end

      private

      def respond_with(resource, _opts = {})
        render json: {
          status: { code: 200, message: 'リクエストに成功しました。' },
          data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
        }
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            status: 200,
            message: 'ログアウトに成功しました。'
          }
        else
          render json: {
            status: 401,
            message: 'ログアウトに失敗しました。'
          }
        end
      end
    end
  end
end 