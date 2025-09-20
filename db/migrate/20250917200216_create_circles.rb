class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.references :frame, null: false, foreign_key: true
      t.decimal :center_x, precision: 12, scale: 4, null: false
      t.decimal :center_y, precision: 12, scale: 4, null: false
      t.decimal :diameter, precision: 12, scale: 4, null: false

      t.timestamps
    end
  end
end
