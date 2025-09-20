class Api::V1::SessionsController < ApiController
  before_action :authenticate_user!, only: [ :show, :current, :destroy ]

  def create
    user = User.find_by(email: login_params[:email])

    if user&.authenticate(login_params[:password])
      token = user.generate_jwt_token
      render_success(
        {
          user: UserSerializer.new(user).serializable_hash,
          token: token
        },
        meta: { message: "Login realizado com sucesso" }
      )
    else
      render_error(
        message: "Credenciais inválidas",
        details: "Email ou senha incorretos",
        status: :unauthorized
      )
    end
  end

  def show
    render_success(
      UserSerializer.new(current_user).serializable_hash
    )
  end

  def current
    render_success(
      UserSerializer.new(current_user).serializable_hash
    )
  end

  def destroy
    # In a real application, you might want to blacklist the token
    # For now, we'll just return success
    render_success(
      {},
      meta: { message: "Logout realizado com sucesso" }
    )
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end
end
