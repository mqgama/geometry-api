class Api::V1::UsersController < ApiController
  def create
    user = User.new(user_params)

    if user.save
      token = user.generate_jwt_token
      render_created(
        {
          user: UserSerializer.new(user).serializable_hash,
          token: token
        },
        meta: { message: "Usuário criado com sucesso" }
      )
    else
      render_error(
        message: "Erro ao criar usuário",
        details: user.errors.full_messages,
        status: :unprocessable_content
      )
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
