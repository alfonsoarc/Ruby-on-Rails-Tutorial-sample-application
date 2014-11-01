class UsersController < ApplicationController
  def new
    @user = User.new
  end

  # From new form, post to /users that goes to create action
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  # From edit form, put to /users/user_id/edit to update action
  def update
    @user = User.find(params[:id])
    #update_attributes update the corresponding user and calls save method
    #user_params!! private method
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
