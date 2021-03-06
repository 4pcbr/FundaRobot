class RemoveEmailFromSubscription < ActiveRecord::Migration
  def self.up
    change_table :subscriptions do |t|
      t.remove :email
    end
  end

  def self.down
    change_table :subscriptions do |t|
      t.string :email
    end
  end
end
