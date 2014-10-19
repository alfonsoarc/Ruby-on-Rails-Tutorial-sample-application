class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    #debugger
  end
  
  
  def new
    @user = User.new
  end
  # From new form, post to /users that goes to create action
  def create
    @user = User.new(user_params)    # Not the final implementation!
    if @user.save
      # Handle a successful save.
    else
      render 'new'
    end
  end
  
    private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  
end
