class Supervise < ActiveRecord::Base
  belongs_to :user
  belongs_to :goal
  
  state_machine initial: :normal do
    state :accepted
    state :refused
    state :changed_user
    
    # 接受督促
    event :accept do
      transition :normal => :accepted
    end
    
    # 拒绝督促
    event :refuse do
      transition :normal => :refused
    end
    
    # 更换督促人
    event :change do
      transition :accepted => :changed_user
    end
    
  end
  
end
