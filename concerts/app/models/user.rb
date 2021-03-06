class User < ApplicationRecord
  has_many :tickets
  has_many :concerts,through: :tickets
  has_many :notes
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  accepts_nested_attributes_for :notes

  
end
