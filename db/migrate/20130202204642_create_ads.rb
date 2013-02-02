class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.string :title
      t.text :description
      t.string :contact
      t.string :location
      t.references :owner

      t.timestamps
    end
    add_index :ads, :owner_id
  end
end
