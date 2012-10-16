# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121016081225) do

  create_table "user_with_merge_vars", :force => true do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.string  "username"
    t.string  "city"
    t.string  "email"
    t.integer "age"
    t.boolean "male"
  end

  create_table "users", :force => true do |t|
    t.string  "username"
    t.string  "email"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "city"
    t.integer "age"
    t.boolean "male"
    t.boolean "wants_email"
  end

end
