class NotesController < ApplicationController
  def destroy
    @goal = Goal.find(params[:goal_id])
    @note = @goal.notes.find(params[:id])
    @note.destroy
    redirect_to @goal
  end
end