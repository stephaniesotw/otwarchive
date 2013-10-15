class AddRedirectWorkId < ActiveRecord::Migration
  def self.up
    add_column :works, :redirect_work_id, :integer
  end

  def self.down
    remove_column :works, :redirect_work_id
  end
end