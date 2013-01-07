class AddFacebookIdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :facebook_id, :string
  end
end
