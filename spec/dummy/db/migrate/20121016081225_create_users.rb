class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :username, :email, :first_name, :last_name, :city
      t.integer :age
      t.boolean :male, :wants_email
    end
  
    create_table :user_with_merge_vars do |t|
      t.string :first_name, :last_name, :username, :city, :email
      t.integer :age
      t.boolean :male
    end
  end

  def down
    
  end
end
