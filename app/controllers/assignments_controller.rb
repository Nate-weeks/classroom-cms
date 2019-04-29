# assignments_controller.rb - controller for assignments - includes methods for
# CRUD actions for assignments - hooks into the assignments model and assignments routes

class AssignmentsController < ApplicationController
  def index
    @assignments = Assignment.all
  end

  def new
    @assignment = Assignment.new
  end

  def show
    @assignment = Assignment.find(params[:id])
    @user = current_user
    if Studentwork.all != []
      if @user.role == "admin"
        @studentworks = Studentwork.where(assignment_id: @assignment.id)
      end
      if @user.role == "student"
        @work = Studentwork.where(user_id: @user.id).take
      end
    end
  end

  def create
    @assignment = Assignment.new(assignment_params)
    @user = current_user

    if @assignment.save
      flash[:notice] = "assignment created successfully"
      redirect_to assignments_path
    else
      @form_errors = @assignment.errors.full_messages
      render :new
    end
  end

  def edit
    @assignment = Assignment.find(params[:id])
  end

  def update
    @assignment = Assignment.find(params[:id])
    @user = current_user

    if @assignment.update(assignment_params)
      redirect_to @assignment
    else
      @form_errors = @assignment.errors.full_messages
      render :edit
    end
  end

  def destroy
    @assignment = Assignment.find(params[:id])
    @assignment.destroy
    redirect_to assignments_path
  end

  def assignment_params
    params.require(:assignment).permit(:title, :assignment)
  end
end
