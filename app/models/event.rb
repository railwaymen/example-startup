class Event < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"

  attr_accessible :facebook_attenders_ids, :description, :end_time, :location, :name, :start_time
  attr_accessor :facebook_attenders_ids

  validates_presence_of :name, :start_time, :end_time
  validate :start_and_end_time

  after_create :post_to_facebook
  after_update :update_on_facebook
  before_destroy :destroy_from_facebook

  def on_facebook?
    facebook_id.present?
  end

  def fetch_from_facebook
    FbGraph::Event.new(facebook_id, :access_token => self.owner.access_token) if on_facebook?
  end

  private

  def start_and_end_time
    errors.add(:start_time, "must be before end time") unless self.start_time < self.end_time
  end 

  def post_to_facebook
    if owner.social_graph.present?
      event = owner.social_graph.event!(attr_for_facebook)
      event.invite!(:users => facebook_attenders_ids) if facebook_attenders_ids.present?
      update_attribute(:facebook_id, event.identifier)
    end
  end

  def update_on_facebook
    if on_facebook?
      event = fetch_from_facebook
      if event.present?
        invited_ids = event.invited.map(&:identifier) 
        event.invite!(:users => facebook_attenders_ids.reject{|attender_id| invited_ids.include?(attender_id)}) if facebook_attenders_ids.present?
        event.update(attr_for_facebook) 
      end
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
