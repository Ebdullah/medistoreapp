class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :branch, optional: true
  has_many :records
  has_many :notifications, foreign_key: 'customer_id', dependent: :destroy
  has_many :audit_logs
  has_many :archives, foreign_key: :user_id, dependent: :destroy 

  
  before_save :debug_email
  validates :phone, presence: true, numericality: {only_integer: true}

  enum role: [ :super_admin, :branch_admin, :cashier, :customer ]

  private

  def debug_email
    # debugger
  end
end
