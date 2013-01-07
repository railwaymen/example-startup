class Event < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"

  attr_accessible :description, :end_time, :location, :name, :start_time

  validates_presence_of :name, :start_time, :end_time
  validate :start_and_end_time

  after_create :post_to_facebook
  after_update :update_on_facebook
  before_destroy :destroy_from_facebook

  def on_facebook?
    facebook_id.present?
  end

  def fetch_from_facebook
    owner.social_graph.events.detect{|event| event.identifier == facebook_id} if on_facebook?
  end

  private

  def start_and_end_time
    errors.add(:start_time, "must be before end time") unless self.start_time < self.end_time
  end 

  def post_to_facebook
    if owner.social_graph.present?
      event = owner.social_graph.event!(attr_for_facebook)
      update_attribute(:facebook_id, event.identifier)
    end
  end

  def update_on_facebook
    if on_facebook?
      event = fetch_from_facebook
      event.update(attr_for_facebook) if event.present?
    end
  end

  def destroy_from_facebook
    if on_facebook?
      event = fetch_from_facebook
      event.destroy if event.present?
    end
  end

  def attr_for_facebook
    {:name => name, :description => description, :start_time => start_time, :end_time => end_time, :location => location}
  end

end
