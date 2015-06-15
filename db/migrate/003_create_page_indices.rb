class CreatePageIndices < ActiveRecord::Migration
  def self.up
    create_table :page_indices do |t|
      t.integer :feed_id
      t.string :item_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :page_indices
  end
end
