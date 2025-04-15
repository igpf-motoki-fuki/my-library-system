module Api
  module V1
    class BooksController < ApplicationController
      before_action :authenticate_user!
      before_action :set_book, only: [:show, :lend, :return]

      def index
        @books = Book.all
        render json: {
          status: { code: 200, message: '書籍一覧の取得に成功しました。' },
          data: BookSerializer.new(@books).serializable_hash[:data][:attributes]
        }
      end

      def show
        render json: {
          status: { code: 200, message: '書籍詳細の取得に成功しました。' },
          data: BookSerializer.new(@book).serializable_hash[:data][:attributes]
        }
      end

      def lend
        if @book.available?
          @lending = current_user.lendings.build(book: @book, status: 'lent')
          if @lending.save
            @book.update(status: 'lent')
            render json: {
              status: { code: 200, message: '貸出に成功しました。' },
              data: LendingSerializer.new(@lending).serializable_hash[:data][:attributes]
            }
          else
            render json: {
              status: { code: 422, message: '貸出に失敗しました。' },
              errors: @lending.errors.full_messages
            }, status: :unprocessable_entity
          end
        else
          render json: {
            status: { code: 422, message: 'この書籍は現在貸出できません。' }
          }, status: :unprocessable_entity
        end
      end

      def return
        @lending = current_user.lendings.find_by(book: @book, status: 'lent')
        if @lending
          @lending.update(status: 'returned', returned_at: Time.current)
          @book.update(status: 'available')
          render json: {
            status: { code: 200, message: '返却に成功しました。' },
            data: LendingSerializer.new(@lending).serializable_hash[:data][:attributes]
          }
        else
          render json: {
            status: { code: 422, message: 'この書籍は貸出されていません。' }
          }, status: :unprocessable_entity
        end
      end

      private

      def set_book
        @book = Book.find(params[:id])
      end
    end
  end
end 