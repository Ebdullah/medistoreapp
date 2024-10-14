# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
branch = Branch.find_or_create_by(name: 'Medistore2') do |b|
    b.some_other_attribute = 'value' # Set other attributes as needed
  end

User.find_or_create_by(email: 'medistore2_admin@medistore.com') do |user|
    user.password = '123456' # Set a strong password
    user.password_confirmation = '12345'
    user.name = 'Omar'
    user.phone = '03201234569' # Set a valid phone number
    user.role = :branch_admin # Assuming you have enum for roles defined
    user.branch_id = branch.id
  end

  puts "Seeded branch admin for Medistore2"
