class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.string :name
      t.string :repo
      t.integer :downloads
      t.integer :stars

      t.timestamps null: false
    end
  end
end
