class CreateFrames < ActiveRecord::Migration[8.0]
  def change
    create_table :frames do |t|
      t.decimal :center_x, precision: 12, scale: 4, null: false
      t.decimal :center_y, precision: 12, scale: 4, null: false
      t.decimal :width, precision: 12, scale: 4, null: false
      t.decimal :height, precision: 12, scale: 4, null: false

      t.timestamps
    end
  end
end
