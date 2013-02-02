class Ad < ActiveRecord::Base
  attr_accessible :contact, :description, :location, :title

  belongs_to :owner, :class_name => "User"

  validates :title, :presence => true
end
