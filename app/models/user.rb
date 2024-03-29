class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  has_many :schedules, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :schedules, through: :answers
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  def reaction(schedule)
    self.answers.find_or_create_by(schedule_id: schedule.id)
  end
  
  def unreaction(schedule)
    answer = self.answers.find_by(schedule_id: schedule.id)
    answer.destroy if answer
  end
  
  def reaction?(schedule)
    self.schedules.include?(schedule)
  end
  
  def alive?
    self.answers.exists?
  end
  
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end
end