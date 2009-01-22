ActiveRecord::Schema.define(:version => 0) do
  create_table :users do |t|
    t.string :username, :email, :first_name, :last_name, :city
    t.integer :age
    t.boolean :male
  end
  
  create_table :user_with_merge_vars do |t|
    t.string :first_name, :last_name, :username, :city, :email
    t.integer :age
    t.boolean :male
  end
end